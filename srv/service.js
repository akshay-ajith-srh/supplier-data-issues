import cds from '@sap/cds'
import { randomUUID } from 'node:crypto'
import { check } from './lib/rules.js'
import { draft } from './lib/ai.js'

const norm = s => (s || '').replace(/\s/g, '')       // 'In Progress' = 'InProgress'
const idOf = req => { const p = req.params[0]; return p?.ID ?? p }

export default cds.service.impl(async function () {
  const { DataIssues, SupplierAddresses } = cds.entities('supplierDataIssues')

  // Criteria 3, 4, 5
  this.before('SAVE', 'DataIssues', async req => {
    const d = req.data
    const old = await SELECT.one.from(DataIssues).where({ ID: d.ID })
    const st = norm(d.status)
    if (st === 'InProgress' && !d.owner)
      return req.error(409, 'Please assign an owner before starting work on this issue.', 'owner')
    if (st === 'FalseAlarm' && !(d.reasonFalseAlarm || '').trim())
      return req.error(400, 'A false alarm needs a reason.', 'reasonFalseAlarm')
    if (st === 'Fixed' && norm(old?.status) !== 'Fixed')
      return req.error(400, 'Fixed can only be set by Recheck.', 'status')
  })

  // Recheck: the only place that sets Fixed
  this.on('recheck', 'DataIssues', async req => {
    const ID = idOf(req)
    const issue = await SELECT.one.from(DataIssues).where({ ID })
    if (!issue) return req.reject(404, 'Issue not found')

    let a = null
    try {
      const bp = await cds.connect.to('API_BUSINESS_PARTNER')
      const { A_BusinessPartnerAddress } = bp.entities
      a = await bp.run(SELECT.one.from(A_BusinessPartnerAddress,
        { BusinessPartner: issue.businessPartner, AddressID: issue.addressID }))
} catch (e) {
  console.error('Mock read failed:', e.message, '| code:', e.code, '| status:', e.statusCode, e.status, e.reason?.status)
  const http = Number(e.reason?.status ?? e.response?.status ?? e.statusCode ?? e.status)
  // 4xx from the mock = it answered but does not know this address -> use local table
  // no answer from the mock (network error, timeout) -> 503, nothing changed
  if (!(http >= 400 && http < 500))
    return req.reject(503, 'S/4 mock not reachable, nothing rechecked')
}
    let addr = a && { StreetName: a.StreetName, HouseNumber: a.HouseNumber,
                      PostalCode: a.PostalCode, CityName: a.CityName, Country: a.Country }
    if (!addr) {   // partner not in the mock (our SUPP... numbers): use local table
      const l = await SELECT.one.from(SupplierAddresses)
        .where({ businessPartner: issue.businessPartner, addressID: issue.addressID })
      if (l) addr = { StreetName: l.streetName, HouseNumber: l.houseNumber,
                      PostalCode: l.postalCode, CityName: l.cityName, Country: l.country }
    }
    const { passed, currentValue } = check(issue.ruleID, addr)
    await UPDATE(DataIssues).set({
      currentValue, lastCheckedAt: new Date().toISOString(),
      ...(passed ? { status: 'Fixed' } : {})
    }).where({ ID })
    return SELECT.one.from(DataIssues).where({ ID })
  })

  // AI question: returns text, does not store it
  this.on('draftQuestion', 'DataIssues', async req => {
    const i = await SELECT.one.from(DataIssues).where({ ID: idOf(req) })
    return draft(
      'You write a short, polite e-mail question to a supplier about one wrong address field. Use only the facts given. Never change or decide anything.',
      { field: i.fieldName, rule: i.ruleID, currentValue: i.currentValue })
  })

  // Criterion 6: import, merge on BusinessPartner + AddressID + FieldName + RuleID
  this.on('importFindings', async req => {
    const lines = req.data.table.trim().split('\n').slice(1)
    let created = 0, merged = 0
    for (const line of lines) {
      const [businessPartner, addressID, fieldName, ruleID, severity, currentValue] =
        line.split(',').map(s => s.trim())
      if (!businessPartner || !addressID || !fieldName || !ruleID)
        return req.reject(400, 'Bad table: need businessPartner,addressID,fieldName,ruleID,severity,currentValue')
      const key = { businessPartner, addressID, fieldName, ruleID }
      const now = new Date().toISOString()
      const ex = await SELECT.one.from(DataIssues).where(key)
      if (ex) {
        await UPDATE(DataIssues).set({ severity, currentValue, lastCheckedAt: now }).where(key)
        merged++
      } else {
        const l = await SELECT.one.from(SupplierAddresses).where({ businessPartner, addressID })
        await INSERT.into(DataIssues).entries({
          ID: randomUUID(), issueID: 'ISS-' + randomUUID().slice(0, 8), ...key,
          severity, currentValue, status: 'Open', lastCheckedAt: now,
          SupplierAddresses_ID: l?.ID })
        created++
      }
    }
    return `Created ${created}, merged ${merged}`
  })
})