extends Node

var paused := false
var settings_menu := false

signal settings_back
signal update_hud_ammo_current(new_value: int)
signal update_hud_ammo_max(new_value: int)
signal update_hud_clip_current(new_value: int)
signal set_hud_visibility(is_visible: bool) 
signal set_clip_label_visibility(is_visible: bool)
signal change_player_character(character: int, id: int)
signal toggle_pause_menu()
signal player_death(name: String)
signal unlock()
signal set_crosshair(is_crosshair: bool)

signal button_hovered
signal button_click
