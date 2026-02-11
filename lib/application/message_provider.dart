import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/domain/models/message.dart';

class MessageNotifier extends StateNotifier<List<GameMessage>> {
  MessageNotifier() : super([]);

  void setMessages(List<GameMessage> messages) {
    state = messages;
  }

  void addMessage(GameMessage message) {
    state = [message, ...state];
  }

  void markAsRead(int messageId) {
    state = [
      for (final m in state)
        if (m.id == messageId) m.copyWith(isRead: true) else m,
    ];
  }

  void archiveMessage(int messageId) {
    state = [
      for (final m in state)
        if (m.id == messageId) m.copyWith(isArchived: true) else m,
    ];
  }

  List<GameMessage> filterByCategory(MessageCategory category) {
    return state.where((m) {
      switch (category) {
        case MessageCategory.critical:
          return m.messageType == MessageType.threat || m.messageType == MessageType.helpRequest;
        case MessageCategory.allies:
          return m.messageType == MessageType.info || m.messageType == MessageType.helpRequest;
        case MessageCategory.enemies:
          return m.messageType == MessageType.threat || m.messageType == MessageType.victoryGloat;
        case MessageCategory.trade:
          return m.messageType == MessageType.tradeOffer;
        case MessageCategory.diplomacy:
          return m.messageType == MessageType.peace || m.messageType == MessageType.betrayal;
        case MessageCategory.world:
          return m.messageType == MessageType.info;
      }
    }).toList();
  }

  int get unreadCount => state.where((m) => !m.isRead).length;
}

final messageProvider =
    StateNotifierProvider<MessageNotifier, List<GameMessage>>((ref) {
  return MessageNotifier();
});
