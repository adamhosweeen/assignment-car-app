// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationThread {

 Conversation get conversation; Message? get lastMessage; int get unreadCount;
/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationThreadCopyWith<ConversationThread> get copyWith => _$ConversationThreadCopyWithImpl<ConversationThread>(this as ConversationThread, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationThread&&(identical(other.conversation, conversation) || other.conversation == conversation)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,lastMessage,unreadCount);

@override
String toString() {
  return 'ConversationThread(conversation: $conversation, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ConversationThreadCopyWith<$Res>  {
  factory $ConversationThreadCopyWith(ConversationThread value, $Res Function(ConversationThread) _then) = _$ConversationThreadCopyWithImpl;
@useResult
$Res call({
 Conversation conversation, Message? lastMessage, int unreadCount
});


$ConversationCopyWith<$Res> get conversation;$MessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$ConversationThreadCopyWithImpl<$Res>
    implements $ConversationThreadCopyWith<$Res> {
  _$ConversationThreadCopyWithImpl(this._self, this._then);

  final ConversationThread _self;
  final $Res Function(ConversationThread) _then;

/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversation = null,Object? lastMessage = freezed,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as Message?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res> get conversation {
  
  return $ConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationThread].
extension ConversationThreadPatterns on ConversationThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationThread value)  $default,){
final _that = this;
switch (_that) {
case _ConversationThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationThread value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conversation conversation,  Message? lastMessage,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationThread() when $default != null:
return $default(_that.conversation,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conversation conversation,  Message? lastMessage,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _ConversationThread():
return $default(_that.conversation,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conversation conversation,  Message? lastMessage,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _ConversationThread() when $default != null:
return $default(_that.conversation,_that.lastMessage,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationThread implements ConversationThread {
  const _ConversationThread({required this.conversation, this.lastMessage, this.unreadCount = 0});
  

@override final  Conversation conversation;
@override final  Message? lastMessage;
@override@JsonKey() final  int unreadCount;

/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationThreadCopyWith<_ConversationThread> get copyWith => __$ConversationThreadCopyWithImpl<_ConversationThread>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationThread&&(identical(other.conversation, conversation) || other.conversation == conversation)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,lastMessage,unreadCount);

@override
String toString() {
  return 'ConversationThread(conversation: $conversation, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationThreadCopyWith<$Res> implements $ConversationThreadCopyWith<$Res> {
  factory _$ConversationThreadCopyWith(_ConversationThread value, $Res Function(_ConversationThread) _then) = __$ConversationThreadCopyWithImpl;
@override @useResult
$Res call({
 Conversation conversation, Message? lastMessage, int unreadCount
});


@override $ConversationCopyWith<$Res> get conversation;@override $MessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$ConversationThreadCopyWithImpl<$Res>
    implements _$ConversationThreadCopyWith<$Res> {
  __$ConversationThreadCopyWithImpl(this._self, this._then);

  final _ConversationThread _self;
  final $Res Function(_ConversationThread) _then;

/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversation = null,Object? lastMessage = freezed,Object? unreadCount = null,}) {
  return _then(_ConversationThread(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as Message?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res> get conversation {
  
  return $ConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}/// Create a copy of ConversationThread
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}

// dart format on
