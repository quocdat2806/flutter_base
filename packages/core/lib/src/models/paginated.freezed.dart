// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Paginated<T> {

 List<T> get items;/// 1-based page index.
 int get page; int get pageSize;/// Total items on the server, when the API exposes it.
 int? get total;/// Set when the API says explicitly whether more pages exist; otherwise
/// [hasMore] is derived from [total] or the page size.
@JsonKey(name: 'hasMore') bool? get knownHasMore;
/// Create a copy of Paginated
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedCopyWith<T, Paginated<T>> get copyWith => _$PaginatedCopyWithImpl<T, Paginated<T>>(this as Paginated<T>, _$identity);

  /// Serializes this Paginated to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as Paginated<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Paginated<T>&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.knownHasMore, _this.knownHasMore) || other.knownHasMore == _this.knownHasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Paginated<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.page,_this.pageSize,_this.total,_this.knownHasMore);
}

@override
String toString() {
  final _this = this as Paginated<T>;
  return 'Paginated<$T>(items: ${_this.items}, page: ${_this.page}, pageSize: ${_this.pageSize}, total: ${_this.total}, knownHasMore: ${_this.knownHasMore})';
}


}

/// @nodoc
abstract mixin class $PaginatedCopyWith<T,$Res>  {
  factory $PaginatedCopyWith(Paginated<T> value, $Res Function(Paginated<T>) _then) = _$PaginatedCopyWithImpl;
@useResult
$Res call({
 List<T> items, int page, int pageSize, int? total,@JsonKey(name: 'hasMore') bool? knownHasMore
});




}
/// @nodoc
class _$PaginatedCopyWithImpl<T,$Res>
    implements $PaginatedCopyWith<T, $Res> {
  _$PaginatedCopyWithImpl(this._self, this._then);

  final Paginated<T> _self;
  final $Res Function(Paginated<T>) _then;

/// Create a copy of Paginated
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? total = freezed,Object? knownHasMore = freezed,}) {
  return _then(Paginated(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,knownHasMore: freezed == knownHasMore ? _self.knownHasMore : knownHasMore // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [Paginated].
extension PaginatedPatterns<T> on Paginated<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Paginated<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Paginated() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Paginated<T> value)  $default,){
final _that = this;
switch (_that) {
case _Paginated():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Paginated<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Paginated() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  int page,  int pageSize,  int? total, @JsonKey(name: 'hasMore')  bool? knownHasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Paginated() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.knownHasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  int page,  int pageSize,  int? total, @JsonKey(name: 'hasMore')  bool? knownHasMore)  $default,) {final _that = this;
switch (_that) {
case _Paginated():
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.knownHasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  int page,  int pageSize,  int? total, @JsonKey(name: 'hasMore')  bool? knownHasMore)?  $default,) {final _that = this;
switch (_that) {
case _Paginated() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.knownHasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _Paginated<T> extends Paginated<T> {
  const _Paginated({required  List<T> items, required this.page, required this.pageSize, this.total, @JsonKey(name: 'hasMore') this.knownHasMore}): _items = items,super._();
  factory _Paginated.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$PaginatedFromJson(json,fromJsonT);

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// 1-based page index.
@override final  int page;
@override final  int pageSize;
/// Total items on the server, when the API exposes it.
@override final  int? total;
/// Set when the API says explicitly whether more pages exist; otherwise
/// [hasMore] is derived from [total] or the page size.
@override@JsonKey(name: 'hasMore') final  bool? knownHasMore;

/// Create a copy of Paginated
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedCopyWith<T, _Paginated<T>> get copyWith => __$PaginatedCopyWithImpl<T, _Paginated<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$PaginatedToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Paginated<T>&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.total, total) || other.total == total)&&(identical(other.knownHasMore, knownHasMore) || other.knownHasMore == knownHasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,total,knownHasMore);
}

@override
String toString() {
    return 'Paginated<$T>(items: $items, page: $page, pageSize: $pageSize, total: $total, knownHasMore: $knownHasMore)';
}


}

/// @nodoc
abstract mixin class _$PaginatedCopyWith<T,$Res> implements $PaginatedCopyWith<T, $Res> {
  factory _$PaginatedCopyWith(_Paginated<T> value, $Res Function(_Paginated<T>) _then) = __$PaginatedCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, int page, int pageSize, int? total,@JsonKey(name: 'hasMore') bool? knownHasMore
});




}
/// @nodoc
class __$PaginatedCopyWithImpl<T,$Res>
    implements _$PaginatedCopyWith<T, $Res> {
  __$PaginatedCopyWithImpl(this._self, this._then);

  final _Paginated<T> _self;
  final $Res Function(_Paginated<T>) _then;

/// Create a copy of Paginated
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? total = freezed,Object? knownHasMore = freezed,}) {
  return _then(_Paginated<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,knownHasMore: freezed == knownHasMore ? _self.knownHasMore : knownHasMore // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
