extends Control

enum MenuOptions {Attacks, Items, Status, Option}

var options : Array[String] = ["Attacks", "Items", "Status", "Option"]

@onready
var main_menu = $Main/MainMenu
@onready
var item_menu = $Main/ItemList

var is_items_open := false
var is_open := false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_up_main()
	pass # Replace with function body.

func set_up_main():
	for i in range(options.size()):
		main_menu.add_item(options[i])

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		if is_open:
			close_menu()
		else:
			open_menu()
	

func open_menu():
	$Main.visible = true
	is_open = true
	PlayerManager.in_menu = true

func close_menu():
	is_open = false
	if is_items_open:
		item_menu.clear()
		item_menu.visible = false
		is_items_open = false
	$Main.visible = false
	PlayerManager.in_menu = false

func _on_main_menu_item_clicked(index, _at_position, _mouse_button_index):
	match index:
		MenuOptions.Attacks:
			print("attacks clicked")
		MenuOptions.Items:
			if !is_items_open:
				item_menu.visible = true
				is_items_open = true
				for item in PlayerManager.inventory:
					item_menu.add_item(item.item_name)
		MenuOptions.Status:
			print("stats")
		MenuOptions.Option:
			print("options")


func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	PlayerManager.use_from_inventory(index)
	close_menu()
	pass # Replace with function body.
