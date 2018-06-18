extends Area2D


signal modify_coolant(item_type)
signal coolant_level_dropping


func _on_LevelTimer_timeout():
	emit_signal("coolant_level_dropping")

func _on_CoolantChamber_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.is_in_group("crystal"):
		emit_signal("modify_coolant", "crystal")
		body.queue_free()
	if body.is_in_group("fuel"):
		emit_signal("modify_coolant", "fuel")
		body.queue_free()
	if body.is_in_group("upgrade"):
		emit_signal("modify_coolant", "upgrade")
		body.queue_free()
	else:
		return

