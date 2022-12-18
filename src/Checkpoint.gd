extends Area2D

onready var animationSprite: = $AnimatedSprite

var active = true


func _on_Checkpoint_body_entered(body):
	if not active: return
	
	if not body is Player: return

	animationSprite.play("Checked")
	Events.emit_signal("hit_checkpoint", position)
	active = false
