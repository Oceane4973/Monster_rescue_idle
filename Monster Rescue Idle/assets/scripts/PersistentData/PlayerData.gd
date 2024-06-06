extends Node

@export var money: int = 0
@export var money_per_sec: int = 10
@export var prestance: int = 0;
var time_accumulator : float = 0.0  # Accumulateur de temps

var list_Of_Building = [
	Building.new("Clinique", "Parfait pour soigner vos monstres", 200, "res://assets/textures/avatar.png", "res://assets/3d_models/house.glb", 1, 25, -14.644, 3.087, -15.457, 0.75, 200),
	Building.new("Accueil", "Ce lieu permettra de faire afflué les visiteurs", 500, "res://assets/textures/avatar.png", "res://assets/3d_models/house.glb", 0, 150, -14.644, 3.087, -15.457, 0.75, 300)
] :
	set (value):
		var buildings = Building.list_from_json(value)
		list_Of_Building = buildings;

var list_Of_Monsters = [
	Monster.new("slime", "A slimy creature", 50, "res://assets/textures/avatar.png", 1, 2, 15, "res://assets/3d_models/neco_slime.glb"),
	Monster.new("slime", "A slimy creature", 500, "res://assets/textures/avatar.png", 0, 10, 10, "res://assets/3d_models/neco_slime.glb")
] :
	set (value):
		var monsters = Monster.list_from_json(value)
		list_Of_Monsters = monsters;

var points: Dictionary = {};
var zoom: float

func _ready():
	money = 0;
	prestance = 0;

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= 1.0:
		money += money_per_sec
		time_accumulator -= 1.0
	if prestance < 500:
		prestance += 1
	
func get_best_building() -> Building:
	var unlocked_buildings = []
	var affordable_buildings = []
	
	# Filtrer les bâtiments débloqués
	#print("Filtrage des bâtiments débloqués...")
	for building in list_Of_Building:
		if not building.is_bloqued():
			unlocked_buildings.append(building)
	#print("Bâtiments débloqués: ", unlocked_buildings.size())
	
	# Filtrer les bâtiments que l'utilisateur peut acheter
	#print("Filtrage des bâtiments abordables...")
	for building in unlocked_buildings:
		if building.price <= money:
			affordable_buildings.append(building)
	#print("Bâtiments abordables: ", affordable_buildings.size())
	
	# Si aucun bâtiment n'est abordable, retourner le bâtiment débloqué le moins cher
	if affordable_buildings.size() == 0:
		#print("Aucun bâtiment abordable trouvé.")
		var cheapest_building = null
		for building in unlocked_buildings:
			if cheapest_building == null or building.price < cheapest_building.price:
				cheapest_building = building
		#print("Bâtiment débloqué le moins cher: ", cheapest_building)
		return cheapest_building
	
	# Sinon, retourner le bâtiment abordable avec le plus de bénéfices
	var best_building = affordable_buildings[0]
	for building in affordable_buildings:
		if building.benefice > best_building.benefice:
			best_building = building
	
	#print("Meilleur bâtiment: ", best_building)
	return best_building


func save():
	var value = {
		"money": money,
		"prestance": prestance,
		"money_per_sec": money_per_sec,
		"list_Of_Monsters" : Monster.list_to_json(list_Of_Monsters),
		"list_Of_Building" : Building.list_to_json(list_Of_Building)
	}
	return value;

func get_total_number_of_monsters() -> int:
	var total_monsters = 0
	for monster in list_Of_Monsters:
		total_monsters += monster.currentNB
	return total_monsters

func get_possible_total_number_of_monsters() -> int:
	var total_monsters = 0
	for monster in list_Of_Monsters:
		total_monsters += monster.maxNB
	return total_monsters
