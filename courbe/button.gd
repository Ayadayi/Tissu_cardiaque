extends Button
@onready var file_dialog = $FileImporter

func _pressed():
	var file_dialog = get_parent().get_node("FileImporter")
	file_dialog.popup_centered()
	
func _on_FileImporter_file_selected(path):
	print("Fichier importé :", path)
	# Tu peux ici charger le fichier selon son type
	# Par exemple, pour une image :
	var texture = ImageTexture.new()
	var img = Image.new()
	img.load(path)
	texture.create_from_image(img)
	$TextureRect.texture = texture
