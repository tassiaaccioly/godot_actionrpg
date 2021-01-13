extends Node

#the program infers automatically that this variable is an integer but we could explicitly say it because the 1 could be a float, which allows for decimals, so we can specify a type
#whenever we export the variable we can set the variable on different values for each scene where we call it on
export(int) var max_health = 1

#using onready var because whenever we update the value of max_health throught the program it doesn't update the health, the health remains using the defined in the script. With onready, the var will only be defined when the function _ready is run (and it runs independently of existing or not)
onready var health = max_health setget set_health


#creating a no_health signal to signal up to the bat (you call down and signal up)
signal no_health

#we can pass a setter getter function (line 8), in this specific case we don't need a getter function, but we can define the setter, which means it will call that function each time the the variable is set/reset (we pass the set funcion on line 8 to use this specific function
#so, whenever the stats.health -= 1 on the bat script is run, this function is automatically called under the hood to reset the health here.

func set_health(value): 
	health = value
	if health <= 0:
		emit_signal("no_health")
