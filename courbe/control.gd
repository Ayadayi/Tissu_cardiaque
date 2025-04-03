extends Control

const RESOLUTION := 100  # Nombre de points pour lisser la courbe
const POINT_SIZE := 3  # Taille des points
var width := 600
var height := 400

# Tableau pour stocker les points (chaque point est un Vector2)
var points : Array = []

func _ready():
	set_size(Vector2(width, height))  # Définit la taille du Control
	connect("resized", Callable(self, "_on_resized"))
	queue_redraw()

	# Exemple d'ajout de points manuellement à partir du tableau
	# Ajouter des points (remplacer par vos propres coordonnées)
	points.append(Vector2(50, height / 2))  # Exemple de point (50, y)
	points.append(Vector2(70, height / 2 - 70))  # Exemple de point (50, y)
	points.append(Vector2(90, height / 2 - 90))
	points.append(Vector2(110, height / 2 - 110))
	points.append(Vector2(130, 190))
	points.append(Vector2(150, height / 2 - 50))  # Exemple de point (150, y)
	points.append(Vector2(250, height / 2 + 50))  # Exemple de point (250, y)
	points.append(Vector2(350, height / 2))  # Exemple de point (350, y)


func _draw():
	var amplitude = height / 3.0  # Amplitude relative à la hauteur
	var center_y = height / 2.0  # Position centrale

	# Dessiner les axes X et Y
	draw_line(Vector2(50, 0), Vector2(50, height), Color(0, 0, 0), 2)  # L'axe Y
	draw_line(Vector2(0, height), Vector2(width, height), Color(0, 0, 0), 2)  # L'axe X
	

	# Dessiner les points saisis
	for point in points:
		draw_circle(point, POINT_SIZE, Color(0, 1, 0)) 

	# Ajouter des graduations sur l'axe des abscisses
	for i in range(0, RESOLUTION, int(RESOLUTION / 10)):
		var x = i / float(RESOLUTION) * width
		draw_line(Vector2(x, height - 5), Vector2(x, height + 5), Color(0, 0, 0), 2)  # Repères sur l'axe des X

	# Ajouter des repères sur l'axe des ordonnées
	for i in range(0, height, int(height / 10)):
		draw_line(Vector2(45, i), Vector2(55, i), Color(0, 0, 0), 2)  # Repères sur l'axe des Y

func _on_resized():
	width = get_size().x
	height = get_size().y
	queue_redraw()  # Redessiner lorsque la taille change
