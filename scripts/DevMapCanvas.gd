extends Control

signal location_selected(index: int)
signal location_position_changed(index: int, normalized_position: Vector2)
signal map_position_chosen(normalized_position: Vector2)

var map_texture: Texture2D
var locations: Array[Dictionary] = []
var selected_index := -1
var zoom := 1.0
var pan := Vector2.ZERO
var dragging_marker := false
var dragging_map := false
var last_mouse := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

func configure(texture: Texture2D, location_data: Array[Dictionary]) -> void:
	map_texture = texture
	locations = location_data
	queue_redraw()

func set_locations(location_data: Array[Dictionary]) -> void:
	locations = location_data
	queue_redraw()

func set_selected_index(index: int) -> void:
	selected_index = index
	queue_redraw()

func _draw() -> void:
	if map_texture == null:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.09, 0.08, 1.0), true)
		return
	var rect := map_rect()
	draw_texture_rect(map_texture, rect, false)
	draw_rect(rect, Color(0.08, 0.06, 0.035, 1.0), false, 2.0)
	var font := get_theme_default_font()
	for index in range(locations.size()):
		var location := locations[index]
		var position := normalized_to_screen(Vector2(float(location.get("x", 0.5)), float(location.get("y", 0.5))))
		var selected := index == selected_index
		var color := Color(0.97, 0.82, 0.26, 1.0) if selected else Color(0.18, 0.86, 0.72, 0.95)
		var radius := 8.0 if selected else 5.5
		draw_circle(position, radius + 2.0, Color(0.05, 0.04, 0.025, 0.75))
		draw_circle(position, radius, color)
		draw_string(font, position + Vector2(10, -8), str(location.get("name", location.get("id", "Location"))), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(1.0, 0.95, 0.78, 1.0))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			set_zoom(zoom * 1.16, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			set_zoom(zoom / 1.16, event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				last_mouse = event.position
				var hit_index := location_at_screen(event.position)
				if hit_index >= 0:
					selected_index = hit_index
					dragging_marker = true
					location_selected.emit(hit_index)
				else:
					dragging_map = true
					map_position_chosen.emit(screen_to_normalized(event.position))
				queue_redraw()
			else:
				dragging_marker = false
				dragging_map = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			map_position_chosen.emit(screen_to_normalized(event.position))
	if event is InputEventMouseMotion:
		if dragging_marker and selected_index >= 0:
			var normalized := screen_to_normalized(event.position)
			location_position_changed.emit(selected_index, normalized)
			queue_redraw()
		elif dragging_map:
			pan += event.position - last_mouse
			last_mouse = event.position
			queue_redraw()

func set_zoom(value: float, pivot: Vector2) -> void:
	var before := screen_to_normalized(pivot)
	zoom = clampf(value, 0.45, 6.0)
	var after_screen := normalized_to_screen(before)
	pan += pivot - after_screen
	queue_redraw()

func map_rect() -> Rect2:
	if map_texture == null:
		return Rect2(Vector2.ZERO, size)
	var texture_size := map_texture.get_size()
	var scale := minf(size.x / texture_size.x, size.y / texture_size.y) * zoom
	var draw_size := texture_size * scale
	return Rect2((size - draw_size) * 0.5 + pan, draw_size)

func normalized_to_screen(normalized: Vector2) -> Vector2:
	var rect := map_rect()
	return rect.position + Vector2(normalized.x * rect.size.x, normalized.y * rect.size.y)

func screen_to_normalized(screen_position: Vector2) -> Vector2:
	var rect := map_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2(0.5, 0.5)
	var normalized := (screen_position - rect.position) / rect.size
	return Vector2(clampf(normalized.x, 0.0, 1.0), clampf(normalized.y, 0.0, 1.0))

func location_at_screen(screen_position: Vector2) -> int:
	for index in range(locations.size() - 1, -1, -1):
		var location := locations[index]
		var marker_position := normalized_to_screen(Vector2(float(location.get("x", 0.5)), float(location.get("y", 0.5))))
		if marker_position.distance_to(screen_position) <= 13.0:
			return index
	return -1
