extends Label

var duration_max: float = 1.5
var timer: float = 1.5
var fade_started = false
var last_tween = null #Last tween we activated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if modulate == Color("ffffff") and timer > 0:
		timer -= duration_max * delta
	
	if timer <= 0 and fade_started == false:
		fade_started = true
		last_tween = UI.tween_alpha(self, true, true)


func notify(notice: String, image_path: String):
	#Reset everything back into place to do the countdown
	timer = duration_max
	visible = true
	modulate = Color("ffffff")
	fade_started = false
	if last_tween != null:
		print(last_tween)
		last_tween.kill()
	last_tween = null
		
	
	if image_path == "": #No images involved
		text = notice
	else:
		var image_name = image_path.get_file()
		text = image_name + " " + notice
