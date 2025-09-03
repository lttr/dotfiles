#!/usr/bin/env node

import { execSync } from "child_process"
import { readFileSync } from "fs"

/**
 * Generate release notes links for outdated packages
 * Usage: node generate-release-notes.js [path-to-json-file]
 * If no file provided, runs `pnpm outdated --format json` automatically
 */

function getPnpmOutdatedData(jsonFile) {
  if (jsonFile) {
    return JSON.parse(readFileSync(jsonFile, "utf8"))
  }

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
  const [currentMajor, currentMinor] = current.split(".").map(Number)
  const [latestMajor, latestMinor] = latest.split(".").map(Number)

  return currentMajor !== latestMajor || currentMinor !== latestMinor
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
  const jsonFile = process.argv[2]
  const outdatedData = getPnpmOutdatedData(jsonFile)

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
  }
}

main()
