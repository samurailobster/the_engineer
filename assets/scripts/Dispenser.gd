extends Node2D

onready var announcement = $Announcement

signal start_reactor
signal start_coolant
signal start_conveyor
signal start_dispenser
signal create_item

func _on_ReactorStart_pressed():
	emit_signal("start_reactor")
	announcement.text = "Now press the green button to start the dispenser."

func _on_CoolantChamberStart_pressed():
	emit_signal("start_coolant")
	announcement.text = "Now press the orange button to start the reactor."

func _on_StartConveyor_pressed():
	emit_signal("start_conveyor")
	announcement.text = "Now press the blue button to start the reactor."

func _on_StartDispenser_pressed():
	emit_signal("start_dispenser")
	announcement.text = "Good luck, engineer!"

func _on_ItemTimer_timeout():
	emit_signal("create_item")