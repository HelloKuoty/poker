extends SceneTree


func _init() -> void:
	var config := ConfigFile.new()
	var error := config.load("res://project.godot")
	if error != OK:
		push_error("PROJECT_CONFIG_TEST_FAILED: cannot load project.godot")
		quit(1)
		return

	var width := int(config.get_value("display", "window/size/viewport_width", 0))
	var height := int(config.get_value("display", "window/size/viewport_height", 0))
	if width <= 0 or height <= 0:
		push_error("PROJECT_CONFIG_TEST_FAILED: invalid viewport size %dx%d" % [width, height])
		quit(1)
		return
	if width > 960 or height > 700:
		push_error("PROJECT_CONFIG_TEST_FAILED: default viewport too large %dx%d" % [width, height])
		quit(1)
		return

	print("PROJECT_CONFIG_TEST_OK viewport=%dx%d" % [width, height])
	quit(0)
