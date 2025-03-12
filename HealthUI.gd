extends Control

var hearts = 3 setget set_hearts
var max_hearts = 3 setget set_max_hearts

onready var heartUIFull = $CanvasLayer/HeartUIFull
onready var heartUIEmpty = $CanvasLayer/HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	print("Current Hearts:", hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 18
		heartUIFull.visible = hearts > 0
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 18
	
	if hearts <= 0:
		heartUIFull.rect_size.x = hearts * 18
		heartUIFull.visible = hearts > 0

func set_max_hearts(value):
	max_hearts = max(value, 1)
	update_hearts_ui()

func _ready():
	var player = get_node("/root/World/Player")  # ใส่ path ที่ถูกต้องของ Player
	self.max_hearts = player.max_health
	self.hearts = player.health
	update_hearts_ui()

	# ฟังสัญญาณจาก Player เพื่ออัปเดต UI เมื่อได้รับความเสียหาย
	player.connect("player_hit", self, "_on_player_hit")
	player.connect("player_fall_off_map", self, "_on_player_fall_off_map")

func update_hearts_ui():
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 18  # อัปเดตความกว้างของหัวใจเต็มตามจำนวนหัวใจที่เหลือ
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 18  # อัปเดตความกว้างของหัวใจว่างตามจำนวนหัวใจสูงสุด

# ฟังก์ชันที่เรียกเมื่อ Player ได้รับความเสียหาย
func _on_player_hit():
	 set_hearts(hearts - 1)  # ลดหัวใจลง 1 เมื่อผู้เล่นได้รับความเสียหาย

func _on_player_fall_off_map():
	set_hearts(0)
