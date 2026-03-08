# Services

## NotezaAuthService

Purpose: user authentication.

RPCs:

| RPC | gRPC | HTTP |
|-----|------|------|
| Register | `Register(RegisterRequest) returns (RegisterResponse)` | `POST /v1/auth/register` |
| Login | `Login(LoginRequest) returns (LoginResponse)` | `POST /v1/auth/login` |
| RefreshAccessToken | `RefreshAccessToken(RefreshAccessTokenRequest) returns (RefreshAccessTokenResponse)` | `POST /v1/auth/refresh` |

Notes:

- `AuthResponse` includes authenticated `User` and token data.
- Token shape is transport-level only; token validation rules live in implementation repos.
- For authenticated RPCs across services, user ownership is resolved from auth context (token), not from request payload fields.

## NotezaApplicationService

Purpose: manage user-owned applications and API tokens for machine clients.

RPCs:

| RPC | gRPC | HTTP |
|-----|------|------|
| CreateApplication | `CreateApplication(CreateApplicationRequest) returns (CreateApplicationResponse)` | `POST /v1/applications` |
| ListApplications | `ListApplications(ListApplicationsRequest) returns (ListApplicationsResponse)` | `GET /v1/applications` |
| RegenerateApplicationToken | `RegenerateApplicationToken(RegenerateApplicationTokenRequest) returns (RegenerateApplicationTokenResponse)` | `POST /v1/applications/{application_id}/token` |
| DeleteApplication | `DeleteApplication(DeleteApplicationRequest) returns (DeleteApplicationResponse)` | `DELETE /v1/applications/{application_id}` |

Notes:

- Plain token is returned only on create/regenerate responses.
- Persistent model exposes `token_hint`, not the full token.

## NotezaMediaService

Purpose: image upload and asset lifecycle.

RPCs:

| RPC | gRPC | HTTP |
|-----|------|------|
| ImageUpload | `ImageUpload(ImageUploadRequest) returns (ImageUploadResponse)` | `POST /v1/images` |
| GetImage | `GetImage(GetImageRequest) returns (GetImageResponse)` | `GET /v1/images/{image_id}` |
| ListImages | `ListImages(ListImagesRequest) returns (ListImagesResponse)` | `GET /v1/images` |
| DeleteImage | `DeleteImage(DeleteImageRequest) returns (DeleteImageResponse)` | `DELETE /v1/images/{image_id}` |

Notes:

- `ImageUploadRequest.image_bytes` carries binary image payload in one-step upload flow.
- `ImageUploadRequest.mime_type` is required and `ImageAsset.mime_type` uses the same `ImageMimeType` enum values.
- `ListImages` returns lightweight `ImagePreview` items; use `GetImage` for full `ImageAsset` metadata.
- `ImageAsset` supports lifecycle states (`PENDING`, `READY`, `FAILED`, `DELETED`).

## NotezaWritesService

Purpose: writing-domain operations.

### Series

| RPC | gRPC | HTTP |
|-----|------|------|
| CreateSeries | `CreateSeries(CreateSeriesRequest) returns (CreateSeriesResponse)` | `POST /v1/series` |
| UpdateSeries | `UpdateSeries(UpdateSeriesRequest) returns (UpdateSeriesResponse)` | `PATCH /v1/series/{id}` |
| GetSeries | `GetSeries(GetSeriesRequest) returns (GetSeriesResponse)` | `GET /v1/series/{id}` |
| ListSeries | `ListSeries(ListSeriesRequest) returns (ListSeriesResponse)` | `GET /v1/series` |

### Articles

| RPC | gRPC | HTTP |
|-----|------|------|
| CreateArticle | `CreateArticle(CreateArticleRequest) returns (CreateArticleResponse)` | `POST /v1/articles` |
| UpdateArticle | `UpdateArticle(UpdateArticleRequest) returns (UpdateArticleResponse)` | `PATCH /v1/articles/{article_id}` |
| GetArticle | `GetArticle(GetArticleRequest) returns (GetArticleResponse)` | `GET /v1/articles/{article_id}` |
| ListArticles | `ListArticles(ListArticlesRequest) returns (ListArticlesResponse)` | `GET /v1/articles` |

Notes:

- `Article` stores all content inline with a `version` counter; there is no separate version snapshot type.
- `Article` includes ownership and parent linkage fields: `user_id` and `series_id`.
- `CreateArticleRequest` and `ListArticlesRequest` accept optional `series_id` for series-scoped behavior.
- `GetArticleRequest.version` is optional. When provided, the server returns the article at that specific version.
- `ListArticles` returns `ArticlePreview` items, not full `Article` objects.

### Posts

| RPC | gRPC | HTTP |
|-----|------|------|
| CreatePost | `CreatePost(CreatePostRequest) returns (CreatePostResponse)` | `POST /v1/posts` |
| UpdatePost | `UpdatePost(UpdatePostRequest) returns (UpdatePostResponse)` | `PATCH /v1/posts/{post_id}` |
| GetPost | `GetPost(GetPostRequest) returns (GetPostResponse)` | `GET /v1/posts/{post_id}` |
| ListPosts | `ListPosts(ListPostsRequest) returns (ListPostsResponse)` | `GET /v1/posts` |

Notes:

- `Post` stores all content inline with a `version` counter; there is no separate version snapshot type.
- `Post` includes `user_id`, `series_id`, and a `body` oneof (`note`, `ArticlePreview`, or `ImageGallery`).
- `CreatePostRequest` includes optional `series_id` to assign the new post to a series at creation time.
- `CreatePostRequest` uses `body` oneof:
  - `note` creates a text-only post body.
  - `article.article_id` links the post to an existing article.
  - `images.image_ids` creates an image-based post body.
- `UpdatePostRequest.images.add_image_ids` and `UpdatePostRequest.images.remove_image_ids` update an image-based post body.
- Image updates are valid only for posts whose current `Post.body` is `images` (`ImageGallery`); otherwise server should return `FAILED_PRECONDITION`.
- `ListPostsRequest` includes optional `series_id` to scope list results to a specific series.
- `GetPostRequest.version` is optional. When provided, the server returns the post at that specific version.

## NotezaEventsService

Purpose: real-time event stream for writing-domain changes.

RPCs:

| RPC | gRPC | HTTP |
|-----|------|------|
| StreamEvents | `StreamEvents(StreamEventsRequest) returns (stream StreamEventsResponse)` | no canonical REST mapping |

Notes:

- `StreamEvents` is server-streaming RPC and emits `EventEnvelope` messages.
- Event payload is typed via `oneof` preview objects (`SeriesPreview`, `ArticlePreview`, `PostPreview`, `ImagePreview`).
- WebSocket/SSE exposure is implementation-specific in gateway/BFF; Buf generation does not create WS reverse-proxy automatically.
