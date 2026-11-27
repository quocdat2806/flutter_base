/// How a repository read combines cache and network.
enum CachePolicy {
  /// Return fresh cache if any, otherwise fetch.
  cacheFirst,

  /// Always fetch; on network failure fall back to (even stale) cache.
  networkFirst,

  /// Always fetch, never read cache (still writes it).
  networkOnly,

  /// Never hit the network.
  cacheOnly,
}
