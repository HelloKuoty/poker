extends RefCounted
class_name LocalizationManager

signal language_changed(language_code: String)

const DEFAULT_LANGUAGE := "zh"
const SUPPORTED_LANGUAGES := ["zh", "en"]
const UI_TEXT_PATH := "res://data/ui_text.json"

var current_language := DEFAULT_LANGUAGE
var ui_text := {}


func _init() -> void:
	load_ui_text()


func load_ui_text(path: String = UI_TEXT_PATH) -> void:
	ui_text = {}
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		ui_text = parsed


func set_language(language_code: String) -> void:
	if not SUPPORTED_LANGUAGES.has(language_code):
		language_code = DEFAULT_LANGUAGE
	if current_language == language_code:
		return
	current_language = language_code
	emit_signal("language_changed", current_language)


func toggle_language() -> void:
	if current_language == "zh":
		set_language("en")
	else:
		set_language("zh")


func get_text(value) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		var chosen = null
		if value.has(current_language):
			chosen = value[current_language]
		elif value.has("zh"):
			chosen = value["zh"]
		elif value.has("en"):
			chosen = value["en"]
		else:
			return ""
		return _value_to_string(chosen)
	if typeof(value) == TYPE_STRING:
		return value
	if value == null:
		return ""
	return str(value)


func get_text_list(value) -> Array:
	if typeof(value) == TYPE_DICTIONARY:
		var chosen = null
		if value.has(current_language):
			chosen = value[current_language]
		elif value.has("zh"):
			chosen = value["zh"]
		elif value.has("en"):
			chosen = value["en"]
		if typeof(chosen) == TYPE_ARRAY:
			return chosen
		if chosen != null:
			return [str(chosen)]
	if typeof(value) == TYPE_ARRAY:
		return value
	if value == null:
		return []
	return [str(value)]


func get_ui_text(key: String) -> String:
	if ui_text.has(key):
		return get_text(ui_text[key])
	return key


func language_toggle_label() -> String:
	return "English" if current_language == "zh" else "中文"


func _value_to_string(value) -> String:
	if typeof(value) == TYPE_ARRAY:
		var parts: Array[String] = []
		for item in value:
			parts.append(str(item))
		return ", ".join(PackedStringArray(parts))
	if value == null:
		return ""
	return str(value)
