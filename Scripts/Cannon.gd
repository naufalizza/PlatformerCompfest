extends Node2D

const bullet_scene = preload("res://scenes/Bullet.tscn")
const sensor_curve_scene = preload("res://scenes/PlayerSensorCurve.tscn")
#const sensor_scene = preload("res://scenes/PlayerSensor.tscn")

export var gravity = 981
export var shoot_speed = 750
export var shoot_period_seconds = 1.0

export var max_trace_seconds = 1.5
export var sensor_count = 16

export var min_angle_degrees = -45
export var max_angle_degrees = 45 # Inclusive
export var angle_count = 40

var bullet: Node2D
var bullet_time = 0.0
var rng = RandomNumberGenerator.new()

var time = 0.0
var next_shoot_time: float

var enter_degrees_total = 0.0
var enter_count = 0

onready var player = get_node("../../../Player")
onready var audio_shoot = $AudioShoot

func _ready():
	rng.randomize()
	next_shoot_time = 0.0
	
	var angle_degrees = min_angle_degrees
	var angle_degrees_step = (max_angle_degrees - min_angle_degrees) / (angle_count - 1)
	for i in range(angle_count):
		add_sensor_curve(angle_degrees)
		angle_degrees += angle_degrees_step

func add_sensor_curve(angle_degrees: float):
	var sensor_curve = sensor_curve_scene.instance()
	sensor_curve.player = player
	sensor_curve.max_trace_seconds = max_trace_seconds
	sensor_curve.sensor_count = sensor_count
	sensor_curve.gravity = gravity
	sensor_curve.shoot_speed = shoot_speed
	sensor_curve.rotation_degrees = angle_degrees
	
	sensor_curve.connect("player_entered", self, "_on_PlayerSensorCurve_player_entered")
	sensor_curve.connect("player_exited", self, "_on_PlayerSensorCurve_player_exited")
	
	add_child(sensor_curve)

func _on_PlayerSensorCurve_player_entered(sensor_angle_degrees: float):
	enter_degrees_total += sensor_angle_degrees
	enter_count += 1
	
func _on_PlayerSensorCurve_player_exited(sensor_angle_degrees: float):
	if enter_count > 0:
		enter_degrees_total -= sensor_angle_degrees
		enter_count -= 1

func _process(delta: float):
	if time >= next_shoot_time and player_detected():
		shoot(get_angle_degrees())
		next_shoot_time = time + shoot_period_seconds
		
	time += delta
	
func player_detected():
	return enter_count > 0
	
func get_angle_degrees() -> float:
	return enter_degrees_total / enter_count

func shoot(angle_degree: float):
	audio_shoot.play()
	bullet = bullet_scene.instance()
	bullet.speed = shoot_speed
	bullet.gravity = gravity
	bullet.rotation = deg2rad(angle_degree)
	bullet.position = Vector2.ZERO
	add_child(bullet)
