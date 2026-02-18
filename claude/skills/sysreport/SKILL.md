---
name: sysreport
description: This skill should be used to generate a system health and status report for a Linux machine. Trigger when user asks for system info, system status, health check, machine report, PC report, diagnostics, or uses keywords like "sysreport", "system report", "how's my machine", "system health". Covers hardware, CPU, memory, disk, temperatures, network, Docker, top processes, listening ports, and recent errors.
---

# Sysreport

Generate a concise system health report for a Linux workstation.

## Workflow

1. Run the data collection script:

```bash
bash /home/lukas/dotfiles/claude/skills/sysreport/scripts/sysreport.sh 2>&1
```

2. Parse the output sections and produce a **summary report** in the following format:

```
**Hardware** - <CPU model> (<cores>C/<threads>T), <RAM total>, <disk size> (<encryption/FS notes>)

**Health**
- Uptime: **<days>**
- CPU temps: **<range>** - <assessment>
- Load: **<1min avg>** - <assessment relative to thread count>
- RAM: <used> / <total> - <assessment>
- Swap: <used> - <assessment based on uptime>
- Disk: **<% used> (<free> free)** - <warning if >85%>
- Journal errors (last 2h): <count or "none">

**Network** - <active interfaces and IPs>

**Docker** - <container count and names, or "not running">

**Notable** - <anything interesting: zombie processes, high-mem processes, unusual ports, stale services>
```

3. **Flag concerns** - Highlight anything actionable:
   - Disk usage >85%
   - CPU temps >80C
   - Load average > thread count
   - High swap usage relative to uptime
   - Error journal entries
   - Zombie or stuck processes

4. Keep the report concise. The user skims - front-load the important bits, bold key numbers.
