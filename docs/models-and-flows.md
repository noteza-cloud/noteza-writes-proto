# Models And Flows

## Core Entities

- `User`: account identity and plan
- `Application`: machine-client credential container
- `ImageAsset`: uploaded image metadata
- `Series`: thematic writing stream for a user
- `Article`: logical article root
- `ArticleVersion`: immutable article snapshot
- `Post`: logical post root
- `PostVersion`: immutable post snapshot
- `WritingContext`: helper context assembled for writing workflows

## Article Model

`Article` stores root metadata and current version reference:

- `id`
- `user_id` (owner)
- `series_id` (parent series)
- `current_version_id`
- `created_at`

`ArticleVersion` stores content snapshot fields including:

- `title`
- `content_md`
- `post_md` (for social adaptation such as LinkedIn)
- `cover_image` (`ImageAsset`)
- `images` (`repeated ImageAsset`)
- editorial metadata (`summary`, `canonical_topic`, `series_part`, `status`, etc.)

`canonical_topic` is the normalized topic label used for deduplication/grouping/search consistency.

## Post Model

`Post` stores root metadata and current version reference:

- `id`
- `user_id` (owner)
- `series_id` (logical grouping)
- `current_version_id`
- `created_at`

`PostVersion` stores snapshot fields including:

- `content_md`
- `images` (`repeated ImageAsset`)
- `status`

## Media Flow

1. Client calls `CreateImageUpload` with expected metadata.
2. API creates an asset in `PENDING` state and returns `image` + `upload_url` (pre-signed).
3. Client uploads binary directly to storage URL.
4. Client calls `FinalizeImageUpload` with optional verification metadata (size/checksum/dimensions).
5. API marks asset as `READY` (or `FAILED` on validation failure).
6. Client references `image_id` in `Create/UpdateArticleRequest` or `Create/UpdatePostRequest`.

`ImageAsset` includes:

- lifecycle state (`status`)
- usage type (`usage`)
- descriptive metadata (`alt_text`, `source`, `checksum_sha256`)
- delivery variants (`variants`, e.g. original/thumbnail/social)

Update semantics for images:

- `CreateArticleRequest.image_ids` and `CreatePostRequest.image_ids` set initial images.
- `UpdateArticleRequest` and `UpdatePostRequest` use append/remove operations:
  - `add_image_ids`: append these image references
  - `remove_image_ids`: remove these image references

Conflict resolution rules for `add_image_ids` / `remove_image_ids`:

| Case | Behavior |
|------|----------|
| Same ID in both `add_image_ids` and `remove_image_ids` | Removal takes precedence; ID is not added |
| Duplicate IDs within a single list | Silently deduplicated |
| ID in `remove_image_ids` not attached to the resource | Ignored (no-op) |

## Article Lifecycle Flow

1. `CreateArticle` creates article root + initial version.
2. `UpdateArticle` creates next immutable version.
3. `GetArticle` returns root + current version.
4. `GetArticleVersions` returns paginated history.

## Post Lifecycle Flow

1. `CreatePost` creates post root + initial version.
2. `UpdatePost` creates next immutable version.
3. `GetPost` returns root + current version.
4. `GetPostVersions` returns paginated history.
