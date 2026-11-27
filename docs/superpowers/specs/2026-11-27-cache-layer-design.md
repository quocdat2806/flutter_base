# Thiết kế tầng cache (client)

Ngày: 2026-11-27 · Phạm vi: `packages/core`, `packages/storage`, `packages/repositories`, `packages/app_core`

## 1. Mục đích

App y tế (`patient`, `customer_support`) cần:

- Mở màn hình nhanh và vẫn xem được dữ liệu vừa tải khi mạng chập chờn.
- Ảnh và PDF không phải tải lại mỗi lần mở.
- **Không** để lộ dữ liệu y tế: không lưu lâu trên máy, user sau không bao giờ thấy dữ liệu của user trước.

Backend chỉ trả JSON, không có `ETag` / `Cache-Control`. Redis ở server không giúp gì khi app mất mạng hoặc chạy trên 4G chậm, nên app cần cache riêng.

## 2. Mục tiêu / không làm / tuyệt đối tránh

**Mục tiêu**
- Một chỗ duy nhất cache JSON: `JsonCache`, đổi backend từ SharedPreferences sang bảng `cache` trong sqflite.
- Một service cho file (ảnh, PDF, audio) dùng chung với `cached_network_image`; file cần đăng nhập được tải qua Dio để có token.
- Logout xoá sạch mọi thứ thuộc về user.
- Dữ liệu y tế chỉ cache ngắn hạn.

**Không làm (lần này)**
- `dio_cache_interceptor`: gỡ khỏi `pubspec.yaml` ở root.
- Mã hoá DB (SQLCipher).
- Các bảng query ở "tầng 4" của CACHE_STRATEGY.md (`messages`, `notifications`, `pending_actions`, `event_queue`): để thành dự án riêng. Thiết kế này chỉ chừa sẵn DB dùng chung để thêm sau.
- Bảng lưu vĩnh viễn `medical_records`, `patient_vitals`: bỏ hẳn.
- Các key e-commerce trong md (products, cart, banners, payment_methods, wishlist…).

**Tuyệt đối tránh**
- User B thấy dữ liệu của user A (kể cả khi lần logout trước bị lỗi giữa chừng).
- Gửi access token tới host khác API (CDN, S3, link ảnh bên ngoài).
- Xoá dữ liệu cũ ngay khi hết hạn khiến chế độ `networkFirst` mất dữ liệu dự phòng lúc offline.
- Coi dữ liệu nháp của user (giỏ, đơn nháp, hàng đợi offline) là cache rồi xoá nhầm.

## 3. Ràng buộc

- `core` là Dart thuần: không Flutter, không plugin. Interface đặt ở `core`, implementation ở `storage`.
- Có bản web của `customer_support` (phụ, auth vẫn Bearer token). Web không có sqflite.
- Dữ liệu sức khoẻ là dữ liệu cá nhân nhạy cảm (Nghị định 13/2023).
- **Lỗi compile (user chốt: bỏ qua lần này):** `api_client`, `auth`, `app_core`, `analytics`, `repositories` đều đang dùng `AppException` / `Result` / `NoopLogger` không có trong `core`. Code cache viết theo các kiểu đang được dùng, sửa lỗi compile là việc riêng.
- **Ghi chú cũ:** `packages/repositories` hiện **không compile** (27 lỗi analyzer). `JsonCache` / `BaseRepository` dùng `AppException`, `Result`, `Success`, `NoopLogger`, `StorageException`, `NetworkException`… nhưng `core` hiện chỉ có hệ `Failure`. Phải thống nhất lại kiểu lỗi trước, hoặc trong bước đầu tiên của kế hoạch. Thiết kế này không quyết định chọn hệ nào; chỉ yêu cầu `JsonCache` biết được "lỗi do mất mạng / server 5xx" để quyết định có trả cache cũ hay không.

## 4. Các phương án đã cân nhắc

| | Cách | Được | Mất |
|---|---|---|---|
| **A (đã chọn)** | Cache ở tầng repository: `JsonCache` → `CacheStore` → bảng `cache` sqflite. File qua `FileCacheService` + Dio. | Gần như không phải sửa repository; key có nghĩa nên xoá theo sự kiện dễ; kiểm soát việc xoá theo user. | Mỗi repository tự khai báo key, TTL, encode/decode (code hiện đã làm vậy). |
| B | Cache ở tầng HTTP bằng `dio_cache_interceptor` (forceCache + maxStale), bỏ `JsonCache`. | Repository không biết có cache. | Key là URL băm, khó xoá sau POST/PATCH; phải tính thứ tự với auth/retry interceptor; không có store sqflite sẵn; mặc định không tách theo user. Không có ETag nên mất ưu điểm chính. |
| C | Cả A và B (interceptor chỉ cache RAM ~30s). | Gộp request trùng. | Hai nơi cache, khó gỡ lỗi; lợi ích nhỏ. |

