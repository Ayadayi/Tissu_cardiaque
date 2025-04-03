extends Control

# Paramètres pour la sinusoïde
var amplitude = 100
var fréquence = 0.05
var phase = 0

# Tableau pour stocker les points sinusoïdaux (en dur)
var points_sinusoidaux = [
	Vector2(0, 300),
	Vector2(50, 280),
	Vector2(100, 250),
	Vector2(150, 230),
	Vector2(200, 210),
	Vector2(250, 180),
	Vector2(300, 150),
	Vector2(350, 120),
	Vector2(400, 100),
	Vector2(450, 120),
	Vector2(470, 140),
	Vector2(500, 180),
	Vector2(550, 140),
	Vector2(600, 130),
	Vector2(650, 110),
	Vector2(700, 80),
	Vector2(750, 60),
	Vector2(800, 70),
	Vector2(880, 80)
]

func _ready():
	# Mettre à jour les points avec les valeurs sinusoïdales
	for i in range(points_sinusoidaux.size()):
		var x = points_sinusoidaux[i].x
		var y = amplitude * sin(fréquence * x + phase) + 300  # Calculer la valeur Y en fonction de la sinusoïde
		points_sinusoidaux[i] = Vector2(x, y)  # Mettre à jour la position Y de chaque point

	# Demander un redessin
	queue_redraw()

func _draw():
	# Dessiner les points sans les relier
	for point in points_sinusoidaux:
		draw_circle(point, 5, Color(1, 0, 0))  # Afficher chaque point sous forme de cercle rouge de rayon 5
