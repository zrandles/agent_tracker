# API Token Setup

## Add to Credentials

Run this command:
```bash
cd /Users/zac/zac_ecosystem/apps/agent_tracker
EDITOR=nano bin/rails credentials:edit
```

Add this section:
```yaml
api:
  agent_tracker_token: 2490e78af166ead21e524b9636d37c46f03829b22f951357dc475555793d6d8c
```

Save and exit.

## Set Environment Variable Locally

Add to your `~/.bashrc` or `~/.zshrc`:
```bash
export AGENT_TRACKER_API_TOKEN='2490e78af166ead21e524b9636d37c46f03829b22f951357dc475555793d6d8c'
```

Then reload:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Verify

```bash
echo $AGENT_TRACKER_API_TOKEN
# Should output: 2490e78af166ead21e524b9636d37c46f03829b22f951357dc475555793d6d8c
```

## API Endpoint

**URL**: `https://24.199.71.69/agent_tracker/api/agent_invocations/bulk_create`
**Method**: POST
**Auth**: Bearer token in Authorization header
**Content-Type**: application/json

##Clean up this file after setup
```bash
rm /Users/zac/zac_ecosystem/apps/agent_tracker/API_TOKEN_SETUP.md
```
