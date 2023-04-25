extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	%ButExit.button_down.connect(_help_exit)
	%LabelInfo.meta_clicked.connect(_on_meta_clicked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible == true: size = Vector2(800, 621) #Bandaid fix, because for some stupid reason the y coordinate keeps exploding.

func _help_exit():
	UI.tween_alpha(self, true, true)

func _on_meta_clicked(meta):
	OS.shell_open(meta)
