extends BoxContainer

@onready var Main = get_node("/root/Main")
var lock_string: String = "🔒 "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButImageReset.button_down.connect(_compare_reset.bind(false))
	%ButZoomReset.button_down.connect(_zoom_reset)
	%ButCenter.button_down.connect(_camera_center)
	%ButLock.get_popup().id_pressed.connect(_image_lock)
	%ButUnlockBulk.button_down.connect(_image_lock_bulk)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LabelZoom.text = str(snapped(%Camera2D.zoom.x * 100, .01)) + "%"

func _image_lock(id):
	#if Main.compare_files_current > -1: #Make sure images are actually loaded
	var text = %ButLock.get_popup().get_item_text(id)
		
	if text.find(lock_string) > -1: #Image is already locked, unlock image.
		text = text.trim_prefix(lock_string)
		%ButLock.get_popup().set_item_text(id, text)
		
		if Main.locked_files.has(text):
			Main.locked_files.erase(text)
			%Notifier.notify("🔒",text)
	else: #Image not locked, lock image.
		%ButLock.get_popup().set_item_text(id, lock_string + text)
		
		if !Main.locked_files.has(text):
			Main.locked_files.append(text)
			%Notifier.notify("🔓",text)

func _image_lock_bulk(): #Toggles image locking for all loaded images
	#print(Main.locked_files)
	if Main.locked_files.is_empty() == true:
		#print("Locking all")
		for i in Main.compare_files.size(): #Nothing is locked, so lock everything.
			var text = %ButLock.get_popup().get_item_text(i)
			
			%ButLock.get_popup().set_item_text(i, lock_string + text)
		
			if !Main.locked_files.has(text):
				Main.locked_files.append(text)
				%Notifier.notify(str(Main.compare_files.size()) + " images 🔒","")
	else:
		for i in Main.compare_files.size(): #Something is locked, so unlock everything
			var text = %ButLock.get_popup().get_item_text(i)
			text = text.trim_prefix(lock_string)
			%ButLock.get_popup().set_item_text(i, text)
			
			if Main.locked_files.has(text):
				Main.locked_files.erase(text)
				%Notifier.notify(str(Main.compare_files.size()) + " images 🔓","")
		

func _compare_reset(hard_reset):
	Main.comparison_reset(hard_reset)
	match hard_reset:
		false:
			%Notifier.notify("Comparisons reset ♻️","")
		true:
			%Notifier.notify("Conducted hard reset ♻️. Locked images have been cleared.","")

func _camera_center():
	%Camera2D.position = %ViewTop.size/2
	

func _zoom_reset():
	%Camera2D.zoom = Vector2(1,1)
	%Camera2D.camera_zoom = Vector2(1,1)
