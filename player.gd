extends CharacterBody3D

@onready var camera = $Camera3D
const SPEED = 10
const JUMP_VELOCITY = 10

var pages_collected = 0

@onready var ray = $Camera3D/RayCast3D
@onready var interaction_notifier = $Control/InteractionNotifier
@onready var collection_tracker = $Control/MarginContainer/CollectionTracker



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func check_ray_hit():
	if ray.is_colliding():
		if ray.get_collider().is_in_group("Pickup"):
			interaction_notifier.visible = true
		if Input.is_action_just_pressed("use"):
			ray.get_collider().queue_free()
			pages_collected += 1
			collection_tracker.text = "Pages :" + str(pages_collected) + "/ 10"
	else:
		interaction_notifier.visible = false
	


func _physics_process(delta):
	check_ray_hit()
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
