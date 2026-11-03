#!/usr/bin/env node
// Prints a markdown table of everything deployed on Coolify and Netlify,
// with Uptime Kuma status and local clone path.
//
// Conventions this relies on (keep them true instead of adding logic here):
// - GitHub repo lttr/<name> is cloned at ~/code/<name>
// - Uptime Kuma monitor name = site hostname without "www.", dots replaced by dashes
//   (www.jedlik-nejedlik.cz -> jedlik-nejedlik-cz), on the public status page "sites"

import { readFileSync, existsSync } from 'node:fs'
import { homedir } from 'node:os'
import { join } from 'node:path'

const HOME = homedir()
const CODE_DIR = join(HOME, 'code')
const UPTIME = 'https://uptime.lttr.cz'
const UPTIME_PAGE = 'sites'

type Row = {
  platform: 'Coolify' | 'Netlify'
  project: string
  name: string
  status: string
  repo: string
  branch: string
  host: string
}

const readJson = (path: string): any => JSON.parse(readFileSync(path, 'utf8'))

async function get(url: string, token?: string): Promise<any> {
  const res = await fetch(url, token ? { headers: { Authorization: `Bearer ${token}` } } : {})
  if (!res.ok) throw new Error(`${res.status} ${url}`)
  return res.json()
}

// "https://a.lttr.cz:3001,https://b.lttr.cz" -> "a.lttr.cz"
const host = (urls?: string): string => (urls ? new URL(urls.split(',')[0]).hostname : '')

const monitorName = (hostname: string): string => hostname.replace(/^www\./, '').replaceAll('.', '-')

const localPath = (repo: string): string => {
  if (!repo) return ''
  const dir = join(CODE_DIR, repo.split('/')[1])
  return existsSync(dir) ? dir.replace(HOME, '~') : 'missing'
}

// --- Coolify -----------------------------------------------------------------

async function coolifyRows(): Promise<Row[]> {
  const cfg = readJson(join(HOME, '.config/coolify/config.json'))
  const { fqdn, token } = cfg.instances.find((i: any) => i.default)
  const api = `${fqdn}/api/v1`

  const envs: Record<number, string> = {}
  for (const { uuid } of await get(`${api}/projects`, token)) {
    const project = await get(`${api}/projects/${uuid}`, token)
    for (const env of project.environments) envs[env.id] = `${project.name} / ${env.name}`
  }

  const apps = (await get(`${api}/applications`, token)).map((a: any): Row => ({
    platform: 'Coolify',
    project: envs[a.environment_id],
    name: a.name,
    status: a.status,
    repo: a.git_repository,
    branch: a.git_branch,
    host: host(a.fqdn),
  }))

  const services = (await get(`${api}/services`, token)).map((s: any): Row => ({
    platform: 'Coolify',
    project: envs[s.environment_id],
    name: s.name,
    status: s.status,
    repo: '',
    branch: '',
    host: host(s.applications?.map((a: any) => a.fqdn).filter(Boolean).join(',')),
  }))

  return [...apps, ...services]
}

// --- Netlify -----------------------------------------------------------------

async function netlifyRows(): Promise<Row[]> {
  const cfg = readJson(join(HOME, '.config/netlify/config.json'))
  const token = cfg.users[cfg.userId].auth.token
  const sites = await get('https://api.netlify.com/api/v1/sites', token)

  return sites.map((s: any): Row => ({
    platform: 'Netlify',
    project: s.account_name,
    name: s.name,
    status: `published ${(s.published_deploy?.published_at ?? s.updated_at).slice(0, 10)}`,
    repo: s.build_settings?.repo_path ?? '',
    branch: s.build_settings?.repo_branch ?? '',
    host: s.custom_domain || host(s.ssl_url || s.url),
  }))
}

// --- Uptime Kuma -------------------------------------------------------------

async function uptimeByMonitor(): Promise<Record<string, 'OK' | 'DOWN'>> {
  const page = await get(`${UPTIME}/api/status-page/${UPTIME_PAGE}`)
  const { heartbeatList } = await get(`${UPTIME}/api/status-page/heartbeat/${UPTIME_PAGE}`)
  const result: Record<string, 'OK' | 'DOWN'> = {}
  for (const group of page.publicGroupList) {
    for (const m of group.monitorList) {
      result[m.name] = heartbeatList[m.id]?.at(-1)?.status === 1 ? 'OK' : 'DOWN'
    }
  }
  return result
}

// --- Output ------------------------------------------------------------------

const [coolify, netlify, uptime] = await Promise.all([coolifyRows(), netlifyRows(), uptimeByMonitor()])
const rows = [...coolify, ...netlify].sort(
  (a, b) => a.platform.localeCompare(b.platform) || a.project.localeCompare(b.project) || a.name.localeCompare(b.name),
)

const header = ['Platform', 'Project / env', 'Resource', 'Uptime', 'Status', 'Repo (branch)', 'URL', 'Local']
const lines = rows.map((r) => {
  const monitored = r.host && uptime[monitorName(r.host)]
  return [
    r.platform,
    r.project,
    r.name,
    monitored || '-',
    r.status,
    r.repo ? `${r.repo} (${r.branch})` : '-',
    r.host || '-',
    localPath(r.repo) || '-',
  ]
})

const matched = new Set(rows.map((r) => r.host && monitorName(r.host)))
const unmatched = Object.keys(uptime).filter((name) => !matched.has(name))

console.log(`| ${header.join(' | ')} |`)
console.log(`|${header.map(() => '---').join('|')}|`)
for (const line of lines) console.log(`| ${line.join(' | ')} |`)
if (unmatched.length) console.log(`\nUptime monitors not matched to any site: ${unmatched.join(', ')}`)
