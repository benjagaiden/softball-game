extends Node

var cheer_power: float = 0.0
var max_cheer: float = 100.0

func add_cheer(amount: float) -> void:
	cheer_power = clamp(cheer_power + amount, 0.0, max_cheer)

func tick(delta: float) -> void:
	cheer_power = max(0.0, cheer_power - delta * 4.0)

func get_boost() -> float:
	return cheer_power / max_cheer