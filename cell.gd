extends Node2D

@export var value: int = 0

var font_sizes = {
	1: 112,
	2: 92,
	3: 62,
	4: 46,
	5: 36,
	6: 32,
}


func _ready():
	update_texture()
	

func update_texture():
	var text = str(value)
	%NumberLabel.text = text
	%NumberLabel.add_theme_font_size_override("font_size", font_sizes[len(text)])
