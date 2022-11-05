extends Node2D


const Coin = preload("items/Coin.tscn")
const Orb = preload("items/Orb.tscn")


var character: KinematicBody2D
var start_position: Vector2
var coins = 0
var orbs = 0

onready var item_coin_id = $ItemMap.tile_set.find_tile_by_name("coin")
onready var item_orb_id = $ItemMap.tile_set.find_tile_by_name("orb")


func _ready():
	character = $Sharik
	start_position = character.position
	$ItemMap.hide()
	reset()


func _physics_process(_delta):
	if character.position.y > 700:
		reset()


func _process(_delta):
	pass


func _on_item_body_entered(body: KinematicBody2D, item: Node2D, item_id: int):
	if body == character:
		item.destroy()
	match item_id:
		item_coin_id:
			coins += 1
		item_orb_id:
			orbs += 1
	update_hud()


func add_item(item_id: int, pos: Vector2):
	match item_id:
		item_coin_id, item_orb_id:
			var Class: PackedScene
			match item_id:
				item_coin_id:
					Class = Coin
				item_orb_id:
					Class = Orb
			var item = Class.instance()
			var item_area = item.get_node("Area2D")
			item_area.connect("body_entered", self,
								"_on_item_body_entered", [item, item_id])
			item.position = $Items.to_local(pos)
			$Items.add_child(item)


func reset():
	coins = 0
	orbs = 0
	character.position = start_position
	character.face_right()
	for child in $Items.get_children():
		$Items.remove_child(child)
		child.queue_free()
	for cell_pos in $ItemMap.get_used_cells():
		var tile_id = $ItemMap.get_cellv(cell_pos)
		if tile_id != TileMap.INVALID_CELL:
			var cell_local_pos = $ItemMap.map_to_world(cell_pos)
			var cell_global_pos = $ItemMap.to_global(cell_local_pos)
			var item_pos = cell_global_pos + $ItemMap.cell_size / 2
			add_item(tile_id, item_pos)
	update_hud()


func update_hud():
	$"%LabelCoins".text = str(coins)
	$"%LabelOrbs".text = str(orbs)