User chọn **A**. Về dữ liệu y tế, user chọn **không lưu lâu** (không mã hoá DB).

## 5. Thiết kế

### 5.1 Tổng thể

```
Repository ──► JsonCache (repositories) ──► CacheStore (core, interface)
                                               ├─ SqfliteCacheStore (storage) — mobile/desktop
                                               └─ MemoryCacheStore  (storage) — web + test

UI ──► AppNetworkImage / PDF viewer ──► FileCacheService (storage)
                                          ├─ publicFiles  : CacheManager (không gửi token)
                                          └─ privateFiles : CacheManager (Dio có token, xoá khi logout)

AuthManager.status ──► SessionCacheGuard (app_core) ──► xoá cache khi logout / đổi user
```

Các tầng còn lại giữ như hiện tại:
- `SecureStorageService`: chỉ token (và `device_id` nếu cần). **Không** lưu PIN dạng chữ. Nếu có PIN thì lưu hash; việc này ngoài phạm vi.
- `SharedPreferencesStorageService`: chỉ settings và cờ (theme, language, onboarding…), không còn chứa JSON cache.

### 5.2 `CacheStore` (core)

File `core/lib/src/interfaces/services/cache_store.dart`, export từ `core.dart`.

```dart
final class CacheRecord {
  final String value;        // JSON đã encode
  final DateTime savedAt;
  final DateTime? expiresAt; // hạn xoá cứng; null = đến khi logout
}

abstract interface class CacheStore {
  Future<CacheRecord?> read(String key);
  Future<void> write(String key, String value, {Duration? maxAge});
  Future<void> remove(String key);
  Future<void> removeWhere({required String prefix}); // vd. 'appointment.'
  /// Xoá mọi key, trừ các key bắt đầu bằng [keepPrefix] (vd. 'public.').
  Future<void> clear({String? keepPrefix});
  /// Xoá các dòng đã quá expiresAt. Trả số dòng đã xoá.
  Future<int> purgeExpired();
}
```

- `read` **không** tự xoá khi quá hạn. Quyết định tươi hay cũ là việc của `JsonCache`; xoá cứng là việc của `purgeExpired`.
- Nhưng `read` **phải trả `null`** nếu `expiresAt` đã qua, để dữ liệu y tế quá hạn không bao giờ bị hiển thị, kể cả khi chưa kịp purge.
- Lỗi backend → `CacheFailure` (dùng `guardStorage` sẵn có).

### 5.3 `SqfliteCacheStore` và DB dùng chung (storage)

- Một file DB `app.db`, mở bằng `SqfliteDatabaseService.open` có version và migration. Các bảng tầng 4 sau này thêm vào chính DB này bằng migration mới.
- Migration v1:

```sql
CREATE TABLE cache (
  key        TEXT PRIMARY KEY,
  value      TEXT NOT NULL,
  saved_at   INTEGER NOT NULL,   -- epoch ms
  expires_at INTEGER              -- epoch ms, NULL = đến khi logout
);
CREATE INDEX idx_cache_expires ON cache(expires_at);
```

- `write` dùng `ConflictStrategy.replace`.
- `removeWhere(prefix)` dùng `DELETE FROM cache WHERE key LIKE ? ESCAPE '\'` (escape `%` và `_` trong prefix).
- `clear()` chỉ xoá bảng `cache`, **không** xoá file DB (để sau này các bảng dữ liệu nháp hay hàng đợi offline có chính sách riêng).
- Nhận `DateTime Function() clock` để test.

`MemoryCacheStore`: `Map` trong RAM, cùng ngữ nghĩa. Dùng cho web và cho test ở các package không có sqflite_ffi.

### 5.4 `JsonCache` (repositories)

Giữ API công khai hiện tại (`read`, `write`, `invalidate`, `fetch` với `CachePolicy`), chỉ đổi:

