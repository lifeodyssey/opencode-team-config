# AGENTS.md — Project Agent Instructions

> Copy this file to your project root. Agents read it automatically at session start.

## Project Context

- **Name**: [project name]
- **Stack**: [e.g., Next.js 16 + Kotlin/Spring Boot + Postgres + AWS]
- **Repo**: [repo URL]

## Conventions

- **Branching**: Trunk-based. Feature branches squash to 1 commit.
- **Testing**: TDD mandatory (team-tdd skill). RED → GREEN → REFACTOR.
- **Code size**: Functions ≤10 lines, Components ≤100 lines, Files ≤300 lines.

## Architecture

- **Frontend**: [e.g., app/ directory, App Router, Server Components]
- **Backend**: [e.g., src/main/kotlin, layered: controller → service → repository]
- **Database**: [e.g., Postgres + Flyway migrations in db/migration/]
- **Infra**: [e.g., Terraform in infra/, Terragrunt for env separation]

## Existing Abstractions (DO NOT reinvent)

- [e.g., HTTP client: src/lib/api-client.ts]
- [e.g., Auth: src/middleware/auth.kt]
- [e.g., DB connection: src/config/database.kt]

## Do NOT Touch

- [e.g., legacy/ directory — scheduled for removal]
- [e.g., .env files — never commit]

## Testing Commands

```bash
# Frontend
npm run test          # vitest
npm run test:e2e      # playwright

# Backend
./gradlew test        # unit tests
./gradlew integrationTest

# Infra
terraform plan
```
