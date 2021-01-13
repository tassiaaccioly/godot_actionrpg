extends Node2D

#Load the scene and store it in a variable
const GrassEffect = preload("res://Effects/GrassEffect.tscn")

#this instantiation of scenes inside the code is very important to do anything inside Godot

func create_grass_effect():
	#instance that scene and save it to a variable uppercase G means it's a scene, the lowercase g is an instance of the scene
	var grassEffect = GrassEffect.instance()
	
	#get access to the world and add that scene as a child of the node you want to add it to. In this case we want to add it to the world because the grass will be destryoed before the effect can exist, so it needs to be added to the world
	#this gets the main scene we are currently on our scene tree and adds the instance of the effect to it
	#var world = get_tree().current_scene
	#world.add_child(grassEffect)
	#instead here we'll add it to the parent:
	
	get_parent().add_child(grassEffect)
	
	#where the effect should be
	#this second global_position is the global_position of our grass
	grassEffect.global_position = global_position
	
	#this adds this node into a list of nodes to be destroyed from the world. It doens't destroy it right away, just in case there are things that have to access on this frame. It normally waits for the end of the frame to remove those from the game
	#queue_free()
	
		


func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
