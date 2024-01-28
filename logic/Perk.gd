class_name Perk


var pid: String
var count_taken: int = 0


func _init(pid: String):
	self.pid = pid

	
func can_spawn() -> bool:
	match self.pid:
		"add_col": 
			return count_taken == 0
		"add_row": 
			return count_taken == 0
		"spawn_buff":
			return true
		"one4all":
			return true
		"all4one":
			return true
	return false


func get_title() -> String:
	match self.pid:
		"add_col": 
			return "+ Col"
		"add_row": 
			return "+ Row"
		"spawn_buff":
			if (count_taken + 1) % 3 == 0:
				return "Ban " + str(2 ** (int((1 + count_taken) / 3)))
			return "+ Spawn"
		"one4all":
			return "One for All"
		"all4one":
			return "All for One"
	return ""


func get_texture() -> Texture2D:
	match self.pid:
		"add_col":
			return preload("res://assets/plus_col.png")
		"add_row":
			return preload("res://assets/plus_row.png")
		"spawn_buff":
			if count_taken != 0 && count_taken % 4 == 0:
				var ban_no = int(count_taken / 4)
				if ban_no == 2:
					return preload("res://assets/ban_2.png")
				elif ban_no == 4:
					return preload("res://assets/ban_4.png")
			return preload("res://assets/placeholder.png")
		"one4all":
			return preload("res://assets/placeholder.png")
		"all4one":
			return preload("res://assets/placeholder.png")
	return null
