extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	#we technically don't need this frame=0, but we can leave just in case
	frame = 0
	play("Animate")
	

func _on_animation_finished():
	queue_free()
