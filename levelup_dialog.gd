extends CanvasLayer


signal perk_selected

const PerkPanel = preload("res://perk_panel.tscn")

var presented_perks: Array[Perk]


func _ready():
	for perk in presented_perks:
		var perk_panel = PerkPanel.instantiate()
		perk_panel.set_perk(perk)
		perk_panel.perk_selected.connect(perk_pressed)
		%PerkContainer.add_child(perk_panel)


func perk_pressed(perk: Perk):
	perk_selected.emit(perk)
	queue_free()
