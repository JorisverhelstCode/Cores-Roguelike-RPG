extends Control

const MAP_PATH := "res://assets/maps/Belland.png"
const TERRAIN_MASK_PATH := "res://assets/maps/Belland_terrain_mask.png"
const KEYBOARD_MOVE_SPEED := 0.075
const CLICK_MOVE_SPEED := 0.065
const OVERWORLD_SQUARE_SIZE := 0.025
const DAYS_PER_YEAR := 365
const HOURS_PER_DAY := 12
const TOWN_ENTRY_RADIUS := 0.018
const TRAVEL_GRID_SIZE := Vector2i(96, 96)
const TERRAIN_SEA := Color8(15, 77, 137)
const TERRAIN_RIVER := Color8(32, 166, 224)
const TERRAIN_PLAINS := Color8(142, 185, 82)
const TERRAIN_DESERT := Color8(221, 190, 112)
const TERRAIN_FOREST := Color8(48, 104, 42)
const TERRAIN_RAINFOREST := Color8(20, 72, 38)
const TERRAIN_MOUNTAIN := Color8(108, 95, 80)
const TERRAIN_TUNDRA := Color8(220, 237, 242)
const MOUNTAIN_CORE_SAMPLE_RADIUS := 0.008
const MOUNTAIN_CORE_NEIGHBOR_THRESHOLD := 6
const FOG_RADIUS := 170.0
const LOCATIONS_DATA_PATH := "res://assets/data/locations.json"
const ROUTES_DATA_PATH := "res://assets/data/routes.json"
const CARDS_DATA_PATH := "res://assets/data/cards.json"
const OVERLAY_CLOSE_BUTTON_TOP := 76.0
const OVERLAY_CLOSE_BUTTON_SIZE := 56.0
const SCREEN_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]
const ICONS := {
	"health": "res://assets/icons/heart.svg",
	"move": "res://assets/icons/foot.svg",
	"speed": "res://assets/icons/running.svg",
	"energy": "res://assets/icons/energy.svg",
	"core": "res://assets/icons/core.svg",
	"block": "res://assets/icons/shield.svg",
	"magic_block": "res://assets/icons/magic_shield.svg",
	"gold": "res://assets/icons/coin.svg",
	"attack": "res://assets/icons/sword.svg",
	"range": "res://assets/icons/range.svg",
	"magic_attack": "res://assets/icons/magic_attack.png",
	"bleeding_heart": "res://assets/icons/bleeding_heart.svg"
}

