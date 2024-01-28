class_name Grid
extends Node2D

const Cell = preload("res://cell.tscn")

signal cell_spawned

@export var grid_width: int = 4
@export var grid_height: int = 4
@export var new_cell_base_val: int = 2
@export var new_cell_upgrade_chance: int = 25

var board: Array[Array] = []
var is_moving: bool = false

# pixel calculation stuff - probably there are ways to write it better...
const window_height := 960
const window_width := 640
const cell_width := 128
const padding := 64
const grid_offset := Vector2(padding, 0)


func _ready():
	add_bg_cells()
	for x in range(grid_width):
		board.append([])
		for y in range(grid_height):
			board[x].append(null)
	await spawn_cell()
	await spawn_cell()


func add_bg_cell_to_pos(pos: Vector2):
	var bg_cell = Sprite2D.new()
	bg_cell.position = board_pos2cell_pos(pos)
	bg_cell.texture = preload("res://assets/cell_bg.png")
	add_child(bg_cell, false, 1)

func add_bg_cells():
	recalculate_grid_offset_and_scale()
	for x in range(grid_width):
		for y in range(grid_height):
			add_bg_cell_to_pos(Vector2(x, y))


func recalculate_grid_offset_and_scale():
	var target_width: float = window_width - padding * 2
	var target_height: float = (window_height - self.global_position.y) - padding
	var actual_width: int = grid_width * cell_width
	var actual_height: int = grid_height * cell_width
	var scale_x = target_width / actual_width
	var scale_y = target_height / actual_height
	assert(scale_x > 0 && scale_y > 0)
	self.scale = Vector2(scale_x, scale_y)


func set_spawn_data(base_bal: int, upgrade_change: int):
	new_cell_base_val = base_bal
	new_cell_upgrade_chance = upgrade_change
	upgrade_all_cells_to(base_bal)


func apply_new_size(new_width: int, new_height: int):
	while grid_width < new_width:
		grid_width += 1
		var new_col = []
		for y in range(grid_height):
			new_col.append(null)
			add_bg_cell_to_pos(Vector2(grid_width - 1, y))
		board.append(new_col)
	while grid_height < new_height:
		grid_height += 1
		for x in range(grid_width):
			board[x].append(null)
			add_bg_cell_to_pos(Vector2(x, grid_height - 1))
	recalculate_grid_offset_and_scale()


func one4all():
	var heighest_val = 0
	for x in range(grid_width):
		for y in range(grid_height):
			var cell = board[x][y]
			if cell != null && cell.value > heighest_val:
				heighest_val = cell.value
	for x in range(grid_width):
		for y in range(grid_height):
			var cell = board[x][y]
			if cell != null:
				if cell.value < heighest_val:
					await upgrade_cell(Vector2(x, y), heighest_val)


func all4one():
	var first_cell_pos := Vector2.ZERO
	for x in range(grid_width):
		for y in range(grid_height):
			var cell = board[x][y]
			if cell != null:
				if first_cell_pos == Vector2.ZERO:
					first_cell_pos = Vector2(x, y)
				else:
					await do_merge(Vector2(x, y), first_cell_pos, first_cell_pos)


func upgrade_all_cells_to(min_val: int):
	for x in range(grid_width):
		for y in range(grid_height):
			var cell = board[x][y]
			if cell != null:
				if cell.value < min_val:
					upgrade_cell(Vector2(x, y), min_val)


func board_pos2cell_pos(board_pos: Vector2) -> Vector2:
	return board_pos * cell_width + Vector2(cell_width/2, cell_width/2) + grid_offset


func new_cell_value():
	if randi_range(0, 100) <= new_cell_upgrade_chance:
		return new_cell_base_val * 2
	else:
		return new_cell_base_val


