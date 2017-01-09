extends KinematicBody2D

export var health = 25
export var worth = 5

var path = []
var pos = Vector2(0,0)
var current_id = 0
var dead = false

onready var main = get_node("/root/main")

var distance = 0
const SPEED = 3
var direction = 1

func _ready():
	add_to_group("enemy")
	distance = main.TILE_SIZE
	current_id = path[0]
	set_direction()
	set_pos(pos-Vector2(48,0))
	set_fixed_process(true)
	if path[0] != main.PATHWAY[0]:
		path.insert(0,main.PATHWAY[0])
	path.append(main.PATHWAY[1]+1)
	direction = 1
	
func _fixed_process(delta):
	if distance > 0:
		distance -= SPEED
		if direction == 1:
			move(Vector2(SPEED,0))
		elif direction == 2:
			move(Vector2(0,SPEED))
		elif direction == 3:
			move(Vector2(-SPEED,0))
		else:
			move(Vector2(0,-SPEED))
		
	else:
		if path.size() > 1:
			distance = main.TILE_SIZE
			set_direction()
			path.remove(0)
			pos = path[0]
			current_id = path[0]
		else:
			if not dead:
				main.remove_life()
				die()
			
	if health <= 0:
		if not dead:
			die()
			main.update_gold(worth)
			
func set_direction():
	var direction_pre = current_id-path[1]
	if direction_pre == -1:
		direction = 1
	elif direction_pre == -main.MAP_WIDTH:
		direction = 2
	elif direction_pre == 1:
		direction = 3
	else:
		direction = 0

func _on_death_wait_timeout():
	queue_free()
	
func damage(damage):
	health -= damage

func die():
	dead = true
	main.enemies_on_field -= 1
	if main.enemies_on_field == 0:
		main.clear_field()
	set_pos(Vector2(4000,get_pos().y))
	get_node("death_wait").start()