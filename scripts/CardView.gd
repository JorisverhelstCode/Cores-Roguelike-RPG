extends PanelContainer

signal hover_card(card_instance: Dictionary)
signal unhover_card
signal drag_finished(card_instance: Dictionary, global_position: Vector2)

var card_instance: Dictionary = {}
var draggable := true
var dragging := false
var drag_start := Vector2.ZERO
var home_position := Vector2.ZERO

const CARD_SIZE := Vector2(136, 184)
const ICONS := {
	"move": "res://assets/icons/foot.svg",
	"energy": "res://assets/icons/energy.svg",
	"core": "res://assets/icons/core.svg",
	"block": "res://assets/icons/shield.svg",
	"magic_block": "res://assets/icons/magic_shield.svg",
	"attack": "res://assets/icons/sword.svg",
	"range": "res://assets/icons/range.svg",
	"magic_attack": "res://assets/icons/magic_blast.svg"
}

func setup(card_data: Dictionary) -> void:
	card_instance = card_data
	custom_minimum_size = CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	clear_children(self)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.89, 0.86, 0.76, 1.0)
	card_style.border_color = Color(0.20, 0.16, 0.10, 1.0)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 6
	card_style.corner_radius_top_right = 6
	card_style.corner_radius_bottom_left = 6
	card_style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", card_style)

	var face := Control.new()
	face.custom_minimum_size = CARD_SIZE
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(face)

	add_header(face)
	add_art_panel(face)
	add_effect_text(face)
	add_side_blocks(face)
	add_bottom_stats(face)
	add_source_badge(face)

func add_header(face: Control) -> void:
	face.add_child(make_stat_badge("core", str(card_instance.get("cores", 0)), Vector2(10, 10), Vector2(38, 38), 21, false, true))
	face.add_child(make_stat_badge("energy", str(card_instance.get("energy", 0)), Vector2(11, 44), Vector2(24, 24), 14, true, false))

	var title := Label.new()
	title.text = str(card_instance.get("name", "Card"))
	title.position = Vector2(52, 12)
	title.size = Vector2(52, 30)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.12, 0.09, 0.06, 1.0))
	face.add_child(title)

func add_art_panel(face: Control) -> void:
	var art := PanelContainer.new()
	art.position = Vector2(14, 62)
	art.size = Vector2(88, 72)
	var art_style := StyleBoxFlat.new()
	art_style.bg_color = Color(0.34, 0.38, 0.34, 0.46)
	art_style.border_color = Color(0.18, 0.15, 0.10, 0.75)
	art_style.border_width_left = 1
	art_style.border_width_top = 1
	art_style.border_width_right = 1
	art_style.border_width_bottom = 1
	art_style.corner_radius_top_left = 3
	art_style.corner_radius_top_right = 3
	art_style.corner_radius_bottom_left = 3
	art_style.corner_radius_bottom_right = 3
	art.add_theme_stylebox_override("panel", art_style)
	face.add_child(art)

func add_effect_text(face: Control) -> void:
	var effect := Label.new()
	effect.text = effect_text()
	effect.position = Vector2(16, 139)
	effect.size = Vector2(104, 22)
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect.add_theme_font_size_override("font_size", 8)
	effect.add_theme_color_override("font_color", Color(0.16, 0.12, 0.08, 1.0))
	face.add_child(effect)

func add_side_blocks(face: Control) -> void:
	if int(card_instance.get("block", 0)) > 0:
		face.add_child(make_stat_badge("block", str(card_instance.block), Vector2(104, 72), Vector2(32, 26), 14, false, false, "left"))
	if int(card_instance.get("magic_block", 0)) > 0:
		face.add_child(make_stat_badge("magic_block", str(card_instance.magic_block), Vector2(104, 104), Vector2(32, 26), 14, false, false, "left"))

func add_bottom_stats(face: Control) -> void:
	if card_instance.has("damage"):
		var attack_icon := "magic_attack" if str(card_instance.get("damage_type", "normal")) == "magic" else "attack"
		face.add_child(make_stat_badge(attack_icon, str(card_instance.damage), Vector2(14, 158), Vector2(24, 24), 14, true, false))
		face.add_child(make_stat_badge("range", str(card_instance.range), Vector2(42, 158), Vector2(24, 24), 13, true, false))
	if card_instance.has("move"):
		face.add_child(make_stat_badge("move", str(card_instance.move), Vector2(98, 158), Vector2(24, 24), 14, true, false))

func add_source_badge(face: Control) -> void:
	var source_icon := str(card_instance.get("source_icon", fallback_source_icon()))
	face.add_child(make_stat_badge(source_icon, "", Vector2(106, 10), Vector2(24, 24), 10, true, false, "", 0.88))

func effect_text() -> String:
	var text := str(card_instance.get("text", ""))
	var lines: Array[String] = []
	for raw_line in text.split("."):
		var line := str(raw_line).strip_edges()
		if line == "":
			continue
		if line.begins_with("NormalAttack") or line.begins_with("MagicAttack") or line.begins_with("Move"):
			continue
		lines.append(line)
	return "\n".join(lines)

func fallback_source_icon() -> String:
	if card_instance.has("damage"):
		return "magic_attack" if str(card_instance.get("damage_type", "normal")) == "magic" else "attack"
	if card_instance.has("move"):
		return "move"
	return "block"

func make_stat_badge(icon_id: String, value: String, badge_position: Vector2, badge_size: Vector2, font_size: int, circle: bool, hexagon: bool, wall_side: String = "", icon_alpha: float = 0.28) -> Control:
	var badge := Control.new()
	badge.position = badge_position
	badge.custom_minimum_size = badge_size
	badge.size = badge_size
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var background := PanelContainer.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.92, 0.80, 0.82)
	style.border_color = Color(0.16, 0.12, 0.08, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	if circle or hexagon:
		var radius: int = int(minf(badge_size.x, badge_size.y) * 0.5)
		style.corner_radius_top_left = radius
		style.corner_radius_top_right = radius
		style.corner_radius_bottom_left = radius
		style.corner_radius_bottom_right = radius
	if wall_side == "left":
		style.corner_radius_top_left = 14
		style.corner_radius_bottom_left = 14
		style.corner_radius_top_right = 0
		style.corner_radius_bottom_right = 0
	background.add_theme_stylebox_override("panel", style)
	badge.add_child(background)

	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 3
	icon.offset_top = 3
	icon.offset_right = -3
	icon.offset_bottom = -3
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = Color(1.0, 1.0, 1.0, icon_alpha)
	if ICONS.has(icon_id):
		icon.texture = load(str(ICONS[icon_id]))
	badge.add_child(icon)

	if value != "":
		var label := Label.new()
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.text = value
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", font_size)
		label.add_theme_color_override("font_color", Color(0.05, 0.04, 0.03, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(1.0, 0.96, 0.84, 0.85))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		badge.add_child(label)
	return badge

func _ready() -> void:
	call_deferred("remember_home_position")

func remember_home_position() -> void:
	home_position = position

func float_home() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", home_position, 0.18)

func _gui_input(event: InputEvent) -> void:
	if not draggable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
		else:
			if dragging:
				dragging = false
				drag_finished.emit(card_instance, get_global_mouse_position())
	if event is InputEventMouseMotion and dragging:
		var delta: Vector2 = get_global_mouse_position() - drag_start
		position += delta
		drag_start = get_global_mouse_position()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		hover_card.emit(card_instance)
	if what == NOTIFICATION_MOUSE_EXIT:
		unhover_card.emit()

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