func spawn_cell():
	var available_positions = get_free_positions()
	var new_cell_pos = available_positions[randi() % available_positions.size()]
	var new_cell = Cell.instantiate()
	new_cell.position = board_pos2cell_pos(new_cell_pos)
	var value = new_cell_value()
	cell_spawned.emit(value)
	new_cell.value = value
	board[new_cell_pos.x][new_cell_pos.y] = new_cell
	new_cell.scale = Vector2.ZERO
	add_child(new_cell)
	var tween = create_tween()
	tween.tween_property(new_cell, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished


func get_free_positions() -> Array:
	var empty_positions = []
	for x in range(grid_width):
		for y in range(grid_height):
			if board[x][y] == null:
				empty_positions.append(Vector2(x, y))
	return empty_positions


func tween_cell(cell_pos: Vector2, target_pos: Vector2):
	var cell = board[cell_pos.x][cell_pos.y]
	var tween = create_tween()
	tween.tween_property(cell, "position", board_pos2cell_pos(target_pos), cell_pos.distance_to(target_pos) * 0.05)
	await tween.finished


func do_move(cell_pos: Vector2, target_pos: Vector2):
	var cell = board[cell_pos.x][cell_pos.y]
	await tween_cell(cell_pos, target_pos)
	board[target_pos.x][target_pos.y] = cell
	board[cell_pos.x][cell_pos.y] = null


func drop_cell(cell_pos: Vector2):
	var cell = board[cell_pos.x][cell_pos.y]
	board[cell_pos.x][cell_pos.y] = null
	cell.queue_free()


func upgrade_cell(cell_pos: Vector2, new_val: int):
	var cell = board[cell_pos.x][cell_pos.y]
	cell.value = new_val
	cell.update_texture()
	cell.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(cell, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished


func do_merge(cell1_pos: Vector2, cell2_pos: Vector2, target_pos: Vector2):
	var cell1_val =  board[cell1_pos.x][cell1_pos.y].value
	var cell2_val =  board[cell2_pos.x][cell2_pos.y].value
	var merged_value = cell1_val + cell2_val
	
	if cell1_pos != target_pos:
		await tween_cell(cell1_pos, target_pos)
	if cell2_pos != target_pos:
		assert (board[target_pos.x][target_pos.y] == null)
		await tween_cell(cell2_pos, target_pos)
		board[target_pos.x][target_pos.y] = board[cell2_pos.x][cell2_pos.y]
		board[cell2_pos.x][cell2_pos.y] = null

	drop_cell(cell1_pos)
	await upgrade_cell(target_pos, merged_value)


func execute_move_for_fields(field_positions: Array):
	var nextEmptyPosIndex: int = -1
	var did_move = false
	var did_merge = false
	var next_cell_pos: Vector2 = Vector2.ZERO
	
	for pos_idx in range(field_positions.size()):
		if did_merge:
			did_merge = false
			continue
		
		var fpos = field_positions[pos_idx]
		var cell = board[fpos.x][fpos.y]
		# if cell is empty - mark is as possible destination for move
		if cell == null:
			if nextEmptyPosIndex == -1:
				nextEmptyPosIndex = pos_idx
		else:
			# cell is not empty - merge maybe?
			var next_cell = null
			for i in range(pos_idx + 1, field_positions.size()):
				var i_cell = board[field_positions[i].x][field_positions[i].y]
				if i_cell != null:
					next_cell = i_cell
					next_cell_pos = field_positions[i]
					break
			
			if next_cell != null && cell.value == next_cell.value:
				did_merge = true
				var target_pos = fpos
				if nextEmptyPosIndex != -1:
					target_pos = field_positions[nextEmptyPosIndex]
					nextEmptyPosIndex += 1
				else:
					nextEmptyPosIndex = pos_idx + 1
				await do_merge(next_cell_pos, fpos, target_pos)
				did_move = true
			else:
				# no merge - okay if free space available, do move - else nothing
				if nextEmptyPosIndex != -1:
					var target_pos = field_positions[nextEmptyPosIndex]
					nextEmptyPosIndex += 1
					await do_move(fpos, target_pos)
					did_move = true
	return did_move


func move(direction: String) :
	print("Moving direction: %s" % direction)
	if is_moving:
		return
	is_moving = true
	var did_move = false
	
	if direction == "up" || direction == "down":
		for col in range(grid_width):
			var field_positions = []
			for row in range(grid_height):
				field_positions.append(Vector2(col, row))
			if direction == "down":
				field_positions.reverse()
			did_move = await execute_move_for_fields(field_positions) || did_move
	
	if direction == "left" || direction == "right":
		for row in range(grid_height):
			var field_positions = []
			for col in range(grid_width):
				field_positions.append(Vector2(col, row))
			if direction == "right":
				field_positions.reverse()
			did_move = await execute_move_for_fields(field_positions) || did_move
	
	if did_move:
		await spawn_cell()
	is_moving = false