- Constructor nhận `CacheStore` thay cho `StorageService`.
- Bỏ lớp bọc `{savedAt, data}`: `savedAt` lấy từ `CacheRecord`.
- `write` / `fetch` nhận thêm `maxAge` (hạn xoá cứng). `ttl` vẫn là ngưỡng "tươi".
- Thêm `invalidatePrefix(String prefix)` gọi `removeWhere`.
- `CacheEntry` giữ `savedAt` để UI hiển thị "Cập nhật lúc HH:mm" khi đang dùng dữ liệu cũ lúc offline.
- Logic fallback offline giữ nguyên ý: chỉ trả cache khi lỗi mạng, timeout hoặc 5xx; không bao giờ che lỗi 401 hay lỗi validate.
- **Chặn ghi muộn sau logout:** `JsonCache` giữ một số đếm phiên `int _generation`. Mỗi `fetch` ghi nhớ giá trị lúc bắt đầu; khi response về, nếu số đếm đã đổi thì **không ghi** vào cache (vẫn trả kết quả cho caller). `SessionCacheGuard` gọi `jsonCache.resetSession()` (tăng số đếm) **trước** khi `clear()`. Như vậy request của user A bắt đầu trước logout không thể ghi lại dữ liệu sau khi đã xoá. *(Quyết định của thiết kế, sau builder check.)*

### 5.5 Key và TTL

`core/lib/src/constants/storage_keys.dart` (đang rỗng) chứa **chỉ các key đang thật sự dùng**, theo nhóm:

```dart
abstract final class CacheKeys {
  static const userMe = 'user.me';
  static const appointmentList = 'appointment.list';
  static const doctorList = 'public.doctor.list';
  static String prescription(String id) => 'prescription.$id';
  // thêm key khi viết repository mới
}

abstract final class PrefKeys { themeMode, language, onboardingDone, … }
abstract final class SecureKeys { accessToken, refreshToken, deviceId }
```

Quy ước key: `<feature>.<tên>[.<id>]`, để `invalidatePrefix('<feature>.')` xoá được cả nhóm. Dữ liệu công khai, không gắn với user (danh sách bác sĩ, chuyên khoa…), có thêm tiền tố `public.` (vd. `public.doctor.list`) để giữ lại khi logout. Mọi key khác coi là của user. *(Quyết định của thiết kế, sau builder check.)*

Bảng TTL (ttl = còn tươi; maxAge = xoá cứng):

| Dữ liệu | ttl | maxAge | Ghi chú |
|---|---|---|---|
| Danh sách bác sĩ, chuyên khoa (công khai) | 6 giờ | 7 ngày | không nhạy cảm |
| Hồ sơ user (`user.me`) | 10 phút | đến logout | đang dùng 10 phút trong code |
| Lịch hẹn | 5 phút | **12 giờ** | nhạy cảm |
| Đơn thuốc, kết quả khám, chỉ số sức khoẻ | 5 phút | **12 giờ** | nhạy cảm; md cũ là 30 ngày / vĩnh viễn → bỏ |

Con số 12 giờ là đề xuất của thiết kế (đủ để xem lại trong ngày khi mất mạng). Có thể chỉnh trong một hằng số `CacheTtl.sensitiveMaxAge`.

### 5.6 `FileCacheService` (storage)

```dart
final class FileCacheService {
  FileCacheService({required Dio dio, required Uri apiBaseUri});
  BaseCacheManager get publicFiles;   // ảnh bác sĩ, banner, icon
  BaseCacheManager get privateFiles;  // ảnh chat, PDF đơn thuốc/hoá đơn, audio
  Future<File> getFile(String url, {bool private = false});
  Future<void> clearPrivate();        // gọi khi logout
}
```

- Hai `CacheManager` với `Config` riêng:
  - public: `stalePeriod` 7 ngày, `maxNrOfCacheObjects` 300.
  - private: `stalePeriod` **1 ngày**, `maxNrOfCacheObjects` 100.

  `flutter_cache_manager` giới hạn theo số file, không theo MB; bảng MB trong md cũ bỏ.
