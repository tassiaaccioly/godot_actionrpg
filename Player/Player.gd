extends KinematicBody2D

#make this exported vars so we can change those as the game is running if needed
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

#enum is an enumarator, these are like constants, and are enumarated like arrays, 0 indexed.
enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

#the changing positions velocity
#Vector is a (x,y) position that represents the change of the current position
var velocity = Vector2.ZERO 
#we want our roll to happen to the direction we were previously on, but the program will only remember if you're trying to move, so we need to start it facing the direction the playersprite is facing and then update de var inside the input map
var roll_vector = Vector2.DOWN

#animationPlayer is a class from GDScript
#var animationPlayer = null

#we need to set the animationPlayer variable inside the ready function because of the time the animations might take to load, this guarantees the animations will be loaded when we try to access them;
#func _ready():
	#the $ is a shorthand to access node inside a scene, with this one we're accessing the animation node inside the player scene
	#animationPlayer = $AnimationPlayer
	
	#the onready keyword makes the same as the function _ready but it simplifies, so this variable will only be available when the animation is loaded
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#importing the sword knockback_vector in order to set it to the pleyer vector
onready var swordHitbox = $HitboxPivot/SwordHitbox

#this makes that our animationTree won't be active until the game starts so we don't have to maintain it constantly active

func _ready():
	animationTree.active = true
	#setting the knowckback vector of the sword to the same vector of the roll_vector (or where the player is facing) so we can make the enemies knockback in the right direction
	swordHitbox.knockback_vector = roll_vector

#creating an input vector. It works as a axis graphic that goes from 1 to -1 (y reversed) so if the person is pressing to the right it woud be a x of 1 and a y of 0, so input_vector would be 1 for x (ui_right = 1 and ui_left = 0) and input_vector for y would be 0 (ui_up = 0 and ui_down = 0)
#this also allows the character to move in all directions but it's chopy giving us faster diagonal speeds (1 + 1)
#delta is a variable that contains the time that the last frame took to process. this game the physics process will be run at 1/60 of a second, so delta will be 1/60, but if the computer is running slower, delta will have a different value (with frame drops, etc). Slower computer makes delta bigger (1/30 s)
#since we are not accessing any of the properties from the kinematic body we don't really need to use the physics_process, since allour variables wqere created by us. If you need to get access to physics or the player's position, you need to use _physics_process

func _physics_process(delta):
	#this is a state machine, a state machine allows our blocks of code to be run one at a time, so, if you are having problem while moving, the problem is on your moving block, if it's in your roll, it'll be a problem in your roll block, because blocks of codes inside state machines doesn't work at the same time
	#match works like a switch statement but unlike other languages, the cases inside the match statement can be a variable
	match state:
		MOVE:
			#move_state is called here and delta is passed as parameter so we can have it available on the other function
			move_state(delta)
			
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)


		
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		
		#we don't to update our var when the input vector is different then zero, so we update when the character is moving so when it stops moving it will store the direction on the var and the character will roll in that direction. We want to avoid the player rolling in place if he's not moving
		roll_vector = input_vector
		
		#this is setting the knockback vector to the same direction as the player, so it starts at the same direction at the roll_vector and as soon as the player start to move it changes direction to face the player vector
		swordHitbox.knockback_vector = input_vector
		
		#to make animations happen when player moves, but since adding everything to if statements would be very verbose, we're using an animation tree.
		#if input_vector.x > 0:
		#	animationPlayer.play("RunRight")
		#else:
		#	animationPlayer.play("RunLeft")
		#we only update our movement position because once the player stops the program will remember the position the player were facing and stop facing that position
		#this string variable was taken from the animation tree by hovering the Idle Blend Position input
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")

		#multiplying our velocity/acceleration by our delta makes it relative to our frame rate so a slow computer won't have a slower velocity but higher sinde delta for slower computer will be higher
		# this also changes our velocity/acceleration from pixels per frame to amount per second
		#the multiplication by our max speed ensures that the player will be able to move in a "normal" velocity, because multiplying by delta will slow it severely down
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: 
		animationState.travel("Idle")
		#this move_toward function takes the vector, the friction variable and the delta (to make it "real world" updating, from frames to seconds)
		#This is what makes the character stop slowly whenever you stop accelerating
		
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		#whenever you have something that changes over time you have to multiply it by delta to normalize the inputs from frames to seconds (and make it real time)
		
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state(delta):
	#our roll doesn't have any acceleration to it. it automatically goes to full speed once pressed, and we want it to be a bit faster than max_speed, therefore multiply by 1.5. We changed to ROLL_SPEED because we set roll_speed on the beginning of the file, and it's roughly MAX_SPEED * 1.5
	velocity = roll_vector * ROLL_SPEED
	
	#update of the animation
	animationState.travel("Roll")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE
