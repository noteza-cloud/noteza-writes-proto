# Noteza Writes Proto

Protocol Buffers contract for **Noteza Writes** — a SaaS writing memory platform designed to help users create, version, and manage structured long-form content and short posts. This contract defines the complete API surface for user management, series organization, full snapshot versioning of articles and posts, and contextual retrieval used by AI agents and client applications. It serves as the canonical schema for service communication, ensuring consistency, backward compatibility, and long-term evolvability of the system.

This repository contains versioned API definitions only. It has no business logic.

## Features

- Versioned API (`v1`)
- Snapshot versioning for articles and posts
- Separate services for auth, applications, media, and writing domain
- Media asset model with status/usage/variants metadata
- HTTP/REST bindings via gRPC-Gateway annotations
- Buf linting and breaking-change checks

## Structure

- `proto/noteza/writes/v1`: protobuf contracts
- `docs`: architecture and contract usage docs
- `docs/proto/noteza/writes/v1`: generated OpenAPI (Swagger 2.0) specs
- `buf.yaml`: lint and breaking configuration
- `buf.gen.yaml`: code generation configuration
- `gen/go`: generated Go output

## Services

- `NotezaAuthService`: registration and login
- `NotezaApplicationService`: app credentials for machine clients (MCP, integrations)
- `NotezaMediaService`: image upload lifecycle via pre-signed URLs
- `NotezaWritesService`: series, articles, posts, and writing context

## Docs

- [`docs/overview.md`](docs/overview.md): repository purpose and boundaries
- [`docs/services.md`](docs/services.md): service-by-service contract map
- [`docs/models-and-flows.md`](docs/models-and-flows.md): entities and end-to-end flows
- [`docs/evolution-rules.md`](docs/evolution-rules.md): compatibility and versioning rules

## Use as a Go Module

```bash
go get github.com/noteza-cloud/noteza-writes-proto
```

```go
import writesv1 "github.com/noteza-cloud/noteza-writes-proto/gen/go/noteza/writes/v1"
```

## Prerequisites

- [Buf CLI](https://buf.build/docs/cli/installation/)

## Generate Code

```bash
buf generate
```

## Lint

```bash
buf lint
```

## Breaking Change Check

```bash
buf breaking --against '.git#branch=main'
```
