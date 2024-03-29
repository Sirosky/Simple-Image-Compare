extends Node

var mode = 0 #0 = image slider, 1 = swap

var window = DisplayServer.get_window_list()[0]
var window_dimensions:Vector2 = DisplayServer.window_get_size(window)
var window_width:int = window_dimensions.x
var window_height:int = window_dimensions.y

var screen_dimensions:Vector2 = DisplayServer.screen_get_size()
var screen_width:int = DisplayServer.screen_get_size().x
var screen_height:int = DisplayServer.screen_get_size().y

@onready var compare_bottom = $ViewBottom/PortBottom/ImageBottom
var compare_bottom_img = "" #Path to loaded image
@onready var compare_top = $ViewTop/PortTop/ImageTop
var compare_top_img = ""
var compare_offset: Vector2 = Vector2(0, 0)
var compare_focused = false
var mouse_pos: Vector2
var compare_files: Array[String] = []
var locked_files: Array[String] = [] #Files that are locked from refresh

#Variables used in mode 1
var compare_files_current = -1 
var previous_image_dimensions: Vector2


var vsep_delay = 240
var vsep_timer = 0 #timer before hiding the vertical separator

var dir_user = DirAccess.open("user://")

func _ready() -> void:
	views_resize()
	%ViewBottom.position = compare_offset
	%ViewTop.position = compare_offset
	%Camera2D.position = window_dimensions/2
	%TopBar.size.x = window_dimensions.x - 48
	_on_window_resized()
	
	#Signals
	get_viewport().files_dropped.connect(_on_files_dropped)
	get_viewport().size_changed.connect(_on_window_resized)
	%MenuButtonL.get_popup().id_pressed.connect(_MenuButtonL_pressed)
	%MenuButtonR.get_popup().id_pressed.connect(_MenuButtonR_pressed)
	
	#Effects
	for i in %HUD.get_children():
		if i != %PanelHelp: #PanelHelp should stay hidden
			UI.tween_alpha(i, false, false)
	
	mode_switch(1)

func _unhandled_input(event):
	if event is InputEventMouseButton: #Prepare to drag slider
		mouse_pos = %ViewTop.get_local_mouse_position()
		
		if mouse_pos > Vector2(0,0) and mouse_pos < %ViewBottom.size and compare_focused == false:
			compare_focused = true
		else:
			compare_focused = false
	
	#Switch to mode 1, full image compare, and cycle through images.
	if Input.is_action_just_released("ui_previous") and !Input.is_key_pressed(KEY_CTRL) and compare_files.size() > 1:
		if mode == 0: mode_switch(1)
		compare_files_current = max(compare_files_current - 1, 0)
		#print(compare_files_current)
		_MenuButtonL_pressed(compare_files_current)
	if Input.is_action_just_released("ui_next") and !Input.is_key_pressed(KEY_CTRL) and compare_files.size() > 1:
		
		if mode == 0: mode_switch(1)
		compare_files_current = min(compare_files_current + 1, compare_files.size() - 1)
		#print(compare_files_current)
		_MenuButtonL_pressed(compare_files_current)
	
	#Other hotkeys
	if Input.is_action_just_released("ui_camera_center"): %UtilityBar._camera_center()
	if Input.is_action_just_released("ui_zoom_reset"): %UtilityBar._zoom_reset()
	if Input.is_action_just_pressed("ui_compare_reset"): %UtilityBar._compare_reset(false)
	if Input.is_action_just_pressed("ui_compare_reset_hard"): %UtilityBar._compare_reset(true)
	if Input.is_action_just_released("ui_help"): %InfoBar._help_show()
	
	if Input.is_action_just_released("ui_toggle_image_lock_bulk"):
		%UtilityBar._image_lock_bulk()
	elif Input.is_action_just_released("ui_toggle_image_lock"): %UtilityBar._image_lock(max(0, compare_files_current))
	

