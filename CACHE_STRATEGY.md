# Cache Strategy

## Tổng quan

App sử dụng **4 package, 5 tầng cache** cho các nhu cầu khác nhau.

> Thiết kế chi tiết và lý do từng quyết định:
> [docs/superpowers/specs/2026-11-27-cache-layer-design.md](docs/superpowers/specs/2026-11-27-cache-layer-design.md).
>
> Nguyên tắc chung:
> - Backend đã cache bằng Redis, nên cache phía app chỉ để hiển thị nhanh và dùng khi offline. Không dùng HTTP cache (`dio_cache_interceptor`); cache nằm ở tầng repository.
> - Dữ liệu sức khoẻ là dữ liệu nhạy cảm (Nghị định 13/2023), nên **không lưu lâu**: tối đa 12 giờ với JSON, 24 giờ với file, và xoá khi logout.

```
┌──────────────────────────────────────────────────────────┐
│                        APP                               │
├──────────────┬───────────────────────────┬───────────────┤
│ SecureStorage│      sqflite              │   FileCache   │
│  (tokens,    ├──────────────┬────────────┤  (PDF, image, │
│   secrets)   │  cache table │   tables   │   audio)      │
│              │  (JSON/KV)   │  (query)   │               │
│              ├──────────────┴────────────┤               │
│              │      SharedPreferences    │               │
│              │  (settings, flags)        │               │
└──────────────┴───────────────────────────┴───────────────┘

Packages:
  flutter_secure_storage   → tầng 1
  shared_preferences       → tầng 2
  sqflite                  → tầng 3 (cache) + tầng 4 (query)
  flutter_cache_manager    → tầng 5
```

---

## Tầng 1 — SecureStorage

**Package:** `flutter_secure_storage`
**Dùng cho:** Dữ liệu nhạy cảm, mã hoá bởi Keychain (iOS) / Keystore (Android)

### Lưu gì

| Key | Type | Mô tả |
|-----|------|-------|
| `access_token` | String | JWT access token |
| `refresh_token` | String | JWT refresh token |
| `user_pin` | String | PIN đăng nhập nhanh |
| `device_id` | String | Định danh thiết bị |

### TTL

```
Không expire tự động.
Xoá khi: logout, uninstall (Android).
iOS: Keychain giữ lại sau uninstall → phải clear khi fresh install.
```

```dart
// iOS: clear keychain nếu fresh install
await secureStorage.clearIfFreshInstall(prefs);
```

---

## Tầng 2 — SharedPreferences

**Package:** `shared_preferences`
**Dùng cho:** Settings, flags, giá trị primitive nhỏ

### Lưu gì

| Key | Type | TTL | Mô tả |
|-----|------|-----|-------|
| `theme_mode` | String | Permanent | light / dark / system |
| `language` | String | Permanent | vi / en / ja |
| `onboarding_done` | bool | Permanent | Đã xem tutorial chưa |
| `first_launch` | bool | Permanent | Lần đầu mở app |
| `fcm_token` | String | Until refresh | Push notification token |
| `notification_enabled` | bool | Permanent | Bật/tắt thông báo |
| `app_version` | String | Permanent | Detect app update |
| `unread_count` | int | Until read | Badge count |
| `search_history` | List\<String\> | 30 ngày | Lịch sử tìm kiếm |

### Giới hạn

```
✅ String, bool, int, double, List<String>
❌ Object phức tạp → dùng sqflite cache table
❌ File lớn        → dùng FileCache
❌ Cần query       → dùng sqflite table
```

---

## Tầng 3 — sqflite cache table (thay Hive)

**Package:** `sqflite` (web: `MemoryCacheStore`, chỉ trong RAM)
**Dùng cho:** response JSON của API, cần TTL, không cần query phức tạp

### Schema

```sql
CREATE TABLE cache (
  key        TEXT PRIMARY KEY,
  value      TEXT NOT NULL,     -- JSON string
  saved_at   INTEGER NOT NULL,  -- epoch ms, dùng để tính "còn mới"
  expires_at INTEGER            -- epoch ms, hạn cứng; NULL = không có
);
CREATE INDEX idx_cache_expires ON cache(expires_at);
```

Bảng được tạo trong `openAppDatabase()` (`packages/storage/lib/src/app_database.dart`).

### Hai mốc thời gian: `ttl` và `maxAge`

