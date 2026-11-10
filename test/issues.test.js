import { test } from 'node:test'
import assert from 'node:assert/strict'
import { check } from '../srv/lib/rules.js'
import { draft } from '../srv/lib/ai.js'

const BASE = 'http://localhost:4004/odata/v4/supplier-data-issues-srv'
const S = 'supplierDataIssuesSrv'

async function api(method, path, body) {
  const r = await fetch(BASE + path, {
    method, headers: { 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined })
  const t = await r.text()
  let json; try { json = t ? JSON.parse(t) : null } catch { json = t }
  return { status: r.status, json }
}
const allIssues = async () => (await api('GET', '/DataIssues?$top=500')).json.value
const msg = r => JSON.stringify(r.json)

async function trySave(id, changes) {
  await api('POST', `/DataIssues(ID=${id},IsActiveEntity=true)/${S}.draftEdit`, { PreserveChanges: true })
  await api('PATCH', `/DataIssues(ID=${id},IsActiveEntity=false)`, changes)
  const r = await api('POST', `/DataIssues(ID=${id},IsActiveEntity=false)/${S}.draftActivate`, {})
  if (r.status >= 400) await api('DELETE', `/DataIssues(ID=${id},IsActiveEntity=false)`)
  return r
}

// import one finding, return the issue row
async function importOne(bp, addr, field, rule, sev, val) {
  await api('POST', '/importFindings', { table: `h\n${bp},${addr},${field},${rule},${sev},${val}` })
  const q = `/DataIssues?$filter=businessPartner eq '${bp}' and addressID eq '${addr}' and ruleID eq '${rule}'`
  return (await api('GET', q)).json.value[0]
}
const recheck = id => api('POST', `/DataIssues(ID=${id},IsActiveEntity=true)/${S}.recheck`, {})
const reload = async id => (await api('GET', `/DataIssues(ID=${id},IsActiveEntity=true)`)).json

test('P3-1 importing the same findings twice creates no duplicates', async () => {
  const p = 'T' + Date.now()
  const table = `h\n${p},A1,postalCode,POSTAL_FORMAT,High,6919\n${p},A1,streetName,STREET_MISSING,Low,x`
  const before = (await allIssues()).length
  await api('POST', '/importFindings', { table })
  const first = (await allIssues()).length
  await api('POST', '/importFindings', { table })
  const second = (await allIssues()).length
  assert.equal(first, before + 2)
  assert.equal(second, first)
})

test('P3-2 In Progress without owner is refused', async () => {
  const i = (await allIssues()).find(x => x.status === 'Open')
  assert.ok(i, 'need an Open issue')
  const r = await trySave(i.ID, { status: 'In Progress', owner: '' })
  assert.ok(r.status >= 400 && r.status < 500, 'status was ' + r.status)
  assert.match(msg(r), /owner/i)
})

test('P3-3 False Alarm without reason is refused', async () => {
  const i = (await allIssues()).find(x => x.status === 'Open')
  const r = await trySave(i.ID, { status: 'False Alarm', reasonFalseAlarm: '' })
  assert.ok(r.status >= 400 && r.status < 500, 'status was ' + r.status)
  assert.match(msg(r), /reason/i)
})

test('P3-4 Recheck on an address that cannot be found stays Open', async () => {
  const i = await importOne('NOPE' + Date.now(), 'A1', 'postalCode', 'POSTAL_FORMAT', 'High', '6919')
  const r = await recheck(i.ID)
  assert.ok(r.status < 300, 'recheck status ' + r.status + ' ' + msg(r))
  assert.equal((await reload(i.ID)).status, 'Open')
})

test('P3-5 Recheck on a correct address sets Fixed', async () => {
  // SUPP0000001 / ADDR001 is London, so the city rule passes
  const i = await importOne('SUPP0000001', 'ADDR001', 'cityName', 'CITY_NAME_CHECK', 'Low', 'x')
  const r = await recheck(i.ID)
  assert.ok(r.status < 300, 'recheck status ' + r.status + ' ' + msg(r))
  assert.equal((await reload(i.ID)).status, 'Fixed')
})

test('P3-6 Setting Fixed by hand is refused', async () => {
  const i = (await allIssues()).find(x => x.status === 'Open')
  const r = await trySave(i.ID, { status: 'Fixed' })
  assert.ok(r.status >= 400 && r.status < 500, 'status was ' + r.status)
  assert.match(msg(r), /Recheck/i)
})

test('Rule check: wrong vs corrected GB postal code', () => {
  assert.equal(check('POSTAL_FORMAT', { PostalCode: 'NW1 6X', Country: 'GB' }).passed, false)
  assert.equal(check('POSTAL_FORMAT', { PostalCode: 'NW1 6XE', Country: 'GB' }).passed, true)
})

test('G4 no AI key gives 503', async () => {
  const saved = process.env.GROQ_API_KEY
  delete process.env.GROQ_API_KEY
  await assert.rejects(() => draft('x', {}), e => e.status === 503)
  if (saved) process.env.GROQ_API_KEY = saved
})