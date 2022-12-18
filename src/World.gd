extends Node2D

const PlayerScene = preload("res://src/Player.tscn")

onready var camera = $Camera2D
onready var player = $Player
onready var timer = $Timer

var player_spawn_location = Vector2.ZERO


func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")
	


func _on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var new_player = PlayerScene.instance()
	new_player.global_position = player_spawn_location
	add_child(new_player)
	new_player.connect_camera(camera)


func _on_hit_checkpoint(checkpoint_location):
	player_spawn_location = checkpoint_location
