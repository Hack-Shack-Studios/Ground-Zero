extends Control

# signal speed_boost

# # Prices
# const SPEED_PRICE: int = 30
# const DAMAGE_REDUCTION_PRICE: int = 100
# const INFINITE_AMMO_PRICE: int = 120
# const DOUBLE_POINTS_PRICE: int = 200
# const DOUBLE_HEALTH_PRICE: int = 350

# ## Timers
# @onready var speed_timer = $Timers/SpeedBoost
# @onready var damage_reduction_timer = $Timers/DamageReduction
# @onready var infinite_ammo_timer = $Timers/InfiniteAmmo
# @onready var double_points_timer = $Timers/DoublePoints

# ## Buttons
# @onready var speed_button = $Menu/Buffs/Speed
# @onready var damage_reduction_button = $Menu/Buffs/DamageReduction
# @onready var infinite_ammo_button = $Menu/Buffs/InfiniteAmmo
# @onready var double_points_button = $Menu/Buffs/DoublePoints
# @onready var double_health_button = $Menu/Buffs/DoubleHealth

# ## Colors
# var green := Color("DARK_GREEN")
# var red := Color("DARK_RED")

# func _on_speed_pressed() -> void:
#     # speed_boost.emit()
#     print("Speed pressed, money: ", Global.score)
#     if Global.score > SPEED_PRICE:
#         Global.score -= SPEED_PRICE
#         Global.speed_boost = true
#         speed_timer.start()
#         # speed_boost.emit()


# func _on_damage_reduction_pressed() -> void:
#     print("Damage Reduction pressed, money: ", Global.score)
#     if Global.score > DAMAGE_REDUCTION_PRICE:
#         Global.score -= DAMAGE_REDUCTION_PRICE
#         Global.damage_reduction = true
#         damage_reduction_timer.start()


# func _on_infinite_ammo_pressed() -> void:
#     print("Infinite Ammo pressed, money: ", Global.score)
#     if Global.score > INFINITE_AMMO_PRICE:
#         Global.score -= INFINITE_AMMO_PRICE
#         Global.infinite_ammo = true
#         infinite_ammo_timer.start()


# func _on_double_points_pressed() -> void:
#     print("Double Points pressed, money: ", Global.score)
#     if Global.score > DOUBLE_POINTS_PRICE:
#         Global.score -= DOUBLE_POINTS_PRICE
#         Global.double_points = true
#         double_points_timer.start()


# func _on_double_health_pressed() -> void:
#     print("Double Health pressed, money: ", Global.score)
#     if Global.score > DOUBLE_HEALTH_PRICE:
#         Global.score -= DOUBLE_HEALTH_PRICE
#         Global.double_health = true


# ## Timer functions

# func _on_speed_boost_timeout() -> void:
#     Global.speed_boost = false


# func _on_damage_reduction_timeout() -> void:
#     Global.damage_reduction = false


# func _on_infinite_ammo_timeout() -> void:
#     Global.infinite_ammo = false


# func _on_double_points_timeout() -> void:
#     Global.double_points = false


# # @onready var buffs = {
# #     "globals": [Global.speed_boost, Global.damage_reduction, Global.infinite_ammo, Global.double_points, Global.double_health],
# #     "prices": [SPEED_PRICE, DAMAGE_REDUCTION_PRICE, INFINITE_AMMO_PRICE, DOUBLE_POINTS_PRICE, DOUBLE_HEALTH_PRICE],
# #     "timers": [speed_timer, damage_reduction_timer, infinite_ammo_timer, double_points_timer, null],
# #     "buttons": [speed_button, damage_reduction_button, infinite_ammo_button, double_points_button, double_health_button],
# # }

# # func _ready():
# #     print("Ready function called")
# #     speed_button.connect("pressed", Callable(self, "_on_speed_pressed"))
# #     damage_reduction_button.connect("pressed", Callable(self, "_on_damage_reduction_pressed"))
# #     infinite_ammo_button.connect("pressed", Callable(self, "_on_infinite_ammo_pressed"))
# #     double_points_button.connect("pressed", Callable(self, "_on_double_points_pressed"))
# #     double_health_button.connect("pressed", Callable(self, "_on_double_health_pressed"))

# # func _process(_delta: float) -> void:
# #     for index in range(len(buffs["prices"])):
# #         if buffs["prices"][index] <= Global.score:
# #             var new_stylebox_normal = StyleBoxFlat.new()
# #             new_stylebox_normal.bg_color = green
# #             buffs["buttons"][index].add_theme_stylebox_override("normal", new_stylebox_normal)
# #         else:
# #             var new_stylebox_normal = StyleBoxFlat.new()
# #             new_stylebox_normal.bg_color = red
# #             buffs["buttons"][index].add_theme_stylebox_override("normal", new_stylebox_normal)

# ## Button functions

# # TODO: Add func to make things cleaner
# # func add_buff(buff: bool, price: int, timer: Timer) -> void:
# #     if Global.score > price:
# #         Global.score -= price
# #         Global.buff = true
# #         timer.start()
