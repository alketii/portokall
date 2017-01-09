extends Node2D

const TILE_SIZE = 48
const TILE_OFF = 24
const MAP_WIDTH = 25
const MAP_HEIGHT = 15
const PATHWAY = [175,199]

const tile = preload("res://tile.tscn")
const enemy_1 = preload("res://enemies/enemy_1.tscn")

const tower_1 = preload("res://towers/tower_1.tscn")
const tower_2 = preload("res://towers/tower_2.tscn")

const bullet_1 = preload("res://bullets/bullet_fireball.tscn")

onready var as = AStar.new()
var path = []

var gold = 110
var level = 1
var amount = 0
var count_wave_boost = 0
var enemies_on_field = 0
var can_build = true

var selected_tower = 1
var towers_cost = []

func _ready():
	towers_cost.append(tower_1.instance().cost)
	towers_cost.append(tower_2.instance().cost)
	
	update_gold(0)
	init()
	
func init():
	get_node("point_start").set_pos(id_to_px(PATHWAY[0]))
	get_node("point_end").set_pos(id_to_px(PATHWAY[1]))
	var i = 0
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var tile_new = tile.instance()
			tile_new.set_pos(Vector2(x*TILE_SIZE+TILE_OFF,y*TILE_SIZE+TILE_OFF))
			tile_new.get_node("Label").set_text(str(i))
			tile_new.get_node("button").id = i
			tile_new.get_node("button").x = x
			tile_new.get_node("button").y = y
			tile_new.set_name("tile_"+str(i))
			as.add_point(i,Vector3(x,y,0))
			add_child(tile_new)
			i += 1
			
	i = 0
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			if x != MAP_WIDTH-1:
				as.connect_points(i,i+1)
			as.connect_points(i,i+MAP_WIDTH)
			i += 1
			
	
	path = as.get_id_path(PATHWAY[0],PATHWAY[1])

func id_to_px(id):
	id = int(id)
	var x = id % MAP_WIDTH
	var y = id / MAP_WIDTH
	return Vector2(x*TILE_SIZE+TILE_OFF,y*TILE_SIZE+TILE_OFF)

func disconnect(id):
	as.disconnect_points(id-1,id)
	as.disconnect_points(id,id+1)
	as.disconnect_points(id-MAP_WIDTH,id)
	as.disconnect_points(id,id+MAP_WIDTH)
	path = as.get_id_path(PATHWAY[0],PATHWAY[1])
	if path.size() == 0:
		if not get_node("tile_"+str(id-1)+"/button").busy and get_node("tile_"+str(id)+"/button").x > 0:
			as.connect_points(id-1,id)
		if not get_node("tile_"+str(id+1)+"/button").busy and get_node("tile_"+str(id)+"/button").x < MAP_WIDTH-1:
			as.connect_points(id,id+1)
		if id > MAP_WIDTH:
			if not get_node("tile_"+str(id-MAP_WIDTH)+"/button").busy:
				as.connect_points(id-MAP_WIDTH,id)
		if id < (MAP_WIDTH-2)*MAP_HEIGHT:
			if not get_node("tile_"+str(id+MAP_WIDTH)+"/button").busy:
				as.connect_points(id,id+MAP_WIDTH)
		path = as.get_id_path(PATHWAY[0],PATHWAY[1])
		helper("Tower can not be placed there!")
		return false
	else:
		update_gold(-towers_cost[selected_tower-1])
		return true

func add_tower(id):
	if not get_node("tile_"+str(id)+"/button").busy && disconnect(id):
		var tower
		if selected_tower == 1:
			tower = tower_1.instance()
		if selected_tower == 2:
			tower = tower_2.instance()
		tower.set_pos(id_to_px(id))
		get_node("tile_"+str(id)+"/button").busy = true
		add_child(tower)
		
func remove_life():
	var lifes = int(get_node("hud/lifes").get_text())
	lifes -= 1
	get_node("hud/lifes").set_text(str(lifes))
	if lifes == 0:
		game_over()
		
func game_over():
	print("GAME OVER!!!")

func _on_next_wave_pressed():
	can_build = false
	amount = level
	enemies_on_field = amount
	get_node("hud/next_wave").set_disabled(true)
	get_node("spawn").start()

func _on_spawn_timeout():
	count_wave_boost += 1
	spawn_enemy()
	amount -= 1
	if amount == 0:
		get_node("spawn").stop()
	
func spawn_enemy():
	var enemy = enemy_1.instance()
	enemy.path = path
	enemy.pos = id_to_px(PATHWAY[0])
	enemy.health += count_wave_boost
	add_child(enemy)
	
func helper(txt):
	get_node("hud/helper").set_text(txt)
	get_node("hud/helper").show()
	get_node("helper").start()

func _on_helper_timeout():
	get_node("hud/helper").hide()

func clear_field():
	get_node("hud/next_wave").set_disabled(false)
	level += 1
	helper("Level "+str(level))
	can_build = true
	
func update_gold(amount):
	gold += amount
	get_node("hud/gold").set_text(str(gold))

func _on_tower_1_pressed():
	selected_tower = 1

func _on_tower_2_pressed():
	selected_tower = 2
