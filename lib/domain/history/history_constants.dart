/// Maximum number of [HistoryEntry] items kept in a player's history.
///
/// When a new entry is added beyond this cap, the oldest entry is dropped
/// (FIFO), keeping only the 100 most recent entries.
const int kHistoryMaxEntries = 100;
