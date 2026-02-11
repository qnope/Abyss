enum MessageCategory {
  critical,
  allies,
  enemies,
  trade,
  diplomacy,
  world,
}

enum MessageType {
  tradeOffer,
  threat,
  peace,
  betrayal,
  helpRequest,
  info,
  victoryGloat,
  apology,
}

class GameMessage {
  final int id;
  final int fromColonyId;
  final int toColonyId;
  final MessageType messageType;
  final String contentTemplateId;
  final Map<String, String> variables;
  final DateTime timestamp;
  final bool isRead;
  final String? responseType;
  final bool isArchived;

  const GameMessage({
    required this.id,
    required this.fromColonyId,
    required this.toColonyId,
    required this.messageType,
    required this.contentTemplateId,
    this.variables = const {},
    required this.timestamp,
    this.isRead = false,
    this.responseType,
    this.isArchived = false,
  });

  GameMessage copyWith({
    int? id,
    int? fromColonyId,
    int? toColonyId,
    MessageType? messageType,
    String? contentTemplateId,
    Map<String, String>? variables,
    DateTime? timestamp,
    bool? isRead,
    String? responseType,
    bool? isArchived,
  }) =>
      GameMessage(
        id: id ?? this.id,
        fromColonyId: fromColonyId ?? this.fromColonyId,
        toColonyId: toColonyId ?? this.toColonyId,
        messageType: messageType ?? this.messageType,
        contentTemplateId: contentTemplateId ?? this.contentTemplateId,
        variables: variables ?? this.variables,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        responseType: responseType ?? this.responseType,
        isArchived: isArchived ?? this.isArchived,
      );
}
