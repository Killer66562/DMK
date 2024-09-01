extends Character
class_name Player


signal player_die
signal player_use_skill


export (PackedScene) var PlayerBullet


var max_skill_remain: int = 8
var max_power: int = 2
var skill_remain_sec: float = 5
var invincible_sec: float = 5
var speed: float = 400


onready var skill_remain: int = max_skill_remain
onready var power: int = 0
onready var can_use_skill: bool = true
onready var is_invincible: bool = false
onready var skill_is_active: bool = false


func _init() -> void:
	shoot_cooldown = 0.125
	health = 100


func _ready() -> void:
	_check_is_die()
	$InvincibleTimer.start(invincible_sec)


func _can_really_use_skill() -> bool:
	return can_use_skill and skill_remain > 0


func _before_use_skill() -> void:
	can_use_skill = false
	skill_remain -= 1
	$SkillTimer.start(skill_remain_sec)


func _check_is_die() -> void:
	if health <= 0:
		emit_signal("player_die")
	

func on_damage() -> void:
	health -= 1
	_check_is_die()


func revive():
	skill_remain = max_skill_remain
	can_use_skill = true
	$InvincibleTimer.start()
	$CollisionShape2D.disabled = false
	show()


func _on_Player_player_die() -> void:
	$CollisionArea.set_deferred("disabled", true)
	$BulletTimer.stop()
	$SkillTimer.stop()
	$InvincibleTimer.stop()
	can_shoot = false
	can_use_skill = false
	is_invincible = false
	hide()


func _on_SkillTimer_timeout() -> void:
	skill_is_active = false
	can_use_skill = true
	

func _on_InvincibleTimer_timeout() -> void:
	is_invincible = false
	
	
func _on_Player_area_entered(area: Area2D) -> void:
	if area.is_in_group("mob") or area.is_in_group("mob_bullet"):
		print("Ouch")
		on_damage()


func _on_Player_player_use_skill() -> void:
	_before_use_skill()
	skill_is_active = true
	

func _shoot_bullet():
	_before_shoot_bullet()
	var bullet = PlayerBullet.instance()
	bullet.position = position
	bullet.velocity = Vector2(0, -1).normalized()
	bullet.speed = 400
	bullet.acceleration = 400
	bullet.set_as_toplevel(true)
	add_child(bullet)
	
	
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	velocity = velocity.normalized() * speed * delta
	
	position += velocity
	position.x = clamp(position.x, 0, 400)
	position.y = clamp(position.y, 0, 800)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot_bullet()


	if Input.is_action_pressed("use_skill") and _can_really_use_skill():
		emit_signal("player_use_skill")


func _on_SkillArea_area_entered(area: Area2D) -> void:
	if skill_is_active:
		if area.is_in_group("mob_bullet"):
			area.queue_free()
		elif area.is_in_group("mob"):
			area.emit_signal('die')