const DEFAULT_LOCATIONS: Array[Dictionary] = [
	{"id": "eno", "name": "Eno", "type": "town", "x": 0.424, "y": 0.169, "danger": 2, "core": "Pine", "lore": "A northern road-stop tucked below the snowline and watched by old border pines.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "lasty", "name": "Lasty", "type": "town", "x": 0.519, "y": 0.176, "danger": 2, "core": "Frost", "lore": "A wind-bitten settlement where winter traders weigh every rumor twice.", "town": ["Inn", "Shop", "Gate Watch"]},
	{"id": "rock_point", "name": "Rock-Point", "type": "town", "x": 0.609, "y": 0.177, "danger": 3, "core": "Stone", "lore": "A cliffside town built where the cold road breaks against black rock.", "town": ["Inn", "Shop", "Trainer"]},
	{"id": "oak", "name": "Oak", "type": "town", "x": 0.697, "y": 0.176, "danger": 2, "core": "Root", "lore": "A quiet wood-town known for hard bargains and older oaths.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "salt", "name": "Salt", "type": "town", "x": 0.666, "y": 0.210, "danger": 3, "core": "Brine", "lore": "A mineral market at the desert's edge, bright with white dust and sharp tongues.", "town": ["Inn", "Shop", "Tavern"]},
	{"id": "cottage", "name": "Cottage", "type": "town", "x": 0.749, "y": 0.202, "danger": 2, "core": "Hearth", "lore": "A small roadside haven where lanterns stay lit through bad weather.", "town": ["Inn", "Shop", "Militia Yard"]},
	{"id": "valley", "name": "Valley", "type": "town", "x": 0.788, "y": 0.225, "danger": 2, "core": "Reed", "lore": "A river-valley town with soft fields, hard boots, and guarded bridges.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "scrant", "name": "Scrant", "type": "town", "x": 0.835, "y": 0.243, "danger": 3, "core": "Coast", "lore": "A coastal hamlet pressed between surf, reeds, and the eastern road.", "town": ["Inn", "Shop", "Gate Watch"]},
	{"id": "hent", "name": "Hent", "type": "town", "x": 0.778, "y": 0.276, "danger": 3, "core": "Willow", "lore": "A river crossing where ferrymen trade news before coin.", "town": ["Inn", "Shop", "Tavern"]},
	{"id": "heat", "name": "Heat", "type": "town", "x": 0.758, "y": 0.313, "danger": 3, "core": "Ash", "lore": "A dryland town of kiln smoke, cracked wells, and stubborn survivors.", "town": ["Inn", "Shop", "Trainer"]},
	{"id": "beach", "name": "Beach", "type": "town", "x": 0.886, "y": 0.329, "danger": 3, "core": "Shell", "lore": "A shore town where fisherfolk read storms better than maps.", "town": ["Inn", "Shop", "Harbor"]},
	{"id": "tower", "name": "Tower", "type": "town", "x": 0.884, "y": 0.395, "danger": 4, "core": "Spire", "lore": "A fortified watchpost rising over the eastern delta roads.", "town": ["Inn", "Shop", "Gate Watch"]},
	{"id": "drasig", "name": "Drasig", "type": "town", "x": 0.322, "y": 0.288, "danger": 2, "core": "Ford", "lore": "A riverside town where western caravans regroup before the central plains.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "love", "name": "Love", "type": "town", "x": 0.368, "y": 0.249, "danger": 1, "core": "Bloom", "lore": "A green village with bright banners, old songs, and guarded smiles.", "town": ["Inn", "Shop", "Tavern"]},
	{"id": "horsetown", "name": "HorseTown", "type": "town", "x": 0.432, "y": 0.265, "danger": 2, "core": "Hoof", "lore": "A plains town built around stables, couriers, and road-worn mercenaries.", "town": ["Inn", "Shop", "Militia Yard"]},
	{"id": "birchwood", "name": "BirchWood", "type": "town", "x": 0.401, "y": 0.473, "danger": 2, "core": "Birch", "lore": "A pale-wood settlement where carts creak through misty groves.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "trade", "name": "Trade", "type": "town", "x": 0.422, "y": 0.494, "danger": 2, "core": "Coin", "lore": "A market town whose square never seems to close.", "town": ["Inn", "Shop", "Trainer"]},
	{"id": "lorrback", "name": "Lorrback", "type": "town", "x": 0.469, "y": 0.480, "danger": 2, "core": "Lantern", "lore": "A mountain-foot town that keeps careful ledgers and brighter lamps.", "town": ["Inn", "Shop", "Tavern"]},
	{"id": "stine", "name": "Stine", "type": "town", "x": 0.492, "y": 0.489, "danger": 2, "core": "Slate", "lore": "A stony village where masons patch roads as often as houses.", "town": ["Inn", "Shop", "Gate Watch"]},
	{"id": "circle", "name": "Circle", "type": "town", "x": 0.560, "y": 0.452, "danger": 3, "core": "Ring", "lore": "A crossroads town laid around an old ritual circle no one admits to using.", "town": ["Inn", "Shop", "Notice Board"]},
	{"id": "greatling", "name": "Greatling", "type": "town", "x": 0.622, "y": 0.454, "danger": 3, "core": "Banner", "lore": "A proud central town whose walls carry too many repaired scars.", "town": ["Inn", "Shop", "Militia Yard"]},
	{"id": "grandwood", "name": "GrandWood", "type": "town", "x": 0.672, "y": 0.509, "danger": 3, "core": "Bough", "lore": "A deepwood trade post where timber, medicine, and secrets change hands.", "town": ["Inn", "Shop", "Tavern"]},
	{"id": "smithy", "name": "Smithy", "type": "town", "x": 0.625, "y": 0.553, "danger": 3, "core": "Iron", "lore": "A forge-town that rings all day and glows all night.", "town": ["Inn", "Shop", "Forge"]},
	{"id": "crown", "name": "Crown", "type": "town", "x": 0.695, "y": 0.629, "danger": 4, "core": "Crown", "lore": "A lakeside town living in the shadow of broken royal stone.", "town": ["Inn", "Shop", "Trainer"]},
	{"id": "glory", "name": "Glory", "type": "town", "x": 0.575, "y": 0.778, "danger": 1, "core": "Hope", "lore": "A southern village beside old palace ruins, safe enough to begin a desperate run.", "town": ["Village Inn", "Shop", "Militia Yard"]},
	{"id": "hill", "name": "Hill", "type": "town", "x": 0.600, "y": 0.656, "danger": 2, "core": "Hill", "lore": "A raised holdfast watching the roads north of Glory.", "town": ["Inn", "Shop", "Gate Watch"]},
	{"id": "fire", "name": "Fire", "type": "town", "x": 0.624, "y": 0.681, "danger": 3, "core": "Ember", "lore": "A camp of forgefires and signal flames on the mountain road.", "town": ["Inn", "Shop", "Forge"]},
	{"id": "sea", "name": "Sea", "type": "town", "x": 0.794, "y": 0.864, "danger": 4, "core": "Tide", "lore": "A southern coast town where jungle paths end at salt gates.", "town": ["Inn", "Shop", "Harbor"]},
	{"id": "empty", "name": "Empty", "type": "event", "x": 0.541, "y": 0.734, "danger": 2, "core": "Hollow", "lore": "A quiet keep where abandoned wells answer with unfamiliar voices."},
	{"id": "dream", "name": "Dream", "type": "event", "x": 0.595, "y": 0.748, "danger": 3, "core": "Moon", "lore": "Mist curls around broken causeways and sleep has sharp little teeth."},
	{"id": "sand", "name": "Sand", "type": "event", "x": 0.931, "y": 0.632, "danger": 4, "core": "Glass", "lore": "The eastern waste scours armor clean and leaves maps full of lies."}
]

const DEFAULT_ROUTES: Array[Array] = [
	["eno", "lasty"], ["lasty", "rock_point"], ["rock_point", "oak"], ["oak", "cottage"], ["cottage", "valley"], ["valley", "scrant"], ["valley", "hent"], ["hent", "heat"], ["heat", "beach"], ["beach", "tower"],
	["love", "drasig"], ["drasig", "horsetown"], ["horsetown", "birchwood"], ["birchwood", "trade"], ["trade", "lorrback"], ["lorrback", "stine"], ["stine", "circle"], ["circle", "greatling"], ["greatling", "grandwood"], ["grandwood", "smithy"], ["smithy", "crown"],
	["glory", "hill"], ["hill", "fire"], ["fire", "dream"], ["dream", "empty"], ["empty", "crown"], ["crown", "sea"], ["crown", "smithy"], ["sand", "tower"]
]
const EQUIPMENT_SLOTS := ["head", "body", "arms", "weapon", "legs", "shoes", "trinket1", "trinket2", "trinket3"]
const BASIC_EQUIPMENT_BY_SLOT := {
	"head": "Empty",
	"body": "Raggs",
	"arms": "Bandages",
	"weapon": "Fists",
	"legs": "Ragged Trousers",
	"shoes": "Sandals"
}
const CORE_SLOT_COUNT := 5
const CORE_ITEM_PREFIX := "Core:"
const STARTER_EQUIPMENT := {"head": "Empty", "body": "Raggs", "arms": "Bandages", "weapon": "Hawk's Spear", "legs": "Ragged Trousers", "shoes": "Sandals", "trinket1": "", "trinket2": "", "trinket3": ""}
const EQUIPMENT_CARDS := {}
const EQUIPMENT_DATA := {
	"Empty": {"slot": "head", "basic": true, "icon": "attack", "stats": {}, "abilities": [], "cards": ["headbut"]},
	"Raggs": {"slot": "body", "basic": true, "icon": "block", "stats": {}, "abilities": [], "cards": ["body_block", "body_block", "shoulder_throw"]},
	"Bandages": {"slot": "arms", "basic": true, "icon": "attack", "stats": {}, "abilities": [], "cards": ["wrap", "wrap"]},
	"Fists": {"slot": "weapon", "basic": true, "icon": "attack", "stats": {}, "abilities": [], "cards": ["jab", "jab", "jab"]},
	"Ragged Trousers": {"slot": "legs", "basic": true, "icon": "attack", "stats": {}, "abilities": [], "cards": ["leg_tap"]},
	"Sandals": {"slot": "shoes", "basic": true, "icon": "move", "stats": {}, "abilities": [], "cards": ["basic_dash", "basic_dash"]},
	"Traveler's Coat": {"slot": "body", "icon": "block", "stats": {"health": 2}, "abilities": [], "cards": ["guard"]},
	"Wrapped Hands": {"slot": "arms", "icon": "attack", "stats": {}, "abilities": [], "cards": ["shove"]},
	"Hawk's Spear": {"slot": "weapon", "icon": "attack", "stats": {}, "abilities": [], "cards": ["quick_stab", "quick_stab", "dash"]},
	"Padded Trousers": {"slot": "legs", "icon": "move", "stats": {}, "abilities": [], "cards": ["step", "step"]},
	"Road Shoes": {"slot": "shoes", "icon": "move", "stats": {"speed": 1}, "abilities": [], "cards": ["dash"]},
	"Ruinguard Hood": {"slot": "head", "icon": "block", "stats": {}, "abilities": [], "cards": ["guard"]},
	"Cracked Moon Charm": {"slot": "trinket", "icon": "magic_attack", "stats": {}, "abilities": [], "cards": ["spark"]}
}
const DEFAULT_CARDS := {
	"headbut": {"name": "Headbut", "cores": 0, "energy": 0, "type": "attack", "damage_type": "normal", "damage": 4, "range": 1, "block": 3, "magic_block": 1, "text": "Only deals damage to characters with an Empty head piece slot."},
	"body_block": {"name": "Body Block", "cores": 0, "energy": 0, "type": "skill", "block": 6, "magic_block": 2, "text": "Lose 2 life."},
	"shoulder_throw": {"name": "Shoulder Throw", "cores": 0, "energy": 1, "type": "attack", "damage_type": "normal", "damage": 6, "range": 2, "block": 2, "magic_block": 0, "text": "NormalAttack 6 on range 2."},
	"wrap": {"name": "Wrap", "cores": 0, "energy": 2, "type": "attack", "damage_type": "normal", "damage": 5, "range": 1, "block": 1, "magic_block": 1, "text": "On hit: The hit character can't move during their next turn."},
	"jab": {"name": "Jab", "cores": 0, "energy": 0, "type": "attack", "damage_type": "normal", "damage": 3, "range": 1, "block": 2, "magic_block": 0, "text": "NormalAttack 3 on range 1."},
	"leg_tap": {"name": "Leg Tap", "cores": 0, "energy": 1, "type": "attack", "damage_type": "normal", "damage": 4, "range": 2, "block": 2, "magic_block": 0, "text": "NormalAttack 4 on range 2."},
	"basic_dash": {"name": "Dash", "cores": 0, "energy": 1, "type": "move", "move": 2, "block": 2, "magic_block": 1, "text": "Move 2."},
	"quick_stab": {"name": "Quick Stab", "cores": 1, "energy": 0, "type": "attack", "damage_type": "normal", "damage": 8, "range": 2, "block": 5, "magic_block": 0, "text": "NormalAttack 8 on range 2."},
	"thrust": {"name": "Thrust", "cores": 0, "energy": 1, "type": "attack", "damage_type": "normal", "damage": 6, "range": 2, "block": 3, "magic_block": 1, "text": "NormalAttack 6 on range 2."},
	"step": {"name": "Step", "cores": 0, "energy": 0, "type": "move", "move": 1, "block": 1, "magic_block": 0, "text": "Move 1 hex."},
	"dash": {"name": "Dash", "cores": 0, "energy": 1, "type": "move", "move": 2, "block": 1, "magic_block": 0, "text": "Move 2 hexes."},
	"strike": {"name": "Strike", "cores": 0, "energy": 1, "type": "attack", "damage_type": "normal", "damage": 5, "range": 1, "block": 2, "magic_block": 1, "text": "NormalAttack 5 on range 1."},
	"guard": {"name": "Guard", "cores": 0, "energy": 0, "type": "skill", "block": 5, "magic_block": 2, "text": "Strong block card."},
	"spark": {"name": "Core Spark", "cores": 1, "energy": 1, "type": "attack", "damage_type": "magic", "damage": 8, "range": 2, "block": 1, "magic_block": 3, "text": "MagicAttack 8 on range 2."},
	"shove": {"name": "Shove", "cores": 0, "energy": 0, "type": "attack", "damage_type": "normal", "damage": 3, "range": 1, "block": 3, "magic_block": 0, "text": "NormalAttack 3 on range 1."}
}
const CATALOGUE_ITEMS := {
	"empty": {"name": "Empty", "type": "Head", "found": true, "cards": ["headbut"]},
	"raggs": {"name": "Raggs", "type": "Body", "found": true, "cards": ["body_block", "shoulder_throw"]},
	"bandages": {"name": "Bandages", "type": "Arms", "found": true, "cards": ["wrap"]},
	"fists": {"name": "Fists", "type": "Weapon", "found": true, "cards": ["jab"]},
	"ragged_trousers": {"name": "Ragged Trousers", "type": "Legs", "found": true, "cards": ["leg_tap"]},
	"sandals": {"name": "Sandals", "type": "Shoes", "found": true, "cards": ["basic_dash"]},
	"hawks_spear": {"name": "Hawk's Spear", "type": "Weapon", "found": true, "cards": ["quick_stab", "dash"]}
}
const CATALOGUE_CHARACTERS := {
	"jiali": {"name": "Jiali", "team": "player", "icon": "health", "hp": 38, "speed": 6, "cores": 0, "cards": ["headbut", "body_block", "shoulder_throw", "wrap", "quick_stab", "dash", "jab", "leg_tap", "basic_dash"]},
	"hollow_knife": {"name": "Hollow Knife", "team": "enemy", "icon": "attack", "hp": 30, "speed": 6, "cores": 0, "cards": ["step", "strike", "guard"]},
	"moth_duelist": {"name": "Moth Duelist", "team": "enemy", "icon": "magic_attack", "hp": 36, "speed": 7, "cores": 0, "cards": ["step", "strike", "guard"]},
	"glass_viper": {"name": "Glass Viper", "team": "enemy", "icon": "speed", "hp": 42, "speed": 8, "cores": 0, "cards": ["step", "strike", "guard"]}
}
const CATALOGUE_CORES := {
	"stone": {"name": "Stone", "color": Color(0.52, 0.52, 0.48, 1.0), "symbol": "block"},
	"ember": {"name": "Ember", "color": Color(0.92, 0.36, 0.16, 1.0), "symbol": "attack"},
	"hollow": {"name": "Hollow", "color": Color(0.28, 0.24, 0.34, 1.0), "symbol": "magic_block"},
	"moon": {"name": "Moon", "color": Color(0.48, 0.58, 0.92, 1.0), "symbol": "magic_attack"},
	"crown": {"name": "Crown", "color": Color(0.92, 0.70, 0.22, 1.0), "symbol": "core"},
	"glass": {"name": "Glass", "color": Color(0.52, 0.86, 0.88, 1.0), "symbol": "range"},
	"tide": {"name": "Tide", "color": Color(0.16, 0.48, 0.78, 1.0), "symbol": "move"}
}
const EVENTS := {
	"empty": {"title": "The Well Without Echo", "text": "A rope descends into black water. Something below pulls twice, then waits.", "enemy": "Hollow Knife"},
	"dream": {"title": "Blue Lantern Dream", "text": "A lantern burns in daylight and casts three shadows. One of them draws a blade.", "enemy": "Moth Duelist"},
	"sand": {"title": "Glass Road Ambush", "text": "Sand hardens beneath your boots. Shapes rise below the transparent crust.", "enemy": "Glass Viper"}
}
const QUESTS: Array[Dictionary] = [
	{"id": "main_reach_crown", "kind": "main", "title": "Reach Crown", "summary": "Find a safe route north from Glory and learn why Crown still matters.", "objective": "Travel through Belland until Crown is discovered.", "completed": false},
	{"id": "side_stock_up", "kind": "side", "title": "Stock Up", "summary": "Visit a town shop and prepare Jiali for the road.", "objective": "Enter any town and use its Shop.", "completed": false},
	{"id": "side_old_roads", "kind": "side", "title": "Old Roads", "summary": "Map the roads around Glory before pushing into danger.", "objective": "Discover Hill, Fire, and Dream.", "completed": false},
	{"id": "finished_leave_glory", "kind": "side", "title": "Leave Glory", "summary": "The run begins just south of Glory.", "objective": "Start Chapter 1.", "completed": true}
]

var run := 0
var calendar_year := 0
var calendar_day := 0
var calendar_hour := 0
var travel_day_progress := 0.0
var player: Dictionary = {}
var player_pos := Vector2.ZERO
var current_location: Dictionary = {}
var discovered: Dictionary = {}
var explored: Array[Dictionary] = []
var resolved_events: Dictionary = {}
var mode := "overworld"
var log_entries: Array = []
var combat: Dictionary = {}
var saved_run: Dictionary = {}
var overworld_movement_queue: Array[Vector2] = []
var fog_hidden_for_testing := false
var collapsed_quests: Dictionary = {}
var locations: Array[Dictionary] = []
var routes: Array[Array] = []
var cards: Dictionary = {}

var title_layer: Control
var title_continue_button: Button
var top_right_controls: PanelContainer
var top_right_button_bar: HBoxContainer
var chronicle_button: Button
var inventory_button: Button
var map_button: Button
var overworld_zoom_controls: HBoxContainer
var fog_test_button: Button
var overworld_stats_bar: HBoxContainer
var quest_tracker_panel: PanelContainer
var quest_tracker_list: VBoxContainer
var enter_town_button: Button
var terrain_image: Image
var map_overlay: Control
var map_overlay_view
var compact_map_panel: PanelContainer
var compact_map_view
var in_game_menu_button: Button
var in_game_menu_popup: PanelContainer
var in_game_menu_return_view := ""
var save_prompt_popup: PanelContainer
var save_prompt_action := ""
var travel_prompt_popup: PanelContainer
var travel_prompt_label: Label
var pending_travel_location_id := ""
var travel_message_popup: PanelContainer
var travel_message_label: Label
var settings_panel: PanelContainer
var settings_return_view := ""
var catalogue_panel: PanelContainer
var catalogue_detail_panel: PanelContainer
var catalogue_detail_box: VBoxContainer
var pinned_catalogue_item_id := ""
var catalogue_tab := "equipment"
var log_popup: PanelContainer
var log_detail_title: Label
var log_detail_text: Label
var log_selected_index := -1
var inventory_popup: PanelContainer
var inventory_grid: GridContainer
var inventory_core_layer: Control
var inventory_character_layer: Control
var inventory_stats_box: VBoxContainer
var deck_grid: GridContainer
var inventory_scroll: ScrollContainer
var equipment_slot_controls: Dictionary = {}
var core_slot_controls: Dictionary = {}
var held_inventory_item := ""
var held_inventory_source := ""
var inventory_drag_preview: PanelContainer
var character_info_popup: PanelContainer
var character_info_box: VBoxContainer
var town_popup: Control
var town_title_label: Label
var town_lore_label: Label
var town_place_box: VBoxContainer
var event_popup: PanelContainer
var event_title_label: Label
var event_text_label: Label
var event_choice_box: HBoxContainer
var game_root: HBoxContainer
var overworld_hud: VBoxContainer
var combat_layer: Control
var combat_board
var combat_map_overlay: Control
var combat_map_view
var initiative_bar: HBoxContainer
var resource_label: Label
var combat_status_label: Label
var action_toggle_bar: HBoxContainer
var base_action_bar: VBoxContainer
var base_action_info: PanelContainer
var base_action_info_label: Label
var combat_hand_bar: HBoxContainer
var combat_deck_popup: PanelContainer
var combat_deck_grid: GridContainer
var energy_hole: PanelContainer
var energy_hole_label: Label
var discard_popup: Control
var discard_grid: GridContainer
var combat_log_scroll: ScrollContainer
var combat_log_list: VBoxContainer
var block_attack_banner: HBoxContainer
var block_attack_label: Label
var card_preview: PanelContainer
var end_turn_button: Button
var skip_action_button: Button
var map_view
var run_label: Label
var hp_label: Label
var cores_label: Label
var deck_label: Label
var gold_label: Label
var mode_label: Label
var time_label: Label
var location_name: Label
var location_lore: Label
var town_panel: VBoxContainer
var event_panel: VBoxContainer
var combat_panel: VBoxContainer
var log_list: VBoxContainer

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	build_ui()
	load_design_data()
	var texture := load(MAP_PATH) as Texture2D
	var terrain_texture := load(TERRAIN_MASK_PATH) as Texture2D
	if terrain_texture != null:
		terrain_image = terrain_texture.get_image()
	map_view.configure(texture, locations, routes)
	map_view.set_map_alignment_left(true)
	map_view.location_clicked.connect(_on_location_clicked)
	map_view.map_clicked.connect(_on_map_clicked)
	map_view.resized.connect(request_overworld_layout_refresh)
	combat_map_view.configure(texture, locations, routes)
	map_overlay_view.configure(texture, locations, routes)
	compact_map_view.configure(texture, locations, routes)
	compact_map_view.set_interaction_enabled(true, false)
	show_title()

func load_design_data() -> void:
	locations = load_location_data()
	routes = load_route_data()
	cards = load_card_data()

func load_location_data() -> Array[Dictionary]:
	var data: Variant = load_json_file(LOCATIONS_DATA_PATH)
	if data is Array:
		var loaded: Array[Dictionary] = []
		for item in data:
			if item is Dictionary:
				loaded.append(item)
		if not loaded.is_empty():
			return loaded
	return DEFAULT_LOCATIONS.duplicate(true)

func load_route_data() -> Array[Array]:
	var data: Variant = load_json_file(ROUTES_DATA_PATH)
	if data is Array:
		var loaded: Array[Array] = []
		for item in data:
			if item is Array:
				loaded.append(item)
		if not loaded.is_empty():
			return loaded
	return DEFAULT_ROUTES.duplicate(true)

func load_card_data() -> Dictionary:
	var data: Variant = load_json_file(CARDS_DATA_PATH)
	if data is Dictionary and not data.is_empty():
		return data
	return DEFAULT_CARDS.duplicate(true)

func load_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

func _process(delta: float) -> void:
	render_time_display()
	process_keyboard_overworld_movement(delta)
	process_overworld_movement(delta)

func build_ui() -> void:
	game_root = HBoxContainer.new()
	game_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(game_root)

	map_view = preload("res://scripts/OverworldView.gd").new()
	map_view.custom_minimum_size = Vector2(900, 600)
	map_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_view.clip_contents = true
	game_root.add_child(map_view)
	build_overworld_zoom_controls()
	build_fog_test_button()

	overworld_stats_bar = HBoxContainer.new()
	overworld_stats_bar.set_anchors_preset(Control.PRESET_TOP_LEFT)
	overworld_stats_bar.offset_left = 18
	overworld_stats_bar.offset_top = 54
	overworld_stats_bar.offset_right = 260
	overworld_stats_bar.offset_bottom = 112
	overworld_stats_bar.add_theme_constant_override("separation", 8)
	overworld_stats_bar.visible = false
	add_child(overworld_stats_bar)
	hp_label = make_stat(overworld_stats_bar, "Health", "health")
	gold_label = make_stat(overworld_stats_bar, "Gold", "gold")

	overworld_hud = VBoxContainer.new()
	overworld_hud.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	overworld_hud.offset_left = 20
	overworld_hud.offset_top = -152
	overworld_hud.offset_right = 210
	overworld_hud.offset_bottom = -18
	overworld_hud.add_theme_constant_override("separation", 8)
	add_child(overworld_hud)

	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(170, 120)
	var portrait_label := Label.new()
	portrait_label.text = "Jiali"
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait.add_child(portrait_label)
	overworld_hud.add_child(portrait)
	build_quest_tracker()

	town_panel = VBoxContainer.new()
	event_panel = VBoxContainer.new()
	combat_panel = VBoxContainer.new()
	run_label = Label.new()
	deck_label = Label.new()
	mode_label = Label.new()
	location_name = Label.new()
	location_lore = Label.new()

	build_title_layer()
	build_settings_panel()
	build_catalogue_panel()
	build_log_popup()
	build_inventory_popup()
	build_character_info_popup()
	build_town_popup()
	build_event_popup()
	build_map_overlay()
	build_compact_map_panel()
	build_combat_layer()
	build_in_game_menu()
	build_save_prompt()
	build_travel_prompt()
	build_travel_message_popup()
	build_time_display()

func build_overworld_zoom_controls() -> void:
	overworld_zoom_controls = HBoxContainer.new()
	overworld_zoom_controls.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	overworld_zoom_controls.offset_left = -178
	overworld_zoom_controls.offset_top = -64
	overworld_zoom_controls.offset_right = -18
	overworld_zoom_controls.offset_bottom = -18
	overworld_zoom_controls.add_theme_constant_override("separation", 6)
	overworld_zoom_controls.visible = false
	add_child(overworld_zoom_controls)

	var zoom_out := Button.new()
	zoom_out.text = "-"
	zoom_out.tooltip_text = "Zoom out"
	zoom_out.custom_minimum_size = Vector2(46, 42)
	zoom_out.pressed.connect(func() -> void: map_view.zoom_out())
	overworld_zoom_controls.add_child(zoom_out)

	var reset := Button.new()
	reset.text = "1x"
	reset.tooltip_text = "Reset zoom"
	reset.custom_minimum_size = Vector2(54, 42)
	reset.pressed.connect(func() -> void: map_view.reset_zoom())
	overworld_zoom_controls.add_child(reset)

	var zoom_in := Button.new()
	zoom_in.text = "+"
	zoom_in.tooltip_text = "Zoom in"
	zoom_in.custom_minimum_size = Vector2(46, 42)
	zoom_in.pressed.connect(func() -> void: map_view.zoom_in())
	overworld_zoom_controls.add_child(zoom_in)

func build_fog_test_button() -> void:
	fog_test_button = Button.new()
	fog_test_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	fog_test_button.offset_left = 202
	fog_test_button.offset_top = -62
	fog_test_button.offset_right = 268
	fog_test_button.offset_bottom = -28
	fog_test_button.custom_minimum_size = Vector2(66, 34)
	fog_test_button.text = "Hide Fog"
	fog_test_button.tooltip_text = "Testing: hide or show fog of war"
	fog_test_button.visible = false
	fog_test_button.pressed.connect(toggle_fog_for_testing)
	add_child(fog_test_button)

func build_quest_tracker() -> void:
	quest_tracker_panel = PanelContainer.new()
	quest_tracker_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	quest_tracker_panel.offset_left = -560
	quest_tracker_panel.offset_top = 70
	quest_tracker_panel.offset_right = 0
	quest_tracker_panel.offset_bottom = 0
	quest_tracker_panel.visible = false
	quest_tracker_panel.add_theme_stylebox_override("panel", make_scroll_panel_style())
	add_child(quest_tracker_panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	quest_tracker_panel.add_child(stack)

	var title := Label.new()
	title.text = "Quests"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color(0.22, 0.13, 0.06, 1.0))
	stack.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	stack.add_child(scroll)

	quest_tracker_list = VBoxContainer.new()
	quest_tracker_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quest_tracker_list.add_theme_constant_override("separation", 8)
	scroll.add_child(quest_tracker_list)

func make_scroll_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.74, 0.61, 0.39, 0.95)
	style.border_color = Color(0.33, 0.20, 0.09, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	return style

func make_top_bar_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.18, 0.11, 0.96)
	style.border_color = Color(0.16, 0.09, 0.04, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 10
	style.content_margin_top = 7
	style.content_margin_right = 10
	style.content_margin_bottom = 7
	return style

func make_full_window_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.045, 0.038, 1.0)
	style.border_color = Color(0.18, 0.16, 0.10, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	return style

func build_time_display() -> void:
	time_label = Label.new()
	time_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	time_label.offset_left = 18
	time_label.offset_top = 14
	time_label.offset_right = 350
	time_label.offset_bottom = 48
	time_label.add_theme_font_size_override("font_size", 20)
	time_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.74, 1.0))
	time_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	time_label.add_theme_constant_override("shadow_offset_x", 2)
	time_label.add_theme_constant_override("shadow_offset_y", 2)
	time_label.visible = false
	add_child(time_label)

func build_title_layer() -> void:
	title_layer = Control.new()
	title_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(title_layer)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.04, 0.055, 0.045, 0.96)
	title_layer.add_child(backdrop)

	var menu := VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.offset_left = -180
	menu.offset_top = -180
	menu.offset_right = 180
	menu.offset_bottom = 220
	menu.add_theme_constant_override("separation", 12)
	title_layer.add_child(menu)

	var title := Label.new()
	title.text = "Aftermath"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	menu.add_child(title)

	var new_run_button := Button.new()
	new_run_button.text = "New Run"
	style_menu_popup_button(new_run_button)
	new_run_button.pressed.connect(start_run)
	menu.add_child(new_run_button)

	title_continue_button = Button.new()
	title_continue_button.text = "Continue Run"
	style_menu_popup_button(title_continue_button)
	title_continue_button.pressed.connect(continue_run)
	menu.add_child(title_continue_button)

	var catalogue_button := Button.new()
	catalogue_button.text = "Catalogue"
	style_menu_popup_button(catalogue_button)
	catalogue_button.pressed.connect(show_catalogue)
	menu.add_child(catalogue_button)

	var settings_button := Button.new()
	settings_button.text = "Settings"
	style_menu_popup_button(settings_button)
	settings_button.pressed.connect(show_settings)
	menu.add_child(settings_button)

	var quit_button := Button.new()
	quit_button.text = "Quit Game"
	style_menu_popup_button(quit_button)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	menu.add_child(quit_button)

func build_settings_panel() -> void:
	settings_panel = PanelContainer.new()
	settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_panel.add_theme_stylebox_override("panel", make_full_window_style())
	settings_panel.visible = false
	add_child(settings_panel)

	var stack := VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_CENTER)
	stack.offset_left = -180
	stack.offset_top = -190
	stack.offset_right = 180
	stack.offset_bottom = 190
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	settings_panel.add_child(stack)

	var size_label := Label.new()
	size_label.text = "Window Size"
	size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var size_dropdown := OptionButton.new()
	size_dropdown.custom_minimum_size = Vector2(260, 58)
	size_dropdown.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_dropdown.add_theme_font_size_override("font_size", 20)
	for index in range(SCREEN_SIZES.size()):
		var screen_size: Vector2i = SCREEN_SIZES[index]
		size_dropdown.add_item("%s x %s" % [screen_size.x, screen_size.y], index)
	size_dropdown.selected = 2
	size_dropdown.disabled = true
	size_dropdown.item_selected.connect(func(index: int) -> void:
		if index >= 0 and index < SCREEN_SIZES.size():
			set_window_size(SCREEN_SIZES[index])
	)

	var fullscreen_toggle := CheckBox.new()
	fullscreen_toggle.text = "Fullscreen"
	fullscreen_toggle.button_pressed = true
	fullscreen_toggle.custom_minimum_size = Vector2(260, 48)
	fullscreen_toggle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	fullscreen_toggle.add_theme_font_size_override("font_size", 20)
	fullscreen_toggle.toggled.connect(func(enabled: bool) -> void:
		set_fullscreen(enabled)
		size_dropdown.disabled = enabled
		size_label.modulate = Color(1, 1, 1, 0.45) if enabled else Color.WHITE
		if not enabled:
			set_window_size(SCREEN_SIZES[size_dropdown.selected])
	)
	stack.add_child(fullscreen_toggle)

	size_label.modulate = Color(1, 1, 1, 0.45)
	stack.add_child(size_label)
	stack.add_child(size_dropdown)

	var close := Button.new()
	close.text = "Close"
	style_menu_popup_button(close)
	close.pressed.connect(close_settings)
	stack.add_child(close)

func build_catalogue_panel() -> void:
	catalogue_panel = PanelContainer.new()
	catalogue_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	catalogue_panel.add_theme_stylebox_override("panel", make_full_window_style())
	catalogue_panel.visible = false
	add_child(catalogue_panel)

func build_log_popup() -> void:
	log_popup = PanelContainer.new()
	log_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	log_popup.add_theme_stylebox_override("panel", make_full_window_style())
	log_popup.visible = false
	add_child(log_popup)

	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	log_popup.add_child(content)

	var stack := VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.offset_left = 24
	stack.offset_top = 24
	stack.offset_right = -78
	stack.offset_bottom = -24
	stack.add_theme_constant_override("separation", 12)
	content.add_child(stack)

	var title := Label.new()
	title.text = "Chronicle"
	title.add_theme_font_size_override("font_size", 28)
	stack.add_child(title)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	stack.add_child(body)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(260, 0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	log_list = VBoxContainer.new()
	log_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_list.add_theme_constant_override("separation", 8)
	scroll.add_child(log_list)

	var detail := Control.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(detail)

	log_detail_title = Label.new()
	log_detail_title.position = Vector2(0, 0)
	log_detail_title.size = Vector2(420, 40)
	log_detail_title.add_theme_font_size_override("font_size", 24)
	detail.add_child(log_detail_title)

	var image_space := PanelContainer.new()
	image_space.position = Vector2(440, 0)
	image_space.size = Vector2(210, 150)
	var image_label := Label.new()
	image_label.text = "Image"
	image_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	image_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	image_space.add_child(image_label)
	detail.add_child(image_space)

	log_detail_text = Label.new()
	log_detail_text.position = Vector2(0, 58)
	log_detail_text.size = Vector2(650, 430)
	log_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_detail_text.add_theme_font_size_override("font_size", 18)
	detail.add_child(log_detail_text)

	var close := Button.new()
	style_overlay_close_button(close)
	close.pressed.connect(func() -> void:
		log_popup.visible = false
		update_top_right_controls()
	)
	content.add_child(close)

func build_inventory_popup() -> void:
	inventory_popup = PanelContainer.new()
	inventory_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_popup.add_theme_stylebox_override("panel", make_full_window_style())
	inventory_popup.visible = false
	add_child(inventory_popup)

	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	inventory_popup.add_child(content)

	inventory_stats_box = VBoxContainer.new()
	inventory_stats_box.position = Vector2(18, 60)
	inventory_stats_box.size = Vector2(110, 300)
	inventory_stats_box.add_theme_constant_override("separation", 8)
	content.add_child(inventory_stats_box)

	inventory_character_layer = Control.new()
	inventory_character_layer.position = Vector2(145, 46)
	inventory_character_layer.size = Vector2(300, 330)
	content.add_child(inventory_character_layer)

	inventory_grid = GridContainer.new()
	inventory_grid.position = Vector2(470, 52)
	inventory_grid.size = Vector2(300, 330)
	inventory_grid.columns = 3
	inventory_grid.add_theme_constant_override("h_separation", 10)
	inventory_grid.add_theme_constant_override("v_separation", 10)
	content.add_child(inventory_grid)

	inventory_core_layer = Control.new()
	inventory_core_layer.position = Vector2(800, 72)
	inventory_core_layer.size = Vector2(180, 180)
	content.add_child(inventory_core_layer)

	inventory_scroll = ScrollContainer.new()
	inventory_scroll.position = Vector2(18, 400)
	inventory_scroll.custom_minimum_size = Vector2(790, 360)
	inventory_scroll.size = Vector2(790, 180)
	inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(inventory_scroll)
	deck_grid = GridContainer.new()
	deck_grid.columns = 8
	deck_grid.add_theme_constant_override("h_separation", 8)
	deck_grid.add_theme_constant_override("v_separation", 8)
	inventory_scroll.add_child(deck_grid)

	var close := Button.new()
	style_overlay_close_button(close)
	close.pressed.connect(func() -> void:
		inventory_popup.visible = false
		update_top_right_controls()
	)
	content.add_child(close)

	inventory_drag_preview = PanelContainer.new()
	inventory_drag_preview.visible = false
	inventory_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(inventory_drag_preview)

func build_character_info_popup() -> void:
	character_info_popup = PanelContainer.new()
	character_info_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	character_info_popup.add_theme_stylebox_override("panel", make_full_window_style())
	character_info_popup.visible = false
	add_child(character_info_popup)

	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	character_info_popup.add_child(content)

	character_info_box = VBoxContainer.new()
	character_info_box.set_anchors_preset(Control.PRESET_CENTER)
	character_info_box.offset_left = -260
	character_info_box.offset_top = -260
	character_info_box.offset_right = 260
	character_info_box.offset_bottom = 260
	character_info_box.alignment = BoxContainer.ALIGNMENT_CENTER
	character_info_box.add_theme_constant_override("separation", 12)
	content.add_child(character_info_box)

	var close := Button.new()
	style_overlay_close_button(close)
	close.pressed.connect(func() -> void: character_info_popup.visible = false)
	content.add_child(close)

func build_town_popup() -> void:
	town_popup = Control.new()
	town_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	town_popup.visible = false
	add_child(town_popup)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.035, 0.045, 0.038, 1.0)
	town_popup.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -460
	panel.offset_top = -310
	panel.offset_right = 460
	panel.offset_bottom = 310
	town_popup.add_child(panel)

	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(content)

	var stack := VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.offset_left = 28
	stack.offset_top = 28
	stack.offset_right = -28
	stack.offset_bottom = -28
	stack.add_theme_constant_override("separation", 14)
	content.add_child(stack)

	town_title_label = Label.new()
	town_title_label.add_theme_font_size_override("font_size", 26)
	town_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(town_title_label)

	var image_space := PanelContainer.new()
	image_space.custom_minimum_size = Vector2(690, 220)
	var image_label := Label.new()
	image_label.text = "Town image"
	image_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	image_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	image_space.add_child(image_label)
	stack.add_child(image_space)

	town_lore_label = Label.new()
	town_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(town_lore_label)

	town_place_box = VBoxContainer.new()
	town_place_box.add_theme_constant_override("separation", 8)
	stack.add_child(town_place_box)

func build_event_popup() -> void:
	event_popup = PanelContainer.new()
	event_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_popup.visible = false
	add_child(event_popup)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.88)
	event_popup.add_child(shade)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -390
	panel.offset_top = -300
	panel.offset_right = 390
	panel.offset_bottom = 300
	event_popup.add_child(panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	panel.add_child(stack)
	event_title_label = Label.new()
	event_title_label.add_theme_font_size_override("font_size", 26)
	event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(event_title_label)
	var image_space := PanelContainer.new()
	image_space.custom_minimum_size = Vector2(720, 260)
	var image_label := Label.new()
	image_label.text = "Event image"
	image_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	image_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	image_space.add_child(image_label)
	stack.add_child(image_space)
	event_text_label = Label.new()
	event_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_text_label.add_theme_font_size_override("font_size", 20)
	stack.add_child(event_text_label)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)
	event_choice_box = HBoxContainer.new()
	event_choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	event_choice_box.add_theme_constant_override("separation", 16)
	stack.add_child(event_choice_box)

