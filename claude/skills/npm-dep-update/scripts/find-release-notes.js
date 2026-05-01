#!/usr/bin/env node

import { execSync } from "child_process";
import { readFileSync } from "fs";

/**
 * Generate release notes links for outdated packages
 * Runs `pnpm outdated --format json` to find outdated packages
 */

function getPnpmOutdatedData(passthrough = []) {
  const cmd = ["pnpm", "outdated", "--format", "json", ...passthrough].join(
    " ",
  );
  try {
    const output = execSync(cmd, { encoding: "utf8" });
    return JSON.parse(output || "{}");
  } catch (error) {
    // pnpm outdated exits with code 1 when packages are outdated, but still outputs valid JSON to stdout
    if (error.stdout) {
      try {
        return JSON.parse(error.stdout || "{}");
      } catch (parseError) {
        console.error(
          "Error parsing pnpm outdated output:",
          parseError.message,
        );
        process.exit(1);
      }
    }
    console.error("Error running pnpm outdated:", error.message);
    process.exit(1);
  }
}

function parseArgs(argv) {
  const passthrough = [];
  let typeFilter = "all";
  let help = false;
  for (const a of argv) {
    if (a === "--help" || a === "-h") help = true;
    else if (a.startsWith("--type=")) typeFilter = a.slice("--type=".length);
    else passthrough.push(a);
  }
  return { passthrough, typeFilter, help };
}

/**
 * Normalize pnpm outdated output across recursive/non-recursive shapes.
 * Returns Map<packageName, { current, latest, wanted, dependencyType, workspaces[] }>
 */
function normalizeOutdated(raw) {
  const map = new Map();
  const ingest = (pkg, info, workspace) => {
    const entry = map.get(pkg) || {
      current: info.current,
      latest: info.latest,
      wanted: info.wanted,
      dependencyType: info.dependencyType,
      workspaces: [],
    };
    if (workspace && !entry.workspaces.includes(workspace))
      entry.workspaces.push(workspace);
    map.set(pkg, entry);
  };
  for (const [key, value] of Object.entries(raw)) {
    if (!value || typeof value !== "object") continue;
    // recursive shape: top-level keys are workspace paths, values are { pkg: info }
    const isWorkspaceBucket =
      !value.current &&
      !value.latest &&
      Object.values(value).some(
        (v) => v && typeof v === "object" && (v.current || v.latest),
      );
    if (isWorkspaceBucket) {
      for (const [pkg, info] of Object.entries(value)) ingest(pkg, info, key);
    } else {
      ingest(key, value, null);
    }
  }
  return map;
}

function matchesTypeFilter(dependencyType, typeFilter) {
  if (typeFilter === "all" || !dependencyType) return true;
  if (typeFilter === "deps") return dependencyType === "dependencies";
  if (typeFilter === "devDeps") return dependencyType === "devDependencies";
  if (typeFilter === "optional")
    return dependencyType === "optionalDependencies";
  return true;
}

function isMinorOrMajorUpdate(current, latest) {
  const currentParts = current.split(".").map(Number);
  const latestParts = latest.split(".").map(Number);

  const currentMajor = currentParts[0] || 0;
  const currentMinor = currentParts[1] || 0;
  const currentPatch = currentParts[2] || 0;

  const latestMajor = latestParts[0] || 0;
  const latestMinor = latestParts[1] || 0;
  const latestPatch = latestParts[2] || 0;

  // For versions >= 1.0.0, normal semver rules
  if (currentMajor >= 1 || latestMajor >= 1) {
    return currentMajor !== latestMajor || currentMinor !== latestMinor;
  }

  // For versions < 1.0.0, minor is breaking and patch is non-breaking
  return currentMinor !== latestMinor || currentPatch !== latestPatch;
}

async function checkUrlExists(url) {
  try {
    const response = await fetch(url, {
      method: "HEAD",
      signal: AbortSignal.timeout(3000),
    });
    return response.ok;
  } catch {
    return false;
  }
}

async function fetchNpmPackageInfo(packageName) {
  const url = `https://registry.npmjs.org/${packageName}`;
  const response = await fetch(url);
  return response.json();
}

async function fetchGitHubReleases(repoPath) {
  try {
    const url = `https://api.github.com/repos/${repoPath}/releases`;
    const response = await fetch(url, {
      headers: {
        Accept: "application/vnd.github.v3+json",
        "User-Agent": "find-release-notes-script",
      },
    });

    if (!response.ok) {
      return [];
    }

    return await response.json();
  } catch {
    return [];
  }
}

function parseVersion(version) {
  const cleaned = version.replace(/^[^\d]*/, "");
  const parts = cleaned.split(".").map(Number);
  return {
    major: parts[0] || 0,
    minor: parts[1] || 0,
    patch: parts[2] || 0,
    original: version,
  };
}

function compareVersions(a, b) {
  const vA = parseVersion(a);
  const vB = parseVersion(b);

  if (vA.major !== vB.major) return vA.major - vB.major;
  if (vA.minor !== vB.minor) return vA.minor - vB.minor;
  return vA.patch - vB.patch;
}

function isSignificantRelease(version) {
  const v = parseVersion(version);

  if (v.major >= 1) {
    return v.patch === 0;
  }

  return true;
}

