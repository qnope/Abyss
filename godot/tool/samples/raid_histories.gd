class_name RaidHistories
extends RefCounted
## The history entries each player of raid_resolver_digest_test.gd holds
## once its 24 turns are over, as the Dart rules leave them: per game and
## player, the number of entries after each turn, then each entry as
## RaidDigests.entry writes it.

const RAIDS: Dictionary[String, Dictionary] = {
	"solo-3": {
		"human": [
			"0 0 0 0 0 0 0 0 0 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4",
			"raid 10 V medium/armoured/5/swarm/21 player 9 26>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15 | guardian:2 | guardian:2",
			"raid 12 V easy/swarm/42/hunter/11 player 3 53>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:2 | harpoonist:13 | harpoonist:2,guardian:2 | ",
			"raid 17 L medium/armoured/7/hunter/8 monster 4 15>13 r2 false |  | algae:30,coral:108,ore:57,energy:30 | harpoonist:15,guardian:2 |  | harpoonist:4,guardian:1 | harpoonist:11,guardian:1",
			"raid 22 L medium/armoured/9/swarm/42 monster 2 51>48 r2 false |  | algae:21,coral:75,ore:39,energy:21 | harpoonist:4,guardian:1 |  | harpoonist:2 | harpoonist:2,guardian:1",
		],
	},
	"hard-11-three": {
		"human": [
			"0 0 0 0 0 0 0 0 0 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4",
			"raid 10 V medium/colossus/1/armoured/4 player 9 5>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:4 | harpoonist:15 | guardian:2 | guardian:2",
			"raid 12 V easy/swarm/42/hunter/11 player 4 53>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:2 | harpoonist:8 | harpoonist:2 | harpoonist:5,guardian:2",
			"raid 17 L medium/colossus/1/armoured/7 monster 6 8>8 r2 false |  | algae:30,coral:108,ore:57,energy:30 | harpoonist:10 |  | harpoonist:1 | harpoonist:9",
			"raid 22 L medium/swarm/42/colossus/2 monster 1 44>44 r2 false |  | algae:21,coral:75,ore:39,energy:21 | harpoonist:1 |  |  | harpoonist:1",
		],
		"faction-currentNomads": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 3 3 3 3 3 3 4",
			"raid 10 V easy/armoured/4/hunter/4 player 15 8>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:2 | harpoonist:1 | harpoonist:5",
			"raid 13 L easy/swarm/36/armoured/8 monster 1 44>40 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:3 |  |  | harpoonist:3",
			"raid 18 L medium/hunter/7/colossus/1 monster 0 8>8 r0 false |  | algae:21,coral:63,ore:31,energy:21 |  |  |  | ",
			"raid 24 L medium/colossus/2/armoured/8 monster 0 10>10 r0 false |  | algae:14,coral:44,ore:22,energy:14 |  |  |  | ",
		],
		"faction-murenaHorde": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 3 3 3 3 3 3 4",
			"raid 10 L easy/armoured/4/hunter/4 monster 10 8>4 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:1 | harpoonist:7",
			"raid 13 L easy/hunter/9/swarm/36 monster 1 45>45 r0 false |  | algae:21,coral:63,ore:31,energy:21 | harpoonist:1 |  | harpoonist:1 | ",
			"raid 18 L medium/armoured/6/colossus/1 monster 1 7>7 r0 false |  | algae:14,coral:44,ore:22,energy:14 | harpoonist:1 |  | harpoonist:1 | ",
			"raid 24 L medium/armoured/8/swarm/36 monster 1 44>44 r0 false |  | algae:10,coral:30,ore:15,energy:10 | harpoonist:1 |  |  | harpoonist:1",
		],
		"faction-wreckPillagers": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 2 3 3 3 3 3 4",
			"raid 10 V easy/hunter/4/swarm/15 player 3 19>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:5 | harpoonist:2 | harpoonist:1",
			"raid 13 L easy/swarm/36/hunter/9 monster 1 45>37 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:7 |  |  | harpoonist:7",
			"raid 19 L medium/colossus/1/hunter/6 monster 0 7>7 r0 false |  | algae:21,coral:63,ore:31,energy:21 |  |  |  | ",
			"raid 24 L medium/hunter/9/colossus/2 monster 0 11>11 r0 false |  | algae:14,coral:44,ore:22,energy:14 |  |  |  | ",
		],
	},
	"easy-24-two": {
		"human": [
			"0 0 0 0 0 0 0 0 0 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4",
			"raid 10 V easy/armoured/9/hunter/10 player 9 19>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:4 | harpoonist:15,guardian:1 | guardian:2 | guardian:1",
			"raid 12 V easy/swarm/39/hunter/9 player 3 48>0 r2 false | algae:0,coral:30,ore:20,pearl:0 |  | harpoonist:15,guardian:3 | harpoonist:15,guardian:1 | guardian:1 | guardian:1",
			"raid 17 V medium/hunter/7/colossus/1 player 5 8>0 r2 false | algae:0,coral:30,ore:20,pearl:1 |  | harpoonist:15,guardian:2 | harpoonist:15 | guardian:2 | ",
			"raid 22 L medium/colossus/2/swarm/36 monster 12 38>2 r2 false |  | algae:30,coral:117,ore:63,energy:30 | harpoonist:15,guardian:2 |  | harpoonist:3 | harpoonist:12,guardian:2",
		],
		"faction-krakenFaithful": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 3 3 3 3 3 3 4",
			"raid 10 V easy/swarm/15/hunter/4 player 3 19>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:4 | harpoonist:3 | harpoonist:1",
			"raid 13 L easy/hunter/8/swarm/30 monster 2 38>30 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:7 |  | harpoonist:3 | harpoonist:4",
			"raid 18 L medium/armoured/5/swarm/21 monster 1 26>26 r0 false |  | algae:21,coral:63,ore:31,energy:21 | harpoonist:3 |  |  | harpoonist:3",
			"raid 24 L medium/swarm/30/hunter/8 monster 0 38>38 r0 false |  | algae:14,coral:44,ore:22,energy:14 |  |  |  | ",
		],
		"faction-murenaHorde": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 3 3 3 3 3 3 4",
			"raid 10 V easy/hunter/4/armoured/2 player 6 6>0 r0 false | algae:0,coral:0,ore:0,pearl:0 |  | harpoonist:8 | harpoonist:6 | harpoonist:1 | harpoonist:1",
			"raid 13 L easy/hunter/8/armoured/7 monster 2 15>14 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:7 |  |  | harpoonist:7",
			"raid 18 L easy/hunter/12/armoured/9 monster 0 21>21 r0 false |  | algae:21,coral:63,ore:31,energy:21 |  |  |  | ",
			"raid 24 L medium/armoured/7/hunter/8 monster 0 15>15 r0 false |  | algae:14,coral:44,ore:22,energy:14 |  |  |  | ",
		],
	},
	"normal-7-one": {
		"human": [
			"0 0 0 0 0 0 0 0 0 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4",
			"raid 10 L medium/armoured/5/colossus/1 monster 17 6>1 r2 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:15,guardian:4 |  | harpoonist:5 | harpoonist:10,guardian:4",
			"raid 12 L easy/swarm/42/armoured/9 monster 3 51>33 r2 false |  | algae:21,coral:63,ore:31,energy:21 | harpoonist:5 |  | harpoonist:1 | harpoonist:4",
			"raid 17 L medium/armoured/7/swarm/30 monster 1 37>37 r2 false |  | algae:14,coral:44,ore:22,energy:14 | harpoonist:1 |  |  | harpoonist:1",
			"raid 22 L medium/hunter/11/swarm/39 monster 1 50>50 r2 false |  | algae:10,coral:30,ore:15,energy:10 |  |  |  | ",
		],
		"faction-anglerCult": [
			"0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 2 2 3 3 3 3 3 3 4",
			"raid 10 L easy/armoured/4/hunter/4 monster 5 8>5 r0 false |  | algae:30,coral:90,ore:45,energy:30 | harpoonist:8 |  | harpoonist:2 | harpoonist:6",
			"raid 13 L easy/hunter/8/swarm/33 monster 1 41>41 r0 false |  | algae:21,coral:63,ore:31,energy:21 | harpoonist:2 |  |  | harpoonist:2",
			"raid 18 L medium/swarm/27/colossus/1 monster 0 28>28 r0 false |  | algae:14,coral:44,ore:22,energy:14 |  |  |  | ",
			"raid 24 L medium/armoured/7/swarm/33 monster 0 40>40 r0 false |  | algae:10,coral:30,ore:15,energy:10 |  |  |  | ",
		],
	},
}