func build_map_overlay() -> void:
	map_overlay = Control.new()
	map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_overlay.visible = false
	add_child(map_overlay)
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.72)
	map_overlay.add_child(shade)
	map_overlay_view = preload("res://scripts/OverworldView.gd").new()
	map_overlay_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_overlay_view.offset_left = 60
	map_overlay_view.offset_top = 60
	map_overlay_view.offset_right = -60
	map_overlay_view.offset_bottom = -60
	map_overlay.add_child(map_overlay_view)
	var close := Button.new()
	close.text = "X"
	close.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close.offset_left = -112
	close.offset_top = 24
	close.offset_right = -24
	close.offset_bottom = 112
	close.add_theme_font_size_override("font_size", 42)
	close.pressed.connect(func() -> void: map_overlay.visible = false)
	map_overlay.add_child(close)

func build_compact_map_panel() -> void:
	compact_map_panel = PanelContainer.new()
	compact_map_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	compact_map_panel.offset_left = -270
	compact_map_panel.offset_top = 72
	compact_map_panel.offset_right = -6
	compact_map_panel.offset_bottom = 372
	compact_map_panel.clip_contents = true
	compact_map_panel.visible = false
	add_child(compact_map_panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	compact_map_panel.add_child(stack)

	compact_map_view = preload("res://scripts/OverworldView.gd").new()
	compact_map_view.custom_minimum_size = Vector2(246, 246)
	compact_map_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compact_map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	compact_map_view.clip_contents = true
	stack.add_child(compact_map_view)

	var zoom_controls := HBoxContainer.new()
	zoom_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	zoom_controls.add_theme_constant_override("separation", 6)
	stack.add_child(zoom_controls)

	var zoom_out := Button.new()
	zoom_out.text = "-"
	zoom_out.tooltip_text = "Zoom out"
	zoom_out.custom_minimum_size = Vector2(46, 36)
	zoom_out.pressed.connect(func() -> void: compact_map_view.zoom_out())
	zoom_controls.add_child(zoom_out)

	var reset := Button.new()
	reset.text = "1x"
	reset.tooltip_text = "Reset zoom"
	reset.custom_minimum_size = Vector2(54, 36)
	reset.pressed.connect(func() -> void: compact_map_view.reset_zoom())
	zoom_controls.add_child(reset)

	var zoom_in := Button.new()
	zoom_in.text = "+"
	zoom_in.tooltip_text = "Zoom in"
	zoom_in.custom_minimum_size = Vector2(46, 36)
	zoom_in.pressed.connect(func() -> void: compact_map_view.zoom_in())
	zoom_controls.add_child(zoom_in)

func build_in_game_menu() -> void:
	top_right_controls = PanelContainer.new()
	top_right_controls.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_right_controls.offset_left = -540
	top_right_controls.offset_top = 10
	top_right_controls.offset_right = -16
	top_right_controls.offset_bottom = 66
	top_right_controls.add_theme_stylebox_override("panel", make_top_bar_style())
	top_right_controls.visible = false
	add_child(top_right_controls)

	top_right_button_bar = HBoxContainer.new()
	top_right_button_bar.add_theme_constant_override("separation", 8)
	top_right_controls.add_child(top_right_button_bar)

	in_game_menu_button = Button.new()
	in_game_menu_button.text = "Menu"
	in_game_menu_button.pressed.connect(show_in_game_menu)
	top_right_button_bar.add_child(in_game_menu_button)

	chronicle_button = Button.new()
	chronicle_button.text = "Chronicle"
	chronicle_button.pressed.connect(show_log_popup)
	top_right_button_bar.add_child(chronicle_button)

	inventory_button = Button.new()
	inventory_button.text = "Inventory"
	inventory_button.pressed.connect(show_inventory_popup)
	top_right_button_bar.add_child(inventory_button)

	map_button = Button.new()
	map_button.text = "Map"
	map_button.pressed.connect(toggle_compact_map)
	top_right_button_bar.add_child(map_button)

	enter_town_button = Button.new()
	enter_town_button.text = "Enter Town"
	enter_town_button.visible = false
	enter_town_button.pressed.connect(enter_nearby_town)
	top_right_button_bar.add_child(enter_town_button)

	in_game_menu_popup = PanelContainer.new()
	in_game_menu_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	in_game_menu_popup.add_theme_stylebox_override("panel", make_full_window_style())
	in_game_menu_popup.visible = false
	add_child(in_game_menu_popup)

	var stack := VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_CENTER)
	stack.offset_left = -150
	stack.offset_top = -210
	stack.offset_right = 150
	stack.offset_bottom = 210
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	in_game_menu_popup.add_child(stack)

	var main_menu := Button.new()
	main_menu.text = "Main Menu"
	style_menu_popup_button(main_menu)
	main_menu.pressed.connect(func() -> void: show_save_prompt("main_menu"))
	stack.add_child(main_menu)

	var settings := Button.new()
	settings.text = "Settings"
	style_menu_popup_button(settings)
	settings.pressed.connect(func() -> void:
		var return_view := in_game_menu_return_view
		in_game_menu_popup.visible = false
		show_settings(return_view)
	)
	stack.add_child(settings)

	var catalogue := Button.new()
	catalogue.text = "Catalogue"
	style_menu_popup_button(catalogue)
	catalogue.pressed.connect(func() -> void:
		in_game_menu_popup.visible = false
		show_catalogue()
	)
	stack.add_child(catalogue)

	var quit := Button.new()
	quit.text = "Quit Game"
	style_menu_popup_button(quit)
	quit.pressed.connect(func() -> void: show_save_prompt("quit"))
	stack.add_child(quit)

	var close := Button.new()
	close.text = "Close"
	style_menu_popup_button(close)
	close.pressed.connect(func() -> void:
		in_game_menu_popup.visible = false
		update_top_right_controls()
	)
	stack.add_child(close)

func style_menu_popup_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(260, 58)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 22)

func style_overlay_close_button(button: Button) -> void:
	button.text = "X"
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -16.0 - OVERLAY_CLOSE_BUTTON_SIZE
	button.offset_top = OVERLAY_CLOSE_BUTTON_TOP
	button.offset_right = -16.0
	button.offset_bottom = OVERLAY_CLOSE_BUTTON_TOP + OVERLAY_CLOSE_BUTTON_SIZE
	button.custom_minimum_size = Vector2(OVERLAY_CLOSE_BUTTON_SIZE, OVERLAY_CLOSE_BUTTON_SIZE)
	button.add_theme_font_size_override("font_size", 28)

func build_save_prompt() -> void:
	save_prompt_popup = PanelContainer.new()
	save_prompt_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	save_prompt_popup.add_theme_stylebox_override("panel", make_full_window_style())
	save_prompt_popup.visible = false
	add_child(save_prompt_popup)

	var stack := VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_CENTER)
	stack.offset_left = -180
	stack.offset_top = -170
	stack.offset_right = 180
	stack.offset_bottom = 170
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	save_prompt_popup.add_child(stack)
	var label := Label.new()
	label.name = "PromptLabel"
	label.text = "Save this run?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 22)
	stack.add_child(label)

	var save_button := Button.new()
	save_button.text = "Save Run"
	style_menu_popup_button(save_button)
	save_button.pressed.connect(func() -> void: complete_save_prompt(true))
	stack.add_child(save_button)

	var dont_save := Button.new()
	dont_save.text = "Do Not Save"
	style_menu_popup_button(dont_save)
	dont_save.pressed.connect(func() -> void: complete_save_prompt(false))
	stack.add_child(dont_save)

	var cancel := Button.new()
	cancel.text = "Cancel"
	style_menu_popup_button(cancel)
	cancel.pressed.connect(func() -> void:
		save_prompt_popup.visible = false
		update_top_right_controls()
	)
	stack.add_child(cancel)

func build_travel_prompt() -> void:
	travel_prompt_popup = PanelContainer.new()
	travel_prompt_popup.set_anchors_preset(Control.PRESET_CENTER)
	travel_prompt_popup.offset_left = -210
	travel_prompt_popup.offset_top = -140
	travel_prompt_popup.offset_right = 210
	travel_prompt_popup.offset_bottom = 140
	travel_prompt_popup.visible = false
	add_child(travel_prompt_popup)

	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	travel_prompt_popup.add_child(stack)

	travel_prompt_label = Label.new()
	travel_prompt_label.text = "Travel there?"
	travel_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	travel_prompt_label.add_theme_font_size_override("font_size", 22)
	stack.add_child(travel_prompt_label)

	var yes := Button.new()
	yes.text = "Travel"
	style_menu_popup_button(yes)
	yes.pressed.connect(confirm_location_travel)
	stack.add_child(yes)

	var no := Button.new()
	no.text = "Cancel"
	style_menu_popup_button(no)
	no.pressed.connect(func() -> void: travel_prompt_popup.visible = false)
	stack.add_child(no)

func build_travel_message_popup() -> void:
	travel_message_popup = PanelContainer.new()
	travel_message_popup.set_anchors_preset(Control.PRESET_CENTER)
	travel_message_popup.offset_left = -210
	travel_message_popup.offset_top = -120
	travel_message_popup.offset_right = 210
	travel_message_popup.offset_bottom = 120
	travel_message_popup.visible = false
	add_child(travel_message_popup)

	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	travel_message_popup.add_child(stack)

	travel_message_label = Label.new()
	travel_message_label.text = "Unable to reach this destination"
	travel_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	travel_message_label.add_theme_font_size_override("font_size", 22)
	stack.add_child(travel_message_label)

	var close := Button.new()
	close.text = "Close"
	style_menu_popup_button(close)
	close.pressed.connect(func() -> void: travel_message_popup.visible = false)
	stack.add_child(close)

func build_combat_layer() -> void:
	combat_layer = Control.new()
	combat_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	combat_layer.visible = false
	add_child(combat_layer)

	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.035, 0.045, 0.038, 1.0)
	combat_layer.add_child(background)

	combat_board = preload("res://scripts/CombatView.gd").new()
	combat_board.set_anchors_preset(Control.PRESET_FULL_RECT)
	combat_board.offset_top = 62
	combat_board.offset_bottom = -172
	combat_board.hex_clicked.connect(_on_combat_hex_clicked)
	combat_board.unit_clicked.connect(_on_combat_unit_clicked)
	combat_layer.add_child(combat_board)

	base_action_bar = VBoxContainer.new()
	base_action_bar.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	base_action_bar.offset_left = 18
	base_action_bar.offset_top = 118
	base_action_bar.offset_right = 86
	base_action_bar.offset_bottom = -204
	base_action_bar.alignment = BoxContainer.ALIGNMENT_END
	base_action_bar.add_theme_constant_override("separation", 12)
	combat_layer.add_child(base_action_bar)
	add_base_action_button("move", "Move", "Cost: 1 Energy\nMove 1 hex.", Color(0.22, 0.55, 0.95, 1.0), begin_base_move_action)

	base_action_info = PanelContainer.new()
	base_action_info.visible = false
	base_action_info.custom_minimum_size = Vector2(180, 92)
	base_action_info.position = Vector2(94, 468)
	combat_layer.add_child(base_action_info)
	base_action_info_label = Label.new()
	base_action_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	base_action_info_label.text = ""
	base_action_info.add_child(base_action_info_label)

	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 16
	top_bar.offset_top = 12
	top_bar.offset_right = -16
	top_bar.offset_bottom = 64
	top_bar.add_theme_constant_override("separation", 10)
	combat_layer.add_child(top_bar)

	var map_button := Button.new()
	map_button.text = "Map"
	map_button.pressed.connect(show_combat_map_overlay)
	top_bar.add_child(map_button)

	initiative_bar = HBoxContainer.new()
	initiative_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	initiative_bar.add_theme_constant_override("separation", 8)
	top_bar.add_child(initiative_bar)

	var bottom_left := VBoxContainer.new()
	bottom_left.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bottom_left.offset_left = 18
	bottom_left.offset_top = -194
	bottom_left.offset_right = 240
	bottom_left.offset_bottom = -20
	bottom_left.add_theme_constant_override("separation", 8)
	combat_layer.add_child(bottom_left)

	resource_label = Label.new()
	resource_label.text = "Resources"
	resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resource_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resource_label.custom_minimum_size = Vector2(160, 58)
	bottom_left.add_child(resource_label)

	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(160, 110)
	var portrait_label := Label.new()
	portrait_label.text = "Jiali"
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait.add_child(portrait_label)
	bottom_left.add_child(portrait)

	var bottom_area := VBoxContainer.new()
	bottom_area.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_area.offset_left = 265
	bottom_area.offset_top = -220
	bottom_area.offset_right = -238
	bottom_area.offset_bottom = -14
	bottom_area.add_theme_constant_override("separation", 8)
	combat_layer.add_child(bottom_area)

	combat_status_label = Label.new()
	combat_status_label.text = ""
	combat_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combat_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combat_status_label.custom_minimum_size = Vector2(420, 28)
	bottom_area.add_child(combat_status_label)

	action_toggle_bar = HBoxContainer.new()
	action_toggle_bar.add_theme_constant_override("separation", 8)
	bottom_area.add_child(action_toggle_bar)

	var hand_row := HBoxContainer.new()
	hand_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_row.custom_minimum_size = Vector2(760, 142)
	hand_row.add_theme_constant_override("separation", 10)
	bottom_area.add_child(hand_row)

	var deck_button := Button.new()
	deck_button.custom_minimum_size = Vector2(78, 116)
	deck_button.text = ""
	deck_button.icon = load(str(ICONS["attack"]))
	deck_button.expand_icon = true
	deck_button.focus_mode = Control.FOCUS_NONE
	deck_button.tooltip_text = "Deck"
	deck_button.pressed.connect(toggle_combat_deck_popup)
	hand_row.add_child(deck_button)

	combat_hand_bar = HBoxContainer.new()
	combat_hand_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	combat_hand_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	combat_hand_bar.add_theme_constant_override("separation", 8)
	hand_row.add_child(combat_hand_bar)

	block_attack_banner = HBoxContainer.new()
	block_attack_banner.custom_minimum_size = Vector2(90, 42)
	block_attack_banner.alignment = BoxContainer.ALIGNMENT_CENTER
	block_attack_banner.visible = false
	combat_layer.add_child(block_attack_banner)
	block_attack_label = Label.new()
	block_attack_label.add_theme_font_size_override("font_size", 28)
	block_attack_banner.add_child(block_attack_label)

	energy_hole = PanelContainer.new()
	energy_hole.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	energy_hole.offset_left = -210
	energy_hole.offset_top = 180
	energy_hole.offset_right = -22
	energy_hole.offset_bottom = -220
	energy_hole.visible = false
	combat_layer.add_child(energy_hole)
	var hole_stack := VBoxContainer.new()
	hole_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	energy_hole.add_child(hole_stack)
	energy_hole_label = Label.new()
	energy_hole_label.text = "Discard"
	energy_hole_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_hole_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	energy_hole_label.add_theme_font_size_override("font_size", 24)
	hole_stack.add_child(energy_hole_label)

	var bottom_right := HBoxContainer.new()
	bottom_right.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bottom_right.offset_left = -430
	bottom_right.offset_top = -68
	bottom_right.offset_right = -16
	bottom_right.offset_bottom = -20
	bottom_right.add_theme_constant_override("separation", 8)
	combat_layer.add_child(bottom_right)

	skip_action_button = Button.new()
	skip_action_button.text = "Skip"
	skip_action_button.pressed.connect(skip_pending_action)
	bottom_right.add_child(skip_action_button)

	var resolve_block_button := Button.new()
	resolve_block_button.name = "ResolveBlockButton"
	resolve_block_button.text = "Resolve Block"
	resolve_block_button.pressed.connect(resolve_player_block)
	bottom_right.add_child(resolve_block_button)

	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.pressed.connect(end_player_turn)
	bottom_right.add_child(end_turn_button)

	var discard_button := Button.new()
	discard_button.text = "Discard"
	discard_button.pressed.connect(show_discard_popup)
	bottom_right.add_child(discard_button)

	card_preview = PanelContainer.new()
	card_preview.visible = false
	card_preview.custom_minimum_size = Vector2(170, 220)
	card_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card_preview)

	combat_deck_popup = PanelContainer.new()
	combat_deck_popup.visible = false
	combat_deck_popup.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	combat_deck_popup.offset_left = 265
	combat_deck_popup.offset_top = -575
	combat_deck_popup.offset_right = 1115
	combat_deck_popup.offset_bottom = -230
	combat_layer.add_child(combat_deck_popup)
	var deck_scroll := ScrollContainer.new()
	deck_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_scroll.offset_left = 14
	deck_scroll.offset_top = 14
	deck_scroll.offset_right = -14
	deck_scroll.offset_bottom = -14
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	deck_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	combat_deck_popup.add_child(deck_scroll)
	combat_deck_grid = GridContainer.new()
	combat_deck_grid.columns = 6
	combat_deck_grid.add_theme_constant_override("h_separation", 10)
	combat_deck_grid.add_theme_constant_override("v_separation", 10)
	deck_scroll.add_child(combat_deck_grid)

	build_discard_popup()

	build_combat_map_overlay()

	var log_panel := PanelContainer.new()
	log_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	log_panel.offset_left = -280
	log_panel.offset_top = -286
	log_panel.offset_right = -20
	log_panel.offset_bottom = -82
	var log_style := StyleBoxEmpty.new()
	log_panel.add_theme_stylebox_override("panel", log_style)
	combat_layer.add_child(log_panel)
	combat_log_scroll = ScrollContainer.new()
	combat_log_scroll.custom_minimum_size = Vector2(240, 190)
	combat_log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	combat_log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	log_panel.add_child(combat_log_scroll)
	combat_log_list = VBoxContainer.new()
	combat_log_list.custom_minimum_size = Vector2(220, 0)
	combat_log_scroll.add_child(combat_log_list)

func add_base_action_button(icon_id: String, action_name: String, detail: String, color: Color, pressed_callback: Callable) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(58, 58)
	button.text = ""
	button.icon = load(str(ICONS[icon_id]))
	button.expand_icon = true
	button.focus_mode = Control.FOCUS_NONE
	var normal_style := make_circle_button_style(color)
	var hover_style := make_circle_button_style(color.lightened(0.18))
	var pressed_style := make_circle_button_style(color.darkened(0.16))
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)
	button.mouse_entered.connect(func() -> void: show_base_action_info(action_name, detail))
	button.mouse_exited.connect(hide_base_action_info)
	button.pressed.connect(pressed_callback)
	base_action_bar.add_child(button)

func make_circle_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(1.0, 1.0, 1.0, 0.35)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_left = 999
	style.corner_radius_bottom_right = 999
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style

func show_base_action_info(action_name: String, detail: String) -> void:
	if mode != "combat":
		return
	base_action_info_label.text = "%s\n%s" % [action_name, detail]
	base_action_info.visible = true

func hide_base_action_info() -> void:
	base_action_info.visible = false

func build_combat_map_overlay() -> void:
	combat_map_overlay = Control.new()
	combat_map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	combat_map_overlay.visible = false
	combat_layer.add_child(combat_map_overlay)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.72)
	combat_map_overlay.add_child(shade)

	combat_map_view = preload("res://scripts/OverworldView.gd").new()
	combat_map_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	combat_map_view.offset_left = 60
	combat_map_view.offset_top = 60
	combat_map_view.offset_right = -60
	combat_map_view.offset_bottom = -60
	combat_map_overlay.add_child(combat_map_view)

	var close := Button.new()
	close.text = "X"
	close.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close.offset_left = -112
	close.offset_top = 24
	close.offset_right = -24
	close.offset_bottom = 112
	close.add_theme_font_size_override("font_size", 42)
	close.pressed.connect(func() -> void: combat_map_overlay.visible = false)
	combat_map_overlay.add_child(close)

func build_discard_popup() -> void:
	discard_popup = Control.new()
	discard_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	discard_popup.visible = false
	combat_layer.add_child(discard_popup)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.62)
	discard_popup.add_child(shade)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360
	panel.offset_top = -260
	panel.offset_right = 360
	panel.offset_bottom = 260
	discard_popup.add_child(panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "Discard Pile"
	title.add_theme_font_size_override("font_size", 28)
	stack.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 410)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	stack.add_child(scroll)
	discard_grid = GridContainer.new()
	discard_grid.columns = 4
	scroll.add_child(discard_grid)

	var close := Button.new()
	close.text = "X"
	close.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close.offset_left = -112
	close.offset_top = 24
	close.offset_right = -24
	close.offset_bottom = 112
	close.add_theme_font_size_override("font_size", 42)
	close.pressed.connect(func() -> void: discard_popup.visible = false)
	discard_popup.add_child(close)

func start_run() -> void:
	run += 1
	calendar_year = 0
	calendar_day = 0
	calendar_hour = 0
	travel_day_progress = 0.0
	player = {
		"name": "Jiali",
		"hp": 38,
		"max_hp": 38,
		"speed": 6,
		"gold": 20,
		"cores": [],
		"max_cores": CORE_SLOT_COUNT,
		"known_characters": {},
		"equipment": STARTER_EQUIPMENT.duplicate(),
		"inventory": [],
		"deck": deck_from_equipment(STARTER_EQUIPMENT)
	}
	current_location = get_location("glory")
	player_pos = Vector2(float(current_location.x), float(current_location.y) + 0.032)
	discovered = {}
	explored = []
	resolved_events = {}
	fog_hidden_for_testing = false
	map_view.set_fog_hidden(false)
	mode = "overworld"
	log_entries = []
	discover_location("glory")
	reveal_around_player()
	add_log("Run begins just south of Glory, a small village beside old ruins.")
	game_root.visible = true
	title_layer.visible = false
	settings_panel.visible = false
	catalogue_panel.visible = false
	log_popup.visible = false
	inventory_popup.visible = false
	character_info_popup.visible = false
	town_popup.visible = false
	travel_prompt_popup.visible = false
	travel_message_popup.visible = false
	map_overlay.visible = false
	compact_map_panel.visible = false
	combat_layer.visible = false
	top_right_controls.visible = true
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	render_all()
	focus_overworld_on_player()
	request_overworld_layout_refresh()
	save_run()

