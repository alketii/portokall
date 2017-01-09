extends TextureButton

onready var main = get_node("/root/main")

var id = 0
var x = 0
var y = 0
var busy = false

func _ready():
	pass

func _on_button_pressed():
	if main.can_build:
		if main.gold >= main.towers_cost[main.selected_tower-1]:
			main.add_tower(id)
		else:
			main.helper("You do not have enough money!")
	else:
		main.helper("You can not build while the enemy is attacking!")