func _process(delta: float) -> void:
	mouse_pos = %ViewTop.get_local_mouse_position()
	if Input.is_mouse_button_pressed(1) and compare_top.texture != null and compare_bottom.texture != null and compare_focused == true: #Have slider track mouse
		if mouse_pos > Vector2(0,0) and mouse_pos < %ViewBottom.size:
			%ViewTop.size.x = mouse_pos.x
			
			#Slider stuff
			vsep_timer = vsep_delay
			if %VSeparator.visible == false or %VSeparator.modulate != Color("ffffff"):
				%VSeparator.visible = true
				%VSeparator.modulate = Color("ffffff")
			%VSeparator.size.y = %ViewBottom.size.y
			%VSeparator.position = Vector2(mouse_pos.x + compare_offset.x - %VSeparator.size.x/2,compare_offset.y)
			mode_switch(0)
	
	if compare_focused == true and Input.is_action_just_released("ui_click"):
		compare_focused = false

	if vsep_timer > 0 and %VSeparator.visible == true: #Timer to hide separator when not in use
		vsep_timer -= 1
	
	if vsep_timer == 0 and %VSeparator.visible == true:
		UI.tween_alpha(%VSeparator, true, true)
	

	

func views_resize(): #Mainly here to handle comparisons with different-sized images
	if compare_top.texture != null and compare_bottom.texture != null:
		if compare_top.size != compare_bottom.size:
			var target_size: Vector2
			if mode == 0:
				if compare_top.size > compare_bottom.size:
					target_size = compare_top.size
				else:
					target_size = compare_bottom.size
			if mode == 1:
				if compare_top.size > previous_image_dimensions:
					target_size = compare_top.size
				else:
					target_size = previous_image_dimensions
			
			%ViewBottom.size = target_size
			%ViewTop.size = target_size
			compare_top.size = target_size
			compare_bottom.size = target_size
		

func _on_files_dropped(files):
	
	#print(files)
	transfer_files(files)
	

func transfer_files(files): #Copying files to user://. Technically not necessary, but leaving it in if I decide to add comparison saving down the line.
	#var path = files[0].get_base_dir()
	#var dir = DirAccess.open(path)
	var ext = ""
	
	for i in files:
		ext = i.get_extension()
		
		if ext == "":
			pass
		
#		var target_path: String = "user://" + i.get_file()
	if ext == "png" or ext == "jpeg" or ext == "jpg" or ext == "bmp" or ext == "webp" or ext == "gif" or ext == "dds":
		process_files(files)
#			print(target_path)

#			if dir_user.file_exists(target_path): #If file already exists, rename the file until we can save it without overwriting
##				print("File exists, rename.")
#				var proceed = false
#				var filename = i.get_file().get_slice(".",0) #Get filename without extension
#				var iteration = 1
#
#				while proceed == false:
#					if !dir_user.file_exists("user://" + filename + "___" + str(iteration) + "." + ext): #Available file, can copy
#						dir.copy(i, "user://" + filename + "___" + str(iteration) + "." + ext)
#						proceed = true
#					else: #Can't copy, try again
#						iteration += 1
#
#			else: dir.copy(i, "user://" + i.get_file()) #No conflicts, copy directly
	
	
		
func process_files(files): #Allow selection of image in the UI
	var first_start = false
	files.sort()
	#print("Loading")
	#print(compare_files)

	
	if compare_files.size() <= 1:
		first_start = true
	
	
	for i in files:
		if compare_files.has(i) == false:
			compare_files.append(i)
			#print("Looping")
			#print(locked_files)
			%MenuButtonL.get_popup().add_item(i)
			#print("Looping")
			#print(locked_files)
			%MenuButtonR.get_popup().add_item(i)
			%ButLock.get_popup().add_item(i)
		
	_locked_files_rebuild()
	
	if files.size() == 1: %Notifier.notify("loaded!", files[0]) #sent notice with image name
	if files.size() > 1: %Notifier.notify("Loaded " + str(files.size()) + " images!","")
	
	#print("Loaded")
	#print(compare_files)
	
	if first_start == true and compare_files.size() > 1: #Autoload images once we have a full comparison
		_MenuButtonL_pressed(0)
		_MenuButtonR_pressed(1)
		UI.tween_alpha(compare_top, false, false)
		UI.tween_alpha(compare_bottom, false, false)
		UI.tween_alpha(%Tip, true, true)
		
		%Camera2D.position = %ViewTop.size/2
		compare_files_current = 0
	
	

func _MenuButtonL_pressed(id):
	var text = %MenuButtonL.get_popup().get_item_text(id)
	%MenuButtonL.text = text
	
	previous_image_dimensions = compare_top.size
	compare_image_load(text, compare_top)
	compare_top_img = text
	compare_files_current = id

