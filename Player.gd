extends KinematicBody2D
class_name Player

enum { MOVE, CLIMB }

export(Resource) var moveData
export var health = 3  # จำนวนหัวใจปัจจุบันของผู้เล่น
export var max_health = 3  # จำนวนหัวใจสูงสุดของผู้เล่น

var velocity = Vector2.ZERO
var state = MOVE
var is_invincible = false  # สถานะเป็นอมตะ
var blink_timer = 0.0
var jumps_left = 2

onready var animatedSprite = $AnimatedSprite
onready var invincibility_timer = $InvincibilityTimer
onready var die_menu = get_node("/root/World/HealthUI/CanvasLayer/DieMenu")
onready var ladderCheck = $LadderCheck

signal player_hit  # ประกาศสัญญาณ player_hit
signal player_fall_off_map

func powerup(): #ใช้ตอนผู้เล่นเก็บของแล้วความเร็วจะเพิ่มขึ้น
	moveData = load("res://FastPlayerMovementData.tres")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)

func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
	
	apply_gravity()
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		
		animatedSprite.flip_h = input.x > 0
	
	if is_on_floor():
		jumps_left = 2
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE
			jumps_left -= 1
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_pressed("ui_up") and jumps_left >0:
			velocity.y = moveData.JUMP_FORCE
			jumps_left -= 1
		
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
			velocity.y = moveData.JUMP_RELEASE_FORCE
		
		if velocity.y > 0:
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY
	
	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1

func climb_state(input):
	if not is_on_ladder(): state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

func _ready():
	var door = get_node("/root/World/DoorYouWin")
	if door:
		door.connect("body_entered", self, "_on_DoorYouWin_body_entered")
	
	if invincibility_timer != null:
		invincibility_timer.connect("timeout", self, "_on_invincibility_timer_timeout")
	else:
		print("Error: invincibility_timer is null.")

func _process(delta):
	if is_invincible:
		blink_timer += delta
		if blink_timer > 0.3:  # กระพริบทุกๆ 0.1 วินาที
			animatedSprite.modulate.a = 0.5 if animatedSprite.modulate.a == 1.0 else 1.0
			blink_timer = 0.0
	
	if position.y > 190:
		fall_off_map()

func fall_off_map():
	health = 0
	emit_signal("player_fall_off_map")
	show_die_menu()

func take_damage(amount = 1):
	if is_invincible:
		return
	
	health = max(health - amount, 0)
	emit_signal("player_hit")
	
	if health <= 0:
		show_die_menu()
	else:
		activate_invicibility()

func activate_invicibility():
	is_invincible = true
	invincibility_timer.start(2)
	blink_timer = 0.0

func _on_invincibility_timer_timeout():
	is_invincible = false
	animatedSprite.modulate.a = 1.0

func show_die_menu():
	die_menu.show_menu()

func _on_DoorYouWin_body_entered(body):
	if body == self:
		print("Player has reached the door!")
		show_win_menu()

func show_win_menu():
	var win_menu = get_node("/root/World/HealthUI/CanvasLayer/WinMenu")
	if win_menu:
		win_menu.visible = true
		get_tree().paused = true
	
