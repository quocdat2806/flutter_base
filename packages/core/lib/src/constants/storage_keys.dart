/// Keys for the JSON cache (`CacheStore` / `JsonCache`).
///
/// Format: `<feature>.<name>[.<id>]`, so a whole feature can be dropped with
/// `invalidatePrefix('<feature>.')`. Data that does not belong to the user
/// starts with [publicPrefix] and survives logout; everything else is wiped.
abstract final class CacheKeys {
  static const publicPrefix = 'public.';

  static const userMe = 'user.me';
  static const appointmentList = 'appointment.list';
  static String prescription(String id) => 'prescription.$id';

  static const doctorList = '${publicPrefix}doctor.list';
}

/// How long cached data stays fresh (`ttl`) and when it must be dropped
/// (`maxAge`). Health data is never kept longer than [sensitiveMaxAge].
abstract final class CacheTtl {
  static const sensitive = Duration(minutes: 5);
  static const sensitiveMaxAge = Duration(hours: 12);

  static const publicList = Duration(hours: 6);
  static const publicMaxAge = Duration(days: 7);

  /// Hard limit for private files (PDF, images that need a token).
  static const privateFilesMaxAge = Duration(hours: 24);
}

/// SharedPreferences keys (settings and flags only, never JSON blobs).
abstract final class PrefKeys {
  static const themeMode = 'theme_mode';
  static const language = 'language';
  static const onboardingDone = 'onboarding_done';

  /// Id of the user whose data is currently cached.
  static const cacheOwner = 'cache.owner';

  /// Epoch ms of the last wipe of private files.
  static const privateFilesClearedAt = 'cache.private_files_cleared_at';
}

/// Secure storage keys.
abstract final class SecureKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const deviceId = 'device_id';
}
