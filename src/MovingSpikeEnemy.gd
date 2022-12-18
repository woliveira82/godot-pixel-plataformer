extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUCE
}

export(ANIMATION_TYPE) var animation_type
export(float) var speed = 1

onready var animationPlayer = $AnimationPlayer


func _ready():
	match animation_type:
		ANIMATION_TYPE.LOOP: animationPlayer.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUCE: animationPlayer.play("BounceAlongPathBounce")
	
	animationPlayer.playback_speed = speed
