extends BoxContainer

@onready var Main = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButImageReset.button_down.connect(_compare_reset)
	%ButZoomReset.button_down.connect(_zoom_reset)
	%ButCenter.button_down.connect(_camera_center)
	%ButLock.get_popup().id_pressed.connect(_image_lock)
	%ButUnlockBulk.button_down.connect(_image_lock_bulk)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LabelZoom.text = str(snapped(%Camera2D.zoom.x * 100, .01)) + "%"

func _image_lock(id):
	var text = %ButLock.get_popup().get_item_text(id)
	var lock_string = "🔒 "
	
	if text.find(lock_string) > -1: #Image is already locked, unlock image.
		text = text.trim_prefix(lock_string)
		%ButLock.get_popup().set_item_text(id, text)
		
		if Main.locked_files.has(text):
			Main.locked_files.erase(text)
	else: #Image not locked, lock image.
		%ButLock.get_popup().set_item_text(id, str("🔒 ") + text)
		
		if !Main.locked_files.has(text):
			Main.locked_files.append(text)

func _image_lock_bulk(): #Toggles image locking for all loaded images
	for i in Main.compare_files.size(): #Relock the remaining images
		_image_lock(i)

func _compare_reset(hard_reset):
	Main.comparison_reset(hard_reset)

func _camera_center():
	%Camera2D.position = %ViewTop.size/2
	

func _zoom_reset():
	%Camera2D.zoom = Vector2(1,1)
	%Camera2D.camera_zoom = Vector2(1,1)
