extends Node


#Tween the alpha value of a node, used for UI nodes. Can also hide and delete nodes once done tweening.
func tween_alpha(node: Object, to_transparent:bool, hide:bool):
	#to_transparent = whether we're tweening to becoming transparent. Otherwise, tweens to non-transparency.
	#delete = whether to delete the node at the end of the tween
	var tween = node.create_tween()
	var result
	node.visible = true
	
	if to_transparent == true: #Check whether we're tweening to transparency or in reverse
		node.modulate = Color("ffffff")
		result = Color("ffffff00")
	else: #Transparent to non-transparent
		node.modulate = Color("ffffff00")
		result = Color("ffffff")
	
	tween.tween_property(node, "modulate", result,.3).set_trans(Tween.TRANS_SINE)
	
	#If we're just hiding, make sure to set the visibility to false
	if hide == true and to_transparent == true:  
		tween.tween_callback(node.hide)

func texture_tween_alpha(node: Object, to_transparent:bool):
	var tween = node.create_tween()
	tween.finished.connect(_texture_tween_finished.bind((node)))
	var result
	node.visible = true
	
	if to_transparent == true: #Check whether we're tweening to transparency or in reverse
		node.modulate = Color("ffffff")
		result = Color("ffffff00")
	else: #Transparent to non-transparent
		node.modulate = Color("ffffff00")
		result = Color("ffffff")
	
	tween.tween_property(node, "modulate", result,.3).set_trans(Tween.TRANS_SINE)


func _texture_tween_finished(node):
	node.texture = null
