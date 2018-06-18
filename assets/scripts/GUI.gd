extends CanvasLayer

onready var coolant = $Left_Coolant
onready var fuel = $Right_Fuel

func _on_Right_Fuel_pressed():
	emit_signal("conveyor_right")
	pass # Replace with function body.


func _on_Left_Coolant_pressed():
	emit_signal("conveyor_left")
	pass # Replace with function body.
