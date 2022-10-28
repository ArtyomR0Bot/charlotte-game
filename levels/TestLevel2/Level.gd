extends Node2D


const FragileBrick = preload("FragileBrick.tscn")
const Coin = preload("items/Coin.tscn")
const Orb = preload("items/Orb.tscn")


var character: KinematicBody2D
var start_position: Vector2
var coins = 0
var orbs = 0

onready var brick_id = $FragileMap.tile_set.find_tile_by_name("brick walls")
onready var item_coin_id = $ItemMap.tile_set.find_tile_by_name("coin")
onready var item_orb_id = $ItemMap.tile_set.find_tile_by_name("orb")


func _physics_process(_delta):
	if character.position.y > 700:
		reset()


func _ready():
	character = $Sharik
	start_position = character.position
	$FragileMap.hide()
	$ItemMap.hide()
	reset()


func _on_item_body_entered(body: KinematicBody2D, item: Node2D, item_id: int):
	if body == character:
		item.destroy()
	match item_id:
		item_coin_id:
			coins += 1
		item_orb_id:
			orbs += 1
	update_hud()


func reset():
	coins = 0
	orbs = 0
	character.reset()
	character.position = start_position
	character.face_right()
	for child in $TileMap.get_children():
		$TileMap.remove_child(child)
		child.queue_free()
	for cell_pos in $FragileMap.get_used_cells():
		var tile_id = $FragileMap.get_cellv(cell_pos)
		if tile_id != TileMap.INVALID_CELL:
			var cell_local_pos = $FragileMap.map_to_world(cell_pos)
			var cell_global_pos = $FragileMap.to_global(cell_local_pos)
			var item_pos = cell_global_pos + $FragileMap.cell_size / 2
			add_fragile_bricks(tile_id, item_pos)
	for cell_pos in $ItemMap.get_used_cells():
		var tile_id = $ItemMap.get_cellv(cell_pos)
		if tile_id != TileMap.INVALID_CELL:
			var cell_local_pos = $ItemMap.map_to_world(cell_pos)
			var cell_global_pos = $ItemMap.to_global(cell_local_pos)
			var item_pos = cell_global_pos + $ItemMap.cell_size / 2
			add_item(tile_id, item_pos)
	for moving in $Moving.get_children():
		var object = moving.get_node("AnimationPlayer") as AnimationPlayer
		object.stop()
		object.play("move")
	update_hud()


func add_fragile_bricks(item_id: int, pos: Vector2):
	match item_id:
		brick_id:
			var brick = FragileBrick.instance()
			brick.position = $TileMap.to_local(pos)
			$TileMap.add_child(brick)


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
			item.position = $TileMap.to_local(pos)
			$TileMap.add_child(item)


func update_hud():
	$"%LabelCoins".text = str(coins)
	$"%LabelOrbs".text = str(orbs)
