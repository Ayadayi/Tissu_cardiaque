extends Control

const POINT_SIZE := 3
var width := 600
var height := 400

var points : Array = []

func _ready():
	# Courbe de points : latence -> contraction -> relaxation
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

func _draw():
	draw_line(Vector2(50, 0), Vector2(50, height), Color.BLACK, 2)  # Axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK, 2)  # Axe X

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

	# Calcul de la vitesse
	var delta_force = closest_point2.y - closest_point1.y
	var delta_time = closest_point2.x - closest_point1.x

	if delta_time == 0:
		return 0

	return abs(delta_force / delta_time)
	
	
######################################  Vitesse de Déontraction ##################################################

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

	# Calcul de la vitesse (pente)
	var delta_force = closest_point2.y - closest_point1.y
	var delta_time = closest_point2.x - closest_point1.x

	if delta_time == 0:
		return 0.0

	return abs(delta_force / delta_time)
