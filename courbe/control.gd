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
	var contraction_time = get_contraction_time()
	print("Temps de contraction : ", contraction_time, " ms")

func _draw():
	draw_line(Vector2(50, 0), Vector2(50, height), Color.BLACK, 2)  # Axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK, 2)  # Axe X

	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)

	draw_circle(get_max_point(), POINT_SIZE + 2, Color(0, 1, 0))
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0))
	
# affichage de l’amplitude
	var base_y = height
	var max_point =  get_max_point()
	var base_point = Vector2(max_point.x, base_y)

	var amplitude = base_y - max_point.y
	print("Amplitude de contraction : ",amplitude)

#le point le plus haut 
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
	
#affichage du temps de contraction 
func get_contraction_time() -> float:
	if points.size() < 2:
		return 0

	var start_time := -1.0
	var max_point := get_max_point()

	for i in range(1, points.size()):
		if points[i].y < points[i - 1].y and start_time == -1:
			start_time = points[i].x
			break

	if start_time == -1:
		return 0

	return max_point.x - start_time
