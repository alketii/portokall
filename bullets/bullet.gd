extends KinematicBody2D

var target
var angle
export var attack_force = 2

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	angle = get_pos().angle_to_point(get_parent().get_node(target.get_name()).get_pos() ) + deg2rad(180)
	move(Vector2(0,4).rotated(angle))
	if target.dead:
		queue_free()

func _on_Area2D_body_enter( body ):
	if body == target:
		target.damage(attack_force)
		queue_free()

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
