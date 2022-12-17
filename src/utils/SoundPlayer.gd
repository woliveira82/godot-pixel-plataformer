extends Node

const HURT = preload("res://assets/sounds/hurt.wav")
const JUMP = preload("res://assets/sounds/jump.wav")

onready var audioStreamPlayers = $AudioPlayers.get_children()


func play_sound(sound):
	for audioStreamPlayer in audioStreamPlayers:
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
