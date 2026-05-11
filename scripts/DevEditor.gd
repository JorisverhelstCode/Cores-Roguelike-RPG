extends Control

const MAIN_SCRIPT = preload("res://scripts/Main.gd")
const CARD_VIEW_SCRIPT = preload("res://scripts/CardView.gd")
const MAP_CANVAS_SCRIPT = preload("res://scripts/DevMapCanvas.gd")
const LOCATIONS_DATA_PATH := "res://assets/data/locations.json"
const ROUTES_DATA_PATH := "res://assets/data/routes.json"
const CARDS_DATA_PATH := "res://assets/data/cards.json"
const MAP_PATH := "res://assets/maps/Belland.png"

var locations: Array[Dictionary] = []
var routes: Array[Array] = []
var cards: Dictionary = {}
var selected_location_index := -1
var selected_card_id := ""
var last_map_click := Vector2(0.5, 0.5)
var populating := false

var status_label: Label
var map_canvas: Control
var location_list: ItemList
var route_text: TextEdit
var location_id_field: LineEdit
var location_name_field: LineEdit
var location_type_field: OptionButton
var location_x_spin: SpinBox
var location_y_spin: SpinBox
var location_danger_spin: SpinBox
var location_core_field: LineEdit
var location_lore_field: TextEdit
var location_places_field: LineEdit

var card_list: ItemList
var card_preview_box: Control
var card_id_field: LineEdit
var card_name_field: LineEdit
var card_type_field: OptionButton
var damage_type_field: OptionButton
var cores_spin: SpinBox
var energy_spin: SpinBox
var damage_spin: SpinBox
var range_spin: SpinBox
var move_spin: SpinBox
var block_spin: SpinBox
var magic_block_spin: SpinBox
var card_text_field: TextEdit

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1500, 920))
	load_data()
	build_ui()
	refresh_all()

func load_data() -> void:
	locations = load_location_data()
	routes = load_route_data()
	cards = load_card_data()

func load_location_data() -> Array[Dictionary]:
	var data: Variant = load_json(LOCATIONS_DATA_PATH)
	if data is Array:
		var loaded: Array[Dictionary] = []
		for item in data:
			if item is Dictionary:
				loaded.append(item)
		if not loaded.is_empty():
			return loaded
	return MAIN_SCRIPT.DEFAULT_LOCATIONS.duplicate(true)

func load_route_data() -> Array[Array]:
	var data: Variant = load_json(ROUTES_DATA_PATH)
	if data is Array:
		var loaded: Array[Array] = []
		for item in data:
			if item is Array:
				loaded.append(item)
		if not loaded.is_empty():
			return loaded
	return MAIN_SCRIPT.DEFAULT_ROUTES.duplicate(true)

func load_card_data() -> Dictionary:
	var data: Variant = load_json(CARDS_DATA_PATH)
	if data is Dictionary and not data.is_empty():
		return data
	return MAIN_SCRIPT.DEFAULT_CARDS.duplicate(true)

func load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

func build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 18
	root.offset_top = 14
	root.offset_right = -18
	root.offset_bottom = -18
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 10)
	root.add_child(top_bar)

	var title := Label.new()
	title.text = "Aftermath Development Editor"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)

	var reload_button := Button.new()
	reload_button.text = "Reload JSON"
	reload_button.pressed.connect(func() -> void:
		load_data()
		refresh_all()
		set_status("Reloaded editor data.")
	)
	top_bar.add_child(reload_button)

	var save_button := Button.new()
	save_button.text = "Save All"
	save_button.pressed.connect(save_all)
	top_bar.add_child(save_button)

	status_label = Label.new()
	status_label.text = "Edits save to res://assets/data for development builds."
	root.add_child(status_label)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)

	var map_tab := HBoxContainer.new()
	map_tab.name = "Map Designer"
	map_tab.add_theme_constant_override("separation", 12)
	tabs.add_child(map_tab)
	build_map_tab(map_tab)

	var card_tab := HBoxContainer.new()
	card_tab.name = "Card Designer"
	card_tab.add_theme_constant_override("separation", 12)
	tabs.add_child(card_tab)
	build_card_tab(card_tab)

