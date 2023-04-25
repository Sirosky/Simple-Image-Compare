extends HBoxContainer

@onready var Main = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButImageReset.button_down.connect(_comparison_reset)
	%ButZoomReset.button_down.connect(_zoom_reset)
	%ButCenter.button_down.connect(_camera_center)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LabelZoom.text = str(snapped(%Camera2D.zoom.x * 100, .01)) + "%"

func _comparison_reset():
	Main.comparison_reset()

func _camera_center():
	%Camera2D.position = %ViewTop.size/2
	

func _zoom_reset():
	%Camera2D.zoom = Vector2(1,1)
	%Camera2D.camera_zoom = Vector2(1,1)
