class_name SiegeHistories
extends RefCounted
## What the scratch Dart script of the digest test of the sieges printed
## (siege_digest_test.gd), on each game: six assaults on the volcanic
## kernel and one refused, the kernel and the first Faille taken, then four
## attacks on the base of the rival.

const DIGESTS: Dictionary[String, Array] = {
	"3": [
		"L- monster 4 31>31 | abyssAdmiral:1,domeBreaker:60 |  | abyssAdmiral:1,domeBreaker:11 | domeBreaker:49 | domeBreaker:11,abyssAdmiral:1 | null n3 h0 -",
		"L- monster 7 31>26 | abyssAdmiral:2,domeBreaker:100 |  | domeBreaker:20 | abyssAdmiral:2,domeBreaker:80 | domeBreaker:20 | null n6 h0 -",
		"VC player 7 31>0 | abyssAdmiral:1,domeBreaker:140,guardian:6 | abyssAdmiral:1,domeBreaker:112 | domeBreaker:17,guardian:4 | domeBreaker:11,guardian:2 | guardian:4,domeBreaker:129,abyssAdmiral:1 | human n9 h1 3 volcanicKernel true",
		"VC player 5 31>0 | abyssAdmiral:2,domeBreaker:180,guardian:9 | abyssAdmiral:2,domeBreaker:171 | domeBreaker:9,guardian:6 | guardian:3 | guardian:6,domeBreaker:180,abyssAdmiral:2 | human n12 h2 4 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:1,domeBreaker:220,guardian:12 | abyssAdmiral:1,domeBreaker:215 | domeBreaker:3,guardian:7 | domeBreaker:2,guardian:5 | guardian:7,domeBreaker:218,abyssAdmiral:1 | human n15 h3 5 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:2,domeBreaker:260,guardian:15 | abyssAdmiral:2,domeBreaker:258 | domeBreaker:1,guardian:15 | domeBreaker:1 | guardian:15,domeBreaker:259,abyssAdmiral:2 | human n18 h4 6 volcanicKernel true",
		"admiralRequired",
		"kernel 1  | 2 null 9",
		"kernel 0 harpoonist:5,guardian:2 | 0 faction-siphonophoreGuild 9",
		"post faille scout:2,harpoonist:4 true | 0 1 true",
		"V 7 | harpoonist:3 | harpoonist:2 | harpoonist:3 | harpoonist:4,guardian:3 |  |  | harpoonist:4,guardian:3 | 0>0 0>1 algae:30,coral:90,ore:45,energy:30 | algae:30,coral:90,ore:45,energy:30 | harpoonist:5 |  | n21 h5 h1",
		"V 4 | harpoonist:14 | guardian:2 |  | harpoonist:5,guardian:4 |  | harpoonist:1 | harpoonist:4,guardian:4 | 1>0 1>1 algae:21,coral:63,ore:31,energy:21 | algae:21,coral:63,ore:31,energy:21 | harpoonist:14,guardian:2 | harpoonist:1 | n24 h6 h2",
		"V 4 | harpoonist:20,guardian:3 | guardian:1 |  | harpoonist:6,guardian:5 |  |  | harpoonist:6,guardian:5 | 2>0 1>1 algae:14,coral:44,ore:22,energy:14 | algae:14,coral:44,ore:22,energy:14 | harpoonist:20,guardian:4 |  | n27 h7 h3",
		"V 4 | harpoonist:26,guardian:6 |  |  | harpoonist:7,guardian:6 |  | harpoonist:2,guardian:2 | harpoonist:5,guardian:4 | 3>1 1>1 algae:10,coral:30,ore:15,energy:10 | algae:10,coral:30,ore:15,energy:10 | harpoonist:26,guardian:6 | harpoonist:2,guardian:2 | n30 h8 h4",
	],
	"11": [
		"L- monster 4 31>31 | abyssAdmiral:1,domeBreaker:60 |  | domeBreaker:9 | abyssAdmiral:1,domeBreaker:51 | domeBreaker:9 | null n3 h0 -",
		"L- monster 7 31>30 | abyssAdmiral:2,domeBreaker:100 |  | abyssAdmiral:1,domeBreaker:15 | abyssAdmiral:1,domeBreaker:85 | domeBreaker:15,abyssAdmiral:1 | null n6 h0 -",
		"VC player 7 31>0 | abyssAdmiral:1,domeBreaker:140,guardian:6 | abyssAdmiral:1,domeBreaker:110 | domeBreaker:26,guardian:6 | domeBreaker:4 | guardian:6,domeBreaker:136,abyssAdmiral:1 | human n9 h1 3 volcanicKernel true",
		"VC player 5 31>0 | abyssAdmiral:2,domeBreaker:180,guardian:9 | abyssAdmiral:2,domeBreaker:161 | domeBreaker:17,guardian:6 | domeBreaker:2,guardian:3 | guardian:6,domeBreaker:178,abyssAdmiral:2 | human n12 h2 4 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:1,domeBreaker:220,guardian:12 | abyssAdmiral:1,domeBreaker:208 | domeBreaker:11,guardian:8 | domeBreaker:1,guardian:4 | guardian:8,domeBreaker:219,abyssAdmiral:1 | human n15 h3 5 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:2,domeBreaker:260,guardian:15 | abyssAdmiral:2,domeBreaker:255 | domeBreaker:4,guardian:15 | domeBreaker:1 | guardian:15,domeBreaker:259,abyssAdmiral:2 | human n18 h4 6 volcanicKernel true",
		"admiralRequired",
		"kernel 1  | 2 null 9",
		"kernel 0 harpoonist:5,guardian:2 | 0 faction-currentNomads 9",
		"post faille scout:2,harpoonist:4 true | 0 1 true",
		"V 7 | harpoonist:5 |  | harpoonist:3 | harpoonist:4,guardian:3 |  | harpoonist:1,guardian:1 | harpoonist:3,guardian:2 | 0>0 0>1 algae:30,coral:90,ore:45,energy:30 | algae:30,coral:90,ore:45,energy:30 | harpoonist:5 | harpoonist:1,guardian:1 | n21 h5 h1",
		"V 5 | harpoonist:14 | guardian:1 | guardian:1 | harpoonist:5,guardian:4 |  | guardian:1 | harpoonist:5,guardian:3 | 1>0 1>1 algae:21,coral:63,ore:31,energy:21 | algae:21,coral:63,ore:31,energy:21 | harpoonist:14,guardian:1 | guardian:1 | n24 h6 h2",
		"V 4 | harpoonist:20,guardian:2 | guardian:2 |  | harpoonist:6,guardian:5 |  | guardian:1 | harpoonist:6,guardian:4 | 2>0 1>1 algae:14,coral:44,ore:22,energy:14 | algae:14,coral:44,ore:22,energy:14 | harpoonist:20,guardian:4 | guardian:1 | n27 h7 h3",
		"V 4 | harpoonist:26,guardian:6 |  |  | harpoonist:7,guardian:6 |  | guardian:1 | harpoonist:7,guardian:5 | 3>1 1>1 algae:10,coral:30,ore:15,energy:10 | algae:10,coral:30,ore:15,energy:10 | harpoonist:26,guardian:6 | guardian:1 | n30 h8 h4",
	],
	"24": [
		"L- monster 4 31>31 | abyssAdmiral:1,domeBreaker:60 |  | domeBreaker:16 | abyssAdmiral:1,domeBreaker:44 | domeBreaker:16 | null n3 h0 -",
		"L- monster 7 31>29 | abyssAdmiral:2,domeBreaker:100 |  | domeBreaker:21 | abyssAdmiral:2,domeBreaker:79 | domeBreaker:21 | null n6 h0 -",
		"VC player 7 31>0 | abyssAdmiral:1,domeBreaker:140,guardian:6 | abyssAdmiral:1,domeBreaker:110 | domeBreaker:24,guardian:5 | domeBreaker:6,guardian:1 | guardian:5,domeBreaker:134,abyssAdmiral:1 | human n9 h1 3 volcanicKernel true",
		"VC player 5 31>0 | abyssAdmiral:2,domeBreaker:180,guardian:9 | abyssAdmiral:2,domeBreaker:169 | domeBreaker:10,guardian:7 | domeBreaker:1,guardian:2 | guardian:7,domeBreaker:179,abyssAdmiral:2 | human n12 h2 4 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:1,domeBreaker:220,guardian:12 | abyssAdmiral:1,domeBreaker:212 | domeBreaker:8,guardian:10 | guardian:2 | guardian:10,domeBreaker:220,abyssAdmiral:1 | human n15 h3 5 volcanicKernel true",
		"VC player 4 31>0 | abyssAdmiral:2,domeBreaker:260,guardian:15 | abyssAdmiral:2,domeBreaker:257 | domeBreaker:2,guardian:10 | domeBreaker:1,guardian:5 | guardian:10,domeBreaker:259,abyssAdmiral:2 | human n18 h4 6 volcanicKernel true",
		"admiralRequired",
		"kernel 1  | 2 null 9",
		"kernel 0 harpoonist:5,guardian:2 | 0 faction-krakenFaithful 9",
		"post faille scout:2,harpoonist:4 true | 0 1 true",
		"V 6 | harpoonist:5 |  | harpoonist:3 | harpoonist:4,guardian:3 |  | guardian:1 | harpoonist:4,guardian:2 | 0>0 0>1 algae:30,coral:90,ore:45,energy:30 | algae:30,coral:90,ore:45,energy:30 | harpoonist:5 | guardian:1 | n21 h5 h1",
		"V 4 | harpoonist:14 | guardian:2 |  | harpoonist:5,guardian:4 |  | guardian:1 | harpoonist:5,guardian:3 | 1>0 1>1 algae:21,coral:63,ore:31,energy:21 | algae:21,coral:63,ore:31,energy:21 | harpoonist:14,guardian:2 | guardian:1 | n24 h6 h2",
		"V 4 | harpoonist:20,guardian:3 | guardian:1 |  | harpoonist:6,guardian:5 |  | harpoonist:3,guardian:1 | harpoonist:3,guardian:4 | 2>0 1>1 algae:14,coral:44,ore:22,energy:14 | algae:14,coral:44,ore:22,energy:14 | harpoonist:20,guardian:4 | harpoonist:3,guardian:1 | n27 h7 h3",
		"V 4 | harpoonist:26,guardian:5 | guardian:1 |  | harpoonist:7,guardian:6 |  | guardian:2 | harpoonist:7,guardian:4 | 3>1 1>1 algae:10,coral:30,ore:15,energy:10 | algae:10,coral:30,ore:15,energy:10 | harpoonist:26,guardian:6 | guardian:2 | n30 h8 h4",
	],
}
