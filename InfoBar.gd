extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButHelp.button_down.connect(_help_show)



func _help_show():
	if %PanelHelp.visible == false:
		UI.tween_alpha(%PanelHelp, false, false)
		get_node("/root/Main")._on_window_resized()
	else:
		%PanelHelp._help_exit()
		
		