- **Hạn 1 ngày của private là hạn cứng.** `stalePeriod` của `flutter_cache_manager` tính từ lần mở gần nhất và chỉ dọn thỉnh thoảng, nên file mở hằng ngày sẽ không bao giờ bị xoá. Vì vậy `SessionCacheGuard` lưu `PrefKeys.privateFilesClearedAt`; khi khởi động và khi app trở lại foreground, nếu quá 24 giờ thì gọi `clearPrivate()` rồi ghi lại mốc. *(Quyết định của thiết kế, sau builder check.)*
- Mỗi manager dùng một `FileService` tự viết (`DioFileService`) tải qua `ApiClient.dio`, để đi qua auth/retry/refresh có sẵn.
- **Gửi token theo host:** `DioFileService` đặt `extra[ApiExtra.requiresAuth] = true` **chỉ khi** là private manager **và** host của URL trùng host của API. Mọi trường hợp khác là `false`. Lý do: `AuthInterceptor` hiện gắn token cho mọi request có `requiresAuth` (mặc định là true), bất kể host.
- **Nơi lưu file (user chốt):** hiện tại file riêng tư nằm trên chính server API, link cố định, cần token. Chat chưa có ảnh. Sau này khoảng 90% sẽ chuyển sang S3; khi đó cần key cache theo id file thay vì URL (`getFile(url, key:)` đã chừa sẵn tham số `key`).
- `FileCacheService` đặt ở `app_core` (không phải `storage`) để dùng trực tiếp `ApiExtra` của `api_client`, tránh để `storage` phụ thuộc `api_client`.
- `cached_network_image`: widget `AppNetworkImage(url, {bool private = false})` đặt trong `app_core`, truyền `cacheManager` tương ứng. Màn hình không dùng `CachedNetworkImage` trực tiếp.
- Web: `cached_network_image` dựa vào cache trình duyệt; `FileCacheService` trên web chỉ cần không crash (không có PDF offline trên web).

### 5.7 Dọn dữ liệu: logout, đổi user, khởi động

`SessionCacheGuard` trong `app_core`, được tạo ở bootstrap:

1. **Khởi động:** `cacheStore.purgeExpired()`. Lỗi thì log, không chặn app.
2. **Logout / hết phiên:** khi `AuthManager.status` chuyển sang `Unauthenticated`:
   - `jsonCache.resetSession()` (chặn ghi muộn, xem 5.4)
   - `cacheStore.clear(keepPrefix: 'public.')`
   - `fileCache.clearPrivate()`
   - `prefs.remove(...)` các key gắn với user (nếu có, vd. `unread_count`)
   - Giữ theme, language, public files.
3. **Chặn lộ dữ liệu khi lần dọn trước bị lỗi:** lưu `PrefKeys.cacheOwner` = id user đang sở hữu cache.
   - Khi `Authenticated` và lấy được id user, nếu khác `cacheOwner` thì chạy lại bước 2 trước khi màn hình nào đọc cache, rồi ghi `cacheOwner` mới.
   - `Authenticated` hiện **không** mang userId. Người làm chọn cách lấy id: claim `sub` trong JWT, hoặc gọi `user.me` với `networkOnly` ngay sau login, hoặc thêm userId vào `Authenticated`.
4. **Chuyển dữ liệu cũ:** một lần, xoá các key prefs có namespace `cache.` mà `JsonCache` cũ đã ghi.

### 5.8 Cấu hình DI

`storage_module.dart` / `network_module.dart` đang comment toàn bộ. Cần đăng ký: `DatabaseService` (app.db), `CacheStore` (sqflite hoặc memory theo `kIsWeb`), `JsonCache`, `FileCacheService`, `SessionCacheGuard`. Cách viết module do người làm quyết định, theo khung DI có sẵn.

### 5.9 Tài liệu

Sửa `CACHE_STRATEGY.md` cho khớp thiết kế này:
- bỏ e-commerce, tầng vĩnh viễn cho dữ liệu y tế, PIN dạng chữ;
- sửa "3 package, 4 tầng";
- ghi rõ logout xoá private files;
- ghi rõ không dùng `dio_cache_interceptor`.

## 6. Kiểm thử

- `SqfliteCacheStore`: test bằng `sqflite_common_ffi` (đã có trong dev deps của `storage`).
  - Ghi/đọc; ghi đè.
  - `read` trả null khi quá `expiresAt`.
  - `purgeExpired` chỉ xoá dòng quá hạn.
  - `removeWhere` với prefix chứa `_` / `%`.
  - `clear`.
- `JsonCache`: với `MemoryCacheStore` và clock giả, test cả 4 `CachePolicy`:
  - offline → trả cache cũ;
  - 401 → không trả cache;
  - quá maxAge → không có cache.
- `DioFileService`: token chỉ được gắn khi private **và** đúng host API (dùng `HttpClientAdapter` giả).
- `SessionCacheGuard`:
  - Unauthenticated → đã gọi clear và clearPrivate;
  - đăng nhập user khác `cacheOwner` → xoá trước khi đọc.

## 7. Để người làm tự quyết

- Thống nhất hệ kiểu lỗi (`Failure` vs `AppException`/`Result`) để `repositories` compile (bắt buộc, làm trước).
- Đặt `ApiExtra` ở đâu để `storage` dùng được mà không phụ thuộc `api_client`.
- Cách lấy userId cho `cacheOwner`.
- Cách viết DI module.
- Con số cụ thể của TTL ngoài bảng ở 5.5, khi thêm repository mới.