func build_map_tab(parent: HBoxContainer) -> void:
	map_canvas = MAP_CANVAS_SCRIPT.new()
	map_canvas.custom_minimum_size = Vector2(860, 720)
	map_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_canvas.location_selected.connect(select_location)
	map_canvas.location_position_changed.connect(move_location)
	map_canvas.map_position_chosen.connect(func(position: Vector2) -> void: last_map_click = position)
	parent.add_child(map_canvas)

	var inspector_scroll := ScrollContainer.new()
	inspector_scroll.custom_minimum_size = Vector2(430, 0)
	inspector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(inspector_scroll)

	var inspector := VBoxContainer.new()
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.add_theme_constant_override("separation", 8)
	inspector_scroll.add_child(inspector)

	location_list = ItemList.new()
	location_list.custom_minimum_size = Vector2(390, 210)
	location_list.item_selected.connect(select_location)
	inspector.add_child(label_above("Locations", location_list))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	inspector.add_child(row)
	row.add_child(make_button("Add Town", func() -> void: add_location("town")))
	row.add_child(make_button("Add Event", func() -> void: add_location("event")))
	row.add_child(make_button("Duplicate", duplicate_location))
	row.add_child(make_button("Delete", delete_location))

	location_id_field = make_line_edit(update_location_id)
	inspector.add_child(label_above("ID", location_id_field))
	location_name_field = make_line_edit(func(text: String) -> void: set_location_value("name", text))
	inspector.add_child(label_above("Name", location_name_field))
	location_type_field = make_option(["town", "event"], func(text: String) -> void: set_location_value("type", text))
	inspector.add_child(label_above("Type", location_type_field))

	var coord_row := HBoxContainer.new()
	coord_row.add_theme_constant_override("separation", 8)
	location_x_spin = make_spin(0.0, 1.0, 0.001, func(value: float) -> void: set_location_float("x", value))
	location_y_spin = make_spin(0.0, 1.0, 0.001, func(value: float) -> void: set_location_float("y", value))
	coord_row.add_child(label_above("X", location_x_spin))
	coord_row.add_child(label_above("Y", location_y_spin))
	inspector.add_child(coord_row)

	location_danger_spin = make_spin(0.0, 10.0, 1.0, func(value: float) -> void: set_location_value("danger", int(value)))
	inspector.add_child(label_above("Danger", location_danger_spin))
	location_core_field = make_line_edit(func(text: String) -> void: set_location_value("core", text))
	inspector.add_child(label_above("Core", location_core_field))
	location_places_field = make_line_edit(update_location_places)
	inspector.add_child(label_above("Town Places, comma separated", location_places_field))

	location_lore_field = TextEdit.new()
	location_lore_field.custom_minimum_size = Vector2(390, 96)
	location_lore_field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	location_lore_field.text_changed.connect(func() -> void:
		if not populating:
			set_location_value("lore", location_lore_field.text)
	)
	inspector.add_child(label_above("Lore", location_lore_field))

	route_text = TextEdit.new()
	route_text.custom_minimum_size = Vector2(390, 170)
	route_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	route_text.text_changed.connect(func() -> void:
		if not populating:
			routes = parse_routes(route_text.text)
	)
	inspector.add_child(label_above("Routes, one id -> id per line", route_text))