func continue_run() -> void:
	if saved_run.is_empty():
		return
	load_run(saved_run)
	fog_hidden_for_testing = false
	map_view.set_fog_hidden(false)
	game_root.visible = true
	title_layer.visible = false
	settings_panel.visible = false
	catalogue_panel.visible = false
	log_popup.visible = false
	inventory_popup.visible = false
	character_info_popup.visible = false
	town_popup.visible = false
	travel_prompt_popup.visible = false
	travel_message_popup.visible = false
	map_overlay.visible = false
	compact_map_panel.visible = false
	combat_layer.visible = mode == "combat"
	top_right_controls.visible = true
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	render_all()
	focus_overworld_on_player()
	request_overworld_layout_refresh()

func return_to_title_with_save() -> void:
	save_run()
	show_title()

func show_in_game_menu() -> void:
	if title_layer.visible:
		return
	in_game_menu_return_view = current_run_view_key()
	in_game_menu_popup.visible = true
	in_game_menu_popup.move_to_front()
	settings_panel.visible = false
	catalogue_panel.visible = false
	character_info_popup.visible = false
	save_prompt_popup.visible = false
	update_top_right_controls()

func show_save_prompt(action: String) -> void:
	save_prompt_action = action
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = true
	var label := save_prompt_popup.find_child("PromptLabel", true, false) as Label
	if label != null:
		label.text = "Save this run before %s?" % ("quitting" if action == "quit" else "returning to the main menu")
	update_top_right_controls()

func complete_save_prompt(should_save: bool) -> void:
	if should_save:
		save_run()
	else:
		saved_run = {}
	save_prompt_popup.visible = false
	if save_prompt_action == "quit":
		get_tree().quit()
	else:
		show_title()

func show_title() -> void:
	game_root.visible = false
	title_layer.visible = true
	settings_panel.visible = false
	catalogue_panel.visible = false
	log_popup.visible = false
	inventory_popup.visible = false
	character_info_popup.visible = false
	town_popup.visible = false
	travel_prompt_popup.visible = false
	travel_message_popup.visible = false
	map_overlay.visible = false
	compact_map_panel.visible = false
	event_popup.visible = false
	combat_layer.visible = false
	top_right_controls.visible = false
	overworld_zoom_controls.visible = false
	fog_test_button.visible = false
	fog_hidden_for_testing = false
	map_view.set_fog_hidden(false)
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	title_continue_button.visible = not saved_run.is_empty()
	title_continue_button.disabled = saved_run.is_empty()

func save_run() -> void:
	if player.is_empty():
		return
	saved_run = {
		"run": run,
		"player": player.duplicate(true),
		"calendar_year": calendar_year,
		"calendar_day": calendar_day,
		"calendar_hour": calendar_hour,
		"travel_day_progress": travel_day_progress,
		"player_pos": player_pos,
		"current_location_id": str(current_location.id),
		"discovered": discovered.duplicate(true),
		"explored": explored.duplicate(true),
		"resolved_events": resolved_events.duplicate(true),
		"mode": mode,
		"log_entries": log_entries.duplicate(),
		"combat": combat.duplicate(true)
	}

func load_run(data: Dictionary) -> void:
	run = int(data.run)
	player = data.player.duplicate(true)
	calendar_year = int(data.get("calendar_year", 0))
	calendar_day = int(data.get("calendar_day", 0))
	calendar_hour = int(data.get("calendar_hour", 0))
	travel_day_progress = float(data.get("travel_day_progress", 0.0))
	normalize_equipment()
	if not player.has("inventory"):
		player.inventory = []
	if not player.has("cores"):
		player.cores = []
	if not player.has("max_cores"):
		player.max_cores = CORE_SLOT_COUNT
	if not player.has("known_characters"):
		player.known_characters = {}
	if not player.has("deck"):
		player.deck = deck_from_equipment(player.equipment)
	player.deck = deck_from_equipment(player.equipment)
	player_pos = data.player_pos
	current_location = get_location(str(data.current_location_id))
	discovered = data.discovered.duplicate(true)
	explored = data.explored.duplicate(true)
	resolved_events = data.resolved_events.duplicate(true)
	mode = str(data.mode)
	log_entries = data.log_entries.duplicate()
	normalize_log_entries()
	combat = data.combat.duplicate(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT and mode == "combat":
			if close_combat_submenus():
				get_viewport().set_input_as_handled()
				return
			cancel_combat_process()
			get_viewport().set_input_as_handled()
		return
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_ESCAPE and not title_layer.visible:
		if in_game_menu_popup.visible:
			in_game_menu_popup.visible = false
		else:
			show_in_game_menu()
		get_viewport().set_input_as_handled()
		return
	if can_accept_overworld_movement() and is_overworld_movement_key(key_event.keycode):
		get_viewport().set_input_as_handled()
		return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var click_event: InputEventMouseButton = event
		if click_event.button_index == MOUSE_BUTTON_RIGHT and click_event.pressed and mode == "combat":
			if close_combat_submenus():
				get_viewport().set_input_as_handled()
				return
		if click_event.button_index == MOUSE_BUTTON_RIGHT and click_event.pressed and catalogue_panel.visible:
			clear_pinned_catalogue_detail()
			get_viewport().set_input_as_handled()
			return
	if held_inventory_item == "":
		return
	if event is InputEventMouseMotion:
		inventory_drag_preview.global_position = get_global_mouse_position() + Vector2(12, 12)
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			finish_inventory_drag(get_global_mouse_position())
			get_viewport().set_input_as_handled()

func start_inventory_drag(item_name: String, source: String) -> void:
	held_inventory_item = item_name
	held_inventory_source = source
	clear_children(inventory_drag_preview)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(54, 54)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(str(ICONS[inventory_item_icon_id(item_name)]))
	inventory_drag_preview.add_child(icon)
	inventory_drag_preview.visible = true
	inventory_drag_preview.global_position = get_global_mouse_position() + Vector2(12, 12)

func finish_inventory_drag(global_position: Vector2) -> void:
	var item_name := held_inventory_item
	var source := held_inventory_source
	held_inventory_item = ""
	held_inventory_source = ""
	inventory_drag_preview.visible = false
	if item_name == "":
		return
	var target_slot := inventory_slot_at(global_position)
	var did_commit := false
	if target_slot != "" and item_fits_slot(item_name, target_slot):
		remove_inventory_drag_source(item_name, source)
		equip_item_to_slot(item_name, target_slot, source)
		did_commit = true
	elif inventory_grid.visible and inventory_grid.get_global_rect().has_point(global_position):
		if source != "inventory":
			remove_inventory_drag_source(item_name, source)
			add_inventory_item(item_name)
			did_commit = true
	if did_commit:
		normalize_equipment()
		player.deck = deck_from_equipment(player.equipment)
		render_inventory()
		render_deck()

func inventory_slot_at(global_position: Vector2) -> String:
	for slot in equipment_slot_controls:
		var control: Control = equipment_slot_controls[slot]
		if control.get_global_rect().has_point(global_position):
			return str(slot)
	for slot in core_slot_controls:
		var control: Control = core_slot_controls[slot]
		if control.get_global_rect().has_point(global_position):
			return str(slot)
	return ""

func equip_inventory_item(item_name: String) -> void:
	if mode == "combat":
		return
	if is_core_item(item_name):
		if not remove_inventory_item(item_name):
			return
		equip_core_to_first_available_slot(core_name_from_item(item_name), "inventory")
		render_inventory()
		return
	if not EQUIPMENT_DATA.has(item_name):
		return
	var slot := first_slot_for_item(item_name)
	if slot == "":
		return
	if not remove_inventory_item(item_name):
		return
	equip_item_to_slot(item_name, slot, "inventory")
	player.deck = deck_from_equipment(player.equipment)
	render_inventory()
	render_deck()

func equip_item_to_slot(item_name: String, slot: String, source: String) -> void:
	if slot.begins_with("core:"):
		equip_core_item_to_slot(item_name, slot, source)
		return
	if not item_fits_slot(item_name, slot):
		return_inventory_item_to_source(item_name, source)
		return
	var replaced := str(player.equipment.get(slot, ""))
	player.equipment[slot] = item_name
	if replaced != "":
		if source.begins_with("slot:"):
			var source_slot := source.trim_prefix("slot:")
			player.equipment[source_slot] = replaced
		elif not is_basic_equipment(replaced):
			add_inventory_item(replaced)

func remove_inventory_drag_source(item_name: String, source: String) -> void:
	if source.begins_with("slot:"):
		var source_slot := source.trim_prefix("slot:")
		if str(player.equipment.get(source_slot, "")) == item_name:
			player.equipment[source_slot] = ""
	elif source.begins_with("core:"):
		var source_index := int(source.trim_prefix("core:"))
		if core_at(source_index) == core_name_from_item(item_name):
			set_core_at(source_index, "")
	else:
		remove_inventory_item(item_name)

func return_inventory_item_to_source(item_name: String, source: String) -> void:
	if source.begins_with("slot:"):
		var source_slot := source.trim_prefix("slot:")
		player.equipment[source_slot] = item_name
	elif source.begins_with("core:"):
		set_core_at(int(source.trim_prefix("core:")), core_name_from_item(item_name))
	else:
		add_inventory_item(item_name)

func item_fits_slot(item_name: String, slot: String) -> bool:
	if slot.begins_with("core:"):
		return is_core_item(item_name)
	if not EQUIPMENT_DATA.has(item_name):
		return false
	var item_slot := str(EQUIPMENT_DATA[item_name].slot)
	if item_slot == slot:
		return true
	return item_slot == "trinket" and slot.begins_with("trinket")

func first_slot_for_item(item_name: String) -> String:
	if not EQUIPMENT_DATA.has(item_name):
		return ""
	var item_slot := str(EQUIPMENT_DATA[item_name].slot)
	if item_slot != "trinket":
		return item_slot
	for slot in ["trinket1", "trinket2", "trinket3"]:
		if str(player.equipment.get(slot, "")) == "":
			return slot
	return "trinket1"

func is_basic_equipment(item_name: String) -> bool:
	return EQUIPMENT_DATA.has(item_name) and bool(EQUIPMENT_DATA[item_name].get("basic", false))

func empty_slot_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.10, 0.34)
	style.border_color = Color(0.72, 0.68, 0.54, 0.28)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func equip_core_item_to_slot(item_name: String, slot: String, source: String) -> void:
	if not is_core_item(item_name):
		return_inventory_item_to_source(item_name, source)
		return
	var target_index := int(slot.trim_prefix("core:"))
	var replaced := core_at(target_index)
	set_core_at(target_index, core_name_from_item(item_name))
	if replaced == "":
		return
	if source.begins_with("core:"):
		set_core_at(int(source.trim_prefix("core:")), replaced)
	else:
		add_inventory_item(core_item(replaced))

func equip_core_to_first_available_slot(core_name: String, source: String) -> void:
	for index in CORE_SLOT_COUNT:
		if core_at(index) == "":
			set_core_at(index, core_name)
			return
	equip_core_item_to_slot(core_item(core_name), "core:0", source)

func core_item(core_name: String) -> String:
	if core_name == "":
		return ""
	return "%s%s" % [CORE_ITEM_PREFIX, core_name]

func is_core_item(item_name: String) -> bool:
	return item_name.begins_with(CORE_ITEM_PREFIX)

func core_name_from_item(item_name: String) -> String:
	return item_name.trim_prefix(CORE_ITEM_PREFIX) if is_core_item(item_name) else item_name

func core_at(index: int) -> String:
	if not player.has("cores"):
		player.cores = []
	var cores: Array = player.cores
	if index < 0 or index >= cores.size():
		return ""
	return str(cores[index])

func set_core_at(index: int, core_name: String) -> void:
	if not player.has("cores"):
		player.cores = []
	var cores: Array = player.cores
	while cores.size() <= index and cores.size() < CORE_SLOT_COUNT:
		cores.append("")
	if index >= 0 and index < CORE_SLOT_COUNT:
		cores[index] = core_name
	player.cores = cores

func equipped_core_count() -> int:
	if not player.has("cores"):
		player.cores = []
	var count := 0
	for core_name in player.cores:
		if str(core_name) != "":
			count += 1
	return count

func add_inventory_item(item_name: String) -> void:
	if not player.has("inventory"):
		player.inventory = []
	var items: Array = player.inventory
	items.append(item_name)
	player.inventory = items

func remove_inventory_item(item_name: String) -> bool:
	if not player.has("inventory"):
		player.inventory = []
	var items: Array = player.inventory
	var index := items.find(item_name)
	if index < 0:
		return false
	items.remove_at(index)
	player.inventory = items
	return true

func process_keyboard_overworld_movement(delta: float) -> void:
	if not can_accept_overworld_movement():
		return
	var direction := held_overworld_direction()
	if direction == Vector2.ZERO:
		return
	clear_overworld_movement_queue()
	move_player(direction, KEYBOARD_MOVE_SPEED * minf(delta, 1.0 / 30.0))

func held_overworld_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	return direction

func is_overworld_movement_key(keycode: Key) -> bool:
	return keycode == KEY_W or keycode == KEY_UP or keycode == KEY_S or keycode == KEY_DOWN or keycode == KEY_A or keycode == KEY_LEFT or keycode == KEY_D or keycode == KEY_RIGHT

func move_player(direction: Vector2, distance: float) -> void:
	if not can_accept_overworld_movement():
		return
	if direction == Vector2.ZERO:
		return
	var old_position := player_pos
	var movement := direction.normalized() * distance
	if not try_move_player_by(movement):
		return
	advance_time_for_overworld_distance(old_position.distance_to(player_pos))
	reveal_around_player()
	check_arrival()
	render_all()

func try_move_player_by(movement: Vector2) -> bool:
	if movement == Vector2.ZERO:
		return false
	var candidates: Array[Vector2] = [movement]
	if not is_zero_approx(movement.x) and not is_zero_approx(movement.y):
		candidates.append(Vector2(movement.x, 0.0))
		candidates.append(Vector2(0.0, movement.y))
	for divisor in [2.0, 4.0, 8.0]:
		candidates.append(movement / divisor)
		if not is_zero_approx(movement.x) and not is_zero_approx(movement.y):
			candidates.append(Vector2(movement.x / divisor, 0.0))
			candidates.append(Vector2(0.0, movement.y / divisor))
	for candidate in candidates:
		var next_position := player_pos + candidate
		next_position = Vector2(clampf(next_position.x, 0.04, 0.96), clampf(next_position.y, 0.04, 0.96))
		if can_stand_at(next_position):
			player_pos = next_position
			return true
	return false

func process_overworld_movement(delta: float) -> void:
	if overworld_movement_queue.is_empty():
		return
	if not can_accept_overworld_movement():
		clear_overworld_movement_queue()
		return
	var target: Vector2 = overworld_movement_queue[0]
	var direction := target - player_pos
	var distance := direction.length()
	var step: float = CLICK_MOVE_SPEED * minf(delta, 1.0 / 30.0)
	var old_position := player_pos
	if distance <= step:
		player_pos = target
		overworld_movement_queue.pop_front()
	else:
		if not try_move_player_by(direction.normalized() * step):
			clear_overworld_movement_queue()
			return
	player_pos = Vector2(clampf(player_pos.x, 0.04, 0.96), clampf(player_pos.y, 0.04, 0.96))
	advance_time_for_overworld_distance(old_position.distance_to(player_pos))
	reveal_around_player()
	check_arrival()
	render_all()

func advance_time_for_overworld_distance(distance: float) -> void:
	if distance <= 0.0:
		return
	travel_day_progress += distance
	var hour_distance := OVERWORLD_SQUARE_SIZE / float(HOURS_PER_DAY)
	while travel_day_progress >= hour_distance:
		travel_day_progress -= hour_distance
		advance_hours(1)

func advance_hours(hours: int) -> void:
	if hours <= 0:
		return
	calendar_hour += hours
	while calendar_hour >= HOURS_PER_DAY:
		calendar_hour -= HOURS_PER_DAY
		advance_days(1)

func advance_days(days: int) -> void:
	if days <= 0:
		return
	calendar_day += days
	while calendar_day >= DAYS_PER_YEAR:
		calendar_day -= DAYS_PER_YEAR
		calendar_year += 1

func queue_overworld_movement(destination: Vector2) -> void:
	if not can_accept_overworld_movement():
		return
	var clamped_destination := Vector2(clampf(destination.x, 0.04, 0.96), clampf(destination.y, 0.04, 0.96))
	if not can_travel_to(clamped_destination):
		return
	overworld_movement_queue.append(clamped_destination)

func enqueue_confirmed_travel_path(path: Array[Vector2]) -> void:
	clear_overworld_movement_queue()
	for destination in path:
		var clamped_destination := Vector2(clampf(destination.x, 0.04, 0.96), clampf(destination.y, 0.04, 0.96))
		overworld_movement_queue.append(clamped_destination)

func clear_overworld_movement_queue() -> void:
	overworld_movement_queue.clear()

func can_accept_overworld_movement() -> bool:
	return mode == "overworld" and not title_layer.visible and not in_game_menu_popup.visible and not save_prompt_popup.visible and not travel_prompt_popup.visible and not travel_message_popup.visible and not settings_panel.visible and not catalogue_panel.visible and not log_popup.visible and not inventory_popup.visible and not town_popup.visible and not event_popup.visible and not map_overlay.visible and not combat_layer.visible

func can_travel_to(_destination: Vector2) -> bool:
	return can_stand_at(_destination)

func can_stand_at(map_position: Vector2) -> bool:
	var terrain := terrain_at(map_position)
	if terrain == "sea":
		return false
	if terrain == "mountain" and is_mountain_core(map_position):
		return false
	return true

func is_mountain_core(map_position: Vector2) -> bool:
	var mountain_neighbors := 0
	var sample_offsets: Array[Vector2] = [
		Vector2(1.0, 0.0),
		Vector2(-1.0, 0.0),
		Vector2(0.0, 1.0),
		Vector2(0.0, -1.0),
		Vector2(1.0, 1.0).normalized(),
		Vector2(1.0, -1.0).normalized(),
		Vector2(-1.0, 1.0).normalized(),
		Vector2(-1.0, -1.0).normalized()
	]
	for offset in sample_offsets:
		var sample_position := map_position + offset * MOUNTAIN_CORE_SAMPLE_RADIUS
		sample_position = Vector2(clampf(sample_position.x, 0.0, 1.0), clampf(sample_position.y, 0.0, 1.0))
		if terrain_at(sample_position) == "mountain":
			mountain_neighbors += 1
	return mountain_neighbors >= MOUNTAIN_CORE_NEIGHBOR_THRESHOLD

func terrain_at(map_position: Vector2) -> String:
	if terrain_image == null:
		return "plains"
	var image_size := terrain_image.get_size()
	if image_size.x <= 0 or image_size.y <= 0:
		return "plains"
	var pixel_x: int = clampi(int(round(map_position.x * float(image_size.x - 1))), 0, image_size.x - 1)
	var pixel_y: int = clampi(int(round(map_position.y * float(image_size.y - 1))), 0, image_size.y - 1)
	var color := terrain_image.get_pixel(pixel_x, pixel_y)
	return nearest_terrain_name(color)

func nearest_terrain_name(color: Color) -> String:
	var best_name := "plains"
	var best_distance := INF
	var terrain_colors := {
		"sea": TERRAIN_SEA,
		"river": TERRAIN_RIVER,
		"plains": TERRAIN_PLAINS,
		"desert": TERRAIN_DESERT,
		"forest": TERRAIN_FOREST,
		"rainforest": TERRAIN_RAINFOREST,
		"mountain": TERRAIN_MOUNTAIN,
		"tundra": TERRAIN_TUNDRA
	}
	for terrain_name in terrain_colors:
		var terrain_color: Color = terrain_colors[terrain_name]
		var red_delta := color.r - terrain_color.r
		var green_delta := color.g - terrain_color.g
		var blue_delta := color.b - terrain_color.b
		var distance := red_delta * red_delta + green_delta * green_delta + blue_delta * blue_delta
		if distance < best_distance:
			best_distance = distance
			best_name = str(terrain_name)
	return best_name

func terrain_travel_cost(map_position: Vector2) -> float:
	match terrain_at(map_position):
		"river":
			return 1.7
		"desert":
			return 1.45
		"forest":
			return 1.35
		"mountain":
			return 2.2
		"rainforest":
			return 1.8
		"tundra":
			return 1.55
		_:
			return 1.0

func map_to_travel_cell(map_position: Vector2) -> Vector2i:
	return Vector2i(
		clampi(int(floor(map_position.x * float(TRAVEL_GRID_SIZE.x))), 0, TRAVEL_GRID_SIZE.x - 1),
		clampi(int(floor(map_position.y * float(TRAVEL_GRID_SIZE.y))), 0, TRAVEL_GRID_SIZE.y - 1)
	)

func travel_cell_to_map(cell: Vector2i) -> Vector2:
	return Vector2((float(cell.x) + 0.5) / float(TRAVEL_GRID_SIZE.x), (float(cell.y) + 0.5) / float(TRAVEL_GRID_SIZE.y))

