extends Character
class_name Mob


signal mob_die


export (PackedScene) var MobBullet
var speed: float
var velocity: Vector2
var bullet_disapper_map: Dictionary = {}


func _init() -> void:
	health = 2
	shoot_cooldown = 1
	

func _ready() -> void:
	_check_is_die()


func _process(delta: float) -> void:
	position += velocity * speed * delta

	
func _check_is_die() -> void:
	if health <= 0:
		emit_signal("mob_die")


func on_damage(damage: int) -> void:
	health -= damage
	_check_is_die()


func _on_Mob_mob_die() -> void:
	queue_free()
	
	
func _shoot_bullet():
	_before_shoot_bullet()
	for i in range(1, 6):
		var bullet = MobBullet.instance()
		bullet.velocity = Vector2(rand_range(-1, 1), i).normalized()
		bullet.acceleration = 50 * i
		bullet.speed = 50 * i
		add_child(bullet)
	
	
func _on_BulletTimer_timeout():
	can_shoot = true
	_shoot_bullet()


func _on_CollisionArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		on_damage(1)
