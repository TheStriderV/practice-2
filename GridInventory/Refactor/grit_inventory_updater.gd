## Updates all GUI and manages inventory functions
class_name GritVendorAgent
extends Node

@export var inventory : Inventory
@export var grit_container : GritContainer

@onready var gold_amount := inventory.get_gold()

func _ready():
	P.pr(gold_amount)
	#gold_amount = inventory.get_gold()
	
	pass

func get_gold_amount():
	return inventory.get_gold()


func _connect_signals():
	pass