func is_travel_cell_passable(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= TRAVEL_GRID_SIZE.x or cell.y >= TRAVEL_GRID_SIZE.y:
		return false
	return can_stand_at(travel_cell_to_map(cell))

func nearest_passable_cell(origin: Vector2i) -> Vector2i:
	if is_travel_cell_passable(origin):
		return origin
	var frontier: Array[Vector2i] = [origin]
	var visited := {origin: true}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		for direction in directions:
			var next_cell := cell + direction
			if visited.has(next_cell):
				continue
			visited[next_cell] = true
			if is_travel_cell_passable(next_cell):
				return next_cell
			if next_cell.x >= 0 and next_cell.y >= 0 and next_cell.x < TRAVEL_GRID_SIZE.x and next_cell.y < TRAVEL_GRID_SIZE.y:
				frontier.append(next_cell)
	return origin

func shortest_travel_path(start_position: Vector2, destination: Vector2) -> Array[Vector2]:
	var start_cell := nearest_passable_cell(map_to_travel_cell(start_position))
	var goal_cell := nearest_passable_cell(map_to_travel_cell(destination))
	if not is_travel_cell_passable(start_cell) or not is_travel_cell_passable(goal_cell):
		return []
	var open_cells: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {}
	var cost_so_far := {start_cell: 0.0}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	while not open_cells.is_empty():
		var current_index := lowest_travel_priority_index(open_cells, goal_cell, cost_so_far)
		var current: Vector2i = open_cells[current_index]
		open_cells.remove_at(current_index)
		if current == goal_cell:
			return reconstruct_travel_path(came_from, start_cell, goal_cell, destination)
		for direction in directions:
			var next_cell := current + direction
			if not is_travel_cell_passable(next_cell):
				continue
			if direction.x != 0 and direction.y != 0:
				if not is_travel_cell_passable(current + Vector2i(direction.x, 0)) or not is_travel_cell_passable(current + Vector2i(0, direction.y)):
					continue
			var step_distance := 1.4142 if direction.x != 0 and direction.y != 0 else 1.0
			var next_position := travel_cell_to_map(next_cell)
			var new_cost: float = float(cost_so_far[current]) + step_distance * terrain_travel_cost(next_position)
			if not cost_so_far.has(next_cell) or new_cost < float(cost_so_far[next_cell]):
				cost_so_far[next_cell] = new_cost
				came_from[next_cell] = current
				if not open_cells.has(next_cell):
					open_cells.append(next_cell)
	return []

func lowest_travel_priority_index(open_cells: Array[Vector2i], goal_cell: Vector2i, cost_so_far: Dictionary) -> int:
	var best_index := 0
	var best_priority := INF
	for index in open_cells.size():
		var cell: Vector2i = open_cells[index]
		var heuristic := absf(float(cell.x - goal_cell.x)) + absf(float(cell.y - goal_cell.y))
		var priority: float = float(cost_so_far[cell]) + heuristic
		if priority < best_priority:
			best_priority = priority
			best_index = index
	return best_index

func reconstruct_travel_path(came_from: Dictionary, start_cell: Vector2i, goal_cell: Vector2i, destination: Vector2) -> Array[Vector2]:
	var cells: Array[Vector2i] = []
	var current := goal_cell
	cells.append(current)
	while current != start_cell:
		if not came_from.has(current):
			return []
		current = came_from[current]
		cells.append(current)
	cells.reverse()
	var points: Array[Vector2] = []
	for index in range(1, cells.size()):
		points.append(travel_cell_to_map(cells[index]))
	points.append(destination)
	return simplify_travel_path(points)

func simplify_travel_path(points: Array[Vector2]) -> Array[Vector2]:
	if points.size() <= 2:
		return points
	var simplified: Array[Vector2] = []
	var previous_direction := Vector2.ZERO
	for index in points.size():
		if index == points.size() - 1:
			simplified.append(points[index])
			continue
		var current_direction := (points[index + 1] - points[index]).normalized().round()
		if index == 0 or current_direction != previous_direction:
			simplified.append(points[index])
		previous_direction = current_direction
	return simplified

func reveal_around_player() -> void:
	if explored.is_empty() or explored[-1].pos.distance_to(player_pos) > 0.018:
		explored.append({"pos": player_pos, "radius": FOG_RADIUS})
	for location in locations:
		var loc_pos: Vector2 = Vector2(float(location.x), float(location.y))
		if player_pos.distance_to(loc_pos) < 0.075 and not discovered.has(location.id):
			discover_location(location.id)

func discover_location(location_id: String) -> void:
	var location := get_location(location_id)
	discovered[location_id] = true
	var already := false
	for spot in explored:
		if spot.pos.distance_to(Vector2(location.x, location.y)) < 0.02:
			already = true
	if not already:
		explored.append({"pos": Vector2(location.x, location.y), "radius": FOG_RADIUS})

func check_arrival() -> void:
	for location in locations:
		if discovered.has(location.id) and player_pos.distance_to(Vector2(location.x, location.y)) < 0.026 and location.id != current_location.id:
			if str(location.type) == "town":
				current_location = location
				render_all()
				return
			current_location = location
			add_log("You arrive at %s." % location.name, str(location.name))
			enter_location()
			return

func enter_location() -> void:
	if current_location.type == "town":
		mode = "town"
	elif resolved_events.has(current_location.id):
		mode = "overworld"
		if str(current_location.type) != "town":
			add_log("%s is quiet now." % current_location.name, str(current_location.name))
	else:
		mode = "event"
		add_log("An event stirs at %s." % current_location.name, str(current_location.name))
	if mode != "overworld":
		clear_overworld_movement_queue()
	render_all()

func nearby_town() -> Dictionary:
	for location in locations:
		if str(location.type) != "town" or not discovered.has(location.id):
			continue
		if player_pos.distance_to(Vector2(float(location.x), float(location.y))) <= TOWN_ENTRY_RADIUS:
			return location
	return {}

func enter_nearby_town() -> void:
	var town := nearby_town()
	if town.is_empty():
		return
	current_location = town
	clear_overworld_movement_queue()
	enter_location()

func scout() -> void:
	for location in locations:
		if not discovered.has(location.id):
			discover_location(location.id)
			add_log("A rumor reveals the way to %s." % location.name)
			render_all()
			return
	add_log("No hidden routes remain in this prototype.")
	render_all()

func toggle_fog_for_testing() -> void:
	fog_hidden_for_testing = not fog_hidden_for_testing
	map_view.set_fog_hidden(fog_hidden_for_testing)
	render_all()

func render_quest_tracker() -> void:
	if quest_tracker_list == null:
		return
	clear_children(quest_tracker_list)
	add_quest_section("Main Quest", quests_for("main", false))
	add_quest_section("Side Quests", quests_for("side", false))
	add_quest_section("Finished", completed_quests(), true)

func quests_for(kind: String, completed: bool) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for quest in QUESTS:
		if str(quest.kind) == kind and bool(quest.completed) == completed:
			results.append(quest)
	return results

func completed_quests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for quest in QUESTS:
		if bool(quest.completed):
			results.append(quest)
	return results

func add_quest_section(title: String, quests: Array[Dictionary], completed_section: bool = false) -> void:
	if quests.is_empty():
		return
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.24, 0.14, 0.06, 1.0) if not completed_section else Color(0.34, 0.31, 0.27, 0.85))
	quest_tracker_list.add_child(label)
	for quest in quests:
		quest_tracker_list.add_child(make_quest_row(quest))

func make_quest_row(quest: Dictionary) -> Control:
	var completed := bool(quest.completed)
	var row_panel := PanelContainer.new()
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.93, 0.80, 0.55, 0.78) if not completed else Color(0.42, 0.39, 0.34, 0.42)
	style.border_color = Color(0.35, 0.22, 0.10, 0.55) if not completed else Color(0.25, 0.24, 0.22, 0.45)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_top = 7
	style.content_margin_right = 8
	style.content_margin_bottom = 7
	row_panel.add_theme_stylebox_override("panel", style)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	row_panel.add_child(stack)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	stack.add_child(header)

	var quest_id := str(quest.id)
	if not collapsed_quests.has(quest_id):
		collapsed_quests[quest_id] = true
	var collapsed := bool(collapsed_quests[quest_id])
	var toggle := Button.new()
	toggle.text = "+" if collapsed else "-"
	toggle.custom_minimum_size = Vector2(28, 28)
	toggle.disabled = false
	if completed:
		toggle.modulate = Color(0.58, 0.55, 0.49, 0.9)
	toggle.pressed.connect(func() -> void:
		collapsed_quests[quest_id] = not bool(collapsed_quests[quest_id])
		render_quest_tracker()
	)
	header.add_child(toggle)

	var title := Label.new()
	title.text = str(quest.title)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.18, 0.10, 0.04, 1.0) if not completed else Color(0.32, 0.30, 0.27, 0.75))
	header.add_child(title)

	if not collapsed:
		var summary := Label.new()
		summary.text = "%s\n\n%s" % [str(quest.summary), str(quest.objective)]
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.add_theme_font_size_override("font_size", 14)
		summary.add_theme_color_override("font_color", Color(0.23, 0.13, 0.06, 0.95) if not completed else Color(0.32, 0.30, 0.27, 0.72))
		stack.add_child(summary)
	return row_panel

func render_all() -> void:
	var inventory_overlay_active: bool = inventory_popup.visible and mode != "combat"
	position_right_side_panels()
	render_time_display()
	run_label.text = "Run %s - %s" % [run, player.name]
	hp_label.text = "Health\n%s/%s" % [player.hp, player.max_hp]
	deck_label.text = "Deck\n%s" % player.deck.size()
	gold_label.text = "Gold\n%s" % player.gold
	mode_label.text = "Mode\n%s" % mode
	var clean_overworld := mode == "overworld" and not title_layer.visible and not inventory_overlay_active and not town_popup.visible and not event_popup.visible and not combat_layer.visible and not in_game_menu_popup.visible and not save_prompt_popup.visible and not settings_panel.visible and not catalogue_panel.visible and not log_popup.visible and not inventory_popup.visible and not map_overlay.visible
	overworld_hud.visible = clean_overworld
	overworld_stats_bar.visible = clean_overworld
	quest_tracker_panel.visible = clean_overworld
	overworld_zoom_controls.visible = mode == "overworld" and not title_layer.visible and not inventory_overlay_active and not town_popup.visible and not event_popup.visible and not combat_layer.visible
	fog_test_button.visible = overworld_zoom_controls.visible
	fog_test_button.text = "Show Fog" if fog_hidden_for_testing else "Hide Fog"
	var town_in_range := nearby_town()
	enter_town_button.visible = mode == "overworld" and not town_in_range.is_empty() and not title_layer.visible
	if enter_town_button.visible:
		enter_town_button.text = "Enter %s" % str(town_in_range.name)
	location_name.text = current_location.name
	location_lore.text = current_location.lore
	map_view.set_world_state(player_pos, discovered, explored, current_location.id)
	if combat_layer.visible:
		combat_map_view.set_world_state(player_pos, discovered, explored, current_location.id)
	if map_overlay.visible:
		map_overlay_view.set_world_state(player_pos, discovered, explored, current_location.id)
	if compact_map_panel.visible:
		compact_map_view.set_world_state(player_pos, discovered, explored, current_location.id)
	render_inventory()
	render_deck()
	render_town()
	render_event()
	render_combat()
	render_fullscreen_combat()
	render_log()
	render_quest_tracker()
	update_top_right_controls()

func position_right_side_panels() -> void:
	if map_view == null or quest_tracker_panel == null or top_right_controls == null:
		return
	var map_rect: Rect2 = map_view.get_base_map_rect()
	var left_edge := clampf(map_rect.end.x, size.x * 0.52, size.x - 360.0)
	var offset_left := left_edge - size.x
	quest_tracker_panel.offset_left = offset_left
	quest_tracker_panel.offset_right = 0

func request_overworld_layout_refresh() -> void:
	if not is_inside_tree():
		return
	call_deferred("refresh_overworld_layout")

func refresh_overworld_layout() -> void:
	if map_view == null:
		return
	position_right_side_panels()
	resize_top_right_controls()
	if quest_tracker_panel != null:
		quest_tracker_panel.queue_sort()

func can_show_compact_map_button() -> bool:
	if title_layer.visible:
		return false
	if mode != "overworld":
		return true
	return in_game_menu_popup.visible or save_prompt_popup.visible or settings_panel.visible or catalogue_panel.visible or log_popup.visible or inventory_popup.visible or character_info_popup.visible

func update_top_right_controls() -> void:
	if top_right_controls == null:
		return
	top_right_controls.visible = not title_layer.visible
	in_game_menu_button.visible = not in_game_menu_popup.visible
	chronicle_button.visible = not log_popup.visible
	inventory_button.visible = not inventory_popup.visible
	var compact_map_available := can_show_compact_map_button()
	if map_button != null:
		map_button.visible = compact_map_available
	if compact_map_panel.visible and not compact_map_available:
		compact_map_panel.visible = false
	resize_top_right_controls()
	if top_right_controls.visible:
		raise_active_overlay()
		if compact_map_panel.visible:
			compact_map_panel.move_to_front()
		top_right_controls.move_to_front()

func raise_active_overlay() -> void:
	if save_prompt_popup.visible:
		save_prompt_popup.move_to_front()
	elif in_game_menu_popup.visible:
		in_game_menu_popup.move_to_front()
	elif settings_panel.visible:
		settings_panel.move_to_front()
	elif inventory_popup.visible:
		inventory_popup.move_to_front()
	elif log_popup.visible:
		log_popup.move_to_front()
	elif catalogue_panel.visible:
		catalogue_panel.move_to_front()
	elif character_info_popup.visible:
		character_info_popup.move_to_front()

func resize_top_right_controls() -> void:
	if top_right_controls == null or top_right_button_bar == null:
		return
	var button_width := top_right_button_bar.get_combined_minimum_size().x
	var bar_width := maxf(86.0, button_width + 20.0)
	top_right_controls.offset_left = -bar_width - 16.0
	top_right_controls.offset_right = -16.0

func render_time_display() -> void:
	if time_label == null:
		return
	time_label.text = "Year %s, Day %s, Hour %s/%s" % [calendar_year, calendar_day, calendar_hour + 1, HOURS_PER_DAY]
	var gameplay_mode := mode == "overworld" or mode == "town" or mode == "event" or mode == "combat"
	var blocking_popup_open := in_game_menu_popup.visible or save_prompt_popup.visible or travel_message_popup.visible or settings_panel.visible or catalogue_panel.visible or log_popup.visible or inventory_popup.visible or map_overlay.visible or character_info_popup.visible
	time_label.visible = gameplay_mode and not title_layer.visible and not blocking_popup_open
	time_label.move_to_front()

func render_inventory() -> void:
	if player.is_empty():
		return
	normalize_equipment()
	equipment_slot_controls = {}
	core_slot_controls = {}
	clear_children(inventory_stats_box)
	clear_children(inventory_character_layer)
	clear_children(inventory_grid)
	clear_children(inventory_core_layer)
	render_inventory_stats()
	render_character_equipment()
	render_core_slots()
	render_inventory_items()

func normalize_equipment() -> void:
	if not player.has("equipment"):
		player.equipment = STARTER_EQUIPMENT.duplicate()
	var equipment: Dictionary = player.equipment
	if equipment.has("trinkets"):
		var old_trinket := str(equipment.get("trinkets", ""))
		if old_trinket != "":
			equipment["trinket1"] = old_trinket
		equipment.erase("trinkets")
	for slot in EQUIPMENT_SLOTS:
		if not equipment.has(slot):
			equipment[slot] = ""
	for slot in BASIC_EQUIPMENT_BY_SLOT:
		if str(equipment.get(slot, "")) == "":
			equipment[slot] = str(BASIC_EQUIPMENT_BY_SLOT[slot])
	player.equipment = equipment

func render_inventory_stats() -> void:
	inventory_stats_box.add_child(make_icon_value("health", "%s/%s" % [player.hp, player.max_hp]))
	inventory_stats_box.add_child(make_icon_value("speed", str(player.speed)))
	inventory_stats_box.add_child(make_icon_value("gold", str(player.gold)))

func render_character_equipment() -> void:
	var body_line := ColorRect.new()
	body_line.color = Color(0.95, 0.90, 0.75, 0.20)
	body_line.position = Vector2(210, 96)
	body_line.size = Vector2(12, 260)
	inventory_character_layer.add_child(body_line)
	var arm_line := ColorRect.new()
	arm_line.color = Color(0.95, 0.90, 0.75, 0.20)
	arm_line.position = Vector2(96, 180)
	arm_line.size = Vector2(240, 12)
	inventory_character_layer.add_child(arm_line)
	var leg_line := ColorRect.new()
	leg_line.color = Color(0.95, 0.90, 0.75, 0.20)
	leg_line.position = Vector2(166, 352)
	leg_line.size = Vector2(100, 12)
	inventory_character_layer.add_child(leg_line)
	var positions := {
		"head": Vector2(174, 20),
		"body": Vector2(174, 126),
		"arms": Vector2(54, 158),
		"weapon": Vector2(294, 158),
		"legs": Vector2(174, 260),
		"shoes": Vector2(174, 368),
		"trinket1": Vector2(294, 20),
		"trinket2": Vector2(294, 82),
		"trinket3": Vector2(294, 260)
	}
	for slot in EQUIPMENT_SLOTS:
		var button := make_equipment_slot_button(slot)
		button.position = positions[slot]
		inventory_character_layer.add_child(button)
		equipment_slot_controls[slot] = button

func render_core_slots() -> void:
	if mode == "combat":
		inventory_core_layer.visible = false
		return
	inventory_core_layer.visible = true
	var slot_positions := [
		Vector2(58, 0),
		Vector2(0, 58),
		Vector2(58, 58),
		Vector2(116, 58),
		Vector2(58, 116)
	]
	for index in CORE_SLOT_COUNT:
		var button := make_core_slot_button(index)
		button.position = slot_positions[index]
		inventory_core_layer.add_child(button)
		core_slot_controls["core:%s" % index] = button

func render_inventory_items() -> void:
	if mode == "combat":
		inventory_grid.visible = false
		return
	inventory_grid.visible = true
	var items: Array = player.inventory if player.has("inventory") else []
	for index in 10:
		var item_name := str(items[index]) if index < items.size() else ""
		inventory_grid.add_child(make_inventory_slot_button(item_name))

func make_equipment_slot_button(slot: String) -> Button:
	var item_name: String = str(player.equipment.get(slot, ""))
	var button := Button.new()
	var slot_size := 74.0 if mode == "combat" else 86.0
	button.custom_minimum_size = Vector2(slot_size, slot_size)
	button.size = Vector2(slot_size, slot_size)
	button.text = ""
	if item_name != "":
		button.icon = load(str(ICONS[equipment_icon_id(item_name)]))
	button.expand_icon = true
	if item_name == "":
		var style := empty_slot_style()
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
	else:
		button.mouse_entered.connect(func() -> void: show_inventory_item_info(item_name, slot))
		button.mouse_exited.connect(hide_card_preview)
	button.gui_input.connect(func(event: InputEvent) -> void:
		if mode == "combat":
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and item_name != "" and not is_basic_equipment(item_name):
			unequip_item_from_slot(slot)
			get_viewport().set_input_as_handled()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and item_name != "" and not is_basic_equipment(item_name):
			start_inventory_drag(item_name, "slot:%s" % slot)
			get_viewport().set_input_as_handled()
	)
	return button

func make_core_slot_button(index: int) -> Button:
	var core_name := core_at(index)
	var button := Button.new()
	button.custom_minimum_size = Vector2(58, 58)
	button.size = Vector2(58, 58)
	button.text = ""
	if core_name != "":
		button.icon = load(str(ICONS["core"]))
	button.expand_icon = true
	if core_name == "":
		var style := empty_slot_style()
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
	else:
		button.mouse_entered.connect(func() -> void: show_inventory_item_info(core_item(core_name), "core"))
		button.mouse_exited.connect(hide_card_preview)
	button.gui_input.connect(func(event: InputEvent) -> void:
		if core_name == "" or mode == "combat":
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			unequip_core_from_slot(index)
			get_viewport().set_input_as_handled()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_inventory_drag(core_item(core_name), "core:%s" % index)
			get_viewport().set_input_as_handled()
	)
	return button

func unequip_item_from_slot(slot: String) -> void:
	var item_name := str(player.equipment.get(slot, ""))
	if item_name == "" or is_basic_equipment(item_name):
		return
	player.equipment[slot] = str(BASIC_EQUIPMENT_BY_SLOT.get(slot, ""))
	add_inventory_item(item_name)
	player.deck = deck_from_equipment(player.equipment)
	render_inventory()
	render_deck()

func unequip_core_from_slot(index: int) -> void:
	var core_name := core_at(index)
	if core_name == "":
		return
	set_core_at(index, "")
	add_inventory_item(core_item(core_name))
	render_inventory()

