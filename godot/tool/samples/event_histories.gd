class_name EventHistories
extends RefCounted
## The history entries each player of event_resolver_digest_test.gd holds
## once its 24 turns are over, as the Dart rules leave them: per game and
## player, the number of entries after each turn, then each entry as
## HistoryDigests.entry writes it.

const EVENTS: Dictionary[String, Dictionary] = {
	"solo-3": {
		"human": [
			"0 0 0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 3",
			"event 9 coldCurrent false false",
			"event 15 storm true false",
			"event 24 caravan false true",
		],
	},
	"hard-11-three": {
		"human": [
			"0 0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 2 4 4 4 4",
			"event 8 caravan false true",
			"event 14 warmCurrent true false",
			"event 21 predators true false",
			"raid 21 V easy/armoured/7/swarm/27 player 6 34>0 r2 true | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:4 |  | ",
		],
		"faction-currentNomads": [
			"0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3",
			"event 8 storm true false",
			"event 16 caravan false false",
			"event 23 survivors false true",
		],
		"faction-murenaHorde": [
			"0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3",
			"event 7 warmCurrent false false",
			"event 13 coldCurrent false false",
			"event 20 survivors true false",
		],
		"faction-wreckPillagers": [
			"0 0 0 0 0 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 4",
			"event 6 warmCurrent false false",
			"event 11 storm true false",
			"event 18 survivors false false",
			"event 24 wreck true false",
		],
	},
	"easy-24-two": {
		"human": [
			"0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 3 3 3 3 3 3 3 4 4",
			"event 5 wreck true false",
			"event 12 warmCurrent false true",
			"event 16 wreck true false",
			"event 23 survivors false false",
		],
		"faction-krakenFaithful": [
			"0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 4 4 4 4 4 4 5",
			"event 7 storm true false",
			"event 13 warmCurrent true false",
			"event 18 predators true false",
			"raid 18 L easy/hunter/6/armoured/4 monster 4 10>8 r0 true |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:2 | harpoonist:6",
			"event 24 storm true false",
		],
		"faction-murenaHorde": [
			"0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3",
			"event 7 storm true false",
			"event 13 coldCurrent false false",
			"event 20 storm true false",
		],
	},
	"normal-7-one": {
		"human": [
			"0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3",
			"event 5 storm true false",
			"event 12 caravan false true",
			"event 20 survivors false true",
		],
		"faction-anglerCult": [
			"0 0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 3 3 3 3 3 4 4",
			"event 7 warmCurrent false true",
			"event 14 survivors false false",
			"event 18 wreck true false",
			"event 23 storm true false",
		],
	},
}
