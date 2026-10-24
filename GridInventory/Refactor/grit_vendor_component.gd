class_name GritVendorComponent
extends GritItemMover

@export var npc_vendor_agent : GritVendorAgent
@export var player_vendor_agent : GritVendorAgent

@export var npc_grit: GritContainer
@export var vendor_grit: GritContainer
@export var player_grit: GritContainer

@export var buy_button : Button
@export var sell_button : Button

## Label for updating the gold amount
@export var buy_label : Label
@export var sell_label : Label

signal items_vendored(item)

var buy_display_amount : int = 0:
	set(value):
		buy_display_amount = value
		if buy_display_amount < 0:
			buy_display_amount = 0
			
var sell_display_amount: int = 0:
	set(value):
		sell_display_amount = value
		if sell_display_amount < 0:
			sell_display_amount = 0

func _ready() -> void:
	buy_label.text = "0"
	sell_label.text = "0"
	
	# Transfer from NPC to Player
	buy_button.pressed.connect(_on_vendor_button_pressed.bind("Player"))
	# Transfer from Player to NPC
	sell_button.pressed.connect(_on_vendor_button_pressed.bind("Npc"))	
	
	vendor_grit.item_added.connect(update_vendor_display_amount)


## For both buy and sell buttons, just changes the owner, either "Player" , "Npc", or "None"
func _on_vendor_button_pressed(new_owner:String):
	
	var item_list := vendor_grit.item_stored.duplicate() # Duplicate or else it doesn't loop as it modifies the list during the loop
	var items_transferred = []
	item_list.sort()
	for item in item_list:		

		if item.item_owner == new_owner: # Skips items that are not meant to be transferred 
			continue
		# If Player is selling to NPC, NPC should enough to buy:
		if new_owner == "Npc":
			if get_items_to_trade_value("Player") > npc_vendor_agent.get_gold_amount():
				P.pr("NPC doesnt have enough gold to buy item")
				return
			
			item.set_item_owner(new_owner)
			move_items(vendor_grit,npc_grit)
			player_vendor_agent.inventory.add_gold(item.get_value())
			npc_vendor_agent.inventory.remove_gold(item.get_value())
			
			items_transferred.append(item)
			
		# If player is buying from NPC; Player should have more than the worth of the items to be sold
		if new_owner == "Player":
			if get_items_to_trade_value("Npc") > player_vendor_agent.get_gold_amount():
				P.pr("Not enough gold to buy item")
				return
			
			item.set_item_owner(new_owner)
			move_items(vendor_grit,player_grit)
			
			player_vendor_agent.inventory.remove_gold(item.get_value())
			npc_vendor_agent.inventory.add_gold(item.get_value())			
			
			items_transferred.append(item)
	
	if items_transferred.size() == 0:
		P.pr("No items transferred")
		return
	
	P.pr("Transferred Items: ", items_transferred)
	
	#items_vendored.emit(items_transferred)
	update_items(new_owner, items_transferred)	
	update_vendor_display_amount()
	
func update_vendor_display_amount(_item = null):
	buy_label.text = str(get_items_to_trade_value("Npc"))
	sell_label.text = str(get_items_to_trade_value("Player"))
			
func get_items_to_trade_value(item_owner):
	var total_value: = 0
	for item in vendor_grit.item_stored:
		if item.item_owner == item_owner:
				total_value += item.get_value()
	
	return total_value

func update_items(target, items_transferred):
	if target == "Player":	
		for i in items_transferred:
			P.pr("Removing item: ", i.item_stack)
			npc_vendor_agent.inventory.remove_item(i.item_stack)
			player_vendor_agent.inventory.add_item(i.item_stack)
			
			
	if target == "Npc":
		for i in items_transferred:
			player_vendor_agent.inventory.remove_item(i.item_stack)
			npc_vendor_agent.inventory.add_item(i.item_stack)
			