import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// A buyer ↔ seller thread about one listing — a row of `conversations`
/// (V1_SPEC §1; unique on `listing_id + buyer_id`). Model only for now: the
/// Chat tab is a placeholder in v1 and nothing reads this yet.
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

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
