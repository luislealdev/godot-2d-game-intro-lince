extends CharacterBody2D

# exportamos al inspector la variable
# variable para la rapidez de movimiento
@export var walk_speed = 4.0
# Constante del tamano de los mosaicos o tiles
const TILE_SIZE = 16

# Referencias para los nodos de animaciones
@onready var animation_tree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")

# Referencias para el nodo raycast
@onready var ray_cast_2d = $RayCast2D

# Variables para la posicion y direccion del jugador
var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
# Bandera para detectar si hay movimiento en el jugador
var is_moving = false
# Porcentaje que hemos cruzado de un tile
var percent_moved_to_next_tile = 0.0

# Al cargar la escena
func _ready():
	animation_tree.active = true # activamos el animation tree
	initial_position = position # Establecemos la posicion inicial del jugador

# called every frame
func _physics_process(delta):
	if is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk") # We change from Idle to Walk
		move(delta)
	else:
		anim_state.travel("Idle") # We change from Walk to Idle
		is_moving = false

func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	if input_direction != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_direction) # Change the direction value in blendspace 
		animation_tree.set("parameters/Walk/blend_position", input_direction) # Change the direction value in blendspace 
		initial_position = position
		is_moving = true
	else:
		anim_state.travel("Idle") # We cahnge from Walk to Idle

func move(delta):
	percent_moved_to_next_tile += walk_speed * delta
	# Vector2 of the Next tile
	var desired_step = input_direction * TILE_SIZE / 2
	ray_cast_2d.target_position = desired_step
	ray_cast_2d.force_raycast_update()
	if !ray_cast_2d.is_colliding():
		if percent_moved_to_next_tile  >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		percent_moved_to_next_tile = 0.0
		is_moving = false

