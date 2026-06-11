// Block writes to NFS/shared filesystems:
//   1. Local NFS mounts on the control machine (from /proc/mounts).
//   2. Shared directories on remote experiment hosts (cloudlab /proj, lab
//      /share, /work, ...) — matched by path prefix, including inside
//      ssh-wrapped commands and scp/rsync host:/path destinations.
// JS port of ~/.agents/hooks/block-nfs-writes.sh (used by Claude Code and
// Codex); keep the two implementations behaviorally in sync.
export const BlockNFSWrites = async ({ $ }) => {
  // Get local NFS mount points
  let nfsPaths = []
  try {
    const mounts = await $`cat /proc/mounts`.text()
    nfsPaths = mounts
      .split('\n')
      .filter(line => line.includes('nfs') || line.includes('nfs4'))
      .map(line => line.split(' ')[1])
      .filter(Boolean)
  } catch {
    // If /proc/mounts doesn't exist (e.g., macOS), try to find NFS mounts another way
    try {
      const mounts = await $`mount`.text()
      nfsPaths = mounts
        .split('\n')
        .filter(line => line.includes('type nfs') || line.includes('type nfs4'))
        .map(line => {
          const match = line.match(/on (\S+)/)
          return match ? match[1] : null
        })
        .filter(Boolean)
    } catch {
      // No NFS mounts found or can't detect them
    }
  }

  // Remote shared-directory prefixes. Remote mounts cannot be probed per tool
  // call, so block by convention; extend per-site via the conf file shared
  // with the shell hook (one absolute prefix per line, # comments).
  const remotePrefixes = ['/proj', '/share', '/work']
  try {
    const conf = await $`cat ${process.env.HOME}/.agents/hooks/nfs-remote-prefixes.conf`.text()
    for (let line of conf.split('\n')) {
      line = line.split('#')[0].trim()
      if (line) remotePrefixes.push(line)
    }
  } catch {
    // Conf file absent — defaults apply
  }

  const isBlockedPath = (path) => {
    if (!path) return false
    // Strip scp/rsync "host:" remote specifier so host:/proj/... checks as /proj/...
    const colonIdx = path.indexOf(':')
    if (colonIdx > 0) path = path.slice(colonIdx + 1)
    for (const p of [...nfsPaths, ...remotePrefixes]) {
      if (path === p || path.startsWith(p + '/')) {
        return true
      }
    }
    return false
  }

  const checkBashCommand = (command) => {
    if (!command) return null

    // Check redirects (>, >>) — also matches redirects inside ssh '...' strings
    const redirectMatches = command.match(/>>?\s*(\/[^\s">|;&]+)/g)
    if (redirectMatches) {
      for (const match of redirectMatches) {
        const path = match.replace(/^>+\s*/, '').trim()
        if (isBlockedPath(path)) {
          return `Redirect targets NFS/shared filesystem: ${path}`
        }
      }
    }

    // Path-like tokens: plain (/path), remote (host:/path), or relative (./dir)
    const pathTokens = command.match(/[^\s">|;&']*\/[^\s">|;&']+/g) || []

    // Check write commands. The leading delimiter set includes quotes and
    // whitespace so commands wrapped in ssh '...' match too.
    const writeCmdLead = "(?:^|[;&|'\"\\s])(?:sudo\\s+)?"
    // For cp/mv/rsync/scp, last path-like token is the destination.
    // Deliberately unfiltered: a relative dest (./data/) must win over an
    // absolute/remote source (host:/proj/...), otherwise copying FROM a
    // shared dir back to local would false-positive.
    if (new RegExp(writeCmdLead + "(?:cp|mv|rsync|scp)\\s+").test(command)) {
      const dest = pathTokens[pathTokens.length - 1]
      if (dest && isBlockedPath(dest)) {
        return `Write command destination is NFS/shared: ${dest}`
      }
    }
    // For tee/dd/touch/mkdir/rm/rmdir, every absolute/remote path is a destination
    if (new RegExp(writeCmdLead + "(?:tee|dd|touch|mkdir|rm|rmdir)\\s+").test(command)) {
      for (const path of pathTokens) {
        if (/^(\/|[^\s/]+:\/)/.test(path) && isBlockedPath(path)) {
          return `Write command targets NFS/shared filesystem: ${path}`
        }
      }
    }

    return null
  }

  return {
    "tool.execute.before": async (input, output) => {
      const tool = output.tool
      const args = output.args || {}

      // Check file write operations
      if (tool === 'write' || tool === 'edit' || tool === 'patch') {
        const filePath = args.file_path || args.filePath || args.path
        if (isBlockedPath(filePath)) {
          throw new Error(`BLOCKED: Cannot write to NFS/shared filesystem: ${filePath}`)
        }
      }

      // Check bash commands
      if (tool === 'bash') {
        const command = args.command
        const blockReason = checkBashCommand(command)
        if (blockReason) {
          throw new Error(`BLOCKED: ${blockReason}`)
        }
      }
    }
  }
}
