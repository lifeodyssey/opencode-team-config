---
name: dev-browser
description: Browser automation with persistent page state. Use when users ask to navigate websites, fill forms, take screenshots, extract web data, test web apps, or automate browser workflows. Trigger phrases include 'go to [url]', 'click on', 'fill out the form', 'take a screenshot', 'scrape', 'automate', 'test the website', 'log into', or any browser interaction request.
triggers:
  - "go to"
  - "click on"
  - "fill out"
  - "take a screenshot"
  - "scrape"
  - "automate browser"
  - "test the website"
  - "log into"
  - "navigate"
  - "browser automation"
---

# Dev Browser Skill

Browser automation that maintains page state across script executions. Write small, focused scripts to accomplish tasks incrementally. Once you've proven out part of a workflow and there is repeated work to be done, you can write a script to do the repeated work in a single execution.

## Choosing Your Approach

- **Local/source-available sites**: Read the source code first to write selectors directly
- **Unknown page layouts**: Use `getAISnapshot()` to discover elements and `selectSnapshotRef()` to interact with them
- **Visual feedback**: Take screenshots to see what the user sees

## Setup

**IMPORTANT**: Before using this skill, ensure the server is running. See [references/installation.md](references/installation.md) for platform-specific setup instructions (macOS, Linux, Windows).

Two modes available. Ask the user if unclear which to use.

### Standalone Mode (Default)

Launches a new Chromium browser for fresh automation sessions.

**macOS/Linux:**
```bash
./skills/dev-browser/server.sh &
```

**Windows (PowerShell):**
```powershell
Start-Process -NoNewWindow -FilePath "node" -ArgumentList "skills/dev-browser/server.js"
```

Add `--headless` flag if user requests it. **Wait for the `Ready` message before running scripts.**

### Extension Mode

Connects to user's existing Chrome browser. Use this when:

- The user is already logged into sites and wants you to do things behind an authed experience that isn't local dev.
- The user asks you to use the extension

**Important**: The core flow is still the same. You create named pages inside of their browser.

**Start the relay server:**

**macOS/Linux:**
```bash
cd skills/dev-browser && npm i && npm run start-extension &
```

**Windows (PowerShell):**
```powershell
cd skills/dev-browser; npm i; Start-Process -NoNewWindow -FilePath "npm" -ArgumentList "run", "start-extension"
```

Wait for `Waiting for extension to connect...` followed by `Extension connected` in the console.

If the extension hasn't connected yet, tell the user to launch and activate it. Download link: https://github.com/SawyerHood/dev-browser/releases

## Writing Scripts

> **Run all scripts from `skills/dev-browser/` directory.** The `@/` import alias requires this directory's config.

Execute scripts inline using heredocs:

**macOS/Linux:**
```bash
cd skills/dev-browser && npx tsx <<'EOF'
import { connect, waitForPageLoad } from "@/client.js";

const client = await connect();
const page = await client.page("example", { viewport: { width: 1920, height: 1080 } });

await page.goto("https://example.com");
await waitForPageLoad(page);

console.log({ title: await page.title(), url: page.url() });
await client.disconnect();
EOF
```

**Windows (PowerShell):**
```powershell
cd skills/dev-browser
@"
import { connect, waitForPageLoad } from "@/client.js";

const client = await connect();
const page = await client.page("example", { viewport: { width: 1920, height: 1080 } });

await page.goto("https://example.com");
await waitForPageLoad(page);

console.log({ title: await page.title(), url: page.url() });
await client.disconnect();
"@ | npx tsx --input-type=module
```

### Key Principles

1. **Small scripts**: Each script does ONE thing (navigate, click, fill, check)
2. **Evaluate state**: Log/return state at the end to decide next steps
3. **Descriptive page names**: Use `"checkout"\
