extends Control

@onready var return_to_main := true

func _ready() -> void:
	Signals.settings_back.connect(_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	visible = false
	Signals.settings_menu = false
	if return_to_main:
		%MainMenu.visible = true
	else:
		$"../PauseMenu".visible = true
	
	Settings.current_settings['Master'] = $VBoxContainer/Master/MasterSlider.value
	Settings.current_settings['music'] = $VBoxContainer/Music/MusicSlider.value
	Settings.current_settings['sfx'] = $VBoxContainer/SFX/EffectsSlider.value
	

# Pause Menu Settings
func _on_settings_button_pressed() -> void:
	Signals.settings_menu = true
	$ColorRect.visible = Signals.paused
	$"../PauseMenu".visible = false
	visible = true
	return_to_main = false
