extends Control

# Liste des points de la courbe en coordonnées normales (0.0 à 1.0)
var points_normaux = [
	Vector2(0.1, 0.2),
	Vector2(0.3, 0.5),
	Vector2(0.5, 0.3),
	Vector2(0.7, 0.8),
	Vector2(0.9, 0.6)
]

func _ready():
	# Redessine lorsque la taille change
	connect("resized", Callable(self, "_on_resized"))
	queue_redraw()

func _draw():
	# Obtenir la taille actuelle du Control (qui correspond à celle du TextureRect)
	var taille = get_size()
	for point_normal in points_normaux:
		# Convertir les coordonnées normales en coordonnées locales
		var point_local = Vector2(point_normal.x * taille.x, point_normal.y * taille.y)
		draw_circle(point_local, 5, Color(1, 0, 0))  # Dessine un cercle rouge de rayon 5

func _on_resized():
	# Redessine les points lorsque la taille change
	queue_redraw()
	### comment 
