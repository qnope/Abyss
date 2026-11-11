class_name DigestRows
extends RefCounted
## lib/domain/reference/digest_rows.dart: the digests of a game, turn after
## turn, written without repeating a digest that did not change: a section
## whose digest is the one of the row before is written SAME.

## Stands for "the digest this section had in the row before".
const SAME := "="


static func compact(rows: Array[PackedStringArray]) -> Array[PackedStringArray]:
	var compacted: Array[PackedStringArray] = []
	for r: int in rows.size():
		var row := PackedStringArray()
		for i: int in rows[r].size():
			row.append(SAME if r > 0 and rows[r][i] == rows[r - 1][i] else rows[r][i])
		compacted.append(row)
	return compacted


static func expand(rows: Array[PackedStringArray]) -> Array[PackedStringArray]:
	var full: Array[PackedStringArray] = []
	for row: PackedStringArray in rows:
		var expanded := PackedStringArray()
		for i: int in row.size():
			expanded.append(full[full.size() - 1][i] if row[i] == SAME else row[i])
		full.append(expanded)
	return full
