extends Node2D

signal player_entered(angle_degrees)
signal player_exited(angle_degrees)

const sensor_scene = preload("res://scenes/PlayerSensor.tscn")

var max_trace_seconds = 2.0
var sensor_count = 25
var gravity = 981
var shoot_speed = 750

var player = null
var sensor_list = []
var detect_count = 0

onready var trace_interval = max_trace_seconds / sensor_count

func _ready():
	for i in range(1, sensor_count + 1):
		var time = i * trace_interval
		if is_not_go_up(time) or true:
			var sensor = sensor_scene.instance()
			sensor.time = time
			sensor.gravity = gravity
			sensor.shoot_speed = shoot_speed
			sensor.player = player
			
			sensor.connect("player_entered", self, "_on_PlayerSensor_player_entered")
			sensor.connect("player_exited", self, "_on_PlayerSensor_player_exited")
			add_child(sensor)
			sensor_list.push_back(sensor)
		
func is_not_go_up(time: float) -> bool:
	return (shoot_speed * sin(global_rotation) - gravity * time) <= 0

func _on_PlayerSensor_player_entered():
	if detect_count == 0:
		emit_signal("player_entered", rotation_degrees)
		
	detect_count += 1
	
func _on_PlayerSensor_player_exited():
	if detect_count == 1:
		emit_signal("player_exited", rotation_degrees)
		
	if detect_count > 0:
		detect_count -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
