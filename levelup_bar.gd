extends ProgressBar


signal level_up


var level: int = 0
var exp_for_level_up: int = 100


func add_exp(value: int):
	self.value += value
	if self.max_value <= self.value:
		self.max_value *= 2
		level_up.emit()
