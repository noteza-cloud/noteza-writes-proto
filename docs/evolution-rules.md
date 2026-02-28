# Evolution Rules

## Compatibility Policy

For `noteza.writes.v1`:

- Add fields only when backward-compatible.
- Do not rename/remove/retype existing fields after release.
- Do not reuse existing field numbers.
- Prefer introducing new RPCs/messages over mutating existing semantics.

Breaking changes require a new API version package (for example `noteza.writes.v2`).

## Field Design Rules

- IDs are UUID strings.
- Time values use `google.protobuf.Timestamp`.
- Status values use enums.
- List endpoints use pagination (`page_size`, `page_token`, `next_page_token`).
- Use `optional` where partial update semantics are needed.

## Service Design Rules

- Keep authentication, application credentials, media uploads, and writing domain separated by service.
- Keep message names explicit and operation-scoped (`CreateXRequest`, `CreateXResponse`).
- Keep entities in domain files and transport request/response in `service.proto`.
- For repeated images in update requests, use append/remove semantics (`add_*`, `remove_*`) instead of full replacement.
- For authenticated ownership checks, derive user identity from auth context, not request `user_id` fields.
- For media uploads, keep binary transport outside protobuf payloads (pre-signed upload flow only).

## HTTP Annotation Rules

- Every RPC must have a `(google.api.http)` annotation in `service.proto`.
- Use standard HTTP verbs: `GET` for reads, `POST` for creates, `PATCH` for partial updates, `DELETE` for deletes.
- Use `PATCH` (not `PUT`) for update RPCs because all update fields are optional.
- Use a sub-path for non-CRUD operations: `POST /{resource}/{action}` (for example, `/token`, `/finalize`).
- For `POST`/`PATCH` RPCs, set `body: "*"` so non-path fields are read from the request body.
- For `GET`/`DELETE` RPCs, omit `body`; non-path fields become query parameters automatically.
- Nest child resources under their parent: `/v1/series/{series_id}/articles`, not `/v1/articles?series_id=…`.

## Delete Semantics

Delete RPCs follow a strict contract:

| Outcome | gRPC status | `deleted` field |
|---------|-------------|-----------------|
| Resource found and deleted | `OK` | `true` |
| Resource not found | `NOT_FOUND` (code 5) | — (error, no response body) |

`deleted: false` is never returned. Clients must handle `NOT_FOUND` as an error, not as a silent no-op.

This applies to all current Delete RPCs: `DeleteApplication`, `DeleteImage`.

## Tooling Gates

- `buf lint` must pass.
- `buf breaking --against '.git#branch=main'` must pass before merge.
- `buf generate` must succeed.
