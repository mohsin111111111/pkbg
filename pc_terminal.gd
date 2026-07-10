extends Area3D
@onready var database_ui = $CanvasLayer
@onready var status_label = $CanvasLayer/ColorRect/StatusLabel
@onready var btn_1 = $CanvasLayer/ColorRect/Btn1
@onready var btn_2 = $CanvasLayer/ColorRect/Btn2
@onready var btn_3 = $CanvasLayer/ColorRect/Btn3
@onready var download_bar = $CanvasLayer/ColorRect/DownloadBar
@onready var download_timer = $DownloadTimer

var player_in_range = false
var puzzle_step = 0
var is_downloading = false

func _ready():
	database_ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		print("Press E to hack the terminal!")
		
func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		close_terminal()
		
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if database_ui.visible:
			close_terminal()
		else:
			open_terminal()

func open_terminal():
	database_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_terminal():
	database_ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_btn_1_pressed():
	check_puzzle(1)
func _on_btn_2_pressed():
	check_puzzle(2)
func _on_btn_3_pressed():
	check_puzzle(3)
func check_puzzle(button_pressed):
	if is_downloading: return
	if puzzle_step == 0 and button_pressed == 2:
		puzzle_step = 1
		status_label.text = "Sequence 1 Accepted..."
	elif puzzle_step == 1 and button_pressed ==3:
		puzzle_step = 2
		status_label.text = "Sequence 2 Accepted..."
	elif puzzle_step == 2 and button_pressed == 1:
		status_label.text = "FIRE BYPASSED. DOWNLOADING DATA..."
		status_label.modulate = Color.GREEN
		start_download()
	else:
		puzzle_step = 0 
		status_label.text = "FIREWALL ALERT: SEQUENCE FAILED! Try again."
		status_label.modulate = Color.RED
		
func start_download():
	is_downloading = true
	btn_1.hide()
	btn_2.hide()
	btn_3.hide()
	download_bar.show()
	download_bar.value = 0
	download_timer.start()
	
func _on_download_timer_timeout():
	download_bar.value += 2
	
	if download_bar.value >= 100:
		download_timer.stop()
		status_label.text = "DATA SECURED. GET TO THE CHOPPER!"
