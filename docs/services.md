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

Purpose: image upload lifecycle.

RPCs:

| RPC | gRPC | HTTP |
|-----|------|------|
| CreateImageUpload | `CreateImageUpload(CreateImageUploadRequest) returns (CreateImageUploadResponse)` | `POST /v1/images` |
| GetImage | `GetImage(GetImageRequest) returns (GetImageResponse)` | `GET /v1/images/{image_id}` |
| ListImages | `ListImages(ListImagesRequest) returns (ListImagesResponse)` | `GET /v1/images` |
| FinalizeImageUpload | `FinalizeImageUpload(FinalizeImageUploadRequest) returns (FinalizeImageUploadResponse)` | `POST /v1/images/{image_id}/finalize` |
| DeleteImage | `DeleteImage(DeleteImageRequest) returns (DeleteImageResponse)` | `DELETE /v1/images/{image_id}` |

Notes:

- Upload flow is designed for pre-signed URL usage.
- Binary image bytes are uploaded directly to object storage, not embedded in API messages.
- `ImageAsset` supports lifecycle states (`PENDING`, `READY`, `FAILED`, `DELETED`).
- `ImageUsage` helps constrain how assets are attached (`ARTICLE_COVER`, `ARTICLE_INLINE`, `POST_IMAGE`).

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
| GetArticleVersions | `GetArticleVersions(GetArticleVersionsRequest) returns (GetArticleVersionsResponse)` | `GET /v1/articles/{article_id}/versions` |

Notes:

- `Article` root now includes ownership and parent linkage fields: `user_id` and `series_id`.
- `CreateArticleRequest` and `ListArticlesRequest` accept optional `series_id` for series-scoped behavior.

### Posts

| RPC | gRPC | HTTP |
|-----|------|------|
| CreatePost | `CreatePost(CreatePostRequest) returns (CreatePostResponse)` | `POST /v1/posts` |
| UpdatePost | `UpdatePost(UpdatePostRequest) returns (UpdatePostResponse)` | `PATCH /v1/posts/{post_id}` |
| GetPost | `GetPost(GetPostRequest) returns (GetPostResponse)` | `GET /v1/posts/{post_id}` |
| ListPosts | `ListPosts(ListPostsRequest) returns (ListPostsResponse)` | `GET /v1/posts` |
| GetPostVersions | `GetPostVersions(GetPostVersionsRequest) returns (GetPostVersionsResponse)` | `GET /v1/posts/{post_id}/versions` |

Notes:

- `Post` root includes `series_id` in addition to `user_id`, `id`, `current_version_id`, and `created_at`.
- `CreatePostRequest` includes `series_id` to assign the new post to a series at creation time.
- `ListPostsRequest` includes `series_id` to scope list results to a specific series.

### Context

| RPC | gRPC | HTTP |
|-----|------|------|
| GetWritingContext | `GetWritingContext(GetWritingContextRequest) returns (GetWritingContextResponse)` | `GET /v1/writing-context` |

Notes:

- `GetWritingContextRequest.series_id` is optional. When provided, context is series-scoped.
- `WritingContext` includes both article and post signals (`last_published_*`, `related_*`) for generation workflows.
