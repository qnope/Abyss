import 'dart:async';

class SaveManager {
  Timer? _autoSaveTimer;
  DateTime? _lastSaveTime;

  DateTime? get lastSaveTime => _lastSaveTime;

  void startAutoSave({Duration interval = const Duration(seconds: 30)}) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(interval, (_) => saveNow());
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  Future<void> saveNow() async {
    // Will integrate with GameDatabase when wired up
    _lastSaveTime = DateTime.now();
  }
}
