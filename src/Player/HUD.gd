extends CanvasLayer

# @onready var current_weapon_label = $"VBoxContainer/HBoxContainer/Current Weapon"
#@onready var current_ammo_label = $"VBoxContainer/HBoxContainer2/Current Ammo"
# @onready var current_weapon_stack = $"VBoxContainer/HBoxContainer3/Weapon Stack"

@onready var weapon_info = $"../HUD/WeaponGUI/InformationLabel"


func _on_weapons_manager_update_ammo(ammo) -> void:
    var remaining_ammo_color: float = ammo[0] / 20.0
    weapon_info.text = "Coil Pistol\n" + str(ammo[0]) + " / " + str(ammo[1])
    if remaining_ammo_color <= 0.5 and remaining_ammo_color >= 0.2:
        weapon_info.add_theme_color_override("font_color", Color(1, 1, 0))
    elif remaining_ammo_color < 0.2:
        weapon_info.add_theme_color_override("font_color", Color(1, 0, 0))
    else:
        weapon_info.add_theme_color_override("font_color", Color(0, 1, 0))


# func _on_weapons_manager_update_weapon_stack(weapon_stack) -> void:
#     current_weapon_stack.set_text("")
#     for i in weapon_stack:
#         current_weapon_stack.text += "\n"+i


# func _on_weapons_manager_weapon_changed(weapon_name) -> void:
#     current_weapon_label.set_text(weapon_name)
