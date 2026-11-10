class_name HistoryConstants
extends RefCounted
## lib/domain/history/history_constants.dart.

## Maximum number of HistoryEntry items kept in a player's history. When a
## new entry is added beyond this cap, the oldest entry is dropped (FIFO),
## keeping only the 100 most recent entries.
const K_HISTORY_MAX_ENTRIES := 100
