extends StaticBody2D

var can_shoot = true
onready var main = get_node("/root/main")

export var cost = 15
export var attack_force = 2
export var cool_off = 1.0

func _ready():
	get_node("cooloff").set_wait_time(cool_off)

func _on_Area2D_body_enter( body ):
	if body.is_in_group("enemy"):
		if can_shoot:
			can_shoot = false
			var bullet = main.bullet_1.instance()
			bullet.set_pos(get_pos())
			bullet.attack_force = attack_force
			bullet.target = body
			main.add_child(bullet)
			get_node("cooloff").start()


func _on_cooloff_timeout():
	can_shoot = true
