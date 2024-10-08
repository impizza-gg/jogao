extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectile") or body.is_in_group("pickup") or body.is_in_group("shell"):
		body.queue_free()
		
	if multiplayer.is_server():
		if body.is_in_group("player"):
			if body.has_method("update_health"):
				body.rpc("update_health", -999.0)
			if body.has_method("change_camera"):
				body.rpc("change_camera")

