class_name VolcanoHistories
extends RefCounted
## The history entries each player of volcano_resolver_digest_test.gd
## holds once its 12 turns are over, as the Dart rules leave them: per game
## and player, the number of entries after each turn, then each entry as
## RaidDigests.entry writes it.

const VOLCANO: Dictionary[String, Dictionary] = {
	"solo-5": {
		"human": [
			"0 1 1 2 3 4 5 6 7 9 10 12",
			"volcano 2 V hard/kraken/3/null/0 player 2 3>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 4 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:12,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | guardian:1",
			"volcano 5 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | ",
			"volcano 6 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | ",
			"volcano 7 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:11,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | ",
			"volcano 8 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:11,domeBreaker:20 | guardian:9,domeBreaker:20 | guardian:2 | ",
			"volcano 9 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:9,domeBreaker:19 | guardian:2,domeBreaker:1 | ",
			"raid 10 V medium/swarm/24/hunter/5 player 3 29>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:2 | guardian:2 | ",
			"volcano 10 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | ",
			"volcano 11 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:11,domeBreaker:20 | guardian:11,domeBreaker:20 |  | ",
			"raid 12 V medium/hunter/6/colossus/1 player 4 7>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:3 | guardian:1 | ",
			"volcano 12 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:9,domeBreaker:20 | guardian:1 | guardian:1",
		],
	},
	"hard-11-three": {
		"human": [
			"0 1 1 2 3 4 5 6 7 9 10 12",
			"volcano 2 V hard/kraken/3/null/0 player 2 3>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 4 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 5 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:12,domeBreaker:20 | guardian:10,domeBreaker:20 | guardian:1 | guardian:1",
			"volcano 6 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:11,domeBreaker:20 |  | ",
			"volcano 7 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:11,domeBreaker:20 |  | ",
			"volcano 8 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:11,domeBreaker:20 |  | ",
			"volcano 9 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:20 | guardian:11,domeBreaker:19 |  | domeBreaker:1",
			"raid 10 V medium/swarm/24/hunter/5 player 3 29>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:3 | guardian:1 | ",
			"volcano 10 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:11,domeBreaker:19 | guardian:9,domeBreaker:19 | guardian:1 | guardian:1",
			"volcano 11 V hard/kraken/5/null/0 player 4 5>0 k3 | guardian:10,domeBreaker:19 | guardian:8,domeBreaker:19 | guardian:2 | ",
			"raid 12 V medium/colossus/1/swarm/21 player 4 22>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:4 |  | ",
			"volcano 12 V hard/kraken/5/null/0 player 3 5>0 k3 | guardian:10,domeBreaker:19 | guardian:7,domeBreaker:19 | guardian:3 | ",
		],
		"faction-currentNomads": [
			"0 1 2 2 2 2 2 2 2 3 3 3",
			"volcano 2 L hard/kraken/2/null/0 monster 7 2>2 k2 | guardian:4 |  | guardian:1 | guardian:3",
			"volcano 3 L hard/kraken/2/null/0 monster 3 2>2 k1 | guardian:1 |  |  | guardian:1",
			"raid 10 L easy/armoured/4/hunter/4 monster 10 8>4 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:1 | harpoonist:7",
		],
		"faction-murenaHorde": [
			"0 1 2 2 2 2 2 2 2 3 3 3",
			"volcano 2 L hard/kraken/2/null/0 monster 9 2>2 k2 | guardian:4 |  |  | guardian:4",
			"volcano 3 L hard/kraken/2/null/0 monster 3 2>2 k1 |  |  |  | ",
			"raid 10 L easy/armoured/4/hunter/4 monster 5 8>5 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:1 | harpoonist:7",
		],
		"faction-wreckPillagers": [
			"0 1 2 2 2 2 2 2 2 3 3 3",
			"volcano 2 L hard/kraken/2/null/0 monster 8 2>2 k2 | guardian:4 |  | guardian:1 | guardian:3",
			"volcano 3 L hard/kraken/2/null/0 monster 3 2>2 k1 | guardian:1 |  |  | guardian:1",
			"raid 10 V easy/swarm/18/armoured/3 player 6 21>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:8 |  | ",
		],
	},
	"easy-24-two": {
		"human": [
			"0 1 1 2 3 4 5 6 7 9 10 12",
			"volcano 2 V hard/kraken/2/null/0 player 2 2>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 4 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 5 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 6 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 7 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:11,domeBreaker:20 | guardian:1 | ",
			"volcano 8 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:11,domeBreaker:20 | guardian:1 | ",
			"volcano 9 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"raid 10 V easy/hunter/10/swarm/39 player 3 49>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:2 |  | guardian:2",
			"volcano 10 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"volcano 11 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
			"raid 12 V easy/hunter/9/armoured/8 player 10 17>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:2 | harpoonist:12 | harpoonist:2 | harpoonist:1,guardian:2",
			"volcano 12 V hard/kraken/4/null/0 player 3 4>0 k3 | guardian:12,domeBreaker:20 | guardian:12,domeBreaker:20 |  | ",
		],
		"faction-krakenFaithful": [
			"0 1 2 2 2 2 2 2 2 3 3 3",
			"volcano 2 L hard/kraken/1/null/0 monster 16 1>1 k2 | guardian:4 |  | guardian:1 | guardian:3",
			"volcano 3 L hard/kraken/1/null/0 monster 5 1>1 k1 | guardian:1 |  |  | guardian:1",
			"raid 10 L easy/armoured/3/hunter/4 monster 13 7>2 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:1 | harpoonist:7",
		],
		"faction-murenaHorde": [
			"0 1 2 2 2 2 2 2 2 3 3 3",
			"volcano 2 L hard/kraken/1/null/0 monster 16 1>1 k2 | guardian:4 |  |  | guardian:4",
			"volcano 3 L hard/kraken/1/null/0 monster 5 1>1 k1 |  |  |  | ",
			"raid 10 V easy/swarm/15/hunter/3 player 2 18>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:6 | harpoonist:2 | ",
		],
	},
}