func make_inventory_slot_button(item_name: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(94, 86)
	button.text = ""
	if item_name != "":
		button.icon = load(str(ICONS[inventory_item_icon_id(item_name)]))
	else:
		var style := empty_slot_style()
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
	button.expand_icon = true
	button.mouse_entered.connect(func() -> void:
		if item_name != "":
			show_inventory_item_info(item_name, "")
	)
	button.mouse_exited.connect(hide_card_preview)
	button.gui_input.connect(func(event: InputEvent) -> void:
		if item_name == "":
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			equip_inventory_item(item_name)
			get_viewport().set_input_as_handled()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_inventory_drag(item_name, "inventory")
			get_viewport().set_input_as_handled()
	)
	return button

func equipment_icon_id(item_name: String) -> String:
	if item_name == "" or not EQUIPMENT_DATA.has(item_name):
		return "core"
	return str(EQUIPMENT_DATA[item_name].icon)

func inventory_item_icon_id(item_name: String) -> String:
	return "core" if is_core_item(item_name) else equipment_icon_id(item_name)

func inventory_item_display_name(item_name: String) -> String:
	return "%s Core" % core_name_from_item(item_name) if is_core_item(item_name) else item_name

func inventory_item_tooltip(item_name: String, slot: String) -> String:
	return core_tooltip(core_name_from_item(item_name)) if is_core_item(item_name) else equipment_tooltip(item_name, slot)

func core_tooltip(core_name: String) -> String:
	if core_name == "":
		return "Core slot empty"
	return "%s Core\nType: Core" % core_name

func equipment_tooltip(item_name: String, slot: String) -> String:
	if is_core_item(item_name):
		return core_tooltip(core_name_from_item(item_name))
	if item_name == "":
		return "%s slot empty" % slot.capitalize()
	var item: Dictionary = EQUIPMENT_DATA.get(item_name, {})
	var lines: Array[String] = [item_name, "Type: %s" % str(item.get("slot", slot)).capitalize()]
	var stats: Dictionary = item.get("stats", {})
	for stat in stats:
		lines.append("%s +%s" % [str(stat).capitalize(), stats[stat]])
	var abilities: Array = item.get("abilities", [])
	for ability in abilities:
		lines.append(str(ability))
	var item_cards: Array = item.get("cards", [])
	var card_names: Array[String] = []
	for card_id in item_cards:
		var card: Dictionary = cards.get(str(card_id), {})
		card_names.append(str(card.get("name", card_id)))
	lines.append("Cards: %s" % (", ".join(card_names) if not card_names.is_empty() else "None"))
	return "\n".join(lines)

func show_inventory_item_info(item_name: String, slot: String) -> void:
	clear_children(card_preview)
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(230, 0)
	panel.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = equipment_tooltip(item_name, slot)
	panel.add_child(label)
	if item_name != "" and EQUIPMENT_DATA.has(item_name):
		var item_cards: Array = EQUIPMENT_DATA[item_name].get("cards", [])
		var row := GridContainer.new()
		row.columns = 3
		row.add_theme_constant_override("h_separation", 6)
		row.add_theme_constant_override("v_separation", 6)
		for card_id in item_cards.slice(0, 3):
			var card: Dictionary = cards.get(str(card_id), {})
			if card.is_empty():
				continue
			var card_view = preload("res://scripts/CardView.gd").new()
			card_view.setup(card)
			card_view.draggable = false
			card_view.scale = Vector2(0.55, 0.55)
			row.add_child(card_view)
		panel.add_child(row)
	card_preview.add_child(panel)
	card_preview.visible = true
	card_preview.move_to_front()
	card_preview.global_position = get_global_mouse_position() + Vector2(18, 18)

func render_deck() -> void:
	if player.is_empty():
		return
	clear_children(deck_grid)
	inventory_scroll.visible = mode != "combat"
	if mode == "combat":
		return
	deck_grid.columns = max(1, mini(10, player.deck.size()))
	for card_id in player.deck:
		var card_data: Dictionary = cards[card_id]
		var card_view = preload("res://scripts/CardView.gd").new()
		card_view.setup(card_data)
		card_view.draggable = false
		card_view.scale = Vector2(0.72, 0.72)
		deck_grid.add_child(card_view)

func render_combat_deck_popup() -> void:
	clear_children(combat_deck_grid)
	if combat.is_empty() or not combat.has("units") or not combat.units.has("player"):
		return
	var unit: Dictionary = combat.units.player
	var remaining_deck: Array[Dictionary] = shuffle_cards(unit.deck)
	combat_deck_grid.columns = max(1, mini(6, remaining_deck.size()))
	if remaining_deck.is_empty():
		var label := Label.new()
		label.text = "Deck is empty."
		combat_deck_grid.add_child(label)
		return
	for card_data in remaining_deck:
		var card_view = preload("res://scripts/CardView.gd").new()
		card_view.setup(card_data)
		card_view.draggable = false
		card_view.scale = Vector2(0.95, 0.95)
		combat_deck_grid.add_child(card_view)

func toggle_combat_deck_popup() -> void:
	if combat_deck_popup.visible:
		combat_deck_popup.visible = false
		hide_card_preview()
		return
	discard_popup.visible = false
	render_combat_deck_popup()
	combat_deck_popup.visible = true
	combat_deck_popup.move_to_front()

func combat_submenu_open() -> bool:
	return mode == "combat" and ((combat_deck_popup != null and combat_deck_popup.visible) or (discard_popup != null and discard_popup.visible))

func close_combat_submenus() -> bool:
	var closed_any := false
	if combat_deck_popup != null and combat_deck_popup.visible:
		combat_deck_popup.visible = false
		closed_any = true
	if discard_popup != null and discard_popup.visible:
		discard_popup.visible = false
		closed_any = true
	if closed_any:
		hide_card_preview()
	return closed_any

func learn_character_info(character_name: String, info_key: String) -> void:
	if not player.has("known_characters"):
		player.known_characters = {}
	var known: Dictionary = player.known_characters
	var entry: Dictionary = known.get(character_name, {})
	entry[info_key] = true
	known[character_name] = entry
	player.known_characters = known

func knows_character_info(character_name: String, info_key: String) -> bool:
	if character_name == "Jiali" or character_name == str(player.get("name", "")):
		return true
	if not player.has("known_characters"):
		player.known_characters = {}
	var known: Dictionary = player.known_characters
	var entry: Dictionary = known.get(character_name, {})
	return bool(entry.get(info_key, false))

func has_met_character(character_name: String) -> bool:
	if character_name == "Jiali" or character_name == str(player.get("name", "")):
		return true
	if not player.has("known_characters"):
		return false
	return player.known_characters.has(character_name)

func show_combat_character_info(unit_id: String) -> void:
	if mode != "combat" or combat.is_empty() or not combat.units.has(unit_id):
		return
	clear_children(character_info_box)
	var unit: Dictionary = combat.units[unit_id]
	var name := str(unit.name)
	var title := Label.new()
	title.text = name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	character_info_box.add_child(title)
	character_info_box.add_child(make_icon("health" if str(unit.team) == "player" else "attack", Vector2(96, 96)))
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.text = character_info_text(unit)
	info.add_theme_font_size_override("font_size", 18)
	character_info_box.add_child(info)
	var card_grid := GridContainer.new()
	card_grid.columns = 3
	card_grid.add_theme_constant_override("h_separation", 8)
	card_grid.add_theme_constant_override("v_separation", 8)
	if character_cards_known(unit):
		for card in known_unit_cards(unit):
			var card_view = preload("res://scripts/CardView.gd").new()
			card_view.setup(card)
			card_view.draggable = false
			card_view.scale = Vector2(0.66, 0.66)
			card_grid.add_child(card_view)
	else:
		var unknown := Label.new()
		unknown.text = "Cards unknown"
		card_grid.add_child(unknown)
	character_info_box.add_child(card_grid)
	character_info_popup.visible = true
	character_info_popup.move_to_front()

func _on_combat_unit_clicked(unit_id: String) -> void:
	if mode != "combat" or combat.is_empty() or not combat.units.has(unit_id):
		return
	if combat.phase == "targeting" and active_unit_id() == "player":
		var unit: Dictionary = combat.units[unit_id]
		_on_combat_hex_clicked(Vector2i(int(unit.q), int(unit.r)))
		return
	show_combat_character_info(unit_id)

func character_info_text(unit: Dictionary) -> String:
	var name := str(unit.name)
	var lines: Array[String] = []
	lines.append("HP: %s/%s" % [unit.hp, unit.max_hp] if knows_character_info(name, "hp") else "HP: Unknown")
	lines.append("Speed: %s" % unit.speed if knows_character_info(name, "speed") else "Speed: Unknown")
	lines.append("Cores: %s" % unit.cores if knows_character_info(name, "cores") else "Cores: Unknown")
	return "\n".join(lines)

func character_cards_known(unit: Dictionary) -> bool:
	return knows_character_info(str(unit.name), "cards")

func known_unit_cards(unit: Dictionary) -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	var seen: Dictionary = {}
	for pile_name in ["hand", "deck", "discard"]:
		for card in unit.get(pile_name, []):
			var card_name := str(card.get("name", "Card"))
			if seen.has(card_name):
				continue
			seen[card_name] = true
			cards.append(card)
	return cards

func render_town() -> void:
	clear_children(town_panel)
	town_panel.visible = false
	town_popup.visible = mode == "town"
	if not town_popup.visible:
		return
	town_title_label.text = "%s Town" % current_location.name
	town_lore_label.text = str(current_location.lore)
	clear_children(town_place_box)
	for place in current_location.town:
		var button := Button.new()
		button.text = place
		button.pressed.connect(func() -> void: use_town_place(place))
		town_place_box.add_child(button)
	var exit := Button.new()
	exit.text = "Exit"
	exit.pressed.connect(leave_town)
	town_place_box.add_child(exit)

func leave_town() -> void:
	mode = "overworld"
	town_popup.visible = false
	clear_overworld_movement_queue()
	render_all()
	focus_overworld_on_player()

func focus_overworld_on_player() -> void:
	if map_view != null:
		map_view.focus_on_map_position(player_pos)

func render_event() -> void:
	clear_children(event_panel)
	event_panel.visible = false
	event_popup.visible = mode == "event"
	if not event_popup.visible:
		return
	var event_data: Dictionary = EVENTS[current_location.id]
	event_title_label.text = event_data.title
	event_text_label.text = event_data.text
	clear_children(event_choice_box)
	var fight := Button.new()
	fight.text = "Face It"
	style_menu_popup_button(fight)
	fight.pressed.connect(func() -> void: start_combat(event_data.enemy, current_location.danger))
	event_choice_box.add_child(fight)
	var search := Button.new()
	search.text = "Search Carefully"
	style_menu_popup_button(search)
	search.pressed.connect(resolve_event_without_combat)
	event_choice_box.add_child(search)

func render_combat() -> void:
	clear_children(combat_panel)
	combat_panel.visible = false
	if not combat_panel.visible:
		return
	add_section_label(combat_panel, combat.title)
	var combat_view: Control = preload("res://scripts/CombatView.gd").new()
	combat_view.custom_minimum_size = Vector2(360, 260)
	combat_view.set_combat_state(combat.units, combat.hexes)
	combat_panel.add_child(combat_view)
	var track := make_wrapped_label(combat_panel)
	track.text = "Initiative: %s" % join_strings(combat.initiative)
	var resources := make_wrapped_label(combat_panel)
	resources.text = "Player hand size 5. Enemy hand size %s. Draw up happens at combat start and turn end." % combat.enemy_hand_size
	var hand_label := make_wrapped_label(combat_panel)
	hand_label.text = "Hand: %s" % join_strings(combat.hand)
	var leave := Button.new()
	leave.text = "Resolve Prototype Combat"
	leave.pressed.connect(win_combat)
	combat_panel.add_child(leave)

func render_fullscreen_combat() -> void:
	combat_layer.visible = mode == "combat"
	if mode != "combat" and combat_deck_popup != null:
		combat_deck_popup.visible = false
	if mode != "combat" or combat.is_empty():
		return
	var move_hexes: Array[Vector2i] = array_to_hexes(combat.move_highlights)
	var target_hexes: Array[Vector2i] = array_to_hexes(combat.target_highlights)
	combat_board.set_combat_state(combat.units, combat.hexes, move_hexes, target_hexes)
	render_initiative()
	render_combat_resources()
	render_base_actions()
	render_action_toggles()
	render_combat_hand()
	render_energy_hole()
	render_block_attack_banner()
	render_combat_log()
	var submenu_open := combat_submenu_open()
	skip_action_button.visible = combat.phase == "targeting"
	skip_action_button.disabled = submenu_open
	var resolve_block_button := combat_layer.find_child("ResolveBlockButton", true, false) as Button
	if resolve_block_button != null:
		resolve_block_button.visible = combat.phase == "blocking" and str(combat.pending_attack.defender_id) == "player"
		resolve_block_button.disabled = submenu_open
	end_turn_button.disabled = active_unit_id() != "player" or combat.phase == "targeting" or combat.phase == "pay_energy" or combat.phase == "blocking" or submenu_open

func render_block_attack_banner() -> void:
	block_attack_banner.visible = mode == "combat" and combat.phase == "blocking" and not combat.pending_attack.is_empty()
	clear_children(block_attack_banner)
	if not block_attack_banner.visible:
		return
	var pending: Dictionary = combat.pending_attack
	var attacker: Dictionary = combat.units[str(pending.attacker_id)]
	var attacker_hex := Vector2i(int(attacker.q), int(attacker.r))
	var board_position: Vector2 = combat_board.hex_to_screen(attacker_hex)
	block_attack_banner.global_position = combat_board.global_position + board_position + Vector2(-34, -86)
	block_attack_banner.add_child(make_icon(attack_icon_id(str(pending.damage_type)), Vector2(34, 34)))
	block_attack_label = Label.new()
	block_attack_label.text = str(pending.damage)
	block_attack_label.add_theme_font_size_override("font_size", 28)
	block_attack_banner.add_child(block_attack_label)

func render_combat_log() -> void:
	clear_children(combat_log_list)
	if mode != "combat" or combat.is_empty():
		return
	for entry in combat.combat_log:
		if entry is Dictionary and entry.has("card"):
			combat_log_list.add_child(make_card_log_row(entry))
		else:
			var label := Label.new()
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.custom_minimum_size = Vector2(220, 0)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			label.text = str(entry)
			combat_log_list.add_child(label)
	call_deferred("scroll_combat_log_to_bottom")

func scroll_combat_log_to_bottom() -> void:
	if combat_log_scroll == null:
		return
	combat_log_scroll.scroll_vertical = int(combat_log_scroll.get_v_scroll_bar().max_value)

func make_card_log_row(entry: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var prefix := Label.new()
	prefix.text = str(entry.get("prefix", ""))
	prefix.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prefix.custom_minimum_size = Vector2(46, 0)
	prefix.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(prefix)
	var card: Dictionary = entry.card
	var card_button := Button.new()
	card_button.text = str(card.get("name", "Card"))
	card_button.flat = true
	card_button.focus_mode = Control.FOCUS_NONE
	card_button.custom_minimum_size = Vector2(86, 28)
	card_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_button.mouse_entered.connect(func() -> void: show_card_preview(card))
	card_button.mouse_exited.connect(hide_card_preview)
	row.add_child(card_button)
	var suffix := Label.new()
	suffix.text = str(entry.get("suffix", ""))
	suffix.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	suffix.custom_minimum_size = Vector2(46, 0)
	suffix.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(suffix)
	return row

func render_initiative() -> void:
	clear_children(initiative_bar)
	initiative_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	for unit_id in combat.initiative:
		var unit: Dictionary = combat.units[unit_id]
		var token := PanelContainer.new()
		token.custom_minimum_size = Vector2(142, 42)
		var style := StyleBoxFlat.new()
		var is_active: bool = unit_id == active_unit_id()
		style.bg_color = Color(0.18, 0.26, 0.22, 0.94) if is_active else Color(0.07, 0.09, 0.075, 0.82)
		style.border_color = Color(0.96, 0.86, 0.48, 0.95) if is_active else Color(0.75, 0.68, 0.44, 0.45)
		style.border_width_left = 2 if is_active else 1
		style.border_width_top = 2 if is_active else 1
		style.border_width_right = 2 if is_active else 1
		style.border_width_bottom = 2 if is_active else 1
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.content_margin_left = 8
		style.content_margin_top = 5
		style.content_margin_right = 8
		style.content_margin_bottom = 5
		token.add_theme_stylebox_override("panel", style)
		var label := Label.new()
		var active_marker: String = ">" if unit_id == active_unit_id() else " "
		label.text = "%s %s %s/%s" % [active_marker, unit.name, unit.hp, unit.max_hp]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		token.add_child(label)
		initiative_bar.add_child(token)

func render_combat_resources() -> void:
	var unit: Dictionary = combat.units.player
	resource_label.text = "Energy %s\nCore %s\nHP %s/%s" % [unit.energy, unit.core_pool, unit.hp, unit.max_hp]
	combat_status_label.text = combat_status_text()

func render_action_toggles() -> void:
	clear_children(action_toggle_bar)
	if combat.phase != "targeting":
		return
	for action in combat.remaining_actions:
		var action_name: String = str(action.kind).capitalize()
		var button := Button.new()
		button.text = action_name
		button.disabled = str(action.kind) == combat.selected_action
		button.pressed.connect(func() -> void: choose_card_action(str(action.kind)))
		action_toggle_bar.add_child(button)

func render_base_actions() -> void:
	base_action_bar.visible = mode == "combat"
	var can_use_base_actions: bool = active_unit_id() == "player" and combat.phase == "idle" and not combat_submenu_open()
	for child in base_action_bar.get_children():
		if child is Button:
			var button: Button = child as Button
			button.disabled = not can_use_base_actions
	if not can_use_base_actions:
		hide_base_action_info()

func render_combat_hand() -> void:
	clear_children(combat_hand_bar)
	var unit: Dictionary = combat.units.player
	for card in unit.hand:
		var card_view = preload("res://scripts/CardView.gd").new()
		card_view.name = "Card_%s" % str(card.instance_id)
		card_view.setup(card)
		card_view.drag_finished.connect(_on_card_drag_finished)
		combat_hand_bar.add_child(card_view)

func float_card_back(instance_id: String) -> void:
	for child in combat_hand_bar.get_children():
		if child.name == "Card_%s" % instance_id and child.has_method("float_home"):
			child.float_home()
			return
	render_all()

func combat_status_text() -> String:
	if combat.phase == "targeting":
		if combat.selected_action == "move":
			return "Choose a highlighted move hex, or Skip."
		if combat.selected_action == "attack":
			return "Choose a red target, or Skip."
	if combat.phase == "pay_energy":
		return "Drag cards into the black hole to pay Energy."
	if combat.phase == "blocking":
		var pending: Dictionary = combat.pending_attack
		var block_name: String = "MagicBlock" if str(pending.damage_type) == "magic" else "Block"
		return "Blocking: drag cards out to add %s, then press Resolve Block." % block_name
	if combat.phase == "resolving":
		return "Resolving attack."
	if active_unit_id() == "player":
		return "Drag a card out of the hand to play it, or use a basic action."
	return "Enemy turn."

func render_energy_hole() -> void:
	energy_hole.visible = mode == "combat" and combat.phase == "pay_energy"
	if not energy_hole.visible:
		return
	energy_hole_label.text = "Energy\n%s more\nDrop card here" % combat.energy_needed

func use_town_place(place: String) -> void:
	advance_hours(1)
	if place.contains("Inn") and player.gold >= 8:
		player.gold -= 8
		player.hp = player.max_hp
		add_log("You rest at the inn.")
	elif place.contains("Shop") and player.gold >= 16:
		player.gold -= 16
		equip_first_empty_slot()
	elif place.contains("Yard") and player.gold >= 18:
		player.gold -= 18
		player.speed += 1
		add_log("Your speed rises by 1 for this run.")
	else:
		scout()
		return
	render_all()

func equip_first_empty_slot() -> void:
	if is_basic_equipment(str(player.equipment.get("head", ""))):
		player.equipment.head = "Ruinguard Hood"
	elif player.equipment.trinket1 == "":
		player.equipment.trinket1 = "Cracked Moon Charm"
	elif player.equipment.trinket2 == "":
		player.equipment.trinket2 = "Cracked Moon Charm"
	elif player.equipment.trinket3 == "":
		player.equipment.trinket3 = "Cracked Moon Charm"
	else:
		add_inventory_item("Cracked Moon Charm")
		add_log("A spare charm is tucked into your inventory.")
	player.deck = deck_from_equipment(player.equipment)
	add_log("Your equipment changes, so your deck changes with it.")

func resolve_event_without_combat() -> void:
	advance_hours(1)
	player.gold += 8
	resolved_events[current_location.id] = true
	mode = "overworld"
	event_popup.visible = false
	add_log("Careful searching finds 8 gold, and the danger slips away.")
	clear_overworld_movement_queue()
	render_all()

func start_combat(enemy_name: String, _difficulty: int) -> void:
	clear_overworld_movement_queue()
	advance_hours(1)
	learn_character_info(enemy_name, "hp")
	var enemy_hand_size := clampi(_difficulty, 1, 3)
	var player_deck: Array[Dictionary] = make_combat_deck(player.deck)
	var enemy_deck: Array[Dictionary] = make_enemy_deck(_difficulty)
	var player_hand: Array[Dictionary] = draw_cards(player_deck, 5)
	var enemy_hand: Array[Dictionary] = draw_cards(enemy_deck, enemy_hand_size)
	combat = {
		"title": "%s at %s" % [enemy_name, current_location.name],
		"enemy_hand_size": enemy_hand_size,
		"initiative": ["player", "enemy"] if player.speed >= 4 + _difficulty else ["enemy", "player"],
		"round": 1,
		"turn_index": 0,
		"phase": "idle",
		"selected_card": {},
		"selected_action": "",
		"remaining_actions": [],
		"energy_needed": 0,
		"pending_attack": {},
		"combat_log": [],
		"move_highlights": [],
		"target_highlights": [],
		"hexes": build_hexes(3),
		"units": {
			"player": {"name": "Jiali", "team": "player", "q": -2, "r": 0, "hp": player.hp, "max_hp": player.max_hp, "speed": player.speed, "energy": 0, "cores": equipped_core_count(), "core_pool": equipped_core_count(), "hand_size": 5, "deck": player_deck, "discard": [], "hand": player_hand},
			"enemy": {"name": enemy_name, "team": "enemy", "q": 2, "r": 0, "hp": 18 + _difficulty * 6, "max_hp": 18 + _difficulty * 6, "speed": 4 + _difficulty, "energy": 0, "cores": 0, "core_pool": 0, "hand_size": enemy_hand_size, "deck": enemy_deck, "discard": [], "hand": enemy_hand}
		}
	}
	mode = "combat"
	event_popup.visible = false
	game_root.visible = false
	combat_layer.visible = true
	start_turn()
	add_log("Combat starts against %s." % enemy_name)
	render_all()
	if active_unit_id() == "enemy":
		enemy_take_turn()

func win_combat() -> void:
	player.gold += 20
	if equipped_core_count() < int(player.max_cores):
		equip_core_to_first_available_slot(str(current_location.core), "reward")
		add_log("%s Core equipped." % current_location.core)
	resolved_events[current_location.id] = true
	finish_run()

func finish_run() -> void:
	saved_run = {}
	combat = {}
	mode = "title"
	add_log("The run ends, and the catalogue remembers what Jiali carried.")
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	show_title()

func active_unit_id() -> String:
	if combat.is_empty():
		return ""
	return str(combat.initiative[int(combat.turn_index)])

func start_turn() -> void:
	var unit_id := active_unit_id()
	var unit: Dictionary = combat.units[unit_id]
	unit.energy = 0
	unit.core_pool = int(unit.cores)
	combat.units[unit_id] = unit
	combat.phase = "idle"
	combat.selected_card = {}
	combat.selected_action = ""
	combat.remaining_actions = []
	combat.energy_needed = 0
	combat.pending_attack = {}
	combat.move_highlights = []
	combat.target_highlights = []

func draw_up_to_hand_size(unit: Dictionary) -> void:
	while unit.hand.size() < int(unit.hand_size):
		if unit.deck.is_empty():
			if unit.discard.is_empty():
				return
			unit.deck = shuffle_cards(unit.discard)
			unit.discard = []
		unit.hand.append(unit.deck.pop_front())

func discard_hand_and_draw(unit: Dictionary) -> void:
	for card in unit.hand:
		unit.discard.append(card)
	unit.hand.clear()
	draw_up_to_hand_size(unit)

func end_player_turn() -> void:
	if mode != "combat" or active_unit_id() != "player" or combat_submenu_open():
		return
	end_active_turn()

func end_active_turn() -> void:
	var unit_id := active_unit_id()
	combat.turn_index = int(combat.turn_index) + 1
	if int(combat.turn_index) >= combat.initiative.size():
		combat.round = int(combat.round) + 1
		combat.turn_index = 0
		end_round_card_cycle()
		reset_initiative()
	start_turn()
	render_all()
	if active_unit_id() == "enemy":
		enemy_take_turn()

func end_round_card_cycle() -> void:
	for unit_id in combat.units:
		var unit: Dictionary = combat.units[unit_id]
		discard_hand_and_draw(unit)
		combat.units[unit_id] = unit

func reset_initiative() -> void:
	var ids: Array = combat.initiative.duplicate()
	ids.sort_custom(func(left: String, right: String) -> bool:
		return int(combat.units[left].speed) > int(combat.units[right].speed)
	)
	combat.initiative = ids

func _on_card_drag_finished(card_instance: Dictionary, global_position: Vector2) -> void:
	if mode != "combat":
		return
	if combat_submenu_open():
		float_card_back(str(card_instance.instance_id))
		return
	if combat.phase == "targeting" and active_unit_id() != "player":
		return
	if combat.phase == "pay_energy":
		handle_energy_discard_drag(card_instance, global_position)
		return
	if combat.phase == "blocking":
		handle_block_card_drag(card_instance, global_position)
		return
	if active_unit_id() != "player":
		return
	var hand_rect := combat_hand_bar.get_global_rect()
	if hand_rect.has_point(global_position):
		reorder_card_in_hand(str(card_instance.instance_id), global_position.x)
		render_all()
		return
	begin_card_play(card_instance)

func reorder_card_in_hand(instance_id: String, global_x: float) -> void:
	var unit: Dictionary = combat.units.player
	var old_index: int = find_card_index(unit.hand, instance_id)
	if old_index < 0:
		return
	var card: Dictionary = unit.hand.pop_at(old_index)
	var local_x: float = global_x - combat_hand_bar.global_position.x
	var slot_width: float = maxf(1.0, combat_hand_bar.size.x / float(maxi(1, unit.hand.size() + 1)))
	var new_index: int = clampi(int(local_x / slot_width), 0, unit.hand.size())
	unit.hand.insert(new_index, card)
	combat.units.player = unit

func begin_base_move_action() -> void:
	if mode != "combat" or combat.is_empty() or active_unit_id() != "player" or combat.phase != "idle" or combat_submenu_open():
		return
	var action_card: Dictionary = {
		"name": "Move",
		"instance_id": "base_move",
		"base_action": true,
		"cores": 0,
		"energy": 1,
		"move": 1,
		"block": 0,
		"magic_block": 0
	}
	var unit: Dictionary = combat.units.player
	var needed: int = int(action_card.energy) - int(unit.energy)
	if needed > 0:
		if unit.hand.size() < needed:
			combat_status_label.text = "Need a card to discard for 1 Energy."
			return
		combat.selected_card = action_card.duplicate(true)
		combat.energy_needed = needed
		combat.phase = "pay_energy"
		render_all()
		return
	combat.selected_card = action_card.duplicate(true)
	start_selected_card_actions()

func begin_card_play(card: Dictionary) -> void:
	if combat_submenu_open():
		float_card_back(str(card.instance_id))
		return
	var unit: Dictionary = combat.units.player
	if int(card.cores) > int(unit.core_pool):
		combat_status_label.text = "Not enough Core."
		float_card_back(str(card.instance_id))
		return
	if int(card.energy) > int(unit.energy):
		var needed: int = int(card.energy) - int(unit.energy)
		var playable_discards: int = unit.hand.size() - 1
		if playable_discards < needed:
			combat_status_label.text = "Not enough cards to discard for energy."
			float_card_back(str(card.instance_id))
			return
		combat.selected_card = card.duplicate(true)
		combat.energy_needed = needed
		combat.phase = "pay_energy"
		render_all()
		return
	combat.selected_card = card.duplicate(true)
	start_selected_card_actions()

func handle_energy_discard_drag(card_instance: Dictionary, global_position: Vector2) -> void:
	var selected_id := str(combat.selected_card.instance_id)
	if str(card_instance.instance_id) == selected_id:
		float_card_back(str(card_instance.instance_id))
		return
	if not energy_hole.get_global_rect().has_point(global_position):
		float_card_back(str(card_instance.instance_id))
		return
	var unit: Dictionary = combat.units.player
	var index: int = find_card_index(unit.hand, str(card_instance.instance_id))
	if index < 0:
		return
	var discarded: Dictionary = unit.hand[index]
	unit.hand.remove_at(index)
	unit.discard.append(discarded)
	unit.energy = int(unit.energy) + 1
	add_combat_card_log("Jiali discards ", discarded, " for 1 Energy.")
	combat.energy_needed = maxi(0, int(combat.energy_needed) - 1)
	combat.units.player = unit
	if int(combat.energy_needed) <= 0:
		start_selected_card_actions()
	else:
		render_all()

func start_selected_card_actions() -> void:
	var card: Dictionary = combat.selected_card
	combat.remaining_actions = card_actions(card)
	if combat.remaining_actions.is_empty():
		return
	choose_card_action(str(combat.remaining_actions[0].kind))

func card_actions(card: Dictionary) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	if card.has("move"):
		actions.append({"kind": "move", "amount": int(card.move)})
	if card.has("damage"):
		actions.append({"kind": "attack", "range": int(card.range), "damage": int(card.damage), "damage_type": str(card.damage_type)})
	return actions

func choose_card_action(action_kind: String) -> void:
	combat.selected_action = action_kind
	combat.phase = "targeting"
	combat.move_highlights = []
	combat.target_highlights = []
	var action: Dictionary = get_remaining_action(action_kind)
	if action.is_empty():
		return
	if action_kind == "move":
		combat.move_highlights = legal_move_hexes(combat.units.player, int(action.amount))
	if action_kind == "attack":
		combat.target_highlights = legal_target_hexes(combat.units.player, int(action.range))
	render_all()

func get_remaining_action(action_kind: String) -> Dictionary:
	for action in combat.remaining_actions:
		if str(action.kind) == action_kind:
			return action
	return {}

func skip_pending_action() -> void:
	if combat.phase != "targeting" or combat_submenu_open():
		return
	complete_selected_action(false)

func _on_combat_hex_clicked(hex: Vector2i) -> void:
	if mode != "combat" or combat.phase != "targeting" or active_unit_id() != "player" or combat_submenu_open():
		return
	if combat.selected_action == "move" and array_to_hexes(combat.move_highlights).has(hex):
		var unit: Dictionary = combat.units.player
		unit.q = hex.x
		unit.r = hex.y
		combat.units.player = unit
		complete_selected_action(true)
	if combat.selected_action == "attack" and array_to_hexes(combat.target_highlights).has(hex):
		var action: Dictionary = get_remaining_action("attack")
		var target_id: String = unit_id_at(hex)
		if target_id != "":
			begin_block_phase(active_unit_id(), target_id, int(action.damage), str(action.damage_type), combat.selected_card)

func complete_selected_action(_used: bool) -> void:
	var action_kind: String = str(combat.selected_action)
	for index in range(combat.remaining_actions.size()):
		if str(combat.remaining_actions[index].kind) == action_kind:
			combat.remaining_actions.remove_at(index)
			break
	combat.move_highlights = []
	combat.target_highlights = []
	if combat.remaining_actions.is_empty():
		finish_card_play()
	else:
		choose_card_action(str(combat.remaining_actions[0].kind))
		return
	combat.phase = "idle"
	combat.selected_action = ""
	render_all()

func finish_card_play() -> void:
	var unit: Dictionary = combat.units.player
	var card: Dictionary = combat.selected_card
	if bool(card.get("base_action", false)):
		add_combat_card_log("%s uses " % unit.name, card, ".")
	else:
		var index: int = find_card_index(unit.hand, str(card.instance_id))
		if index >= 0:
			unit.hand.remove_at(index)
		unit.discard.append(card)
		add_combat_card_log("%s plays " % unit.name, card, ".")
	unit.energy = int(unit.energy) - int(card.energy)
	unit.core_pool = int(unit.core_pool) - int(card.cores)
	combat.units.player = unit
	combat.selected_card = {}
	combat.energy_needed = 0

func cancel_combat_process() -> void:
	if mode != "combat" or combat.is_empty():
		return
	if combat.phase != "pay_energy" and combat.phase != "targeting":
		return
	combat.phase = "idle"
	combat.selected_card = {}
	combat.selected_action = ""
	combat.remaining_actions = []
	combat.energy_needed = 0
	combat.move_highlights = []
	combat.target_highlights = []
	hide_base_action_info()
	render_all()

func find_card_index(hand: Array, instance_id: String) -> int:
	for index in range(hand.size()):
		if str(hand[index].instance_id) == instance_id:
			return index
	return -1

func legal_move_hexes(unit: Dictionary, move_amount: int) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(int(unit.q), int(unit.r))
	var results: Array[Vector2i] = []
	var frontier: Array[Vector2i] = [origin]
	var costs := {origin: 0}
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_cost: int = int(costs[current])
		if current_cost >= move_amount:
			continue
		for neighbor in adjacent_hexes(current):
			if not combat.hexes.has(neighbor) or costs.has(neighbor):
				continue
			var occupant_id := unit_id_at(neighbor)
			if occupant_id != "":
				var occupant: Dictionary = combat.units[occupant_id]
				if str(occupant.team) != str(unit.team):
					continue
			costs[neighbor] = current_cost + 1
			frontier.append(neighbor)
	for hex in costs.keys():
		var destination: Vector2i = hex
		if destination != origin and unit_at(destination).is_empty():
			results.append(destination)
	return results

func adjacent_hexes(hex: Vector2i) -> Array[Vector2i]:
	return [
		hex + Vector2i(1, 0),
		hex + Vector2i(1, -1),
		hex + Vector2i(0, -1),
		hex + Vector2i(-1, 0),
		hex + Vector2i(-1, 1),
		hex + Vector2i(0, 1)
	]

func legal_target_hexes(unit: Dictionary, attack_range: int) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(int(unit.q), int(unit.r))
	var results: Array[Vector2i] = []
	for unit_id in combat.units:
		var target: Dictionary = combat.units[unit_id]
		if str(target.team) == str(unit.team):
			continue
		var target_hex: Vector2i = Vector2i(int(target.q), int(target.r))
		if hex_distance(origin, target_hex) <= attack_range:
			results.append(target_hex)
	return results

func hex_distance(left: Vector2i, right: Vector2i) -> int:
	return int((abs(left.x - right.x) + abs(left.x + left.y - right.x - right.y) + abs(left.y - right.y)) / 2)

func unit_at(hex: Vector2i) -> Dictionary:
	for unit_id in combat.units:
		var unit: Dictionary = combat.units[unit_id]
		if int(unit.q) == hex.x and int(unit.r) == hex.y and int(unit.hp) > 0:
			return unit
	return {}

func unit_id_at(hex: Vector2i) -> String:
	for unit_id in combat.units:
		var unit: Dictionary = combat.units[unit_id]
		if int(unit.q) == hex.x and int(unit.r) == hex.y and int(unit.hp) > 0:
			return str(unit_id)
	return ""

func begin_block_phase(attacker_id: String, defender_id: String, damage: int, damage_type: String, attack_card: Dictionary = {}) -> void:
	combat.phase = "blocking"
	combat.move_highlights = []
	combat.target_highlights = []
	combat.pending_attack = {
		"attacker_id": attacker_id,
		"defender_id": defender_id,
		"damage": damage,
		"damage_type": damage_type,
		"blocked": 0
	}
	if attack_card.is_empty():
		add_combat_log("%s attacks %s for %s %s damage." % [combat.units[attacker_id].name, combat.units[defender_id].name, damage, damage_type])
	else:
		add_combat_card_log(
			"%s attacks %s with " % [combat.units[attacker_id].name, combat.units[defender_id].name],
			attack_card,
			" for %s %s damage." % [damage, damage_type]
		)
	if defender_id == "enemy":
		enemy_block_pending_attack()
		resolve_pending_attack()
	else:
		render_all()

func handle_block_card_drag(card_instance: Dictionary, global_position: Vector2) -> void:
	var pending: Dictionary = combat.pending_attack
	if str(pending.defender_id) != "player":
		return
	if combat_hand_bar.get_global_rect().has_point(global_position):
		float_card_back(str(card_instance.instance_id))
		return
	var block_value := card_block_value(card_instance, str(pending.damage_type))
	if block_value <= 0:
		float_card_back(str(card_instance.instance_id))
		return
	var unit: Dictionary = combat.units.player
	var index: int = find_card_index(unit.hand, str(card_instance.instance_id))
	if index < 0:
		return
	var card: Dictionary = unit.hand[index]
	unit.hand.remove_at(index)
	unit.discard.append(card)
	pending.blocked = int(pending.blocked) + block_value
	add_combat_card_log("Jiali blocks %s with " % block_value, card, ".")
	combat.pending_attack = pending
	combat.units.player = unit
	show_combat_value("player", int(pending.blocked), block_icon_id(str(pending.damage_type)))
	render_all()

func resolve_player_block() -> void:
	if mode != "combat" or combat.phase != "blocking":
		return
	if str(combat.pending_attack.defender_id) != "player":
		return
	resolve_pending_attack()

func enemy_block_pending_attack() -> void:
	var pending: Dictionary = combat.pending_attack
	var unit: Dictionary = combat.units.enemy
	var blockers: Array[Dictionary] = []
	for card in unit.hand:
		var block_card: Dictionary = card
		if card_block_value(block_card, str(pending.damage_type)) > 0:
			blockers.append(block_card)
	blockers.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return card_block_value(left, str(pending.damage_type)) > card_block_value(right, str(pending.damage_type))
	)
	for card in blockers:
		if int(pending.blocked) >= int(pending.damage):
			break
		var index: int = find_card_index(unit.hand, str(card.instance_id))
		if index < 0:
			continue
		var value: int = card_block_value(card, str(pending.damage_type))
		pending.blocked = int(pending.blocked) + value
		add_combat_card_log("%s blocks %s with " % [unit.name, value], card, ".")
		unit.discard.append(card)
		unit.hand.remove_at(index)
	combat.pending_attack = pending
	combat.units.enemy = unit
	show_combat_value("enemy", int(pending.blocked), block_icon_id(str(pending.damage_type)))

func resolve_pending_attack() -> void:
	var pending: Dictionary = combat.pending_attack
	var defender_id := str(pending.defender_id)
	var attacker_id := str(pending.attacker_id)
	var damage_taken: int = maxi(0, int(pending.damage) - int(pending.blocked))
	var defender: Dictionary = combat.units[defender_id]
	add_combat_log("%s total block: %s. HP loss: %s." % [defender.name, pending.blocked, damage_taken])
	show_combat_value(defender_id, int(pending.blocked), block_icon_id(str(pending.damage_type)))
	if damage_taken > 0:
		show_combat_value(defender_id, damage_taken, "bleeding_heart", Vector2(0, 38))
	defender.hp = int(defender.hp) - damage_taken
	combat.units[defender_id] = defender
	if defender_id == "player":
		player.hp = defender.hp
	combat.phase = "targeting"
	combat.pending_attack = {}
	if defender_id == "enemy" and int(defender.hp) <= 0:
		win_combat()
		return
	if defender_id == "player" and int(defender.hp) <= 0:
		finish_run()
		return
	if attacker_id == "player":
		complete_selected_action(true)
	else:
		combat.phase = "idle"
		render_all()
		end_active_turn()

func card_block_value(card: Dictionary, damage_type: String) -> int:
	return int(card.magic_block) if damage_type == "magic" else int(card.block)

func attack_icon_id(damage_type: String) -> String:
	return "magic_attack" if damage_type == "magic" else "attack"

func block_icon_id(damage_type: String) -> String:
	return "magic_block" if damage_type == "magic" else "block"

func show_combat_value(unit_id: String, value: int, icon_id: String, offset: Vector2 = Vector2.ZERO) -> void:
	if combat.is_empty() or not combat.units.has(unit_id):
		return
	var unit: Dictionary = combat.units[unit_id]
	var hex := Vector2i(int(unit.q), int(unit.r))
	var board_position: Vector2 = combat_board.hex_to_screen(hex)
	var popup := HBoxContainer.new()
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_theme_constant_override("separation", 4)
	popup.add_child(make_icon(icon_id, Vector2(26, 26)))
	var label := Label.new()
	label.text = str(value)
	label.add_theme_font_size_override("font_size", 26)
	popup.add_child(label)
	combat_layer.add_child(popup)
	popup.global_position = combat_board.global_position + board_position + Vector2(-26, -70) + offset
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", popup.global_position + Vector2(0, -28), 0.7)
	tween.tween_property(popup, "modulate:a", 0.0, 0.7)
	tween.finished.connect(func() -> void:
		if is_instance_valid(popup):
			popup.queue_free()
	)

func array_to_hexes(values: Array) -> Array[Vector2i]:
	var hexes: Array[Vector2i] = []
	for value in values:
		if value is Vector2i:
			hexes.append(value)
	return hexes

func enemy_take_turn() -> void:
	if mode != "combat" or active_unit_id() != "enemy":
		return
	var enemy: Dictionary = combat.units.enemy
	var player_unit: Dictionary = combat.units.player
	var enemy_hex: Vector2i = Vector2i(int(enemy.q), int(enemy.r))
	var player_hex: Vector2i = Vector2i(int(player_unit.q), int(player_unit.r))
	var attack_card: Dictionary = first_enemy_attack_card(enemy, hex_distance(enemy_hex, player_hex))
	if not attack_card.is_empty():
		enemy_pay_and_discard_for_energy(enemy, attack_card)
		var attack_index: int = find_card_index(enemy.hand, str(attack_card.instance_id))
		if attack_index >= 0:
			enemy.hand.remove_at(attack_index)
		enemy.discard.append(attack_card)
		combat.units.enemy = enemy
		add_combat_card_log("%s plays " % enemy.name, attack_card, ".")
		begin_block_phase("enemy", "player", int(attack_card.damage), str(attack_card.damage_type), attack_card)
		return
	var move_card: Dictionary = first_enemy_move_card(enemy)
	if not move_card.is_empty():
		enemy_pay_and_discard_for_energy(enemy, move_card)
		var options: Array[Vector2i] = legal_move_hexes(enemy, int(move_card.move))
		var move_index: int = find_card_index(enemy.hand, str(move_card.instance_id))
		if move_index >= 0:
			enemy.hand.remove_at(move_index)
		enemy.discard.append(move_card)
		if not options.is_empty():
			options.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
				return hex_distance(left, player_hex) < hex_distance(right, player_hex)
			)
			enemy.q = options[0].x
			enemy.r = options[0].y
		combat.units.enemy = enemy
		add_combat_card_log("%s plays " % enemy.name, move_card, ".")
	end_active_turn()

