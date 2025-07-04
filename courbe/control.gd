extends Control

@onready var mesures_label: RichTextLabel = $MesuresLabel
@onready var decalage_input: LineEdit = $UI/UIVBox/HBoxContainer/DecalageInput
@onready var bouton_droite: Button = $UI/UIVBox/HBoxContainer/ButtonRight
@onready var bouton_gauche: Button = $UI/UIVBox/HBoxContainer/ButtonLeft

const POINT_SIZE := 3
var width := 900
var height := 400

var points: Array = [] # points pour la reponse du muscle
var stim_points: Array = [] # points pour la valeur de stimulation

var start_time := 2000.0    
var end_time := 8000.0
var density := 0.1 # 10% des points
##
func _ready():
	var file_dialog := FileDialog.new()
	file_dialog.name = "FileDialog"
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.txt", "*.csv", "*.*"]
	add_child(file_dialog)
	file_dialog.file_selected.connect(self._on_fichier_selectionne)
	
	# Connecter les signaux des boutons
	bouton_droite.pressed.connect(self._on_button_right_pressed)
	bouton_gauche.pressed.connect(self._on_button_left_pressed)

	queue_redraw()
	
	
############################# afficher les mesures #############################
func afficher_mesures():
	mesures_label.bbcode_enabled = true

	var texte = ""
	var amplitude = get_amplitude()
	texte += "[color=light blue]Amplitude de contraction : " + str(amplitude) + "[/color]\n"


	var contraction_time = get_contraction_time()
	texte += "Temps de contraction : " + str(contraction_time) + " ms\n"

	var decontraction_time = get_decontraction_time()
	texte += "Temps de décontraction : " + str(decontraction_time) + " ms\n"

	var vitesse_contraction = get_contraction_speed_percent(20, 80)
	texte += "Vitesse de contraction (20%-80%) : " + str(vitesse_contraction) + "\n"

	var vitesse_decontraction = get_decontraction_speed_percent(80, 20)
	texte += "Vitesse de décontraction (80%-20%) : " + str(vitesse_decontraction) + "\n"

	var max_point = get_max_point()
	var min_point = get_min_point()
	texte += "Coordonnées du pic de contraction (max) : " + str(max_point) + "\n"
	texte += "Coordonnées du point de repos (min) : " + str(min_point) + "\n"
	texte += "Nombre de points affichés : " + str(points.size()) + "\n"
	texte += "Plage de temps : " + str(start_time) + " - " + str(end_time) + " ms\n"
	

	mesures_label.clear()
	mesures_label.append_text(texte)
	

####################### Quand on clique sur le bouton ####################### permet de choisir un fichier
func _on_ouvrir_fichier_pressed():
	var file_dialog = get_node("FileDialog")
	file_dialog.popup_centered()

######################## Quand un fichier est sélectionné #######################
func _on_fichier_selectionne(path: String):
	print("Fichier sélectionné : ", path)

	points.clear()
	stim_points.clear()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Erreur d'ouverture du fichier")
		return

	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	var min_stim := INF
	var max_stim := -INF
	
# Première passe : récupérer min/max dans la plage de temps
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var parts := line.split("\t")
		if parts.size() >= 4:
			var x = float(parts[0])
			var stim = float(parts[1])
			var y = float(parts[3])
			if x >= start_time and x <= end_time:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
				min_stim = min(min_stim, stim)
				max_stim = max(max_stim, stim)
	file.close()

#Protection contre division par zéro
	if max_y == min_y:
		max_y += 0.0001
	if max_stim == min_stim:
		max_stim += 0.0001

# Deuxième passe : lire les points
	file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var parts := line.split("\t")
		if parts.size() >= 4:
			var x_raw = float(parts[0])
			var stim_raw = float(parts[1])
			var y_raw = float(parts[3])

			if x_raw >= start_time and x_raw <= end_time:
				if randf() <= density:
					var x_scaled = 50 + ((x_raw - min_x) / (max_x - min_x) * (width - 50))
					var y_scaled = height - ((y_raw - min_y) / (max_y - min_y) * height)
					var y_stim_scaled = height - ((stim_raw - min_stim) / (max_stim - min_stim) * height)

					points.append(Vector2(x_scaled, y_scaled))
					stim_points.append(Vector2(x_scaled, y_stim_scaled))
	file.close()
#print("Nombre de points affichés : ", points.size())
	if points.size() > 0:
		afficher_mesures()

	queue_redraw()


