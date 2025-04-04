extends Control

const RESOLUTION := 100  # Nombre de points 
const POINT_SIZE := 3  # Taille des points
var width := 600
var height := 400

# Tableau pour stocker les points (chaque point est un Vector2)
var points : Array = []

func _ready():
	# Ajout de points manuellement à partir du tableau
	# Ajouter des points 
	points.append(Vector2(50, height / 2))  
	points.append(Vector2(70, height / 2 - 70))  
	points.append(Vector2(90, height / 2 - 90))
	points.append(Vector2(110, height / 2 - 110))
	points.append(Vector2(130, 190))
	points.append(Vector2(150, height / 2 - 50)) 
	points.append(Vector2(250, height / 2 + 50)) 
	points.append(Vector2(350, height / 2)) 
	
	
func _draw():
	# Dessiner les axes X et Y
	draw_line(Vector2(50, 0), Vector2(50, height), Color(0, 0, 0), 2)  # L'axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color(0, 0, 0), 2)  # L'axe X
	

	# Dessiner les points saisis
	for point in points:
		draw_circle(point, POINT_SIZE, Color.BLACK)

		
	# Relier les points entre eux
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.BLACK, 2)
		
	# Point le plus haut en vert
	draw_circle(get_max_point(), POINT_SIZE + 2, Color(0, 1, 0))

	# Point le plus bas en rouge
	draw_circle(get_min_point(), POINT_SIZE + 2, Color(1, 0, 0))


	# Ajouter des graduations sur l'axe des abscisses
	for i in range(0, RESOLUTION, int(RESOLUTION / 10)):
		var x = i / float(RESOLUTION) * width
		draw_line(Vector2(x, height - 5), Vector2(x, height + 5), Color(0, 0, 0), 2)  # Repères sur l'axe des X

	# Ajouter des repères sur l'axe des ordonnées
	for i in range(0, height, int(height / 10)):
		draw_line(Vector2(45, i), Vector2(55, i), Color(0, 0, 0), 2)  # Repères sur l'axe des Y
		

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
