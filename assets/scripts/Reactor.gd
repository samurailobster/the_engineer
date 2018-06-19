extends Area2D

signal reactor_cooling
signal modify_reactor(item_type)

func _on_BurnTimer_timeout():
	emit_signal("reactor_cooling")
	
func _on_ReactorChamber_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.is_in_group("crystal"):
		emit_signal("modify_reactor", "crystal")
		body.queue_free()
	if body.is_in_group("fuel"):
		emit_signal("modify_reactor", "fuel")
		body.queue_free()
	if body.is_in_group("upgrade"):
		emit_signal("modify_reactor", "upgrade")
		body.queue_free()
	else:
		return