func build_card_tab(parent: HBoxContainer) -> void:
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(320, 0)
	left.add_theme_constant_override("separation", 8)
	parent.add_child(left)

	card_list = ItemList.new()
	card_list.custom_minimum_size = Vector2(300, 500)
	card_list.item_selected.connect(func(index: int) -> void:
		var ids := sorted_card_ids()
		if index >= 0 and index < ids.size():
			select_card(ids[index])
	)
	left.add_child(label_above("Cards", card_list))

	var card_buttons := HBoxContainer.new()
	card_buttons.add_theme_constant_override("separation", 8)
	left.add_child(card_buttons)
	card_buttons.add_child(make_button("Add", add_card))
	card_buttons.add_child(make_button("Duplicate", duplicate_card))
	card_buttons.add_child(make_button("Delete", delete_card))

	var middle_scroll := ScrollContainer.new()
	middle_scroll.custom_minimum_size = Vector2(470, 0)
	middle_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	middle_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(middle_scroll)

	var inspector := VBoxContainer.new()
	inspector.add_theme_constant_override("separation", 8)
	middle_scroll.add_child(inspector)

	card_id_field = make_line_edit(func(_text: String) -> void: pass)
	inspector.add_child(label_above("ID", card_id_field))
	inspector.add_child(make_button("Apply ID Rename", apply_card_id_rename))
	card_name_field = make_line_edit(func(text: String) -> void: set_card_value("name", text))
	inspector.add_child(label_above("Name", card_name_field))
	card_type_field = make_option(["attack", "skill", "move"], func(text: String) -> void: set_card_value("type", text))
	inspector.add_child(label_above("Type", card_type_field))
	damage_type_field = make_option(["normal", "magic"], func(text: String) -> void: set_card_value("damage_type", text))
	inspector.add_child(label_above("Damage Type", damage_type_field))

	var stats_grid := GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 10)
	stats_grid.add_theme_constant_override("v_separation", 8)
	inspector.add_child(stats_grid)
	cores_spin = add_card_spin(stats_grid, "Cores", "cores")
	energy_spin = add_card_spin(stats_grid, "Energy", "energy")
	damage_spin = add_card_spin(stats_grid, "Damage", "damage")
	range_spin = add_card_spin(stats_grid, "Range", "range")
	move_spin = add_card_spin(stats_grid, "Move", "move")
	block_spin = add_card_spin(stats_grid, "Block", "block")
	magic_block_spin = add_card_spin(stats_grid, "Magic Block", "magic_block")

	card_text_field = TextEdit.new()
	card_text_field.custom_minimum_size = Vector2(430, 160)
	card_text_field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	card_text_field.text_changed.connect(func() -> void:
		if not populating:
			set_card_value("text", card_text_field.text)
	)
	inspector.add_child(label_above("Rules Text", card_text_field))

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(260, 0)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(preview_panel)
	card_preview_box = CenterContainer.new()
	preview_panel.add_child(card_preview_box)

func refresh_all() -> void:
	refresh_map()
	refresh_card_list()
	if selected_location_index < 0 and not locations.is_empty():
		select_location(0)
	if selected_card_id == "" and not cards.is_empty():
		select_card(sorted_card_ids()[0])

func refresh_map() -> void:
	var texture := load(MAP_PATH) as Texture2D
	map_canvas.configure(texture, locations)
	refresh_location_list()
	route_text.text = routes_to_text()

func refresh_location_list() -> void:
	location_list.clear()
	for location in locations:
		location_list.add_item("%s  [%s]" % [str(location.get("name", location.get("id", "Location"))), str(location.get("type", "town"))])

func select_location(index: int) -> void:
	if index < 0 or index >= locations.size():
		return
	selected_location_index = index
	location_list.select(index)
	map_canvas.set_selected_index(index)
	populating = true
	var location := locations[index]
	location_id_field.text = str(location.get("id", ""))
	location_name_field.text = str(location.get("name", ""))
	set_option_text(location_type_field, str(location.get("type", "town")))
	location_x_spin.value = float(location.get("x", 0.5))
	location_y_spin.value = float(location.get("y", 0.5))
	location_danger_spin.value = float(location.get("danger", 1))
	location_core_field.text = str(location.get("core", ""))
	location_lore_field.text = str(location.get("lore", ""))
	location_places_field.text = ", ".join(PackedStringArray(location.get("town", [])))
	populating = false

func add_location(kind: String) -> void:
	var id := unique_id("new_%s" % kind, location_ids())
	var location := {"id": id, "name": id.capitalize(), "type": kind, "x": last_map_click.x, "y": last_map_click.y, "danger": 1, "core": "", "lore": ""}
	if kind == "town":
		location["town"] = ["Inn", "Shop"]
	locations.append(location)
	refresh_location_list()
	select_location(locations.size() - 1)

func duplicate_location() -> void:
	if selected_location_index < 0:
		return
	var copy: Dictionary = locations[selected_location_index].duplicate(true)
	copy["id"] = unique_id("%s_copy" % str(copy.get("id", "location")), location_ids())
	copy["name"] = "%s Copy" % str(copy.get("name", "Location"))
	locations.append(copy)
	refresh_location_list()
	select_location(locations.size() - 1)

