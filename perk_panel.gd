extends MarginContainer


signal perk_selected


var perk: Perk


func _ready():
	update()


func set_perk(perk: Perk):
	self.perk = perk
	

func update():
	%PerkLabel.text = perk.get_title()
	%PerkTexture.texture_normal = perk.get_texture()


func _on_perk_button_down():
	perk_selected.emit(perk)
