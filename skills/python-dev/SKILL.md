---
name: python-dev
description: Python development best practices with uv, pytest, ruff, and modern tooling
triggers:
  - python
  - pytest
  - uv sync
  - uv run
  - pyproject.toml
  - ruff
  - mypy
  - python test
---

# Python Development Skill

This skill provides best practices for modern Python development using uv, pytest, ruff, and related tooling.

## Toolchain Overview

| Tool | Purpose | Command |
|------|---------|---------|
| **uv** | Package manager (replaces pip/poetry) | `uv sync`, `uv run` |
| **pytest** | Testing framework | `uv run pytest` |
| **ruff** | Linter + Formatter | `uv run ruff check .` |
| **mypy** | Type checker | `uv run mypy .` |
| **pyright** | LSP server | Integrated via plugin |

## Project Setup

### Initialize New Project

```bash
# Create new project
uv init my-project
cd my-project

# Or with specific Python version
uv init my-project --python 3.11
```

### Project Structure

```
my-project/
├── pyproject.toml        # Project configuration (single source of truth)
├── uv.lock               # Lock file (commit this)
├── .python-version       # Python version pinning
├── src/
│   └── my_project/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py       # Pytest fixtures
│   └── test_main.py
└── README.md
```

## Common Commands

### Dependency Management

```bash
# Install all dependencies
uv sync

# Add a dependency
uv add requests

# Add dev dependency
uv add --dev pytest pytest-asyncio

# Remove dependency
uv remove requests

# Update all dependencies
uv sync --upgrade
```

### Running Code

```bash
# Run a script
uv run python my_script.py

# Run module
uv run python -m my_project

# Run with specific Python
uv run --python 3.12 python my_script.py
```

### Testing

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=src --cov-report=term-missing

# Run specific test file
uv run pytest tests/test_main.py

# Run specific test function
uv run pytest tests/test_main.py::test_function_name

# Run with verbose output
uv run pytest -v

# Run and stop on first failure
uv run pytest -x

# Run in parallel
uv run pytest -n auto
```

### Linting & Formatting

```bash
# Check for issues
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .

# Format code
uv run ruff format .

# Type check
uv run mypy .
```

## pyproject.toml Configuration

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "My Python project"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0",
    "httpx>=0.25",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4",
    "pytest-asyncio>=0.21",
    "pytest-cov>=4.1",
    "ruff>=0.1",
    "mypy>=1.5",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = "-v --tb=short"

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP"]
ignore = ["E501"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_ignores = true

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## Testing Patterns

### Basic Test

```python
def test_addition():
    assert 1 + 1 == 2
```

### Async Test

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await my_async_function()
    assert result == expected
```

### Fixtures

```python
# conftest.py
import pytest

@pytest.fixture
def sample_data():
    return {"key": "value"}

@pytest.fixture
async def async_client():
    async with AsyncClient() as client:
        yield client
```

### Parametrized Tests

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    assert input * 2 == expected
```

## Type Hints

```python
from typing import Optional, List, Dict, Any
from collections.abc import Callable, Awaitable

def process_items(
    items: List[str],
    callback: Callable[[str], None],
    config: Optional[Dict[str, Any]] = None,
) -> int:
    """Process items and return count."""
    for item in items:
        callback(item)
    return len(items)

async def fetch_data(url: str) -> Dict[str, Any]:
    """Fetch JSON data from URL."""
    ...
```

## Best Practices

1. **Always use uv**: Faster and more reliable than pip
2. **Pin Python version**: Use `.python-version` file
3. **Type everything**: Enable strict mypy checking
4. **Test coverage**: Aim for 80%+ coverage on business logic
5. **Format on save**: Configure editor to run ruff format
6. **Commit lock file**: Always commit `uv.lock`

## Resources

- [uv Documentation](https://docs.astral.sh/uv/)
- [pytest Documentation](https://docs.pytest.org/)
- [ruff Documentation](https://docs.astral.sh/ruff/)
- [mypy Documentation](https://mypy.readthedocs.io/)
- [Python Type Hints Cheat Sheet](https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html)
