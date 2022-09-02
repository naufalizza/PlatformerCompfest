extends Node2D

signal player_entered()
signal player_exited()

var time = 0.0
var gravity = 981
var shoot_speed = 1000
var player: Node = null

onready var area = get_node("Area2D")
onready var initial_position = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = initial_position
	global_position.x += shoot_speed * cos(global_rotation) * time
	global_position.y += -(shoot_speed * sin(global_rotation) - gravity * time / 2.0) * time

func _on_Area2D_body_entered(body):
	if body == player:
		emit_signal("player_entered")

func _on_Area2D_body_exited(body):
	if body == player:
		emit_signal("player_exited")
