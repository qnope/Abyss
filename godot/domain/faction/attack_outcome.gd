class_name AttackOutcome
extends RefCounted
## `AttackOutcome` of lib/domain/faction/faction_attack_report.dart: how an
## attack on the human ended, from the human's side: the base razed, losing
## part of its stocks or not, the post taken, the kernel down one level or
## taken.

enum Value {
	REPELLED,
	DAMAGED,
	PILLAGED,
	POST_TAKEN,
	KERNEL_DAMAGED,
	KERNEL_TAKEN,
}
