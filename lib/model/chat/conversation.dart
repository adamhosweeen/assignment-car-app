import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// A buyer ↔ seller thread about one listing — a row of `conversations`
/// (unique on `listing_id + buyer_id`).
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String listingId,
    required String buyerId,
    required String sellerId,
    required DateTime createdAt,
    DateTime? lastMessageAt,
  }) = _Conversation;

  const Conversation._();

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  /// The participant who isn't [currentUserId] — the person to show in the
  /// thread list / thread header.
  String otherParticipantId(String currentUserId) =>
      currentUserId == buyerId ? sellerId : buyerId;
}
