extends Node2D

var time = 0.0
var gravity = 981
var speed = 1000
var lifespan = 3.0

onready var x_factor = cos(global_rotation)
onready var y_factor = sin(global_rotation)
onready var initial_position = global_position

func _ready():
	pass # Replace with function body.

func _process(delta):
	time += delta
	
	if time < lifespan:
		# Update position
		global_position = initial_position
		global_position.x += speed * x_factor * time
		global_position.y += -(speed * y_factor - gravity * time / 2.0) * time
	else:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
