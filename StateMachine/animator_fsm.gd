class_name AnimatorFSM
extends Node

#$"../MovementComponent"

@export var sprite: AnimatedSprite2D

@onready var movement: MovementComponent

var state: State = State.IDLE
var facing: String = "down"

enum State { IDLE, RUN, ATTACK, HURT }

func _ready() -> void:
	if movement == null:
		movement = $"../MovementComponent"
		movement.direction_changed.connect(on_direction_changed)
	else:
		print_debug("No MovementComponent")

func on_direction_changed(dir: Vector2) -> void:
	if state == State.ATTACK or state == State.HURT:
		return  # don't let movement animation interrupt an action
	if dir != Vector2.ZERO:
		facing = _direction_name(dir)
		_set_state(State.RUN)
	else:
		_set_state(State.IDLE)

func trigger_attack() -> void:
	_set_state(State.ATTACK)

func _on_animation_finished() -> void:
	if state == State.ATTACK or state == State.HURT:
		_set_state(State.IDLE)

func _set_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE: sprite.play("idle_" + facing)
		State.RUN: sprite.play("run_" + facing)
		State.ATTACK: sprite.play("attack_" + facing)
		State.HURT: sprite.play("hurt_" + facing)

func _direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"
