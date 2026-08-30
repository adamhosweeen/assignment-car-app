import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';

void main() {
  group('Conversation', () {
    final c = Conversation(
      id: 'c1',
      listingId: 'l1',
      buyerId: 'buyer',
      sellerId: 'seller',
      createdAt: DateTime.utc(2026, 8, 30, 9),
    );

    test(
      'otherParticipantId returns the seller for the buyer and vice versa',
      () {
        expect(c.otherParticipantId('buyer'), 'seller');
        expect(c.otherParticipantId('seller'), 'buyer');
      },
    );

    test('round-trips through JSON with a null last_message_at', () {
      final json = c.toJson();
      expect(json['listing_id'], 'l1');
      expect(json['buyer_id'], 'buyer');
      expect(json['last_message_at'], isNull);
      expect(Conversation.fromJson(json), c);
    });
  });

  group('Message', () {
    test('isMine follows sender_id', () {
      final m = Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'buyer',
        body: 'Hi, still available?',
        createdAt: DateTime.utc(2026, 8, 30, 9),
      );
      expect(m.isMine('buyer'), isTrue);
      expect(m.isMine('seller'), isFalse);
    });

    test('round-trips a text message through JSON', () {
      final m = Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'buyer',
        body: 'Hi, still available?',
        createdAt: DateTime.utc(2026, 8, 30, 9),
      );
      final json = m.toJson();
      expect(json['conversation_id'], 'c1');
      expect(json['message_type'], 'text');
      expect(json['offer_amount_myr'], isNull);
      expect(Message.fromJson(json), m);
    });

    test('round-trips an offer message through JSON', () {
      final m = Message(
        id: 'm2',
        conversationId: 'c1',
        senderId: 'buyer',
        body: 'Would you take RM40,000?',
        messageType: MessageType.offer,
        offerAmountMyr: 40000,
        createdAt: DateTime.utc(2026, 8, 30, 9),
      );
      final json = m.toJson();
      expect(json['message_type'], 'offer');
      expect(json['offer_amount_myr'], 40000);
      final back = Message.fromJson(json);
      expect(back, m);
      expect(back.messageType, MessageType.offer);
    });
  });
}
