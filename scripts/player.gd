extends CharacterBody2D

@onready var camera := $Camera2D

const MOVE_SPEED = 600

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom.x = max(0.5, camera.zoom.x - 0.01)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom.x = min(2, camera.zoom.x + 0.01)
		camera.zoom.y = camera.zoom.x

func _process(delta: float) -> void:
	var vec = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = vec * MOVE_SPEED
	move_and_slide()
