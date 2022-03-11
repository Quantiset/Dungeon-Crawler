extends Area2D

var player
var item

func _ready():
	pass
	
func chest_open():
	var item_idx = randi()%Globals.item_dict.size()
	item = Globals.item_dict.keys()[item_idx]
	

func _on_ItemPickup_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		queue_free()
		player.pickup_item(item)
		