function getVersionsBetween(current, latest, releases) {
  return releases
    .filter((release) => {
      if (release.draft || release.prerelease) return false;

      if (
        compareVersions(release.tag_name, current) <= 0 ||
        compareVersions(release.tag_name, latest) > 0
      ) {
        return false;
      }

      return isSignificantRelease(release.tag_name);
    })
    .sort((a, b) => compareVersions(a.tag_name, b.tag_name));
}

function extractGitHubRepo(repoUrl) {
  if (!repoUrl) {
    return null;
  }

  if (typeof repoUrl === "object" && repoUrl.url) {
    repoUrl = repoUrl.url;
  }

  const match = repoUrl.match(
    /github\.com[\/:]([^\/]+\/[^\/]+?)(?:\.git|\/|$)/,
  );
  return match ? match[1] : null;
}

async function main() {
  const { passthrough, typeFilter, help } = parseArgs(process.argv.slice(2));

  if (help) {
    console.log("Generate release notes links for outdated packages");
    console.log("");
    console.log("Usage: node find-release-notes.js [options]");
    console.log("");
    console.log("Options (passthrough to pnpm outdated):");
    console.log("  -r, --recursive   Check every workspace package");
    console.log("  -P, --prod        Only dependencies + optionalDependencies");
    console.log("  -D, --dev         Only devDependencies");
    console.log("      --no-optional Skip optionalDependencies");
    console.log("");
    console.log("Custom options:");
    console.log(
      "      --type=<filter>  Post-filter: deps|devDeps|optional|all (default: all)",
    );
    console.log("  -h, --help           Show this help");
    return;
  }

  const raw = getPnpmOutdatedData(passthrough);
  const normalized = normalizeOutdated(raw);

  if (normalized.size === 0) {
    console.log("No outdated packages found!");
    return;
  }

  console.log("# Release Notes for Outdated Packages\n");
  console.log(
    `Scope: ${passthrough.length ? passthrough.join(" ") : "current package"} | type filter: ${typeFilter}\n`,
  );

  const filteredPackages = [...normalized.entries()].filter(
    ([, info]) =>
      matchesTypeFilter(info.dependencyType, typeFilter) &&
      isMinorOrMajorUpdate(info.current, info.latest),
  );

  if (filteredPackages.length === 0) {
    console.log("No packages with minor or major updates found!");
    return;
  }

  // Batch fetch repository info for all packages
  const repoPromises = filteredPackages.map(async ([packageName]) => {
    try {
      const packageJsonPath = `node_modules/${packageName}/package.json`;
      const packageJson = JSON.parse(readFileSync(packageJsonPath, "utf8"));
      const repo =
        extractGitHubRepo(packageJson.repository) ||
        extractGitHubRepo(packageJson.homepage);
      if (repo) {
        return { packageName, repo };
      }
    } catch {
      //
    }

    try {
      const npmData = await fetchNpmPackageInfo(packageName);
      const repo =
        extractGitHubRepo(npmData.repository) ||
        extractGitHubRepo(npmData.homepage);
      return { packageName, repo: repo || `${packageName}/${packageName}` };
    } catch {
      return { packageName, repo: `${packageName}/${packageName}` };
    }
  });

  const repoResults = await Promise.all(repoPromises);
  const repoMap = new Map(repoResults.map((r) => [r.packageName, r.repo]));

  const releaseNotesData = [];

  for (const [packageName, info] of filteredPackages) {
    const { current, latest, dependencyType, workspaces } = info;
    const repoPath = repoMap.get(packageName);

    const meta = [];
    if (dependencyType) meta.push(dependencyType);
    if (workspaces && workspaces.length)
      meta.push(`in: ${workspaces.join(", ")}`);
    const metaStr = meta.length ? `  _${meta.join(" | ")}_` : "";

    console.log(`## ${packageName} (${current} → ${latest})${metaStr}`);

    const candidateUrls = [
      `https://github.com/${repoPath}/blob/main/CHANGELOG.md`,
      `https://github.com/${repoPath}/blob/master/CHANGELOG.md`,
      `https://github.com/${repoPath}/releases`,
    ];

    let foundUrl = null;
    for (const url of candidateUrls) {
      if (await checkUrlExists(url)) {
        foundUrl = url;
        break;
      }
    }

    console.log(
      `${foundUrl || `https://www.npmjs.com/package/${packageName}?activeTab=versions`}\n`,
    );

    const releases = await fetchGitHubReleases(repoPath);
    if (releases.length > 0) {
      const relevantReleases = getVersionsBetween(current, latest, releases);
      if (relevantReleases.length > 0) {
        releaseNotesData.push({
          packageName,
          current,
          latest,
          releases: relevantReleases,
        });
      }
    }
  }

  if (releaseNotesData.length > 0) {
    console.log("\n---\n");
    console.log("# Detailed Release Notes\n");

    for (const { packageName, current, latest, releases } of releaseNotesData) {
      console.log(`## ${packageName} Release Notes (${current} → ${latest})\n`);

      for (const release of releases) {
        console.log(`### ${release.name || release.tag_name}`);
        if (release.published_at) {
          const date = new Date(release.published_at).toLocaleDateString();
          console.log(`*Released: ${date}*\n`);
        }

        if (release.body && release.body.trim()) {
          console.log(release.body.trim());
        } else {
          console.log("*No release notes available*");
        }
        console.log("\n---\n");
      }
    }
  }
}

main();
