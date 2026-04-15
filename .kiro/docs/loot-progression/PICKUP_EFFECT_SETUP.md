# Pickup Effect Scene Setup Instructions

## Overview

The pickup effect is a simple particle effect that plays when an item is collected. This provides visual feedback to the player.

## Scene Structure

```
PickupEffect (Node2D)
├── CPUParticles2D
└── Timer (for auto-cleanup)
```

## Step-by-Step Setup

### 1. Create New Scene

1. In Godot Editor, click **Scene → New Scene**
2. Select **Other Node** and choose **Node2D**
3. Rename root node to `PickupEffect`

### 2. Add CPUParticles2D

1. Right-click `PickupEffect` → **Add Child Node**
2. Search for `CPUParticles2D` and add it
3. In **Inspector → Emission Shape**:
   - **Shape**: Sphere
   - **Sphere Radius**: `16`

4. In **Inspector → Particle Properties**:
   - **Amount**: `20`
   - **Lifetime**: `0.5`
   - **One Shot**: Check this box
   - **Explosiveness**: `1.0`
   - **Emitting**: Uncheck (will be triggered by script)

5. In **Inspector → Direction**:
   - **Direction**: `(0, -1)` (upward)
   - **Spread**: `45` degrees

6. In **Inspector → Gravity**:
   - **Gravity**: `(0, 200)` (downward)

7. In **Inspector → Initial Velocity**:
   - **Velocity Min**: `50`
   - **Velocity Max**: `100`

8. In **Inspector → Scale**:
   - **Scale Amount Min**: `0.5`
   - **Scale Amount Max**: `1.5`

9. In **Inspector → Color**:
   - **Color**: `#FFFF00` (yellow/gold for pickup)
   - **Color Ramp**: Optional gradient from yellow to transparent

### 3. Add Timer for Auto-Cleanup

1. Right-click `PickupEffect` → **Add Child Node** → **Timer**
2. In **Inspector**:
   - **Wait Time**: `1.0` second
   - **One Shot**: Check this box
   - **Autostart**: Check this box

### 4. Add Script

1. Select root `PickupEffect` node
2. Click **Attach Script** button
3. Save as: `res://scripts/effects/pickup_effect.gd`
4. Add this code:

```gdscript
# pickup_effect.gd
extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	# Start particle emission
	if particles:
		particles.emitting = true
	
	# Connect timer to cleanup
	if timer:
		timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	queue_free()
```

### 5. Save Scene

1. Press **Ctrl+S**
2. Save as: `res://scenes/effects/pickup_effect.tscn`

## Register with EffectManager

### Update EffectManager

1. Open `scripts/effects/effect_manager.gd`
2. Add pickup_effect to the effects dictionary:

```gdscript
const EFFECTS = {
	"hit_effect": preload("res://scenes/effects/HitEffect.tscn"),
	"pickup_effect": preload("res://scenes/effects/pickup_effect.tscn")
}
```

3. The EffectManager should already have a method to spawn effects via EventBus

## Testing

### Test in Isolation

1. Open `pickup_effect.tscn`
2. Click **Play Scene** (F6)
3. Should see particles burst upward and fade out
4. Scene should auto-delete after 1 second

### Test with Pickup

1. Open `Prototype_World.tscn`
2. Add a PickupItem instance
3. Run scene (F5)
4. Pick up the item
5. Should see yellow particles burst at pickup location

## Verification Checklist

- [ ] CPUParticles2D configured with burst emission
- [ ] Particles emit upward with gravity pulling down
- [ ] Timer set to 1 second, one-shot, autostart
- [ ] Script attached and particles emit on _ready()
- [ ] Scene auto-deletes after timer timeout
- [ ] Effect registered in EffectManager
- [ ] EventBus.spawn_effect signal works

## Customization

### Change Particle Color

Edit **Color** property in CPUParticles2D to match item rarity:
- Common items: White `#FFFFFF`
- Uncommon items: Green `#00FF00`
- Rare items: Blue `#0000FF`
- Epic items: Purple `#9B59B6`

### Add Sound Effect

1. Add **AudioStreamPlayer** node to PickupEffect
2. Set **Stream** to pickup sound file
3. Set **Autoplay**: Check
4. Adjust **Volume Db** as needed

## Common Issues

### Issue: Particles don't show
**Solution**: Check that "Emitting" is checked in script, and "One Shot" is enabled

### Issue: Effect doesn't disappear
**Solution**: Check that Timer is connected to queue_free() in script

### Issue: Effect spawns at wrong position
**Solution**: Check that global_position is set correctly when spawning via EffectManager

## Next Steps

After creating pickup effect:
1. Test with different item types
2. Add sound effect (optional)
3. Integrate with full loot flow
4. Test performance with many pickups

---

**Status**: Pickup effect setup instructions complete  
**Next**: Wire all systems together and test full loot flow

