// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's inbox, newest first, live over realtime. Empty
/// stream when signed out; re-created when the user changes.

@ProviderFor(inbox)
final inboxProvider = InboxProvider._();

/// The signed-in user's inbox, newest first, live over realtime. Empty
/// stream when signed out; re-created when the user changes.

final class InboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          Stream<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $StreamProvider<List<AppNotification>> {
  /// The signed-in user's inbox, newest first, live over realtime. Empty
  /// stream when signed out; re-created when the user changes.
  InboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotification>> create(Ref ref) {
    return inbox(ref);
  }
}

String _$inboxHash() => r'2cba8a9ba360bd1b172466ad69761a6e5340e50b';

/// Unread count for the hub row and the Profile tab badge (0 while loading).

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Unread count for the hub row and the Profile tab badge (0 while loading).

final class UnreadCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Unread count for the hub row and the Profile tab badge (0 while loading).
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadCountHash() => r'2f42e394acadc47262601ec19b9502e0e886cafa';
