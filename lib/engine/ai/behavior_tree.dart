enum NodeResult { success, failure, running }

abstract class Node {
  NodeResult tick(Map<String, dynamic> context);
}

class Sequence extends Node {
  final List<Node> children;
  Sequence(this.children);

  @override
  NodeResult tick(Map<String, dynamic> context) {
    for (final child in children) {
      final result = child.tick(context);
      if (result == NodeResult.failure) return NodeResult.failure;
      if (result == NodeResult.running) return NodeResult.running;
    }
    return NodeResult.success;
  }
}

class Selector extends Node {
  final List<Node> children;
  Selector(this.children);

  @override
  NodeResult tick(Map<String, dynamic> context) {
    for (final child in children) {
      final result = child.tick(context);
      if (result == NodeResult.success) return NodeResult.success;
      if (result == NodeResult.running) return NodeResult.running;
    }
    return NodeResult.failure;
  }
}

class Condition extends Node {
  final bool Function(Map<String, dynamic> context) condition;
  Condition(this.condition);

  @override
  NodeResult tick(Map<String, dynamic> context) {
    return condition(context) ? NodeResult.success : NodeResult.failure;
  }
}

class ActionNode extends Node {
  final NodeResult Function(Map<String, dynamic> context) action;
  ActionNode(this.action);

  @override
  NodeResult tick(Map<String, dynamic> context) {
    return action(context);
  }
}

class Inverter extends Node {
  final Node child;
  Inverter(this.child);

  @override
  NodeResult tick(Map<String, dynamic> context) {
    final result = child.tick(context);
    if (result == NodeResult.success) return NodeResult.failure;
    if (result == NodeResult.failure) return NodeResult.success;
    return NodeResult.running;
  }
}

class Repeater extends Node {
  final Node child;
  final int maxRepeats;
  Repeater(this.child, {this.maxRepeats = -1});

  @override
  NodeResult tick(Map<String, dynamic> context) {
    int count = 0;
    while (maxRepeats < 0 || count < maxRepeats) {
      final result = child.tick(context);
      if (result == NodeResult.failure) return NodeResult.failure;
      if (result == NodeResult.running) return NodeResult.running;
      count++;
    }
    return NodeResult.success;
  }
}