########################################  draw  ##########################################################
func _draw():
	# fond blanc
	draw_rect(Rect2(Vector2(0, 0), Vector2(width, height)), Color.WHITE)

	# axes
	draw_line(Vector2(50, 0), Vector2(50, height), Color.NAVY_BLUE, 2)
	draw_line(Vector2(0, height), Vector2(width, height), Color.NAVY_BLUE, 2)

	# points (réponse du muscle)
	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)

	# stimulation
	for point in stim_points:
		draw_circle(point, POINT_SIZE, Color.RED)
	for i in range(stim_points.size() - 1):
		draw_line(stim_points[i], stim_points[i + 1], Color.RED, 2)
	
	# min et max
	var max_point = get_max_point()
	var min_point = get_min_point()

	draw_circle(max_point, POINT_SIZE + 2, Color(0, 1, 0)) # Pic contraction
	draw_circle(min_point, POINT_SIZE + 2, Color(1, 0, 0)) # Repos

	# amplitude (ligne bleue verticale du max au min)
	if max_point and min_point:
		var x_amplitude = max_point.x  # même x pour max et min
		var top = Vector2(x_amplitude, max_point.y)
		var bottom = Vector2(x_amplitude, min_point.y)
		draw_line(top, bottom, Color(0.4, 0.8, 1.0), 2)  # ligne bleue
		
		
	########################################
	

##########################################
func get_start_of_contraction() -> int:
	for i in range(1, points.size()):
		if points[i].y < points[i - 1].y:
			return i - 1
	return 0

########################################  Min et Max  ##########################################################
#le point le plus haut
func get_max_point() -> Vector2:
	if points.size() == 0:
		return Vector2.ZERO
	var start_index = get_start_of_contraction()
	var max_point = points[start_index]
	for i in range(start_index, points.size()):
		if points[i].y < max_point.y:
			max_point = points[i]
	return max_point

#le point le plus bas
func get_min_point() -> Vector2:
	if points.size() == 0:
		return Vector2.ZERO
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
	var start = points[get_start_of_contraction()].x
	var peak = get_max_point().x
	return peak - start

########################################  Duree de decontraction ##################################################
func get_decontraction_time() -> float:
	if points.size() < 2:
		return 0
	var peak = get_max_point().x
	var end = points[points.size() - 1].x
	return end - peak
	
	
######################################  Vitesse de Contraction ##################################################
func get_contraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0

	var y_rest = points[0].y
	var y_peak = get_max_point().y
	var amplitude = y_rest - y_peak

	var y1 = y_rest - (x_percent / 100.0) * amplitude
	var y2 = y_rest - (y_percent / 100.0) * amplitude

	var max_point = get_max_point()

	var closest_point1 = Vector2.ZERO
	var closest_point2 = Vector2.ZERO
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
	
	
######################################  Vitesse de decontraction ##################################################
func get_decontraction_speed_percent(x_percent: float, y_percent: float) -> float:
	if points.size() < 2:
		return 0.0

	var y_rest = points[0].y
	var y_peak = get_max_point().y
	var amplitude = y_rest - y_peak

	var y1 = y_peak + (x_percent / 100.0) * amplitude
	var y2 = y_peak + (y_percent / 100.0) * amplitude

	var max_point = get_max_point()

	var closest_point1 = Vector2.ZERO
	var closest_point2 = Vector2.ZERO
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

func _on_calculate_button_pressed() -> void:
	var start_input = $UI/UIVBox/StartTimeInput.text
	var end_input = $UI/UIVBox/EndTimeInput.text
	var density_input = $UI/UIVBox/DensityInput.text

	if start_input.is_valid_float():
		start_time = float(start_input)
	if end_input.is_valid_float():
		end_time = float(end_input)
	if density_input.is_valid_float():
		density = clamp(float(density_input), 0.0, 1.0)

	var file_dialog = $FileDialog
	if file_dialog.current_path != "":
		_on_fichier_selectionne(file_dialog.current_path)

# Bouton gauche → décale vers la gauche
func _on_button_left_pressed() -> void:
	print("Bouton gauche pressé")
	if decalage_input.text.is_valid_float():
		var pas = float(decalage_input.text)
		start_time -= pas
		end_time -= pas
		print("Décalage à gauche de ", pas, " ms. Nouvelle plage : ", start_time, " - ", end_time)
		var file_dialog = $FileDialog
		if file_dialog.current_path != "":
			_on_fichier_selectionne(file_dialog.current_path)

# Bouton droit → décale vers la droite
func _on_button_right_pressed() -> void:
	print("Bouton droit pressé")
	if decalage_input.text.is_valid_float():
		var pas = float(decalage_input.text)
		start_time += pas
		end_time += pas
		print("Décalage à droite de ", pas, " ms. Nouvelle plage : ", start_time, " - ", end_time)
		var file_dialog = $FileDialog
		if file_dialog.current_path != "":
			_on_fichier_selectionne(file_dialog.current_path)
