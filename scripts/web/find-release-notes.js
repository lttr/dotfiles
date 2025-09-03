#!/usr/bin/env node

import { execSync } from "child_process"
import { readFileSync } from "fs"

/**
 * Generate release notes links for outdated packages
 * Usage: node find-release-notes.js
 * Runs `pnpm outdated --format json` to find outdated packages
 */

function getPnpmOutdatedData() {
  try {
    // pnpm outdated --format json outputs to stderr and exits with code 1 when packages are outdated
    const output = execSync("pnpm outdated --format json", {
      encoding: "utf8",
    })
    return JSON.parse(output)
  } catch (error) {
    // pnpm outdated exits with code 1 when packages are outdated, but still outputs valid JSON to stdout
    if (error.stdout) {
      try {
        return JSON.parse(error.stdout)
      } catch (parseError) {
        console.error("Error parsing pnpm outdated output:", parseError.message)
        process.exit(1)
      }
    }
    console.error("Error running pnpm outdated:", error.message)
    process.exit(1)
  }
}

function isMinorOrMajorUpdate(current, latest) {
  const currentParts = current.split(".").map(Number)
  const latestParts = latest.split(".").map(Number)
  
  const currentMajor = currentParts[0] || 0
  const currentMinor = currentParts[1] || 0
  const currentPatch = currentParts[2] || 0
  
  const latestMajor = latestParts[0] || 0
  const latestMinor = latestParts[1] || 0
  const latestPatch = latestParts[2] || 0

  // For versions >= 1.0.0, normal semver rules
  if (currentMajor >= 1 || latestMajor >= 1) {
    return currentMajor !== latestMajor || currentMinor !== latestMinor
  }
  
  // For versions < 1.0.0, minor is breaking and patch is non-breaking
  // So we consider minor changes as significant (like major changes in >= 1.0.0)
  return currentMinor !== latestMinor || currentPatch !== latestPatch
}

async function checkUrlExists(url) {
  try {
    const response = await fetch(url, {
      method: "HEAD",
      signal: AbortSignal.timeout(3000),
    })
    return response.ok
  } catch {
    return false
  }
}

async function fetchNpmPackageInfo(packageName) {
  const url = `https://registry.npmjs.org/${packageName}`
  const response = await fetch(url)
  return response.json()
}

async function fetchGitHubReleases(repoPath) {
  try {
    const url = `https://api.github.com/repos/${repoPath}/releases`
    const response = await fetch(url, {
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'find-release-notes-script'
      }
    })
    
    if (!response.ok) {
      return []
    }
    
    return await response.json()
  } catch {
    return []
  }
}

function parseVersion(version) {
  const cleaned = version.replace(/^[^\d]*/, '') // Remove leading non-digits
  const parts = cleaned.split('.').map(Number)
  return {
    major: parts[0] || 0,
    minor: parts[1] || 0,
    patch: parts[2] || 0,
    original: version
  }
}

function compareVersions(a, b) {
  const vA = parseVersion(a)
  const vB = parseVersion(b)
  
  if (vA.major !== vB.major) return vA.major - vB.major
  if (vA.minor !== vB.minor) return vA.minor - vB.minor
  return vA.patch - vB.patch
}

function isSignificantRelease(version) {
  const v = parseVersion(version)
  
  // For versions >= 1.0.0, only include x.y.0 (major.minor.0)
  if (v.major >= 1) {
    return v.patch === 0
  }
  
  // For versions < 1.0.0:
  // - 0.x.0 are considered major releases (breaking changes)
  // - 0.x.y where y > 0 are considered minor releases (new features)
  // We include both as significant
  return true // All 0.x.y versions are considered significant in pre-1.0
}

function getVersionsBetween(current, latest, releases) {
  const currentVersion = parseVersion(current)
  const latestVersion = parseVersion(latest)
  
  return releases
    .filter(release => {
      if (release.draft || release.prerelease) return false
      
      const version = parseVersion(release.tag_name)
      
      // Include versions greater than current and less than or equal to latest
      if (compareVersions(release.tag_name, current) <= 0 || 
          compareVersions(release.tag_name, latest) > 0) {
        return false
      }
      
      // Only include significant releases based on version
      return isSignificantRelease(release.tag_name)
    })
    .sort((a, b) => compareVersions(a.tag_name, b.tag_name))
}

