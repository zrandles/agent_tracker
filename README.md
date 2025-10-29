# Agent Tracker

A Rails application for tracking agent invocations, success rates, issues, and improvements across the zac_ecosystem.

## Purpose

Track every invocation of custom agents (market-research, ux-expert, rails-expert, etc.) to:
- Measure agent effectiveness and success rates
- Identify patterns in agent usage
- Track issues and improvements over time
- Inform decisions about which agents to invest in
- Document learnings from agent work

## URL

Production: **http://24.199.71.69/agent_tracker**

## Core Models

### Agent
- Represents a custom agent spec (e.g., market-research, ux-expert)
- Tracks: name, description, success_rate, total_invocations
- Auto-created when first invocation is logged

### AgentInvocation
- Individual usage of an agent
- Fields: task_description, status (pending/success/failure), duration, output_summary
- Links to Agent and can have multiple AgentIssues and AgentImprovements

### AgentIssue
- Problems encountered during agent execution
- Fields: description, severity (low/medium/high/critical), status (open/resolved)
- Used to track bugs, failures, or areas needing improvement

### AgentImprovement
- Enhancements made to agents based on usage
- Fields: description, impact (low/medium/high), implemented_at
- Documents what changes were made and why

### AgentChange
- Version control for agent prompt changes
- Fields: change_type (prompt_update/capability_added/bug_fix), description, diff
- Tracks evolution of agent prompts over time

## Features

### Dashboard
- Overview of all agents with success rates
- Recent invocations across all agents
- Top performing agents
- Issue summary (open vs resolved)

### Agent Detail Pages
- Full invocation history for specific agent
- Success rate trends over time
- Related issues and improvements
- Change log of prompt updates

### Invocation Tracking
- Log each agent usage via web UI or API
- Track success/failure with detailed notes
- Link issues discovered during execution
- Document improvements implemented

### Analytics
- Success rate by agent
- Average duration per agent
- Common failure patterns
- Most frequently used agents

## Workflow

See `docs/AGENT_DEVELOPMENT.md` in the ecosystem root for the complete agent development workflow, including:
- When to create agents
- How to test agents
- Rating system (1-5 scale)
- Logging invocations in agent_tracker

## Deployment

```bash
cd ~/zac_ecosystem/apps/agent_tracker
git add -A && git commit -m "Update agent tracker"
git push
cap production deploy
```

## Technical Details

- **Rails Version**: 8.0
- **Database**: SQLite (production.sqlite3)
- **Service**: agent_tracker.service (systemd)
- **URL Path**: `/agent_tracker`
- **Test Coverage**: 80.59% (302 examples, 0 failures)

## Integration

Part of zac_ecosystem infrastructure apps:
- Works alongside app_monitor (server health)
- Works alongside idea_tracker (product ideas)
- Works alongside code_quality (code health)

All agent invocations should be logged here to track effectiveness and improve agent prompts over time.