func delete_location() -> void:
	if selected_location_index < 0:
		return
	locations.remove_at(selected_location_index)
	selected_location_index = mini(selected_location_index, locations.size() - 1)
	refresh_location_list()
	if selected_location_index >= 0:
		select_location(selected_location_index)
	map_canvas.set_locations(locations)

func move_location(index: int, position: Vector2) -> void:
	if index < 0 or index >= locations.size():
		return
	locations[index]["x"] = snappedf(position.x, 0.001)
	locations[index]["y"] = snappedf(position.y, 0.001)
	if index == selected_location_index:
		populating = true
		location_x_spin.value = float(locations[index]["x"])
		location_y_spin.value = float(locations[index]["y"])
		populating = false
	map_canvas.set_locations(locations)

func update_location_id(text: String) -> void:
	if selected_location_index < 0 or populating:
		return
	locations[selected_location_index]["id"] = text.strip_edges().to_lower().replace(" ", "_")
	refresh_location_list()

func update_location_places(text: String) -> void:
	if selected_location_index < 0 or populating:
		return
	var places: Array[String] = []
	for raw_place in text.split(","):
		var place := str(raw_place).strip_edges()
		if place != "":
			places.append(place)
	locations[selected_location_index]["town"] = places

func set_location_float(key: String, value: float) -> void:
	set_location_value(key, snappedf(value, 0.001))
	map_canvas.set_locations(locations)

func set_location_value(key: String, value: Variant) -> void:
	if selected_location_index < 0 or populating:
		return
	locations[selected_location_index][key] = value
	refresh_location_list()
	map_canvas.set_locations(locations)

func refresh_card_list() -> void:
	card_list.clear()
	for card_id in sorted_card_ids():
		var card: Dictionary = cards[card_id]
		card_list.add_item("%s  [%s]" % [str(card.get("name", card_id)), card_id])

func select_card(card_id: String) -> void:
	if not cards.has(card_id):
		return
	selected_card_id = card_id
	var ids := sorted_card_ids()
	var index := ids.find(card_id)
	if index >= 0:
		card_list.select(index)
	populating = true
	var card: Dictionary = cards[card_id]
	card_id_field.text = card_id
	card_name_field.text = str(card.get("name", ""))
	set_option_text(card_type_field, str(card.get("type", "attack")))
	set_option_text(damage_type_field, str(card.get("damage_type", "normal")))
	cores_spin.value = float(card.get("cores", 0))
	energy_spin.value = float(card.get("energy", 0))
	damage_spin.value = float(card.get("damage", 0))
	range_spin.value = float(card.get("range", 0))
	move_spin.value = float(card.get("move", 0))
	block_spin.value = float(card.get("block", 0))
	magic_block_spin.value = float(card.get("magic_block", 0))
	card_text_field.text = str(card.get("text", ""))
	populating = false
	refresh_card_preview()

func add_card() -> void:
	var id := unique_id("new_card", sorted_card_ids())
	cards[id] = {"name": "New Card", "cores": 0, "energy": 0, "type": "attack", "damage_type": "normal", "damage": 1, "range": 1, "block": 0, "magic_block": 0, "text": ""}
	refresh_card_list()
	select_card(id)

func duplicate_card() -> void:
	if selected_card_id == "":
		return
	var id := unique_id("%s_copy" % selected_card_id, sorted_card_ids())
	cards[id] = cards[selected_card_id].duplicate(true)
	cards[id]["name"] = "%s Copy" % str(cards[id].get("name", "Card"))
	refresh_card_list()
	select_card(id)

func delete_card() -> void:
	if selected_card_id == "":
		return
	cards.erase(selected_card_id)
	selected_card_id = ""
	refresh_card_list()
	if not cards.is_empty():
		select_card(sorted_card_ids()[0])
	else:
		clear_children(card_preview_box)

func apply_card_id_rename() -> void:
	if selected_card_id == "":
		return
	var new_id := card_id_field.text.strip_edges().to_lower().replace(" ", "_")
	if new_id == "" or new_id == selected_card_id or cards.has(new_id):
		set_status("Card ID rename skipped. Use a unique non-empty ID.")
		return
	cards[new_id] = cards[selected_card_id]
	cards.erase(selected_card_id)
	selected_card_id = new_id
	refresh_card_list()
	select_card(new_id)