function extractGitHubRepo(repoUrl) {
  if (!repoUrl) {
    return null
  }

  // Handle repository object format
  if (typeof repoUrl === "object" && repoUrl.url) {
    repoUrl = repoUrl.url
  }

  // Extract owner/repo from various GitHub URL formats
  const match = repoUrl.match(/github\.com[\/:]([^\/]+\/[^\/]+?)(?:\.git|\/|$)/)
  return match ? match[1] : null
}

async function main() {
  const arg = process.argv[2]
  
  // Handle help flag
  if (arg === '--help' || arg === '-h') {
    console.log('Generate release notes links for outdated packages')
    console.log('Usage: node find-release-notes.js')
    console.log('Runs `pnpm outdated --format json` to find outdated packages')
    return
  }
  
  const outdatedData = getPnpmOutdatedData()

  if (Object.keys(outdatedData).length === 0) {
    console.log("No outdated packages found!")
    return
  }

  console.log("# Release Notes for Outdated Packages\n")

  const filteredPackages = Object.entries(outdatedData).filter(
    ([packageName, info]) => {
      return isMinorOrMajorUpdate(info.current, info.latest)
    },
  )

  if (filteredPackages.length === 0) {
    console.log("No packages with minor or major updates found!")
    return
  }

  // Batch fetch repository info for all packages
  const repoPromises = filteredPackages.map(async ([packageName]) => {
    // First try local package.json
    try {
      const packageJsonPath = `node_modules/${packageName}/package.json`
      const packageJson = JSON.parse(readFileSync(packageJsonPath, "utf8"))
      const repo =
        extractGitHubRepo(packageJson.repository) ||
        extractGitHubRepo(packageJson.homepage)
      if (repo) {
        return { packageName, repo }
      }
    } catch {
      //
    }

    // Fallback to npm API
    try {
      const npmData = await fetchNpmPackageInfo(packageName)
      const repo =
        extractGitHubRepo(npmData.repository) ||
        extractGitHubRepo(npmData.homepage)
      return { packageName, repo: repo || `${packageName}/${packageName}` }
    } catch {
      return { packageName, repo: `${packageName}/${packageName}` }
    }
  })

  const repoResults = await Promise.all(repoPromises)
  const repoMap = new Map(repoResults.map((r) => [r.packageName, r.repo]))

  // Collect release notes data
  const releaseNotesData = []

  for (const [packageName, info] of filteredPackages) {
    const { current, latest } = info
    const repoPath = repoMap.get(packageName)

    console.log(`## ${packageName} (${current} → ${latest})`)

    const candidateUrls = [
      `https://github.com/${repoPath}/blob/main/CHANGELOG.md`,
      `https://github.com/${repoPath}/blob/master/CHANGELOG.md`,
      `https://github.com/${repoPath}/releases`,
    ]

    let foundUrl = null
    for (const url of candidateUrls) {
      if (await checkUrlExists(url)) {
        foundUrl = url
        break
      }
    }

    console.log(
      `${foundUrl || `https://www.npmjs.com/package/${packageName}?activeTab=versions`}\n`,
    )

    // Fetch GitHub releases for this package
    const releases = await fetchGitHubReleases(repoPath)
    if (releases.length > 0) {
      const relevantReleases = getVersionsBetween(current, latest, releases)
      if (relevantReleases.length > 0) {
        releaseNotesData.push({
          packageName,
          current,
          latest,
          releases: relevantReleases
        })
      }
    }
  }

  // Output detailed release notes
  if (releaseNotesData.length > 0) {
    console.log('\n---\n')
    console.log('# Detailed Release Notes\n')

    for (const { packageName, current, latest, releases } of releaseNotesData) {
      console.log(`## ${packageName} Release Notes (${current} → ${latest})\n`)
      
      for (const release of releases) {
        console.log(`### ${release.name || release.tag_name}`)
        if (release.published_at) {
          const date = new Date(release.published_at).toLocaleDateString()
          console.log(`*Released: ${date}*\n`)
        }
        
        if (release.body && release.body.trim()) {
          console.log(release.body.trim())
        } else {
          console.log('*No release notes available*')
        }
        console.log('\n---\n')
      }
    }
  }
}

main()
