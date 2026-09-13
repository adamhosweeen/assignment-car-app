// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's threads, most recent activity first, live over
/// realtime. Empty stream when signed out; re-created when the user changes.

@ProviderFor(conversations)
final conversationsProvider = ConversationsProvider._();

/// The signed-in user's threads, most recent activity first, live over
/// realtime. Empty stream when signed out; re-created when the user changes.

final class ConversationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationThread>>,
          List<ConversationThread>,
          Stream<List<ConversationThread>>
        >
    with
        $FutureModifier<List<ConversationThread>>,
        $StreamProvider<List<ConversationThread>> {
  /// The signed-in user's threads, most recent activity first, live over
  /// realtime. Empty stream when signed out; re-created when the user changes.
  ConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsHash();

  @$internal
  @override
  $StreamProviderElement<List<ConversationThread>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConversationThread>> create(Ref ref) {
    return conversations(ref);
  }
}

String _$conversationsHash() => r'8cc90716cc65bb9bb47f8fb82d36c12d8cb20e20';

/// Messages in one thread, oldest first, live over realtime.

@ProviderFor(messages)
final messagesProvider = MessagesFamily._();

/// Messages in one thread, oldest first, live over realtime.

final class MessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          Stream<List<Message>>
        >
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Messages in one thread, oldest first, live over realtime.
  MessagesProvider._({
    required MessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as String;
    return messages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'5cc289a4522d409c76625bfbb6e72c14455d63a2';

/// Messages in one thread, oldest first, live over realtime.

final class MessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Message>>, String> {
  MessagesFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Messages in one thread, oldest first, live over realtime.

  MessagesProvider call(String conversationId) =>
      MessagesProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'messagesProvider';
}

/// One conversation by id — rebuilds the thread screen when it wasn't
/// reached with the [Conversation] already in hand (route `extra` doesn't
/// survive Android killing and restoring the app process).

@ProviderFor(conversationById)
final conversationByIdProvider = ConversationByIdFamily._();

/// One conversation by id — rebuilds the thread screen when it wasn't
/// reached with the [Conversation] already in hand (route `extra` doesn't
/// survive Android killing and restoring the app process).

final class ConversationByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Conversation>,
          Conversation,
          FutureOr<Conversation>
        >
    with $FutureModifier<Conversation>, $FutureProvider<Conversation> {
  /// One conversation by id — rebuilds the thread screen when it wasn't
  /// reached with the [Conversation] already in hand (route `extra` doesn't
  /// survive Android killing and restoring the app process).
  ConversationByIdProvider._({
    required ConversationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationByIdHash();

  @override
  String toString() {
    return r'conversationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Conversation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Conversation> create(Ref ref) {
    final argument = this.argument as String;
    return conversationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationByIdHash() => r'34e6297ee20514e0b98300ee121f310b200265ff';

/// One conversation by id — rebuilds the thread screen when it wasn't
/// reached with the [Conversation] already in hand (route `extra` doesn't
/// survive Android killing and restoring the app process).

final class ConversationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Conversation>, String> {
  ConversationByIdFamily._()
    : super(
        retry: null,
        name: r'conversationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One conversation by id — rebuilds the thread screen when it wasn't
  /// reached with the [Conversation] already in hand (route `extra` doesn't
  /// survive Android killing and restoring the app process).

  ConversationByIdProvider call(String id) =>
      ConversationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'conversationByIdProvider';
}

/// Total unread messages across every thread, for the Chat tab badge.

@ProviderFor(unreadChatCount)
final unreadChatCountProvider = UnreadChatCountProvider._();

/// Total unread messages across every thread, for the Chat tab badge.

final class UnreadChatCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Total unread messages across every thread, for the Chat tab badge.
  UnreadChatCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadChatCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadChatCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadChatCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadChatCountHash() => r'd3e3a1718fd50bc1ad63e699feb7d3c948fe0f4d';