func first_enemy_attack_card(enemy: Dictionary, distance_to_player: int) -> Dictionary:
	for card in enemy.hand:
		var candidate: Dictionary = card
		if candidate.has("damage") and int(candidate.range) >= distance_to_player and enemy_can_pay_card(enemy, candidate):
			return candidate
	return {}

func first_enemy_move_card(enemy: Dictionary) -> Dictionary:
	for card in enemy.hand:
		var candidate: Dictionary = card
		if candidate.has("move") and enemy_can_pay_card(enemy, candidate):
			return candidate
	return {}

func enemy_can_pay_card(enemy: Dictionary, card: Dictionary) -> bool:
	if int(card.cores) > int(enemy.core_pool):
		return false
	var needed: int = maxi(0, int(card.energy) - int(enemy.energy))
	return enemy.hand.size() - 1 >= needed

func enemy_pay_and_discard_for_energy(enemy: Dictionary, protected_card: Dictionary) -> void:
	var needed: int = maxi(0, int(protected_card.energy) - int(enemy.energy))
	var index: int = enemy.hand.size() - 1
	while index >= 0 and needed > 0:
		var card: Dictionary = enemy.hand[index]
		if str(card.instance_id) != str(protected_card.instance_id):
			enemy.discard.append(card)
			enemy.hand.remove_at(index)
			enemy.energy = int(enemy.energy) + 1
			needed -= 1
		index -= 1
	enemy.energy = int(enemy.energy) - int(protected_card.energy)
	enemy.core_pool = int(enemy.core_pool) - int(protected_card.cores)

