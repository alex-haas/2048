class_name Game
extends Node2D

const LevelupDialog = preload("res://levelup_dialog.tscn")

@onready var grid: Grid = %GridContainer
@onready var score_label: Label = %ScoreLabel
@onready var levelup_bar: ProgressBar = %LevelupBar

var score: int = 0

var perks = [
	Perk.new("add_col"),
	Perk.new("add_row"),
	Perk.new("spawn_buff"),
	Perk.new("one4all"),
	Perk.new("all4one"),
]


"""
Ideas:
	Perks:
		Undo's (3 per Point?)
		Future Vision
		Shuffle ?
		Multi-Shift (All at the same time down)
		Polymorhism (merge cells with heigher potency)
"""


func _physics_process(delta):
	var move_actions = ["up", "down", "left", "right"]
	for action in move_actions:
		if Input.is_action_just_pressed(action):
			grid.move(action)
			break


func _on_grid_container_cell_spawned(value):
	score += value
	if score_label != null:
		score_label.text = str(score)
	if levelup_bar != null:
		levelup_bar.add_exp(value)


func _on_level_up():
	var presented_perks: Array[Perk] = []
	perks.shuffle()
	for p in perks:
		if p.can_spawn():
			presented_perks.append(p)
			if len(presented_perks) >= 4:
				break
	
	var dialog = LevelupDialog.instantiate()
	dialog.perk_selected.connect(_on_perk_selected)
	dialog.presented_perks = presented_perks
	add_child(dialog)


func _on_perk_selected(perk: Perk):
	perk.count_taken += 1
	match perk.pid:
		"spawn_buff":
			var upgrade_chance = (perk.count_taken % 3) * 25 + 25
			var base_val = 2 ** (1 + int(perk.count_taken / 3))
			grid.set_spawn_data(base_val, upgrade_chance)
		"add_col":
			grid.apply_new_size(grid.grid_width + 1, grid.grid_height)
		"add_row":
			grid.apply_new_size(grid.grid_width, grid.grid_height + 1)
		"one4all":
			grid.one4all()
		"all4one":
			grid.all4one()


func _on_debug_level_up():
	_on_level_up()
