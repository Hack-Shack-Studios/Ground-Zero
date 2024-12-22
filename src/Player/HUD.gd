extends CanvasLayer

@onready var current_weapon_label = $"VBoxContainer/HBoxContainer/Current Weapon"
@onready var current_ammo_label = $"VBoxContainer/HBoxContainer2/Current Ammo"
@onready var current_weapon_stack = $"VBoxContainer/HBoxContainer3/Weapon Stack"


func _on_weapons_manager_update_ammo(ammo) -> void:
    current_ammo_label.set_text(str(ammo[0]) + " / " + str(ammo[1]))


func _on_weapons_manager_update_weapon_stack(weapon_stack) -> void:
    current_weapon_stack.set_text("")
    for i in weapon_stack:
        current_weapon_stack.text += "\n"+i


func _on_weapons_manager_weapon_changed(weapon_name) -> void:
    current_weapon_label.set_text(weapon_name)