func set_card_value(key: String, value: Variant) -> void:
	if selected_card_id == "" or populating:
		return
	cards[selected_card_id][key] = value
	refresh_card_list()
	refresh_card_preview()

func refresh_card_preview() -> void:
	clear_children(card_preview_box)
	if selected_card_id == "" or not cards.has(selected_card_id):
		return
	var card_view = CARD_VIEW_SCRIPT.new()
	var preview_data: Dictionary = cards[selected_card_id].duplicate(true)
	preview_data["source_icon"] = preview_data.get("type", "attack")
	card_view.setup(preview_data)
	card_view.draggable = false
	card_view.scale = Vector2(1.85, 1.85)
	card_preview_box.add_child(card_view)

func save_all() -> void:
	ensure_data_dir()
	routes = parse_routes(route_text.text)
	save_json(LOCATIONS_DATA_PATH, locations)
	save_json(ROUTES_DATA_PATH, routes)
	save_json(CARDS_DATA_PATH, cards)
	set_status("Saved map and card data to assets/data.")

func ensure_data_dir() -> void:
	var dir := DirAccess.open("res://")
	if dir != null:
		dir.make_dir_recursive("assets/data")

func save_json(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))

func routes_to_text() -> String:
	var lines: Array[String] = []
	for route in routes:
		if route.size() >= 2:
			lines.append("%s -> %s" % [str(route[0]), str(route[1])])
	return "\n".join(lines)

func parse_routes(text: String) -> Array[Array]:
	var parsed: Array[Array] = []
	for raw_line in text.split("\n"):
		var line := str(raw_line).strip_edges()
		if line == "":
			continue
		var separator := "->" if line.contains("->") else ","
		var parts := line.split(separator)
		if parts.size() >= 2:
			parsed.append([str(parts[0]).strip_edges(), str(parts[1]).strip_edges()])
	return parsed

func add_card_spin(parent: Control, label: String, key: String) -> SpinBox:
	var spin := make_spin(0.0, 99.0, 1.0, func(value: float) -> void: set_card_value(key, int(value)))
	parent.add_child(label_above(label, spin))
	return spin

func make_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(92, 34)
	button.pressed.connect(action)
	return button

func make_line_edit(on_change: Callable) -> LineEdit:
	var field := LineEdit.new()
	field.custom_minimum_size = Vector2(260, 34)
	field.text_changed.connect(func(text: String) -> void:
		if not populating:
			on_change.call(text)
	)
	return field

func make_option(items: Array[String], on_change: Callable) -> OptionButton:
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(220, 34)
	for item in items:
		option.add_item(item)
	option.item_selected.connect(func(index: int) -> void:
		if not populating:
			on_change.call(option.get_item_text(index))
	)
	return option

func make_spin(minimum: float, maximum: float, step: float, on_change: Callable) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.custom_minimum_size = Vector2(120, 34)
	spin.value_changed.connect(func(value: float) -> void:
		if not populating:
			on_change.call(value)
	)
	return spin

func label_above(text: String, control: Control) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	box.add_child(label)
	box.add_child(control)
	return box

func set_option_text(option: OptionButton, value: String) -> void:
	for index in range(option.item_count):
		if option.get_item_text(index) == value:
			option.select(index)
			return
	option.select(0)

func location_ids() -> Array[String]:
	var ids: Array[String] = []
	for location in locations:
		ids.append(str(location.get("id", "")))
	return ids

func sorted_card_ids() -> Array[String]:
	var ids: Array[String] = []
	for card_id in cards.keys():
		ids.append(str(card_id))
	ids.sort()
	return ids

func unique_id(base_id: String, existing_ids: Array[String]) -> String:
	var clean := base_id.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
	if clean == "":
		clean = "item"
	var candidate := clean
	var suffix := 2
	while existing_ids.has(candidate):
		candidate = "%s_%s" % [clean, suffix]
		suffix += 1
	return candidate

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func set_status(message: String) -> void:
	status_label.text = message
