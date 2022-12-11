extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite
onready var ledgeCast = $LedgeCast

const GRAVITY = 5


func _physics_process(delta):
	apply_gravity()
	
	var found_wall = is_on_wall()
	var found_ledge = not ledgeCast.is_colliding()
	if found_wall or found_ledge:
		direction *= -1

	animatedSprite.flip_h = direction.x > 0
	velocity.x = direction.x * 25
	velocity = move_and_slide(velocity, Vector2.UP)


func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 300)
