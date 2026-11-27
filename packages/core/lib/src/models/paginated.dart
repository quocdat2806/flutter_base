import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated.freezed.dart';
part 'paginated.g.dart';

/// One page of a paginated collection.
///
/// `==`, `hashCode`, `toString`, `copyWith` and JSON come from Freezed /
/// json_serializable. [items] is unmodifiable.
///
/// ```dart
/// final page = Paginated<User>.fromJson(
///   json,
///   (e) => User.fromJson(e! as Map<String, dynamic>),
/// );
/// ```
@Freezed(genericArgumentFactories: true)
abstract class Paginated<T> with _$Paginated<T> {
  const factory Paginated({
    required List<T> items,

    /// 1-based page index.
    required int page,
    required int pageSize,

    /// Total items on the server, when the API exposes it.
    int? total,

    /// Set when the API says explicitly whether more pages exist; otherwise
    /// [hasMore] is derived from [total] or the page size.
    @JsonKey(name: 'hasMore') bool? knownHasMore,
  }) = _Paginated<T>;

  const Paginated._();

  factory Paginated.empty({int pageSize = 20}) => Paginated(
    items: const [],
    page: 1,
    pageSize: pageSize,
    total: 0,
    knownHasMore: false,
  );

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedFromJson(json, fromJsonT);

  bool get hasMore =>
      knownHasMore ??
      (total != null ? page * pageSize < total! : items.length >= pageSize);

  int get nextPage => page + 1;

  Paginated<R> map<R>(R Function(T item) transform) => Paginated(
    items: items.map(transform).toList(growable: false),
    page: page,
    pageSize: pageSize,
    total: total,
    knownHasMore: knownHasMore,
  );

  /// Appends [next] to this page – for infinite scrolling.
  Paginated<T> merge(Paginated<T> next) => Paginated(
    items: [...items, ...next.items],
    page: next.page,
    pageSize: next.pageSize,
    total: next.total ?? total,
    knownHasMore: next.knownHasMore,
  );
}
