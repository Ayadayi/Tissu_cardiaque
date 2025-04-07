extends Control

const RESOLUTION := 100
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
		Vector2(130, height - 85),
		Vector2(140, height - 100), # Pic de contraction
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
		Vector2(260, height),      
		Vector2(260, height),    
		Vector2(260, height),  
		Vector2(260, height),   
	]

	queue_redraw()

func _draw():
	# Axes
	draw_line(Vector2(50, 0), Vector2(50, height), Color(0, 0, 0), 2)  # Axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color(0, 0, 0), 2)  # Axe X

	# Points + lignes
	for point in points:
		draw_circle(point, POINT_SIZE, Color(0, 0, 0))  # Noir

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color(0, 0, 0), 2)

	# Point de contraction max (plus haut) en vert
	var max_point = get_max_point()
	draw_circle(max_point, POINT_SIZE + 2, Color(0, 1, 0))

	# Point min en rouge
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0))

	# Repères sur X
	for i in range(0, RESOLUTION, int(RESOLUTION / 10)):
		var x = i / float(RESOLUTION) * width
		draw_line(Vector2(x, height - 5), Vector2(x, height + 5), Color(0, 0, 0), 1)

	# Repères sur Y
	for i in range(0, height, int(height / 10)):
		draw_line(Vector2(45, i), Vector2(55, i), Color(0, 0, 0), 1)

	# Affichage dans la console de l’amplitude
	var base_y = height
	var base_point = Vector2(max_point.x, base_y)
	var amplitude = base_y - max_point.y
	print("Amplitude de contraction : ", amplitude)

func get_max_point() -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	var max_point = points[0]
	for p in points:
		if p.y < max_point.y:
			max_point = p
	return max_point

func get_min_point() -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	var min_point = points[0]
	for p in points:
		if p.y > min_point.y:
			min_point = p
	return min_point