func show_card_preview(card_instance: Dictionary) -> void:
	clear_children(card_preview)
	var card_view = preload("res://scripts/CardView.gd").new()
	card_view.setup(card_instance)
	card_view.draggable = false
	card_view.scale = Vector2(1.35, 1.35)
	card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_preview.add_child(card_view)
	card_preview.visible = true
	card_preview.move_to_front()
	card_preview.global_position = get_global_mouse_position() + Vector2(-70, -250)

func hide_card_preview() -> void:
	card_preview.visible = false

func detailed_card_text(card: Dictionary) -> String:
	var lines: Array[String] = [str(card.name), "Cores(%s), Energy(%s)" % [card.cores, card.energy]]
	if card.has("move"):
		lines.append("Move %s" % card.move)
	if card.has("damage"):
		var attack_name: String = "MagicAttack" if card.damage_type == "magic" else "NormalAttack"
		lines.append("%s %s on Range %s" % [attack_name, card.damage, card.range])
	lines.append("Block %s, MagicBlock %s" % [card.block, card.magic_block])
	return join_with_separator(lines, "\n")

func show_combat_map_overlay() -> void:
	combat_map_view.set_world_state(player_pos, discovered, explored, current_location.id)
	combat_map_overlay.visible = true

func show_discard_popup() -> void:
	combat_deck_popup.visible = false
	hide_card_preview()
	render_discard_popup()
	discard_popup.visible = true
	discard_popup.move_to_front()

func render_discard_popup() -> void:
	clear_children(discard_grid)
	if combat.is_empty():
		return
	var unit: Dictionary = combat.units.player
	if unit.discard.is_empty():
		var label := Label.new()
		label.text = "Discard pile is empty."
		discard_grid.add_child(label)
		return
	for card in unit.discard:
		var card_view = preload("res://scripts/CardView.gd").new()
		card_view.setup(card)
		card_view.draggable = false
		discard_grid.add_child(card_view)

func add_combat_log(text: String) -> void:
	if combat.is_empty() or not combat.has("combat_log"):
		return
	combat.combat_log.append(text)
	if combat.combat_log.size() > 12:
		combat.combat_log.pop_front()

func add_combat_card_log(prefix: String, card: Dictionary, suffix: String) -> void:
	if combat.is_empty() or not combat.has("combat_log"):
		return
	combat.combat_log.append({
		"prefix": prefix,
		"card": card.duplicate(true),
		"suffix": suffix
	})
	if combat.combat_log.size() > 12:
		combat.combat_log.pop_front()

func deck_from_equipment(equipment: Dictionary) -> Array[String]:
	var deck: Array[String] = []
	for slot in EQUIPMENT_SLOTS:
		var item_name := str(equipment.get(slot, ""))
		if item_name == "":
			continue
		if EQUIPMENT_DATA.has(item_name):
			for card_id in EQUIPMENT_DATA[item_name].cards:
				deck.append(str(card_id))
	return deck

func draw_preview_hand(deck: Array[String], hand_size: int) -> Array[String]:
	var hand: Array[String] = []
	for index in min(hand_size, deck.size()):
		hand.append(cards[deck[index]].name)
	return hand

func make_combat_deck(deck_ids: Array[String]) -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	for card_id in deck_ids:
		var card: Dictionary = cards[card_id].duplicate(true)
		card["id"] = card_id
		card["instance_id"] = "%s-%s" % [card_id, deck.size()]
		card["source_icon"] = source_icon_for_card(card_id)
		deck.append(card)
	return deck

func source_icon_for_card(card_id: String) -> String:
	for item_name in EQUIPMENT_DATA:
		var item: Dictionary = EQUIPMENT_DATA[item_name]
		if item.get("cards", []).has(card_id):
			return str(item.get("icon", "core"))
	return "core"

func make_enemy_deck(difficulty: int) -> Array[Dictionary]:
	var ids: Array[String] = ["step", "strike", "guard"]
	if difficulty >= 2:
		ids.append("dash")
	if difficulty >= 3:
		ids.append("spark")
	return make_combat_deck(ids)

func draw_cards(deck: Array[Dictionary], count: int) -> Array[Dictionary]:
	var hand: Array[Dictionary] = []
	while hand.size() < count and not deck.is_empty():
		hand.append(deck.pop_front())
	return hand

func shuffle_cards(cards: Array) -> Array[Dictionary]:
	var shuffled: Array[Dictionary] = []
	for card in cards:
		var card_copy: Dictionary = card
		shuffled.append(card_copy)
	for index in range(shuffled.size() - 1, 0, -1):
		var swap_index: int = randi_range(0, index)
		var temp: Dictionary = shuffled[index]
		shuffled[index] = shuffled[swap_index]
		shuffled[swap_index] = temp
	return shuffled

func build_hexes(radius: int) -> Array[Vector2i]:
	var hexes: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		var r_min: int = maxi(-radius, -q - radius)
		var r_max: int = mini(radius, -q + radius)
		for r in range(r_min, r_max + 1):
			hexes.append(Vector2i(q, r))
	return hexes

func join_strings(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(str(value))
	return join_with_separator(parts, ", ")

func join_with_separator(values: Array[String], separator: String) -> String:
	var joined := ""
	for index in range(values.size()):
		if index > 0:
			joined += separator
		joined += values[index]
	return joined

func _on_location_clicked(location_id: String) -> void:
	var location := get_location(location_id)
	if location.is_empty():
		return
	if not can_accept_overworld_movement():
		return
	pending_travel_location_id = location_id
	travel_prompt_label.text = "Travel to %s?" % str(location.name)
	travel_prompt_popup.visible = true
	travel_prompt_popup.move_to_front()

func _on_map_clicked(_map_position: Vector2) -> void:
	pass

func confirm_location_travel() -> void:
	if pending_travel_location_id == "":
		travel_prompt_popup.visible = false
		return
	var location := get_location(pending_travel_location_id)
	pending_travel_location_id = ""
	travel_prompt_popup.visible = false
	if location.is_empty():
		return
	var destination := Vector2(float(location.x), float(location.y))
	var path := shortest_travel_path(player_pos, destination)
	if path.is_empty():
		show_travel_message("Unable to reach this destination")
		render_all()
		return
	enqueue_confirmed_travel_path(path)

func show_travel_message(message: String) -> void:
	travel_message_label.text = message
	travel_message_popup.visible = true
	travel_message_popup.move_to_front()

func show_settings(return_view: String = "") -> void:
	settings_return_view = return_view
	settings_panel.visible = true
	settings_panel.move_to_front()
	catalogue_panel.visible = false
	if settings_return_view != "chronicle":
		log_popup.visible = false
	if settings_return_view != "inventory":
		inventory_popup.visible = false
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	update_top_right_controls()

func close_settings() -> void:
	settings_panel.visible = false
	restore_settings_return_view()
	settings_return_view = ""
	update_top_right_controls()

func current_run_view_key() -> String:
	if inventory_popup.visible:
		return "inventory"
	if log_popup.visible:
		return "chronicle"
	if town_popup.visible:
		return "town"
	if event_popup.visible:
		return "event"
	if catalogue_panel.visible:
		return "catalogue"
	if mode == "combat" and combat_layer.visible:
		return "combat"
	return "overworld"

func restore_settings_return_view() -> void:
	match settings_return_view:
		"inventory":
			position_inventory_popup()
			render_inventory()
			render_deck()
			inventory_popup.visible = true
			inventory_popup.move_to_front()
		"chronicle":
			render_log()
			log_popup.visible = true
			log_popup.move_to_front()
		"town":
			town_popup.visible = true
			town_popup.move_to_front()
		"event":
			event_popup.visible = true
			event_popup.move_to_front()
		"catalogue":
			render_catalogue()
			catalogue_panel.visible = true
			catalogue_panel.move_to_front()
		"combat":
			combat_layer.visible = true
			combat_layer.move_to_front()

func set_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_window_size(window_size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(window_size)
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	DisplayServer.window_set_position(Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2))

func show_catalogue() -> void:
	settings_panel.visible = false
	catalogue_panel.visible = true
	catalogue_panel.move_to_front()
	log_popup.visible = false
	inventory_popup.visible = false
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	render_catalogue()
	update_top_right_controls()

func show_log_popup() -> void:
	render_log()
	log_popup.visible = true
	log_popup.move_to_front()
	settings_panel.visible = false
	catalogue_panel.visible = false
	inventory_popup.visible = false
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	update_top_right_controls()

func show_inventory_popup() -> void:
	position_inventory_popup()
	render_inventory()
	render_deck()
	inventory_popup.visible = true
	inventory_popup.move_to_front()
	settings_panel.visible = false
	catalogue_panel.visible = false
	log_popup.visible = false
	in_game_menu_popup.visible = false
	save_prompt_popup.visible = false
	update_top_right_controls()

func position_inventory_popup() -> void:
	if mode == "combat":
		inventory_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
		inventory_popup.offset_left = 0
		inventory_popup.offset_top = 0
		inventory_popup.offset_right = 0
		inventory_popup.offset_bottom = 0
		inventory_stats_box.position = Vector2(18, 56)
		inventory_character_layer.position = Vector2(120, 16)
		inventory_character_layer.size = Vector2(340, 310)
		inventory_grid.visible = false
		inventory_core_layer.visible = false
		inventory_scroll.visible = false
	else:
		inventory_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
		inventory_popup.offset_left = 0
		inventory_popup.offset_top = 0
		inventory_popup.offset_right = 0
		inventory_popup.offset_bottom = 0
		inventory_stats_box.position = Vector2(18, 74)
		inventory_character_layer.position = Vector2(140, 42)
		inventory_character_layer.size = Vector2(430, 470)
		inventory_grid.position = Vector2(610, 74)
		inventory_grid.columns = 4
		inventory_grid.visible = true
		inventory_core_layer.position = Vector2(1035, 86)
		inventory_core_layer.visible = true
		deck_grid.columns = 10
		inventory_scroll.position = Vector2(18, 545)
		inventory_scroll.size = Vector2(1180, 145)
		inventory_scroll.custom_minimum_size = Vector2(1180, 145)
		inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		inventory_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		inventory_scroll.visible = true
	render_all()

func show_map_overlay() -> void:
	map_overlay_view.set_world_state(player_pos, discovered, explored, current_location.id)
	map_overlay.visible = true
	map_overlay.move_to_front()

func toggle_compact_map() -> void:
	if not can_show_compact_map_button():
		return
	compact_map_panel.visible = not compact_map_panel.visible
	if compact_map_panel.visible:
		compact_map_view.set_world_state(player_pos, discovered, explored, current_location.id)
		compact_map_panel.move_to_front()
		top_right_controls.move_to_front()

func render_catalogue() -> void:
	clear_children(catalogue_panel)
	pinned_catalogue_item_id = ""
	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	catalogue_panel.add_child(content)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(60, 24)
	tabs.add_theme_constant_override("separation", 10)
	content.add_child(tabs)
	for tab in ["equipment", "characters", "cores"]:
		var tab_button := Button.new()
		tab_button.text = tab.capitalize()
		tab_button.custom_minimum_size = Vector2(150, 42)
		tab_button.disabled = catalogue_tab == tab
		tab_button.pressed.connect(func() -> void:
			catalogue_tab = tab
			pinned_catalogue_item_id = ""
			render_catalogue()
		)
		tabs.add_child(tab_button)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.position = Vector2(60, 86)
	grid.size = Vector2(620, 520)
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)

	var entries := catalogue_entries()
	for item_id in entries:
		var item: Dictionary = entries[item_id]
		grid.add_child(make_catalogue_item_button(str(item_id), item))

	catalogue_detail_panel = PanelContainer.new()
	catalogue_detail_panel.visible = false
	catalogue_detail_panel.position = Vector2(720, 80)
	catalogue_detail_panel.size = Vector2(520, 560)
	content.add_child(catalogue_detail_panel)
	catalogue_detail_box = VBoxContainer.new()
	catalogue_detail_box.add_theme_constant_override("separation", 10)
	catalogue_detail_panel.add_child(catalogue_detail_box)

	var close := Button.new()
	style_overlay_close_button(close)
	close.pressed.connect(func() -> void:
		catalogue_panel.visible = false
		update_top_right_controls()
	)
	content.add_child(close)

func make_catalogue_item_button(item_id: String, item: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(96, 96)
	var found := catalogue_entry_found(item_id, item)
	button.text = "" if found else "?"
	button.expand_icon = true
	if found:
		button.icon = load(str(ICONS[catalogue_entry_icon(item)]))
	if catalogue_tab == "cores":
		button.add_theme_stylebox_override("normal", make_core_catalogue_style(item, found))
		button.add_theme_stylebox_override("hover", make_core_catalogue_style(item, true))
	button.mouse_entered.connect(func() -> void: show_catalogue_detail(item_id, false))
	button.mouse_exited.connect(func() -> void:
		if pinned_catalogue_item_id == "":
			catalogue_detail_panel.visible = false
	)
	button.pressed.connect(func() -> void: show_catalogue_detail(item_id, true))
	return button

func catalogue_entries() -> Dictionary:
	match catalogue_tab:
		"characters":
			return CATALOGUE_CHARACTERS
		"cores":
			return CATALOGUE_CORES
		_:
			return CATALOGUE_ITEMS

func catalogue_entry_icon(item: Dictionary) -> String:
	if catalogue_tab == "characters":
		return str(item.get("icon", "health"))
	if catalogue_tab == "cores":
		return str(item.get("symbol", "core"))
	var item_name := str(item.get("name", ""))
	if EQUIPMENT_DATA.has(item_name):
		return equipment_icon_id(item_name)
	return "core"

func make_core_catalogue_style(item: Dictionary, found: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = item.get("color", Color(0.3, 0.3, 0.3, 1.0)) if found else Color(0.02, 0.02, 0.025, 1.0)
	style.border_color = Color(1.0, 0.95, 0.72, 0.8) if found else Color(0.12, 0.12, 0.12, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style

func catalogue_entry_found(item_id: String, item: Dictionary) -> bool:
	match catalogue_tab:
		"characters":
			return has_met_character(str(item.get("name", item_id)))
		"cores":
			return player_has_core(str(item.get("name", item_id)))
		_:
			return bool(item.get("found", false))

func show_catalogue_detail(item_id: String, pin_detail: bool) -> void:
	var entries := catalogue_entries()
	if not entries.has(item_id):
		return
	if pin_detail:
		pinned_catalogue_item_id = item_id
	elif pinned_catalogue_item_id != "" and pinned_catalogue_item_id != item_id:
		return
	var item: Dictionary = entries[item_id]
	clear_children(catalogue_detail_box)
	if not catalogue_entry_found(item_id, item):
		var unknown := Label.new()
		unknown.text = "Unknown %s" % catalogue_tab.trim_suffix("s")
		unknown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		catalogue_detail_box.add_child(unknown)
		catalogue_detail_panel.visible = true
		return
	var title := Label.new()
	title.text = str(item.name)
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catalogue_detail_box.add_child(title)
	var image_space := PanelContainer.new()
	image_space.custom_minimum_size = Vector2(480, 180)
	var icon := make_icon(catalogue_entry_icon(item), Vector2(96, 96))
	image_space.add_child(icon)
	catalogue_detail_box.add_child(image_space)
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = catalogue_entry_text(item)
	catalogue_detail_box.add_child(label)
	if catalogue_entry_cards_visible(item):
		var row := GridContainer.new()
		row.columns = 3
		row.add_theme_constant_override("h_separation", 8)
		row.add_theme_constant_override("v_separation", 8)
		for card_id in item.cards:
			var card: Dictionary = cards[str(card_id)]
			var card_view = preload("res://scripts/CardView.gd").new()
			card_view.setup(card)
			card_view.draggable = false
			card_view.scale = Vector2(0.65, 0.65)
			row.add_child(card_view)
		catalogue_detail_box.add_child(row)
	catalogue_detail_panel.visible = true

func clear_pinned_catalogue_detail() -> void:
	pinned_catalogue_item_id = ""
	if catalogue_detail_panel != null:
		catalogue_detail_panel.visible = false

func catalogue_entry_text(item: Dictionary) -> String:
	if catalogue_tab == "characters":
		return catalogue_character_text(item)
	if catalogue_tab == "cores":
		return "%s Core\nType: Core" % item.name
	return catalogue_item_text(item)

func catalogue_entry_cards_visible(item: Dictionary) -> bool:
	if catalogue_tab == "characters":
		return knows_character_info(str(item.name), "cards")
	return item.has("cards")

func catalogue_item_text(item: Dictionary) -> String:
	var lines: Array[String] = ["Type: %s" % item.type, "Cards:"]
	for card_id in item.cards:
		var card: Dictionary = cards[card_id]
		lines.append("- %s" % card_rules_text(card))
	return join_with_separator(lines, "\n")

func catalogue_character_text(item: Dictionary) -> String:
	var name := str(item.name)
	var lines: Array[String] = []
	lines.append("HP: %s" % item.hp if knows_character_info(name, "hp") else "HP: Unknown")
	lines.append("Speed: %s" % item.speed if knows_character_info(name, "speed") else "Speed: Unknown")
	lines.append("Cores: %s" % item.cores if knows_character_info(name, "cores") else "Cores: Unknown")
	lines.append("Cards: Known" if knows_character_info(name, "cards") else "Cards: Unknown")
	return "\n".join(lines)

func player_has_core(core_name: String) -> bool:
	if player.is_empty():
		return false
	for equipped in player.get("cores", []):
		if str(equipped) == core_name:
			return true
	for item_name in player.get("inventory", []):
		if is_core_item(str(item_name)) and core_name_from_item(str(item_name)) == core_name:
			return true
	return false

func card_rules_text(card: Dictionary) -> String:
	if card.type == "attack":
		var attack_name: String = "MagicAttack" if card.damage_type == "magic" else "NormalAttack"
		return "Name: %s, Cores(%s), Energy(%s), %s %s on Range %s, Block %s, MagicBlock %s" % [
			card.name,
			card.cores,
			card.energy,
			attack_name,
			card.damage,
			card.range,
			card.block,
			card.magic_block
		]
	if card.type == "move":
		return "Name: %s, Cores(%s), Energy(%s), Move %s" % [card.name, card.cores, card.energy, card.move]
	return "Name: %s, Cores(%s), Energy(%s), Block %s, MagicBlock %s" % [card.name, card.cores, card.energy, card.block, card.magic_block]

func get_location(location_id: String) -> Dictionary:
	for location in locations:
		if location.id == location_id:
			return location
	return {}

func add_log(text: String, entry_name: String = "") -> void:
	var name := entry_name if entry_name != "" else chronicle_name_from_text(text)
	log_entries.append({"name": name, "text": text})
	if log_entries.size() > 40:
		log_entries.pop_front()
		if log_selected_index >= 0:
			log_selected_index = maxi(0, log_selected_index - 1)

func render_log() -> void:
	clear_children(log_list)
	normalize_log_entries()
	if log_entries.is_empty():
		log_detail_title.text = ""
		log_detail_text.text = ""
		return
	if log_selected_index < 0 or log_selected_index >= log_entries.size():
		log_selected_index = log_entries.size() - 1
	for index in range(log_entries.size()):
		var entry_value = log_entries[index]
		var entry: Dictionary = entry_value as Dictionary
		var button := Button.new()
		button.text = str(entry.name)
		button.disabled = index == log_selected_index
		button.pressed.connect(func() -> void:
			log_selected_index = index
			render_log()
		)
		log_list.add_child(button)
	render_log_detail()

func render_log_detail() -> void:
	if log_selected_index < 0 or log_selected_index >= log_entries.size():
		return
	var entry_value = log_entries[log_selected_index]
	var entry: Dictionary = entry_value as Dictionary
	log_detail_title.text = str(entry.name)
	log_detail_text.text = str(entry.text)

func chronicle_name_from_text(text: String) -> String:
	var stripped := text.strip_edges()
	var stop := stripped.find(".")
	if stop > 0:
		stripped = stripped.substr(0, stop)
	return stripped.substr(0, mini(32, stripped.length()))

func normalize_log_entries() -> void:
	for index in range(log_entries.size()):
		if log_entries[index] is String:
			var text := str(log_entries[index])
			log_entries[index] = {"name": chronicle_name_from_text(text), "text": text}

func add_section_label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	parent.add_child(label)
	return label

func make_label(parent: Node) -> Label:
	var label := Label.new()
	parent.add_child(label)
	return label

func make_wrapped_label(parent: Node) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func make_stat(parent: Node, title: String, icon_id: String) -> Label:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(104, 56)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.09, 0.075, 0.86)
	style.border_color = Color(0.75, 0.68, 0.44, 0.55)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	if icon_id != "":
		row.add_child(make_icon(icon_id, Vector2(24, 24)))
	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	panel.add_child(row)
	parent.add_child(panel)
	return label

func make_icon_value(icon_id: String, value: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.custom_minimum_size = Vector2(76, 34)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 5)
	row.add_child(make_icon(icon_id, Vector2(18, 18)))
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	return row

func make_icon(icon_id: String, icon_size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ICONS.has(icon_id):
		icon.texture = load(str(ICONS[icon_id]))
	return icon

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