func _MenuButtonR_pressed(id):
	var text = %MenuButtonR.get_popup().get_item_text(id)
	%MenuButtonR.text = text
	
	compare_image_load(text, compare_bottom)
	compare_bottom_img = text
	compare_files_current = id

func compare_image_load(path, texturerect): #Loads the actual image into the comparison tool
	var image = Image.load_from_file(path)
	#print(image)
	var texture = ImageTexture.create_from_image(image)
	texturerect.texture = texture
	texturerect.size = Vector2(image.data.width, image.data.height)
	texturerect.get_node("../../").size = Vector2(image.data.width, image.data.height)
	#print(str(Vector2(image.data.width, image.data.height)))
	views_resize()

func comparison_reset(hard_reset:bool): #Resets comparison images. Hard reset on overrides the locked files and resets everything.
	
	compare_files_current = -1
	previous_image_dimensions = Vector2(0,0)
	locked_files.clear()
	compare_files = []
	
	_locked_files_rebuild()
	%MenuButtonL.get_popup().clear()
	%MenuButtonR.get_popup().clear()
	%ButLock.get_popup().clear()

	#print(compare_files)
	if hard_reset == false: #Reload locked files
		
		compare_files = locked_files
		for i in compare_files:
			%MenuButtonL.get_popup().add_item(i)
			%MenuButtonR.get_popup().add_item(i)
			%ButLock.get_popup().add_item(i)
		
		for i in compare_files.size():
			%UtilityBar._image_lock(i)
		
		if compare_files.size() > 1: #Autoload images if needed
			_MenuButtonL_pressed(0)
			_MenuButtonR_pressed(1)
		if compare_files.size() == 1: _MenuButtonL_pressed(0)
			#print("Reload complete")
			#print(compare_files)
	
	if compare_files.is_empty():
		UI.texture_tween_alpha(compare_top, true)
		UI.texture_tween_alpha(compare_bottom, true)
		UI.tween_alpha(%Tip, false, false)
		if %VSeparator.visible == true: UI.tween_alpha(%VSeparator, true, true)
	
	match hard_reset:
		false:
			%Notifier.notify("Comparisons reset ♻️","")
		true:
			%Notifier.notify("Conducted hard reset ♻️. Locked images have been cleared.","")


func _locked_files_rebuild():#Rebuild locked files. Seems to be an issue where files are being added automatically to locked files. Makes no sense, almost certainly a Godot bug but not sure where.
	locked_files = []
	for i in %ButLock.get_popup().item_count: 
		var text = %ButLock.get_popup().get_item_text(i)
		#print(text)
		if text.find("🔒") > -1:
			#print(text)
			#print(text.find("🔒"))
			text = text.trim_prefix(%UtilityBar.lock_string)
			locked_files.append(text)
	#print(locked_files)

func _notification(notification): #On exit
	if notification == NOTIFICATION_WM_CLOSE_REQUEST:
		temp_files_clear()

func mode_switch(m) -> void:
	if mode == m: return
	
	match m:
		0:
			%MenuButtonR.visible = true
			%VSeparator.visible = true
		1:
			%MenuButtonR.visible = false
			%VSeparator.visible = false
	
	mode = m

func _on_window_resized():
	window_dimensions = DisplayServer.window_get_size(window)
	window_width = window_dimensions.x
	window_height = window_dimensions.y

	screen_dimensions = DisplayServer.screen_get_size()
	screen_width = DisplayServer.screen_get_size().x
	screen_height = DisplayServer.screen_get_size().y
	
	%TopBar.position = Vector2(window_width/2 - %TopBar.size.x/2, 32)
	%Tip.position = window_dimensions/2 - %Tip.size/2
	%Notifier.position = Vector2(window_dimensions.x/2 - %Notifier.size.x/2, window_dimensions.y - 256)
	if %PanelHelp.visible == true: %PanelHelp.position = window_dimensions/2 - %PanelHelp.custom_minimum_size/2
	%UtilityBar.position = Vector2(64, window_height - 128)
	
	%InfoBar.position = Vector2(window_width - 64 - %InfoBar.size.x, window_height - 128)

func temp_files_clear():
	var files = dir_user.get_files()
		
	for i in files: #Delete all the temp files upon exit
		dir_user.remove(i)
