extends Control

const POINT_SIZE := 3
var width := 900
var height := 400

var points : Array = []

func _ready():
	var file_dialog := FileDialog.new()
	file_dialog.name = "FileDialog"
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.txt", "*.csv", "*.*"]
	add_child(file_dialog)
	file_dialog.file_selected.connect(self._on_fichier_selectionne)

	points = [
		Vector2(50, height),
		Vector2(60, height),
		Vector2(70, height),
		Vector2(80, height),
		Vector2(90, height),
		Vector2(100, height - 20),
		Vector2(110, height - 40),
		Vector2(120, height - 65),
		Vector2(130, height - 85),
		Vector2(140, height - 100),
		Vector2(150, height - 95),
		Vector2(160, height - 85),
		Vector2(170, height - 70),
		Vector2(180, height - 55),
		Vector2(190, height - 40),
		Vector2(200, height - 30),
		Vector2(210, height - 22),
		Vector2(220, height - 15),
		Vector2(230, height - 10),
		Vector2(240, height - 5),
		Vector2(250, height - 2),
		Vector2(260, height),
	]
	
	queue_redraw()

	# Calculs
	afficher_mesures()

func afficher_mesures():
	var amplitude = get_amplitude()
	print("Amplitude de contraction : ", amplitude)

	var contraction_time = get_contraction_time()
	print("Temps de contraction : ", contraction_time, " ms")

	var decontraction_time = get_decontraction_time()
	print("Temps de décontraction : ", decontraction_time, " ms")

	var vitesse_contraction = get_contraction_speed_percent(20, 80)
	print("Vitesse de contraction (20%-80%) : ", vitesse_contraction)

	var vitesse_decontraction = get_decontraction_speed_percent(80, 20)
	print("Vitesse de décontraction (80%-20%) : ", vitesse_decontraction)

###########################################
func _on_ouvrir_fichier_pressed():
	var file_dialog = get_node("FileDialog")
	file_dialog.popup_centered()

func _on_fichier_selectionne(path: String):
	print("Fichier sélectionné : ", path)

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Erreur d'ouverture du fichier")
		return

	var total_lignes := 0
	var step := 1
	points.clear()

	while not file.eof_reached():
		file.get_line()
		total_lignes += 1
	file.close()

	step = max(total_lignes / 50, 1)
	print("Nombre total de lignes : ", total_lignes)
	print("Step calculé : ", step)

	file = FileAccess.open(path, FileAccess.READ)
	var count := 0

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if count % step == 0 and line != "":
			var parts := line.split("\t")
			if parts.size() >= 4:
				var x = float(parts[0])
				var y = float(parts[3])

				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
		count += 1
	file.close()

	file = FileAccess.open(path, FileAccess.READ)
	count = 0

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if count % step == 0 and line != "":
			var parts := line.split("\t")
			if parts.size() >= 4:
				var x_raw = float(parts[0])
				var y_raw = float(parts[3])

				var x_scaled = 50 + ((x_raw - min_x) / (max_x - min_x) * (width - 50))
				var y_scaled = height - ((y_raw - min_y) / (max_y - min_y) * height)

				points.append(Vector2(x_scaled, y_scaled))
		count += 1
	file.close()

	print("Nombre de points affichés : ", points.size())
	
	if points.size() > 0:
		afficher_mesures()

	queue_redraw()

##########################################
func _draw():
	draw_line(Vector2(50, 0), Vector2(50, height), Color.NAVY_BLUE, 2)
	draw_line(Vector2(0, height), Vector2(width, height), Color.NAVY_BLUE, 2)

	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)

	draw_circle(get_max_point(), POINT_SIZE + 2, Color(0, 1, 0)) # Pic contraction
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0)) # Repos

##########################################
func get_start_of_contraction() -> int:
	for i in range(1, points.size()):
		if points[i].y < points[i - 1].y:
			return i - 1
	return 0

func get_max_point() -> Vector2:
	var start_index = get_start_of_contraction()
	var max_point = points[start_index]
	for i in range(start_index, points.size()):
		if points[i].y < max_point.y:
			max_point = points[i]
	return max_point

func get_min_point() -> Vector2:
	var min_point = points[0]
	for p in points:
		if p.y > min_point.y:
			min_point = p
	return min_point

func get_amplitude() -> float:
	var base_y = height
	var max_y = get_max_point().y
	return base_y - max_y

func get_contraction_time() -> float:
	if points.size() < 2:
		return 0
	var start_time = points[get_start_of_contraction()].x
	var peak_time = get_max_point().x
	return peak_time - start_time

func get_decontraction_time() -> float:
	if points.size() < 2:
		return 0
	var peak_time = get_max_point().x
	var end_time = points[points.size() - 1].x
	return end_time - peak_time

func get_contraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0

	var y_rest = points[0].y
	var y_peak = get_max_point().y
	var amplitude = y_rest - y_peak

	var y1 = y_rest - (x_percent / 100.0) * amplitude
	var y2 = y_rest - (y_percent / 100.0) * amplitude

	var max_point = get_max_point()

	var closest_point1: Vector2 = Vector2.ZERO
	var closest_point2: Vector2 = Vector2.ZERO
	var min_diff1 := INF
	var min_diff2 := INF

	for p in points:
		if p.x > max_point.x:
			continue
		var diff1 = abs(p.y - y1)
		if diff1 < min_diff1:
			min_diff1 = diff1
			closest_point1 = p

		var diff2 = abs(p.y - y2)
		if diff2 < min_diff2:
			min_diff2 = diff2
			closest_point2 = p

	var delta_force = closest_point2.y - closest_point1.y
	var delta_time = closest_point2.x - closest_point1.x

	if delta_time == 0:
		return 0

	return abs(delta_force / delta_time)

func get_decontraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0.0

	var y_rest = points[0].y
	var y_peak = get_max_point().y
	var amplitude = y_rest - y_peak

	var y1 = y_peak + (x_percent / 100.0) * amplitude
	var y2 = y_peak + (y_percent / 100.0) * amplitude

	var max_point = get_max_point()

	var closest_point1: Vector2 = Vector2.ZERO
	var closest_point2: Vector2 = Vector2.ZERO
	var min_diff1 := INF
	var min_diff2 := INF

	for p in points:
		if p.x <= max_point.x:
			continue
		var diff1 = abs(p.y - y1)
		if diff1 < min_diff1:
			min_diff1 = diff1
			closest_point1 = p

		var diff2 = abs(p.y - y2)
		if diff2 < min_diff2:
			min_diff2 = diff2
			closest_point2 = p

	var delta_force = closest_point2.y - closest_point1.y
	var delta_time = closest_point2.x - closest_point1.x

	if delta_time == 0:
		return 0.0

	return abs(delta_force / delta_time)

func _on_button_pressed() -> void:
	pass
 
