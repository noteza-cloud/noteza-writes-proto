# Models And Flows

## Core Entities

- `User`: account identity and plan
- `Application`: machine-client credential container
- `ImageAsset`: uploaded image metadata
- `Series`: thematic writing stream for a user
- `Article`: article with inline versioned content
- `Post`: post with inline versioned content

## Series Model

`Series` stores all metadata inline:

- `id`
- `user_id` (owner)
- `name`
- `description`
- `tone`
- `target_audience`
- `language`
- `strategy_note`
- `created_at`

`SeriesPreview` is a lightweight projection used in event payloads:

- `id`
- `name`
- `description` (optional)

## Article Model

`Article` stores all content and metadata inline:

- `id`
- `user_id` (owner)
- `series_id` (optional parent series link)
- `version` (monotonically increasing version counter)
- `cover_image` (optional `ImagePreview`)
- `images` (`repeated ImagePreview`)
- `title`
- `content_md`
- `status` (`ArticleStatus`)
- `created_at`, `updated_at`, `published_at` (`published_at` is optional)

`ArticlePreview` is a lightweight projection used inside `Post.body` and `ListArticles` responses:

- `id`
- `version`
- `cover_image` (optional `ImagePreview`)
- `title`
- `content_preview`

## Post Model

`Post` stores all content and metadata inline:

- `id`
- `user_id` (owner)
- `series_id` (optional logical grouping)
- `version` (monotonically increasing version counter)
- `content`
- `status` (`PostStatus`)
- `created_at`, `updated_at`, `published_at` (`published_at` is optional)
- `body` oneof:
  - `note` (`google.protobuf.Empty`) — text-only post body
  - `article` (`ArticlePreview`) — post linked to an article
  - `images` (`ImageGallery`) — standalone image post

`PostPreview` is a lightweight projection used in event payloads:

- `id`
- `series_id` (optional)
- `version`
- `content`
- `status` (`PostStatus`)
- `updated_at`

## Media Flow

1. Client calls `ImageUpload` with binary payload in `image_bytes`, required `mime_type`, and optional metadata (`file_name`, `alt_text`).
2. API validates/stores the image and returns `ImageAsset`.
3. Client references `image_id` in `Create/UpdateArticleRequest` or in `CreatePostRequest.body.images` / `UpdatePostRequest.images`.

`ImageAsset` includes:

- `id`
- `user_id` (owner)
- `url`
- `mime_type` (`ImageMimeType`), `size_bytes`, `width`, `height`
- `status` (lifecycle state)
- `alt_text` (optional)
- `created_at`

`ImagePreview` is a lightweight projection used in `Article` and `Post` body:

- `id`
- `url`
- `alt_text` (optional)

Update semantics for images:

- `CreateArticleRequest.image_ids` and `CreatePostRequest.body.images.image_ids` set initial images.
- `CreateArticleRequest.series_id` and `CreatePostRequest.series_id` optionally link new content to a series.
- `ListArticlesRequest.series_id` and `ListPostsRequest.series_id` optionally scope list results to one series.
- `UpdateArticleRequest` and `UpdatePostRequest.images` use append/remove operations:
  - `add_image_ids`: append these image references
  - `remove_image_ids`: remove these image references
- `CreatePostRequest.body.article.article_id` is used for article-based post creation.
- `CreatePostRequest.body.note` is used for note (text-only) post creation.
- `UpdatePostRequest.images` can be used only when the current post body is `images` (`ImageGallery`); otherwise server should return `FAILED_PRECONDITION`.

Conflict resolution rules for `add_image_ids` / `remove_image_ids`:

| Case | Behavior |
|------|----------|
| Same ID in both `add_image_ids` and `remove_image_ids` | Removal takes precedence; ID is not added |
| Duplicate IDs within a single list | Silently deduplicated |
| ID in `remove_image_ids` not attached to the resource | Ignored (no-op) |

## Article Lifecycle Flow

1. `CreateArticle` creates an article with its initial content (optionally linked to `series_id`).
2. `UpdateArticle` writes a new version (increments `version`, updates content fields).
3. `GetArticle` returns the current article state. Pass optional `version` to retrieve a specific historical version.
4. `ListArticles` returns paginated `ArticlePreview` items and can be filtered by optional `series_id`.

## Post Lifecycle Flow

1. `CreatePost` creates a post with its initial content (optionally linked to `series_id`) and body variant selected via `body` oneof (`note`, `article`, or `images`).
2. `UpdatePost` writes a new version (increments `version`, updates content/status, and allows image append/remove only for `images` posts).
3. `GetPost` returns the current post state. Pass optional `version` to retrieve a specific historical version.
4. `ListPosts` returns paginated `Post` items and can be filtered by optional `series_id`.

## Events Flow

1. Client opens `StreamEvents`.
2. Client provides optional filters (`event_types`, `series_id`, `article_id`, `post_id`).
3. Server emits `StreamEventsResponse` records with `EventEnvelope`.

Event payload shape:

- `series`: `SeriesPreview`
- `article`: `ArticlePreview`
- `post`: `PostPreview`
- `image`: `ImagePreview`
