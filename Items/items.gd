class_name Items
extends RefCounted

const ARMOR_BRONZE = preload("res://Items/Resources/ItemData/armor_bronze.tres")
const AXE = preload("res://Items/Resources/ItemData/axe.tres")
const BOW_WOOD = preload("res://Items/Resources/ItemData/bow_wood.tres")
const CUTLASS = preload("res://Items/Resources/ItemData/cutlass.tres")
const PLANKS = preload("res://Items/Resources/ItemData/planks.tres")
const POTION = preload("res://Items/Resources/ItemData/potion.tres")
const SWORD = preload("res://Items/Resources/ItemData/sword.tres")

static func get_all_items() -> Array:
	var all_items_array = [ARMOR_BRONZE,AXE,BOW_WOOD,CUTLASS,PLANKS,POTION,SWORD]
	return all_items_array
