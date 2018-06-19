extends Node2D

export(PackedScene) var random_item

onready var reactor_chamber = $Reactor
onready var item_dispenser = $item_spawner
onready var announcement = $Dispenser/Announcement
onready var gear_noise = $EngineRoomFloor/gears_noise
onready var reactor_animation = $Reactor/chamber/fire
onready var dispenser = $Dispenser
onready var left_blinker = $Dispenser/left_blinker
onready var right_blinker = $Dispenser/right_blinker
onready var reactor_sound = $Reactor/noise
onready var reactor_temp = $ReactorTemp
onready var reactor_timer = $Reactor/BurnTimer
onready var coolant_level = $CoolantLevel
onready var coolant_timer = $CoolantChamber/LevelTimer
onready var coolant_animation = $CoolantChamber/chamber/coolant
onready var coolant_sound = $CoolantChamber/noise
onready var item_timer = $Dispenser/ItemTimer
onready var conveyor = $Conveyor
onready var fuel_count = $GridContainer/fuelcrystal/fuelcounter
onready var cool_count = $GridContainer/coolantcrystal/coolantcounter
onready var upgrade_count = $GridContainer/upgrade2/upgradecounter
onready var restart_button = $background/Restart
onready var score = $score

var conveyor_velocity = Vector2()
var reactor_running = false
var gears_running = false
var coolant_running = false
var dispenser_running = false
var xs = "x"

var last_item_spawn_position
var item_buffer = []
var current_item

var run_speed = 350
var gravity = 2500
var velocity = Vector2()

var reactor_max_temp = 5000
var coolant_level_max = 5000
var score_temp

func _ready():
	restart_button.visible = not visible

func _on_Dispenser_start_conveyor():
	var gears = get_tree().get_nodes_in_group("gears")
	if not gears_running:
		for each in gears:
			each.play("turn")
		gear_noise.play()
		gears_running = true
	else:
		for each in gears:
			each.stop()
		gear_noise.stop()
		gears_running = false

func _on_Dispenser_start_reactor():
	if not reactor_running:
		reactor_animation.visible = visible
		reactor_animation.play("burn")
		reactor_sound.play()
		reactor_timer.start()
		reactor_running = true
		reactor_temp.text = "1000"
	else:
		reactor_animation.stop()
		reactor_animation.visible = not visible
		reactor_sound.stop()
		reactor_running = false

func _on_Dispenser_start_coolant():
	if not coolant_running:
		coolant_animation.visible = visible
		coolant_animation.play("cool")
		coolant_sound.play()
		coolant_timer.start()
		coolant_running = true
		coolant_level.text = "1000"
	else:
		coolant_animation.stop()
		coolant_animation.visible = not visible
		coolant_sound.stop()
		coolant_running = false

func _on_Reactor_reactor_cooling():
	var r_temp = int(reactor_temp.text)
	r_temp -= 15
	reactor_temp.text = str(r_temp)
	if int(r_temp) <= 500:
		announcement.text = "Critically low reactor temp! Stall out imminient!"
	if int(r_temp) < 100:
		announcement.text = "Reactor scrammed! Shutting down!"
		game_stop()

func _on_CoolantChamber_coolant_level_dropping():
	var c_level = int(coolant_level.text)
	c_level -= 10
	coolant_level.text = str(c_level)
	if c_level <= 500:
		announcement.text = "Critically low coolant level! Reactor temperature rising faster!"
	if c_level < 100:
		announcement.text = "Coolant levels collapsing! Abandon ship!"
		game_stop()
			
func game_stop():
	item_timer.stop()
	dispenser.visible = not visible
	restart_button.visible = visible
	
func _on_Dispenser_start_dispenser():
	if not dispenser_running:
		item_timer.start()
		dispenser_running = true
	else:
		item_timer.stop()
		dispenser_running = false

func get_input():
	conveyor_velocity = conveyor.constant_linear_velocity
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	if right:
		if conveyor_velocity > Vector2(500,0):
			conveyor_velocity = Vector2(250,0)
		conveyor_velocity += Vector2(10,0)
		conveyor.constant_linear_velocity = conveyor_velocity
		right_blinker.playing = true
		left_blinker.playing = false
	if left:
		if conveyor_velocity < Vector2(-500,0):
			conveyor_velocity = Vector2(-250,0)
		conveyor_velocity -= Vector2(10,0)
		conveyor.constant_linear_velocity = conveyor_velocity
		left_blinker.playing = true
		right_blinker.playing = false

func _physics_process(delta):
	get_input()

func _on_Dispenser_create_item():
	if item_buffer.size() <= 4:
		reactor_timer.paused = true
		var new_item = random_item.instance()
		item_buffer.append(new_item)
		return
	elif item_buffer.size() >= 5:
		reactor_timer.paused = false
		var new_item_position = item_dispenser.position
		current_item = item_buffer[0]
		item_buffer.pop_front()
		add_child(current_item)
		var c_item_type = str(current_item.item_type)
		current_item.add_to_group(c_item_type)
		current_item.position = new_item_position
		announcement.text = "Current item: " + c_item_type
		_count_items(c_item_type)
		
func _count_items(c_item_type):
	var itemtype = c_item_type
	if itemtype == "coolant":
		var cc = int(cool_count.text)
		cc += 1
		cool_count.text = xs + str(cc)
	if itemtype == "fuel":
		var fc = int(fuel_count.text)
		fc += 1
		fuel_count.text = xs + str(fc)
	if itemtype == "upgrade":
		var uc = int(upgrade_count.text)
		uc += 1
		upgrade_count.text = xs + str(uc)

func _on_CoolantChamber_modify_coolant(area):
	if area == "coolant":
		var c_level = int(coolant_level.text)
		c_level += 100
		coolant_level.text = str(c_level)
		score_temp = int(score.text) + 100 * 2
		score.text = str(score_temp)
		announcement.text = "Coolant level rising!"
	if area == "fuel":
		var c_level = int(coolant_level.text)
		c_level -= 250
		coolant_level.text = str(c_level)
		announcement.text = "Fuel contaminate in coolant!"
	if area == "upgrade":
		coolant_level_max += 30
		score_temp = int(score.text) + 30 * 2
		score.text = str(score_temp)
		announcement.text = "Raising maximum coolant level!"


func _on_Reactor_modify_reactor(area):
	if area == "coolant":
		var r_temp = int(reactor_temp.text)
		r_temp -= 250
		reactor_temp.text = str(r_temp)
		announcement.text = "Reactor temp falling!"
	if area == "fuel":
		var r_temp = int(reactor_temp.text)
		r_temp += 100
		score_temp = int(score.text) + 100 * 2
		score.text = str(score_temp)
		reactor_temp.text = str(r_temp)
		announcement.text = "Reactor temp rising! Upgrade shieleding immediately!"
	if area == "upgrade":
		reactor_max_temp += 100
		score_temp = int(score.text) + 100 * 2
		score.text = str(score_temp)
		announcement.text = "Reactor maximum temp raised!"


func _on_Restart_pressed():
	get_tree().reload_current_scene()
