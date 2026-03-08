# Overview

## Goal

`noteza-writes-proto` is the canonical contract repository for Noteza Writes APIs.
All backend services, MCP adapters, and clients must treat these protobuf definitions as the source of truth.

## Scope

Included:

- API message schemas
- Service RPC contracts
- Versioned package namespace (`noteza.writes.v1`)
- HTTP/REST bindings via gRPC-Gateway annotations
- Server-streaming event contract (`NotezaEventsService`)
- Code generation and compatibility tooling (Buf)

Excluded:

- Business rules
- Storage schemas
- Runtime authorization logic
- Infrastructure configuration

## Package and Versioning

- Package: `noteza.writes.v1`
- Versioning strategy: additive changes inside `v1`; breaking changes only in a new version (for example `v2`).

## Go Package

Generated Go code is published as part of this module:

```
github.com/noteza-cloud/noteza-writes-proto/gen/go/noteza/writes/v1
```

## Design Principles

- Clear, flat message structures
- Explicit enums for statuses
- Request/response messages separated from entity models
- UUID strings for IDs
- Timestamp fields with `google.protobuf.Timestamp`
- Pagination fields for list endpoints
