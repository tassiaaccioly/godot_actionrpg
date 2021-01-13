extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO

onready var stats = $Stats

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

func _on_HurtBox_area_entered(area):
	#(this is calling down to the stats)
	#area.damage is the hitbox variable inside the hitbox area that is entering the enemy area, in this case, the player sword
	stats.health -= area.damage
	knockback = area.knockback_vector * 120 

func _on_Stats_no_health():
	queue_free()
	#instancing the effect
	var enemyDeathEffect = EnemyDeathEffect.instance()
	#adding the instance of the effect to the parent node (in this case bat)
	get_parent().add_child(enemyDeathEffect)
	#positioning it in the same spot as our enemy
	enemyDeathEffect.global_position = global_position
