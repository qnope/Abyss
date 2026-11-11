extends UiTestCase
## test/presentation/widgets/game_over/defeat_cause_card_test.dart and the
## statistics card: what the cards of the end-of-game screens say.

const Advice := DefeatAdvice.Value
const Difficulty := MonsterDifficulty.Value
const Family := MonsterFamily.Value

var _wave := MonsterLair.new(Difficulty.EASY, 30, Family.SWARM, Family.HUNTER, 10)


func _card(advice: DefeatAdvice.Value, defenders: Array[int], needed: Variant = null) -> DefeatCauseCard:
	var raids: Array[LostRaid] = []
	for i in defenders.size():
		raids.append(LostRaid.new(10 + i, _wave, defenders[i]))
	return mount(DefeatCauseCard.new(DefeatAnalysis.new(raids, advice, needed)))


func test_the_statistics_card_counts_each_line() -> void:
	var card: GameStatisticsCard = mount(GameStatisticsCard.new(GameStatistics.new(27, 40, 1, 5000, 2, 4)))
	assert_eq(texts(card), PackedStringArray(["Tours joués : 27", "Monstres vaincus : 40", "Bases capturées : 1",
		"Ressources collectées : 5000", "Raids repoussés : 2", "Raids perdus : 4"]))


func test_the_statistics_card_follows_the_language() -> void:
	var card: GameStatisticsCard = mount(GameStatisticsCard.new(GameStatistics.new(27, 40, 1, 5000, 2, 4)))
	use_language("en")
	assert_eq(texts(card)[0], "Turns played: 27")
	assert_eq(texts(card)[5], "Raids lost: 4")
	use_language("es")
	assert_no_raw_keys(card)


func test_the_cause_card_lists_each_raid_against_its_defenders() -> void:
	var card := _card(Advice.MORE_DEFENDERS, [0, 1, 7], 12)
	assert_eq(card.title_label.text, "Ce qui s'est passé")
	var wave := "30 Dents-de-verre et 10 Calmars-chasseurs niv. 1"
	assert_eq(card.raid_labels[0].text, "Tour 10 : %s contre aucun défenseur" % wave)
	assert_eq(card.raid_labels[1].text, "Tour 11 : %s contre 1 défenseur" % wave)
	assert_eq(card.raid_labels[2].text, "Tour 12 : %s contre 7 défenseurs" % wave)


func test_advises_an_army_to_a_base_that_was_empty() -> void:
	assert_eq(_card(Advice.RAISE_AN_ARMY, [0]).advice_label.text,
		"Ta base était vide. Construis la Caserne et recrute des Harponneurs dès qu'un raid est annoncé.")


func test_advises_the_harpoonists_that_would_have_held() -> void:
	assert_eq(_card(Advice.MORE_DEFENDERS, [4], 12).advice_label.text,
		"Contre ton dernier raid, il fallait environ 12 Harponneurs. Tu avais 4 défenseurs.")


func test_says_when_the_wave_was_too_strong_for_any_advice() -> void:
	assert_eq(_card(Advice.MORE_DEFENDERS, [4]).advice_label.text,
		"Ton dernier raid demandait plus de 150 Harponneurs : garde la jauge de bruit plus basse et monte le rempart de la Citadelle.")


func test_advises_the_units_the_families_fear() -> void:
	assert_eq(_card(Advice.COUNTER_THE_FAMILIES, [30], 12).advice_label.text,
		"Tu avais assez de défenseurs, mais pas les bons. Faibles contre : Harponneurs, Gardiens")


func test_advises_the_right_units_without_a_weakness_for_generic_monsters() -> void:
	_wave = MonsterLair.new(Difficulty.EASY, 30)
	assert_eq(_card(Advice.COUNTER_THE_FAMILIES, [30], 12).advice_label.text,
		"Tu avais assez de défenseurs, mais pas les bons.")


func test_the_cause_card_follows_the_language() -> void:
	var card := _card(Advice.MORE_DEFENDERS, [0, 4], 12)
	use_language("en")
	assert_eq(card.title_label.text, "What happened")
	assert_eq(card.raid_labels[0].text, "Turn 10: 30 Glassfangs and 10 Hunter Squids lv. 1 against no defender")
	use_language("es")
	assert_no_raw_keys(card)
