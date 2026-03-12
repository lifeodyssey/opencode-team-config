---
name: google-adk
description: Google Agent Development Kit (ADK) development guidance for building AI agents
triggers:
  - adk
  - agent development kit
  - google adk
  - vertex ai agent
  - adk agent
  - llmagent
  - adk deploy
---

# Google ADK Development Skill

This skill helps you develop AI agents using Google's Agent Development Kit (ADK).

## Overview

ADK is Google's open-source framework for building, evaluating, and deploying AI agents. It's the same framework powering agents within Google products like Agentspace and Google Customer Engagement Suite.

## Core Concepts

### Agent Types
- **LlmAgent** (alias: `Agent`): Uses LLM as core reasoning engine
- **SequentialAgent**: Runs sub-agents in sequence
- **ParallelAgent**: Runs sub-agents concurrently
- **LoopAgent**: Runs sub-agents in a loop until condition met
- **Custom Agents**: Extend `BaseAgent` for custom logic

### Tools
- **FunctionTool**: Wrap Python functions as agent tools
- **McpToolset**: Connect to MCP (Model Context Protocol) servers
- **Built-in Tools**: Search, Code Execution, etc.

### Sessions
- **InMemorySessionService**: For development/testing
- **DatabaseSessionService**: For production persistence

## Project Structure

```
adk_agents/
├── agent.py              # Root agent definition
├── _agents/              # Individual agent implementations
│   └── my_agent.py
├── _workflows/           # Workflow orchestrations
│   └── my_workflow.py
├── tools/                # Custom tool implementations
│   └── my_tool.py
├── _state.py             # State key definitions
├── _schemas.py           # Pydantic schemas
└── .adk/                 # ADK config & eval history
```

## Common Patterns

### Creating an LlmAgent

```python
from google.adk.agents import LlmAgent
from google.adk.tools import FunctionTool

agent = LlmAgent(
    name="my_agent",
    model="gemini-2.0-flash",
    instruction="You are a helpful assistant.",
    tools=[FunctionTool(my_function)],
)
```

### Creating a Sequential Workflow

```python
from google.adk.agents import SequentialAgent

workflow = SequentialAgent(
    name="my_workflow",
    sub_agents=[agent1, agent2, agent3],
)
```

### Using MCP Tools

```python
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset
from google.adk.tools.mcp_tool.mcp_session_manager import StdioConnectionParams

toolset = McpToolset(
    connection_params=StdioConnectionParams(
        server_params=StdioServerParameters(
            command="python",
            args=["-m", "my_mcp_server"],
        )
    ),
    tool_filter=["my_tool"],
)
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `adk dev` | Start local development server with web UI |
| `adk deploy` | Deploy to Vertex AI Agent Engine |
| `adk eval` | Run evaluation suite |
| `adk web` | Start web interface |

## Deployment to Vertex AI

```bash
# Single command deployment
adk deploy --project=my-project --region=us-central1

# Or via gcloud
gcloud ai agent-engines create my-agent \
  --project=my-project \
  --location=us-central1
```

## Best Practices

1. **State Management**: Define all state keys in a central `_state.py`
2. **Schema Definitions**: Use Pydantic models in `_schemas.py`
3. **Tool Design**: Keep tools focused and composable
4. **Testing**: Use `adk eval` for systematic agent evaluation
5. **Error Handling**: Implement graceful fallbacks in agents

## Resources

- [ADK Documentation](https://google.github.io/adk-docs/)
- [ADK Python GitHub](https://github.com/google/adk-python)
- [ADK Samples](https://github.com/google/adk-samples)
- [Vertex AI Agent Engine](https://cloud.google.com/agent-builder/agent-engine/overview)