| | Ý nghĩa | Hết hạn thì |
|---|---|---|
| `ttl` | Bao lâu thì dữ liệu còn **mới** | Gọi lại API. Nếu mất mạng thì vẫn hiển thị bản cache |
| `maxAge` | Hạn **cứng**, lưu ở cột `expires_at` | Coi như không có cache, kể cả khi offline |

- Khi đọc, dòng đã quá `expires_at` sẽ bị bỏ qua nhưng **không bị xoá**. Việc dọn do `purgeExpired()` làm, chạy lúc mở app và lúc app quay lại foreground (`SessionCacheGuard`).
- Giá trị không decode được (vd. đổi schema model) thì bị xoá và coi như cache miss.

### Policy

| `CachePolicy` | Hành vi |
|---|---|
| `networkFirst` (mặc định) | Gọi API trước. Chỉ khi lỗi mạng, timeout hoặc 5xx mới dùng cache |
| `cacheFirst` | Trả cache nếu còn trong `ttl`. Hết `ttl` thì gọi API, lỗi mạng thì dùng bản cũ |
| `networkOnly` | Luôn gọi API, sau đó ghi cache |
| `cacheOnly` | Chỉ đọc cache. Không có thì ném lỗi |

Lỗi 401/403/4xx **không bao giờ** được che bằng dữ liệu cache.

### Lưu gì

| Key | Policy | `ttl` | `maxAge` | Còn lại sau logout |
|-----|--------|-------|----------|--------------------|
| `user.me` | networkFirst | 5 phút | 12 giờ | ❌ |
| `appointment.list` | networkFirst | 5 phút | 12 giờ | ❌ |
| `prescription.{id}` | networkFirst | 5 phút | 12 giờ | ❌ |
| `public.doctor.list` | cacheFirst | 6 giờ | 7 ngày | ✅ |

Quy tắc chung:
- **Dữ liệu sức khoẻ / của user:** `CacheTtl.sensitive` (5 phút) và `CacheTtl.sensitiveMaxAge` (12 giờ).
- **Dữ liệu public:** `CacheTtl.publicList` (6 giờ) và `CacheTtl.publicMaxAge` (7 ngày). Key phải bắt đầu bằng `public.`.

