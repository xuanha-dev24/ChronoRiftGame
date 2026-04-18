extends Sprite2D

@export var variant_textures: Array[Texture2D] = []
@export var randomize_frame: bool = true
@export var randomize_flip_h: bool = false
@export var bob_enabled: bool = false
@export var bob_amplitude: float = 1.5
@export var bob_speed: float = 2.0
@export var animate: bool = false
@export var animate_fps: float = 6.0

var _base_position: Vector2 = Vector2.ZERO
var _time_offset: float = 0.0
var _rng := RandomNumberGenerator.new()
var _anim_time: float = 0.0
var _current_frame: int = 0
var _total_frames: int = 1


func _ready() -> void:
	_rng.randomize()
	_base_position = position
	_time_offset = _rng.randf_range(0.0, TAU)

	if not variant_textures.is_empty():
		texture = variant_textures[_rng.randi_range(0, variant_textures.size() - 1)]

	# Determine total frames from sprite sheet settings
	_total_frames = max(1, hframes * vframes)
	if randomize_frame and texture != null:
		_current_frame = _rng.randi_range(0, _total_frames - 1)
		frame = _current_frame

	if randomize_flip_h:
		flip_h = _rng.randf() < 0.5

	# Ensure processing if bobbing or animation is enabled
	set_process(bob_enabled or animate)



func _process(_delta: float) -> void:
	# Bobbing motion
	if bob_enabled:
		position.y = _base_position.y + sin(Time.get_ticks_msec() * 0.001 * bob_speed + _time_offset) * bob_amplitude

	# Frame animation for sprite sheets
	if animate and _total_frames > 1:
		_anim_time += _delta
		var frame_len: int= 1.0 / max(0.001, animate_fps)
		if _anim_time >= frame_len:
			var steps := int(_anim_time / frame_len)
			_anim_time -= steps * frame_len
			_current_frame = (_current_frame + steps) % _total_frames
			frame = _current_frame
