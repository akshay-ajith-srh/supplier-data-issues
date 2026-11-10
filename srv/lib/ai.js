async function draft(system, facts) {
  if (!process.env.GROQ_API_KEY) { const e = new Error('AI key missing'); e.status = 503; throw e }
  const r = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${process.env.GROQ_API_KEY}` },
    body: JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      messages: [{ role: 'system', content: system }, { role: 'user', content: JSON.stringify(facts) }]
    })
  })
  if (!r.ok) { const e = new Error('AI not reachable'); e.status = 503; throw e }
  return (await r.json()).choices[0].message.content
}
export { draft }