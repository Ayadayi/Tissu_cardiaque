extends Control

const RESOLUTION := 100
const POINT_SIZE := 3
var width := 600
var height := 400

var points : Array = [
	Vector2(50, 400),   # latence
	Vector2(80, 400),   # latence
	Vector2(110, 360),  # début contraction
	Vector2(130, 300),
	Vector2(150, 220),
	Vector2(170, 160),  # sommet
	Vector2(190, 180),
	Vector2(210, 210),
	Vector2(230, 250),
	Vector2(250, 290),
	Vector2(270, 330),
	Vector2(290, 360),
	Vector2(310, 380),
	Vector2(330, 390),
	Vector2(350, 400)
]

func _ready():
	var amplitude = get_amplitude()
	print("Amplitude de contraction : ", amplitude)
	
	var contraction_time = get_contraction_time()
	print("Temps de contraction : ", contraction_time, " ms")
	
	var decontraction_time = get_decontraction_time()
	print("Temps de décontraction : ", decontraction_time, " ms")
	
	var vitesse_contraction = get_contraction_speed_percent(10, 90)
	print("Vitesse de contraction (10%-90%) : ", vitesse_contraction)

	

func _draw():
	draw_line(Vector2(50, 0), Vector2(50, height), Color.BLACK, 2)  # Axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK, 2)  # Axe X

	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)

	draw_circle(get_max_point(), POINT_SIZE + 2, Color(0, 1, 0))
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0))

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

#affichage de l'amplitude 
func get_amplitude() -> float:
	var base_y = height
	var max_y = get_max_point().y
	return base_y - max_y

#affichage du temps de contraction = dès que y commence à descendre
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
	
	
#affichage de la duree de decontraction
func get_decontraction_time() -> float:
	if points.size() < 2:
		return 0

	var max_point := get_max_point()
	var end_time: float = points[points.size() - 1].x

	return end_time - max_point.x
	
	
	
#vitesse de contraction #
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
