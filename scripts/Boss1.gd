extends Mob


signal boss_use_skill(skill_type)


var skill_cooldown_sec: float = 10
var skill_lasting_sec: float = 5
enum ATTACK_TYPE {
	NORMAL = 0
	SKILL = 1
}
var attack_type: int = ATTACK_TYPE.NORMAL


func _shoot_bullet_normal():
	var center_point = position + $BulletSpawnPath/PathFollow2D.position
	for i in range(-6, 6):
		var bullet = MobBullet.instance()
		bullet.position = center_point
		bullet.speed = bullet_speed
		bullet.acceleration = bullet_acceleration
		var rad = PI / 6 * i
		bullet.velocity = Vector2(sin(rad), cos(rad)).normalized()
		bullet.rotation = rad
		bullet.set_as_toplevel(true)
		add_child(bullet)


func _shoot_bullet_skill():
	var center_point = position + $BulletSpawnPath/PathFollow2D.position
	for i in range(-12, 12):
		var bullet = MobBullet.instance()
		bullet.position = center_point
		bullet.speed = bullet_speed
		bullet.acceleration = bullet_acceleration
		var rad = PI / 12 * i
		bullet.velocity = Vector2(sin(rad), cos(rad)).normalized()
		bullet.rotation = rad
		bullet.set_as_toplevel(true)
		add_child(bullet)


func _init() -> void:
	health = 20000
	bullet_speed = 100
	bullet_acceleration = 100
	bullet_veloctiy = Vector2(0, -1)
	shoot_cooldown = 0.1


func _process(delta: float) -> void:
	$BulletSpawnPath/PathFollow2D.offset += rand_range(-100, 200) * delta
	position += Vector2(rand_range(-5, 5), rand_range(-5, 5))
	position.x = clamp(position.x, 0, 400)
	position.y = clamp(position.y, 0, 800)


func _shoot_bullet():
	_before_shoot_bullet()
	if attack_type == ATTACK_TYPE.NORMAL:
		_shoot_bullet_normal()
	elif attack_type == ATTACK_TYPE.SKILL:
		_shoot_bullet_skill()


func _ready() -> void:
	position = Vector2(200, 50)
	$ProgressBar.value = health
	$SkillCooldownTimer.start(skill_cooldown_sec)


func _on_SkillCooldownTimer_timeout() -> void:
	attack_type = ATTACK_TYPE.SKILL
	bullet_speed = 60
	bullet_acceleration = 20
	$SkillLastingTimer.start(skill_lasting_sec)
	emit_signal("boss_use_skill", 0)


func _on_SkillLastingTimer_timeout() -> void:
	attack_type = ATTACK_TYPE.NORMAL
	bullet_speed = 100
	bullet_acceleration = 100
	$SkillCooldownTimer.start(skill_cooldown_sec)
	
