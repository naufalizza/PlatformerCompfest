extends KinematicBody2D



export var move_speed = 200
export var move_accel_factor = 600
export var move_deccel_factor = 900
export var turn_accel_factor = 500

export var gravity = 981
export var jump_factor = 450
export var air_control_factor = 1

export var coyote_time = 10

var speed = Vector2.ZERO
var accel = Vector2.DOWN * gravity
var hold_left = false
var hold_right = false
var hold_hand_key = false
var speed_treshold = 17
var coyote_time_counter = coyote_time
var on_gfield = false
var alive = true

onready var animated_sprite = $AnimatedSprite 
onready var audio_jump = get_node("Audio/Jump")
onready var audio_death = get_node("Audio/Death")

var on_air = false
	
func is_on_ground():
	var on_ground = false
	var slide_count = get_slide_count()
	var i = 0
	while i < slide_count and (not on_ground):
		var collision = get_slide_collision(i)
		if collision.normal.y < -0.5:
			on_ground = true
		else:
			i += 1
	return on_ground

func is_on_ceiling():
	var on_ceil = false
	var slide_count = get_slide_count()
	var i = 0
	while i < slide_count and (not on_ceil):
		var collision = get_slide_collision(i)
		if collision.normal.y > 0.5:
			on_ceil = true
		else:
			i += 1
	return on_ceil

func _physics_process(delta: float):
	if alive:
		if on_gfield:
			print(accel)
		if is_on_ground() or (on_gfield and is_on_ceiling()):
			coyote_time_counter = coyote_time
		elif coyote_time_counter > 0:
			coyote_time_counter -= 1
		speed = move_and_slide(speed)
	#	if self.is_on_wall():
	#		print("on wall")
		if speed.x >= 0.001:
			animated_sprite.play("run")
			animated_sprite.flip_h = false
		elif speed.x <= -0.001:
			animated_sprite.play("run")
			animated_sprite.flip_h = true
		else:
			animated_sprite.play("idle")

		on_air = not is_on_ground()

		acceleration_update()
		speed_update(delta)
		speed += accel * delta

### INPUT
func _unhandled_input(event: InputEvent):
	handle_move_left(event)
	handle_move_right(event)
	handle_jump(event)

func handle_move_left(event: InputEvent):
	if event.is_action_pressed("move_left"):
		hold_left = true
	if event.is_action_released("move_left"):
		hold_left = false

func handle_move_right(event: InputEvent):
	if event.is_action_pressed("move_right"):
		hold_right = true
	if event.is_action_released("move_right"):
		hold_right = false

func handle_jump(event: InputEvent):
	if event.is_action_pressed("jump") and (is_on_ground() or coyote_time_counter > 0 or (on_gfield and is_on_ceiling())):
		speed.y = -jump_factor * (accel.y / abs(accel.y))
		audio_jump.play()
		on_air = true
func update_action_display():
	pass

### END OF INPUT
func acceleration_update():
	if hold_right or hold_left:
		move_acceleration_update()
	else:
		move_decceleration_update()
		
func move_acceleration_update():
	# Ini belum menangani turn speed
	var x_direction = 0
	if hold_right:
		x_direction += 1
	if hold_left:
		x_direction -= 1
		
	var factor = x_direction * get_air_factor()
	
	if speed.x == 0 or abs(speed.x) / speed.x == x_direction:
		accel.x = factor * move_accel_factor
	else:
		accel.x = factor * turn_accel_factor
	
func move_decceleration_update():
	var abs_speed_x = abs(speed.x)
	if abs_speed_x >= speed_treshold:
		accel.x = -(abs_speed_x / speed.x) * move_deccel_factor * get_air_factor()
	else:
		accel.x = 0
		speed.x = 0
		
func get_air_factor() -> float:
	var factor = 1
	if on_air:
		factor *= air_control_factor
		
	return factor
		
func speed_update(delta):
	speed += accel * delta
	var abs_speed_x = abs(speed.x)
	if abs_speed_x > move_speed:
		speed.x = move_speed * abs_speed_x / speed.x
#	elif abs_speed_x < 1:
#		speed.x = 0
		
func gravity_update(delta: float):
	speed += Vector2.DOWN * gravity * delta
	var collision = move_and_collide(speed * delta)
	if collision:
		speed = speed.project(Vector2.RIGHT)

func dead():
	audio_death.play()
	alive = false
	self.visible = false
	get_tree().reload_current_scene()
	
func _on_TrampolineDetector_area_entered(area):
	if area.is_in_group("trampoline") and gravity != 0:
		audio_jump.play()
		speed.y = -1000 * abs(gravity) / gravity


func _on_GravityDetector_area_entered(area):
	if area.is_in_group("gravity_field"):
		on_gfield = true
		accel.y = -abs(accel.y)
		$AnimatedSprite.flip_v = true
		$AnimatedSprite.offset.y = 32
		print("enter gfield")


func _on_GravityDetector_area_exited(area):
	if area.is_in_group("gravity_field"):
		on_gfield = false
		accel.y = abs(accel.y)
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.offset.y = 0
		print("exit gfield")


func _on_HitDetector_area_entered(area):
	if area.is_in_group("hitter"):
		print("HIT")
		dead()
