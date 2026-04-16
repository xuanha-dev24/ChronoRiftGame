# Restore hud.gd After Testing

## ⚠️ IMPORTANT
After running the Phase 1 test, you MUST restore `hud.gd` to its original code!

---

## Quick Restore

### Option 1: Copy from Backup File
1. Open `scripts/ui/hud.gd.backup`
2. Copy all content (Ctrl+A, Ctrl+C)
3. Open `scripts/ui/hud.gd`
4. Replace all content (Ctrl+A, Ctrl+V)
5. Save (Ctrl+S)

### Option 2: Manual Restore
Replace `scripts/ui/hud.gd` with this code:

```gdscript
# hud.gd
# Main HUD controller
extends CanvasLayer

@onready var hp_label: Label = $HPLabel

func _ready() -> void:
	# Connect to player damage signal
	EventBus.player_damaged.connect(_on_player_damaged)
	
	# Initialize HP display
	_update_hp_display(100, 100)
	
	print("[HUD] Initialized")

func _on_player_damaged(current_hp: int, max_hp: int) -> void:
	"""Update HP display when player takes damage."""
	_update_hp_display(current_hp, max_hp)

func _update_hp_display(current_hp: int, max_hp: int) -> void:
	"""Update HP label text."""
	if hp_label:
		hp_label.text = "HP: %d / %d" % [current_hp, max_hp]
		
		# Color code based on HP percentage
		var hp_percent = float(current_hp) / float(max_hp)
		if hp_percent > 0.6:
			hp_label.modulate = Color.WHITE
		elif hp_percent > 0.3:
			hp_label.modulate = Color.YELLOW
		else:
			hp_label.modulate = Color.RED
```

---

## Verify Restore

After restoring:
1. Open `scripts/ui/hud.gd`
2. Check that it has the original code (not test code)
3. Run Prototype_World (F6)
4. Should see "[HUD] Initialized" in Output (not test messages)

---

## Clean Up (Optional)

After restoring, you can delete:
- `scripts/ui/hud.gd.backup` (backup file)
- This guide file (RESTORE_HUD_AFTER_TEST.md)
