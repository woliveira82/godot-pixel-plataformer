extends KinematicBody2D
class_name Player

export(Resource) var moveData

var velocity = Vector2.ZERO
enum { MOVE, CLIMB }
var state = MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var jumpCoyoteTimer: = $JumpCoyoteTimer
onready var remoteTransform2D: = $RemoteTransform2D


func _ready():
	animatedSprite.frames = load("res://src/resources/GreenCharacter.tres")
	moveData = load("res://src/resources/DefaultMovementData.tres")


func power_up():
	moveData = load("res://src/resources/FastPlayerMovementData.tres")


func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)


func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true


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
		double_jump = moveData.DOUBLE_JUMP_COUNT

	else:
		animatedSprite.animation = "Jump"

	if can_jump():
		input_jump()

	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
		fast_fall()

	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor() and not was_on_floor:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1

	if not is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump = true
		jumpCoyoteTimer.start()


func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	Events.emit_signal("player_died")
	queue_free()


func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path


func can_jump():
	return is_on_floor() or coyote_jump


func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
		velocity.y = moveData.JUMP_RELEASE_FORCE


func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1
	

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()


func fast_fall():
	if velocity.y > 0:
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY


func input_jump():
	if Input.is_action_pressed("ui_up") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false


func climb_state(input):
	if not is_on_ladder():
		state = MOVE

	animatedSprite.animation = "Run" if input.length() != 0 else "Idle"
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)


func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)


func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)


func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)


func _on_JumpBufferTimer_timeout():
	buffered_jump = false


func _on_JumpCoyoteTimer_timeout():
	coyote_jump = false
