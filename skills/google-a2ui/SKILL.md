---
name: google-a2ui
description: Google A2UI (Agent-to-User Interface) protocol for building agent-driven UIs
triggers:
  - a2ui
  - agent to ui
  - agent ui
  - a2ui component
  - a2ui renderer
  - agent driven interface
---

# Google A2UI Development Skill

This skill helps you develop agent-driven user interfaces using Google's A2UI protocol.

## Overview

A2UI (Agent-to-User Interface) is an open-source protocol that allows AI agents to generate rich, contextual user interfaces safely. Instead of generating executable code, agents send declarative component descriptions that clients render using their own native widgets.

**Key Principle**: A2UI is a declarative data format, NOT executable code. This provides security by design.

## Core Concepts

### How A2UI Works

1. **Agent** generates a JSON payload describing UI components
2. **Client** receives the payload via A2A, AG-UI, or other protocols
3. **A2UI Renderer** parses the JSON
4. **Renderer** maps abstract components to native implementations

### Component Catalog

Your client maintains a catalog of trusted, pre-approved UI components:
- Card, Button, TextField, List, Image, etc.
- The agent can ONLY request components from this catalog

### Message Format

```json
{
  "components": [
    {
      "id": "card-1",
      "type": "Card",
      "props": {
        "title": "Welcome",
        "variant": "elevated"
      }
    },
    {
      "id": "btn-1",
      "type": "Button",
      "props": {
        "label": "Get Started",
        "action": "navigate",
        "target": "/onboarding"
      },
      "parent": "card-1"
    }
  ]
}
```

## Integration with ADK

### Presenter Pattern (Deterministic UI)

```python
def build_a2ui_response(session_state: dict, language: str) -> dict:
    """Build A2UI response based on session state."""
    components = []

    if "route_plan" in session_state:
        # Show route view
        components.append({
            "id": "route-view",
            "type": "RouteMap",
            "props": {"points": session_state["route_plan"]["points"]}
        })
    elif "candidates" in session_state:
        # Show candidates picker
        components.append({
            "id": "picker",
            "type": "CandidatesPicker",
            "props": {"items": session_state["candidates"]}
        })
    else:
        # Show welcome view
        components.append({
            "id": "welcome",
            "type": "WelcomeCard",
            "props": {"language": language}
        })

    return {"components": components}
```

### With ADK Agent

```python
from google.adk.agents import LlmAgent

agent = LlmAgent(
    name="ui_agent",
    model="gemini-2.0-flash",
    instruction="""
    Generate A2UI components for user requests.
    Use only these component types: Card, Button, TextField, List.
    Always include component id, type, and props.
    """,
)
```

## A2UI Server Setup

### Using aiohttp

```python
from aiohttp import web

async def chat_handler(request):
    data = await request.json()
    session_id = data["session_id"]
    user_text = data["message"]

    # Process with agent
    response_text, session_state = await agent.chat(session_id, user_text)

    # Build A2UI response
    a2ui_response = build_a2ui_response(session_state, "en")

    return web.json_response({
        "text": response_text,
        "ui": a2ui_response
    })

app = web.Application()
app.router.add_post("/api/chat", chat_handler)
```

## Component Types (Common)

| Type | Description | Props |
|------|-------------|-------|
| `Card` | Container with optional title | title, variant, elevation |
| `Button` | Clickable action | label, action, variant, disabled |
| `TextField` | Text input | placeholder, value, multiline |
| `List` | List of items | items, selectable, multiSelect |
| `Image` | Display image | src, alt, width, height |
| `Markdown` | Render markdown | content |
| `Progress` | Loading indicator | value, indeterminate |

## Best Practices

1. **Security**: Never execute agent-generated code directly
2. **Validation**: Validate all component props before rendering
3. **Fallbacks**: Handle unknown component types gracefully
4. **Accessibility**: Ensure rendered components are accessible
5. **Localization**: Support multiple languages in props

## Resources

- [A2UI GitHub](https://github.com/google/A2UI)
- [A2UI Documentation](https://a2ui.org/)
- [A2UI + ADK Samples](https://github.com/google/A2UI/tree/main/samples/agent/adk)
- [AG-UI Protocol](https://google.github.io/adk-docs/tools/third-party/ag-ui/)
- [A2UI Announcement](https://developers.googleblog.com/introducing-a2ui-an-open-project-for-agent-driven-interfaces/)
