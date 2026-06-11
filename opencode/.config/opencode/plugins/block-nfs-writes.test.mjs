// Test matrix for block-nfs-writes.js — run with: node block-nfs-writes.test.mjs
// Mirrors the cases the shell hook (~/.agents/hooks/block-nfs-writes.sh) is
// tested against; keep the two in sync.
import { readFileSync } from 'fs'

const { BlockNFSWrites } = await import('./block-nfs-writes.js')

// Fake $ tag: only 'cat <file>' is used by the plugin
const $ = (strings, ...vals) => {
  const cmd = strings.reduce((a, s, i) => a + s + (vals[i] ?? ''), '')
  return { text: async () => readFileSync(cmd.replace(/^cat\s+/, ''), 'utf8') }
}

const hooks = await BlockNFSWrites({ $ })
const hook = hooks['tool.execute.before']

const cases = [
  ['block', 'write', { filePath: '/proj/group/notes.md' }],
  ['allow', 'write', { filePath: '/home/berkay/notes.md' }],
  ['block', 'bash', { command: "ssh hds01 'cp results.csv /proj/group/x'" }],
  ['block', 'bash', { command: 'scp data.csv hds01:/share/lab/x.csv' }],
  ['allow', 'bash', { command: 'scp hds01:/proj/results.csv ./data/' }],
  ['allow', 'bash', { command: "ssh hds01 'cat /proj/data.csv | head'" }],
  ['block', 'bash', { command: "ssh hds01 'echo done > /work/log.txt'" }],
  ['block', 'bash', { command: "ssh hds01 'sudo rm -rf /proj/old-results'" }],
  ['allow', 'bash', { command: 'mkdir -p /home/berkay/tmp/x' }],
  ['allow', 'bash', { command: "ssh amd062.cloudlab.us 'nohup sudo ./exp.sh > /tmp/experiment.log 2>&1 & echo $!'" }],
  ['block', 'bash', { command: "ssh hds01 'tee /share/notes.txt'" }],
  ['allow', 'bash', { command: 'rsync -av hds01:/proj/data/ ./local-data/' }],
  ['block', 'bash', { command: 'rsync -av ./local-data/ hds01:/proj/data/' }],
  ['allow', 'bash', { command: 'git status' }],
]

let fail = 0
for (const [expect, tool, args] of cases) {
  let got = 'allow', msg = ''
  try { await hook({}, { tool, args }) } catch (e) { got = 'block'; msg = e.message }
  const ok = got === expect
  if (!ok) fail++
  console.log(`${ok ? 'PASS' : 'FAIL'} [${expect}] ${tool}: ${JSON.stringify(args).slice(0, 80)} ${ok ? '' : '-> got ' + got + ' ' + msg}`)
}
process.exit(fail ? 1 : 0)
