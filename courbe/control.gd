extends Control

const POINT_SIZE := 3
var width := 900
var height := 400

var points : Array = []

func _ready():
	# Ajouter FileDialog si pas dans l'éditeur
	var file_dialog := FileDialog.new()
	file_dialog.name = "FileDialog"
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.txt", "*.csv", "*.*"]
	add_child(file_dialog)
	file_dialog.file_selected.connect(self._on_fichier_selectionne)

	# Courbe de points : latence -> contraction -> relaxation (démo)
	points = [
		Vector2(50, height),      # Latence (repos)
		Vector2(60, height),
		Vector2(70, height),
		Vector2(80, height),
		Vector2(90, height),
		Vector2(100, height - 20),  # Début contraction
		Vector2(110, height - 40),
		Vector2(120, height - 65),
		Vector2(130, height - 85),  # Pic de contraction
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
		Vector2(260, height),      # Retour au repos
	]
	

	queue_redraw()

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


####################### Quand on clique sur le bouton #####################################################
func _on_ouvrir_fichier_pressed():
	var file_dialog = get_node("FileDialog")
	file_dialog.popup_centered()


######################## Quand un fichier est sélectionné #################################################
func _on_fichier_selectionne(path: String):
	print("Fichier sélectionné : ", path)

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Erreur d'ouverture du fichier")
		return

	var total_lignes := 0
	var step := 1
	points.clear()

	# Lire une fois pour compter les lignes
	while not file.eof_reached():
		file.get_line()
		total_lignes += 1
	file.close()

	step = max(total_lignes / 50, 1)
	print("Nombre total de lignes : ", total_lignes)
	print("Step calculé : ", step)

	# Relire pour collecter les points
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
				#print("Y brut :", y)
				#print("X brut :", x)     # Ajoute cette ligne


				# Mettre à jour les min/max pour x et y
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)

		count += 1
	file.close()

	# Normalisation de X (étaler les points sur toute la largeur)
	#print("min_x = ", min_x, " max_x = ", max_x)
	#print("min_y = ", min_y, " max_y = ", max_y)

	# Relire encore une fois avec les points
	file = FileAccess.open(path, FileAccess.READ)
	count = 0

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if count % step == 0 and line != "":
			var parts := line.split("\t")
			if parts.size() >= 4:
				var x_raw = float(parts[0]) # temps en ms
				var y_raw = float(parts[3]) # reponse du muscle

				# Mettre à l’échelle X et Y
				var x_scaled = 50 + ((x_raw - min_x) / (max_x - min_x) * (width - 50))
  # Adapter X à la largeur
				var y_scaled = height - ((y_raw - min_y) / (max_y - min_y) * height)  # Adapter Y à la hauteur

				points.append(Vector2(x_scaled, y_scaled))
		count += 1
	file.close()

	print("Nombre de points affichés : ", points.size())
		# Une fois les points chargés, calculer et afficher
	if points.size() > 0:
		var amplitude = get_amplitude()
		print("Amplitude de contraction2 : ", amplitude)

		var contraction_time = get_contraction_time()
		print("Temps de contraction2 : ", contraction_time, " ms")

		var decontraction_time = get_decontraction_time()
		print("Temps de décontraction2 : ", decontraction_time, " ms")

		var vitesse_contraction = get_contraction_speed_percent(20, 80)
		print("Vitesse de contraction (20%-80%)2 : ", vitesse_contraction)

		var vitesse_decontraction = get_decontraction_speed_percent(80, 20)
		print("Vitesse de décontraction (80%-20%)2 : ", vitesse_decontraction)

	queue_redraw()






########################################  draw  ##########################################################

func _draw():
	draw_line(Vector2(50, 0), Vector2(50, height), Color.NAVY_BLUE, 2)  # Axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color.NAVY_BLUE, 2)  # Axe X

	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)

	draw_circle(get_max_point(), POINT_SIZE + 2, Color(0, 1, 0))
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0))


########################################  Min et Max  ##########################################################
#la point le plus haut
func get_max_point() -> Vector2:
	var max_point = points[0]
	for p in points:
		if p.y < max_point.y:
			max_point = p
	return max_point

#le point le plus bas 
func get_min_point() -> Vector2:
	var min_point = points[0]
	for p in points:
		if p.y > min_point.y:
			min_point = p
	return min_point


#######################################  L'amplitude Max  #########################################################
func get_amplitude() -> float:
	var base_y = height
	var max_y = get_max_point().y
	return base_y - max_y


########################################  Duree de Contraction ##################################################
func get_contraction_time() -> float:
	if points.size() < 2:
		return 0
	var start_time := -1.0
	var max_point := get_max_point()

	for i in range(1, points.size()):
		if points[i].y < points[i - 1].y:
			start_time = points[i - 1].x  # Prendre le x du dernier point plat (fin de la latence)
			break

	if start_time == -1:
		return 0
	return max_point.x - start_time


######################################  Duree de Decontraction ##################################################
func get_decontraction_time() -> float:
	if points.size() < 2:
		return 0

	var max_point := get_max_point()
	var end_time: float = points[points.size() - 1].x

	return end_time - max_point.x


######################################  Vitesse de Contraction ##################################################
func get_contraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0

	var y_rest = points[0].y              # niveau de repos
	var y_peak = get_max_point().y        # sommet (force max)
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
			continue  # on reste dans la montée

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


######################################  Vitesse de Décontraction ##################################################
func get_decontraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0.0

	var y_rest = points[0].y               # niveau de repos
	var y_peak = get_max_point().y         # sommet (force max)
	var amplitude = y_rest - y_peak        # amplitude toujours positive

	var y1 = y_peak + (x_percent / 100.0) * amplitude
	var y2 = y_peak + (y_percent / 100.0) * amplitude

	var max_point = get_max_point()

	var closest_point1: Vector2 = Vector2.ZERO
	var closest_point2: Vector2 = Vector2.ZERO
	var min_diff1 := INF
	var min_diff2 := INF

	for p in points:
		if p.x <= max_point.x:
			continue  # on ignore la phase de contraction (avant ou au pic)

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


#func _on_button_pressed() -> void:
	#pass # bouton inutilisé ici pour l’instant


func _on_button_pressed() -> void:
	pass # Replace with function body.