> Các key cũ như `products`, `cart_items`, `wishlist`… chưa có trong code. Khi thêm, đặt tên theo quy tắc ở [Keys](#keys--tập-trung-1-chỗ) và chọn TTL theo hai nhóm trên.

### Cách dùng (trong repository)

```dart
Future<User> getMe({CachePolicy policy = CachePolicy.networkFirst}) =>
    _cache.fetch(
      key: CacheKeys.userMe,
      fetch: _api.getMe,
      encode: (u) => u.toJson(),
      decode: (j) => User.fromJson(j! as Json),
      policy: policy,
      ttl: CacheTtl.sensitive,
      maxAge: CacheTtl.sensitiveMaxAge,
    );
```

Khi tự ghi cache ngoài `fetch()`, phải lấy `session` **trước** khi gọi API rồi truyền vào `write`. Nhờ vậy, response về muộn sau khi user đã logout sẽ không được ghi:

```dart
final session = _cache.session;
final user = await _api.updateMe(body);
await _cache.write(CacheKeys.userMe, user.toJson(),
    maxAge: CacheTtl.sensitiveMaxAge, session: session);
```

---

## Tầng 4 — sqflite tables (thay Isar/Drift)

**Package:** `sqflite` (cùng package với tầng 3)
**Dùng cho:** Cần query, filter, sort, relations, lượng data lớn

### Schema

```sql
-- Messages
CREATE TABLE messages (
  id              TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  content         TEXT NOT NULL,
  sender_id       TEXT NOT NULL,
  type            TEXT NOT NULL,
  created_at      INTEGER NOT NULL,
  is_read         INTEGER DEFAULT 0,
  metadata        TEXT
);
CREATE INDEX idx_messages_conv ON messages(conversation_id, created_at DESC);

-- Notifications
CREATE TABLE notifications (
  id         TEXT PRIMARY KEY,
  type       TEXT NOT NULL,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  payload    TEXT,
  is_read    INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX idx_notif_created ON notifications(created_at DESC);

-- Pending actions (offline sync queue)
CREATE TABLE pending_actions (
  id          TEXT PRIMARY KEY,
  type        TEXT NOT NULL,
  payload     TEXT NOT NULL,
  retry_count INTEGER DEFAULT 0,
  status      TEXT DEFAULT 'pending',
  created_at  INTEGER NOT NULL
);

-- Analytics event queue
CREATE TABLE event_queue (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  params     TEXT,
  is_sent    INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);
```

### Lưu gì

#### Chat

| Table | Query phổ biến | TTL |
|-------|---------------|-----|
| `messages` | filter conversationId, sort time, paginate | Until server delete |
| `conversations` | sort lastMessage.time | Until server delete |

#### Notifications

| Table | Query phổ biến | TTL |
|-------|---------------|-----|
| `notifications` | filter type, isRead, sort createdAt | 90 ngày |

#### Offline Support

| Table | Query phổ biến | TTL |
|-------|---------------|-----|
| `pending_actions` | filter status, retry | Until synced |
| `event_queue` | filter isSent, batch | Until sent |

#### Healthcare (nếu có)

| Table | Query phổ biến | TTL |
|-------|---------------|-----|
| `medical_records` | filter patientId, date range | Chưa làm. Nếu làm: tối đa 12 giờ, xoá khi logout |
| `patient_vitals` | filter type, date range | Chưa làm. Nếu làm: tối đa 12 giờ, xoá khi logout |

> Dữ liệu sức khoẻ không được lưu vĩnh viễn trên máy (xem tầng 3).

### Sync Strategy

```
Local first → hiển thị data local ngay lập tức
Background sync → fetch API trong nền, non-blocking
Update UI → cập nhật nếu có thay đổi
```

```dart
Future<List<Message>> getMessages(String conversationId, int page) async {
  // 1. Trả local ngay
  final local = await _db.getMessages(conversationId, page);
  if (local.isNotEmpty) {
    _syncInBackground(conversationId); // non-blocking
    return local;
  }

  // 2. Local trống → fetch API
  return _fetchAndSave(conversationId, page);
}
```

---

## Tầng 5 — FileCache

**Package:** `flutter_cache_manager` + `cached_network_image`
**Dùng cho:** file binary (PDF, ảnh, audio)

Có hai `CacheManager` riêng, cả hai nằm trong `FileCacheService` (`packages/app_core/lib/src/cache/`). Cả hai tải file qua `DioFileService`, tức là dùng chung Dio và interceptor của app.

| Manager | Dùng cho | `stalePeriod` | Số file tối đa | Token | Sau logout |
|---------|----------|---------------|----------------|-------|------------|
| `public_files` | ảnh bác sĩ, banner | 7 ngày | 300 | Không gửi | Giữ |
| `private_files` | đơn thuốc PDF, hoá đơn, file user upload | 24 giờ (hạn cứng) | 100 | Có | **Xoá** |

- Token chỉ được gắn khi file nằm trên **chính server API** (cùng origin với `apiBaseUri`), để không lộ token sang domain khác.
- `SessionCacheGuard` xoá toàn bộ file riêng tư mỗi 24 giờ (dựa vào `PrefKeys.privateFilesClearedAt`) và khi logout.
- Hiện file vẫn nằm trên server API, link cố định và cần token. Sau này chuyển sang S3 presigned URL (URL đổi mỗi lần) thì truyền `key` ổn định (id file) vào `getFilePath`.

### Cách dùng

```dart
// Ảnh: luôn dùng AppNetworkImage, không dùng CachedNetworkImage trực tiếp
AppNetworkImage(doctor.avatarUrl);
AppNetworkImage(upload.url, private: true);

// PDF / audio player cần đường dẫn file
final path = await fileCache.getFilePath(prescription.pdfUrl, private: true);
```

`AppNetworkImage` lấy `FileCacheService` qua `context.read`, nên cần có `RepositoryProvider<FileCacheService>` ở phía trên trong cây widget.

---

## Quyết định dùng tầng nào

```
Dữ liệu nhạy cảm? (token, PIN)
  YES → SecureStorage
  NO  ↓

Chỉ là flag / setting / số đơn giản?
  YES → SharedPreferences
  NO  ↓

Là file binary? (PDF, image, audio)
  YES → FileCache
  NO  ↓

Cần query / filter / sort / paginate?
  YES → sqflite table (tầng 4)
  NO  → sqflite cache table (tầng 3)
```

---

## Invalidation — khi nào xoá cache

Mọi việc xoá cache tự động đều do `SessionCacheGuard` (`packages/app_core/lib/src/cache/session_cache_guard.dart`) làm.

### Xoá khi logout / hết phiên (`Unauthenticated`)

```dart
Future<void> clearUserData() async {
  _jsonCache.resetSession();                                   // bỏ các write về muộn
  await _store.clear(keepPrefix: CacheKeys.publicPrefix);      // giữ public.*
  await _files.clearPrivate();                                 // xoá file riêng tư
  await _prefs.remove(PrefKeys.cacheOwner);
}
```

- Mỗi bước vẫn chạy dù bước trước lỗi; lỗi được ghi log.
- Token (tầng 1) do auth xoá, không thuộc guard.
- Settings như `theme_mode`, `language` được giữ lại.

### Chống thấy cache của người dùng trước

Sau khi login, **trước khi màn hình nào đọc cache**, gọi `guard.claimFor(userId)`. Nếu cache đang thuộc người khác (vd. lần xoá trước bị lỗi giữa chừng), guard sẽ xoá hết rồi ghi lại owner.

### Xoá định kỳ (lúc mở app và lúc app quay lại foreground)

- `purgeExpired()`: xoá các dòng đã quá `expires_at`.
- File riêng tư cũ hơn 24 giờ bị xoá toàn bộ.

### Xoá theo event (trong repository)

| Event | Cache bị xoá |
|-------|-------------|
| Update profile | `user.me` (ghi đè bằng response mới) |
| Đặt / huỷ lịch khám | `appointment.list` |
| Đổi ngôn ngữ | Không xoá cache, chỉ đổi phần hiển thị |

Xoá cả một feature: `jsonCache.invalidatePrefix('appointment.')`.

---

## Keys — tập trung 1 chỗ

File: `packages/core/lib/src/constants/storage_keys.dart`. File này chia key thành các class riêng cho từng tầng:

```dart
abstract final class CacheKeys {     // tầng 3, format <feature>.<name>[.<id>]
  static const publicPrefix = 'public.';         // còn lại sau logout
  static const userMe = 'user.me';
  static const appointmentList = 'appointment.list';
  static String prescription(String id) => 'prescription.$id';
  static const doctorList = '${publicPrefix}doctor.list';
}

abstract final class CacheTtl { ... }   // ttl / maxAge dùng chung
abstract final class PrefKeys { ... }   // tầng 2 (+ cache.owner, cache.private_files_cleared_at)
abstract final class SecureKeys { ... } // tầng 1
```

Quy tắc đặt key:
- Dùng dấu `.` để có thể xoá theo prefix của cả feature.
- Chỉ dùng tiền tố `public.` cho dữ liệu **không** gắn với user.

---

## Package structure

```
packages/
├── core/                                 ← pure Dart, không import Flutter
│   ├── constants/storage_keys.dart       ← CacheKeys, CacheTtl, PrefKeys, SecureKeys
│   └── interfaces/services/
│       ├── storage_service.dart          ← SharedPrefs + Secure
│       └── cache_store.dart              ← CacheStore, CacheRecord (tầng 3)
│
├── storage/                              ← implementation
│   ├── app_database.dart                 ← openAppDatabase(), tạo bảng cache
│   ├── sqflite_cache_store.dart          ← CacheStore trên sqflite (mobile)
│   └── memory_cache_store.dart           ← CacheStore trong RAM (web, test)
│
├── repositories/
│   └── cache/
│       ├── json_cache.dart               ← JsonCache: TTL, policy, session
│       └── cache_policy.dart
│
└── app_core/
    └── cache/
        ├── file_cache_service.dart       ← public_files / private_files (tầng 5)
        ├── dio_file_service.dart         ← tải file qua Dio, gắn token
        ├── app_network_image.dart        ← widget ảnh dùng chung
        └── session_cache_guard.dart      ← dọn cache: logout, resume, owner
```

`FileCacheService` nằm ở `app_core` chứ không ở `storage`, để `storage` không phải phụ thuộc vào `api_client`.

---

## TTL Reference

```
Không expire   → settings, flags, tokens            (xoá theo event)
5 phút / 12 giờ → dữ liệu user & sức khoẻ           (ttl / maxAge, xoá khi logout)
6 giờ / 7 ngày  → dữ liệu public (danh sách bác sĩ) (ttl / maxAge, giữ sau logout)
24 giờ          → file riêng tư (PDF đơn thuốc, hoá đơn) — hạn cứng
7 ngày          → file public (ảnh bác sĩ, banner)
```

Không có loại dữ liệu sức khoẻ nào được lưu vĩnh viễn trên máy.
