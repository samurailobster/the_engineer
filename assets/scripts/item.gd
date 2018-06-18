extends KinematicBody2D

onready var sprite = $Sprite

var conveyor_speed = 350
var GRAVITY = 600
var velocity = Vector2()

export var damage = 25
export var item_type = ["crystal", "fuel", "upgrade"]
export var textures = ['crystal.png', 'fuel.png', 'upgrade.png']

func _ready():
	randomize()
	_initialize_item()

func _initialize_item():
	var random_item = randi() % 3
	var texture = textures[random_item]
	texture = load("res://assets/sprites/items/%s" % texture)
	sprite.texture = texture
	if random_item == 0:
		item_type = "crystal"
	if random_item == 1:
		item_type = "fuel"
	if random_item == 2:
		item_type = "upgrade"
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	if self.is_on_floor():
		if Input.is_action_pressed("move_left"):
        	velocity.x = -conveyor_speed
		elif Input.is_action_pressed("move_right"):
        	velocity.x =  conveyor_speed
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		velocity.x = 0
		velocity = move_and_slide(velocity, Vector2(0, -1))