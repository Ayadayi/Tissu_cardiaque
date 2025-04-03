extends TextureRect

const WIDTH := 400
const HEIGHT := 200
const POINT_COLOR := Color(1, 1, 1)  # Blanc
const BACKGROUND_COLOR := Color(0, 0, 0)  # Noir

var image := Image.new()
var generated_texture := ImageTexture.new()  # Nouveau nom pour éviter le conflit

func _ready():
	# Créer une image noire
	image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGB8)
	image.fill(BACKGROUND_COLOR)
	
	# Dessiner la courbe
	draw_sin_wave()
	
	# Appliquer l'image à la texture
	generated_texture = ImageTexture.create_from_image(image)
	self.texture = generated_texture  # Utilisation de la propriété `texture` de TextureRect

func draw_sin_wave():
	var amplitude := HEIGHT / 4.0  # Hauteur de l'onde
	var center_y := HEIGHT / 2.0  # Position centrale
	
	for x in range(WIDTH):
		var y := center_y - amplitude * sin(x * 2.0 * PI / float(WIDTH))  
		image.set_pixel(x, int(y), POINT_COLOR)  # Dessin du point
