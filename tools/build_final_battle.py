#!/usr/bin/env python3
"""
build_final_battle.py
Builds the extended "FINAL BATTLE" level (Level 8 Extended) with extra platforming,
celestial void hazards, ruined shrines, and the 10,000 HP Primordial Void Emperor.
"""

import os

def build_final_battle():
    tscn = """[gd_scene load_steps=27 format=3]

[ext_resource type="Script" path="res://scripts/systems/level_controller.gd" id="1_ctrl"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/ultimate_void/ultimate_sky.png" id="2_sky"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/ultimate_void/singularity_spires.png" id="3_spires"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/ultimate_void/celestial_pillars.png" id="4_pillars"]
[ext_resource type="Texture2D" path="res://assets/tiles/platform_ultimate_160.png" id="5_p160"]
[ext_resource type="Texture2D" path="res://assets/tiles/platform_ultimate_80.png" id="6_p80"]
[ext_resource type="Texture2D" path="res://assets/tiles/spike_trap.png" id="7_spike"]
[ext_resource type="Texture2D" path="res://assets/tiles/boss_barrier.png" id="8_barr"]
[ext_resource type="PackedScene" path="res://scenes/player/player.tscn" id="9_player"]
[ext_resource type="PackedScene" path="res://scenes/objects/crystal.tscn" id="10_crys"]
[ext_resource type="PackedScene" path="res://scenes/objects/checkpoint.tscn" id="11_chk"]
[ext_resource type="PackedScene" path="res://scenes/objects/tutorial_sign.tscn" id="12_sign"]
[ext_resource type="PackedScene" path="res://scenes/objects/moving_platform.tscn" id="13_mplat"]
[ext_resource type="PackedScene" path="res://scenes/objects/spike_trap.tscn" id="14_spiketrap"]
[ext_resource type="PackedScene" path="res://scenes/objects/boss_trigger.tscn" id="15_btrig"]
[ext_resource type="PackedScene" path="res://scenes/enemies/shadow_monster.tscn" id="16_sm"]
[ext_resource type="PackedScene" path="res://scenes/enemies/flying_bat.tscn" id="17_bat"]
[ext_resource type="PackedScene" path="res://scenes/enemies/fire_demon.tscn" id="18_fdemon"]
[ext_resource type="PackedScene" path="res://scenes/enemies/boss_ultimate_overlord.tscn" id="19_boss"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="20_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/pause_menu.tscn" id="21_pmenu"]
[ext_resource type="PackedScene" path="res://scenes/ui/game_over_menu.tscn" id="22_gomenu"]
[ext_resource type="PackedScene" path="res://scenes/objects/ruined_shrine.tscn" id="23_shrine"]
[ext_resource type="PackedScene" path="res://scenes/objects/level_portal.tscn" id="24_port"]
[ext_resource type="PackedScene" path="res://scenes/objects/god_relic_shrine.tscn" id="25_godshrine"]
[ext_resource type="PackedScene" path="res://scenes/objects/secret_wall.tscn" id="26_secwall"]

[sub_resource type="RectangleShape2D" id="Shape_160"]
size = Vector2(160, 32)

[sub_resource type="RectangleShape2D" id="Shape_80"]
size = Vector2(80, 24)

[sub_resource type="RectangleShape2D" id="Shape_Barrier"]
size = Vector2(32, 280)

[node name="FinalBattle" type="Node2D"]
script = ExtResource("1_ctrl")
level_number = 8
music_track = "dark_dream"
death_y = 650.0

[node name="ParallaxBackground" type="ParallaxBackground" parent="."]

[node name="LayerSky" type="ParallaxLayer" parent="ParallaxBackground"]
motion_scale = Vector2(0, 0)
motion_mirroring = Vector2(960, 0)

[node name="Sprite2D" type="Sprite2D" parent="ParallaxBackground/LayerSky"]
texture = ExtResource("2_sky")
centered = false

[node name="LayerSpires" type="ParallaxLayer" parent="ParallaxBackground"]
motion_scale = Vector2(0.2, 0.05)
motion_mirroring = Vector2(960, 0)

[node name="Sprite2D" type="Sprite2D" parent="ParallaxBackground/LayerSpires"]
texture = ExtResource("3_spires")
centered = false

[node name="LayerPillars" type="ParallaxLayer" parent="ParallaxBackground"]
motion_scale = Vector2(0.6, 0.1)
motion_mirroring = Vector2(960, 0)

[node name="Sprite2D" type="Sprite2D" parent="ParallaxBackground/LayerPillars"]
texture = ExtResource("4_pillars")
centered = false

[node name="Platforms" type="Node2D" parent="."]

"""
    # Extended Ground platforms (160x32)
    # Start: 0 to 640
    # Zone 2: 960 to 1280
    # Zone 3 (Extended Celestial Bridge): 1560 to 1880
    # Zone 4 (Pre-Boss Sanctuary): 2160 to 2480
    # Boss Arena: 2680 to 3800
    ground_x = [
        # Zone 1
        0, 160, 320, 480, 640,
        # Zone 2
        960, 1120, 1280,
        # Zone 3 (Extended)
        1560, 1720, 1880,
        # Zone 4 (Extended Approach)
        2160, 2320, 2480,
        # Boss Arena (Giant 1200px Wide Arena)
        2680, 2840, 3000, 3160, 3320, 3480, 3640, 3800
    ]
    for i, gx in enumerate(ground_x):
        tscn += f"""[node name="Ground_{i}" type="StaticBody2D" parent="Platforms"]
position = Vector2({gx + 80}, 464)
collision_layer = 1
collision_mask = 6

[node name="Sprite2D" type="Sprite2D" parent="Platforms/Ground_{i}"]
texture = ExtResource("5_p160")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Platforms/Ground_{i}"]
shape = SubResource("Shape_160")

"""

    # Extended Floating platforms (80x24)
    floats = [
        # Zone 1 Ascent
        (420, 340), (560, 260), (740, 330), (860, 260),
        # Zone 2
        (1100, 330), (1260, 250), (1420, 320),
        # Secret Room Access & Platforms
        (1440, 230), (1600, 180), (1720, 180), (1840, 180),
        # Zone 3 Extended Floating Islands
        (1680, 340), (1840, 270), (2020, 320), (2100, 250),
        # Zone 4 High Spires
        (2280, 340), (2440, 260), (2580, 330),
        # Boss Arena Tactical Platforms (X=2700 to 3700)
        (2850, 340), (3050, 260), (3240, 200), (3430, 260), (3630, 340)
    ]
    for i, (fx, fy) in enumerate(floats):
        tscn += f"""[node name="Float_{i}" type="StaticBody2D" parent="Platforms"]
position = Vector2({fx}, {fy})
collision_layer = 1
collision_mask = 6

[node name="Sprite2D" type="Sprite2D" parent="Platforms/Float_{i}"]
texture = ExtResource("6_p80")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Platforms/Float_{i}"]
shape = SubResource("Shape_80")
one_way_collision = true

"""

    # Moving Platforms across gaps
    tscn += """[node name="MovingPlatform1" parent="." instance=ExtResource("13_mplat")]
position = Vector2(800, 390)
move_offset = Vector2(100, 0)
speed = 55.0

[node name="MovingPlatform2" parent="." instance=ExtResource("13_mplat")]
position = Vector2(1420, 390)
move_offset = Vector2(90, 0)
speed = 50.0

[node name="MovingPlatform3" parent="." instance=ExtResource("13_mplat")]
position = Vector2(2020, 410)
move_offset = Vector2(90, 0)
speed = 60.0

"""

    # Checkpoints across the extended journey
    tscn += """[node name="Checkpoint1" parent="." instance=ExtResource("11_chk")]
position = Vector2(960, 416)
checkpoint_id = 1

[node name="Checkpoint2" parent="." instance=ExtResource("11_chk")]
position = Vector2(1720, 416)
checkpoint_id = 2

[node name="Checkpoint3" parent="." instance=ExtResource("11_chk")]
position = Vector2(2480, 416)
checkpoint_id = 3

"""

    # Ruined Shrines: HP & Damage boosts
    tscn += """[node name="RuinedShrine1" parent="." instance=ExtResource("23_shrine")]
position = Vector2(560, 226)
stat_buff = "hp"

[node name="RuinedShrine2" parent="." instance=ExtResource("23_shrine")]
position = Vector2(1260, 216)
stat_buff = "damage"

[node name="RuinedShrine3" parent="." instance=ExtResource("23_shrine")]
position = Vector2(2100, 216)
stat_buff = "hp"

"""

    # Secret Room: Cracked Secret Wall + God Relic Shrine
    tscn += """[node name="SecretRoom" type="Node2D" parent="."]

[node name="SecretWall" parent="SecretRoom" instance=ExtResource("26_secwall")]
position = Vector2(1520, 180)

[node name="GodRelicShrine" parent="SecretRoom" instance=ExtResource("25_godshrine")]
position = Vector2(1720, 140)

"""

    # Signs
    signs = [
        (140, 420, "⚔️ FINAL BATTLE: THE PRIMORDIAL VOID EMPEROR ⚔️\\nThe Ultimate Void Sovereign Malakor awaits ahead with 10,000 HP!"),
        (980, 420, "TIP: Cast Fireball [J] and Freeze [K]! Ricochet your shots off platforms for massive damage multipliers!"),
        (1620, 140, "✦ ANCIENT ASTRAL SANCTUM (SECRET ROOM) ✦\\nAwaken the God Relic Shrine! Bestows +1,500 HP, +500 MP, and +60% Spell Damage!"),
        (1800, 420, "ADVANCE: Traverse the Celestial Void Bridge! Watch out for floating bats and demonic fire!"),
        (2500, 420, "⚠️ CAUTION: BEYOND THIS GATE LIES THE 4-PHASE APOCALYPSE! PREPARE FOR THE FINAL BATTLE!")
    ]
    for i, (sx, sy, msg) in enumerate(signs):
        tscn += f"""[node name="Sign_{i}" parent="." instance=ExtResource("12_sign")]
position = Vector2({sx}, {sy})
message = "{msg}"

"""

    # Crystals
    crys = [
        (220, 410), (360, 350), (560, 210), (740, 290), (860, 220),
        (1100, 290), (1260, 200), (1420, 270), (1640, 410),
        # Secret room
        (1680, 100), (1720, 80), (1760, 100),
        # Zone 3 & 4
        (1680, 300), (1840, 230), (2020, 280), (2100, 190), (2280, 300), (2440, 220),
        # Boss Arena
        (2850, 300), (3050, 220), (3240, 160), (3430, 220), (3630, 300)
    ]
    for i, (cx, cy) in enumerate(crys):
        tscn += f"""[node name="Crystal_{i}" parent="." instance=ExtResource("10_crys")]
position = Vector2({cx}, {cy})

"""

    # Enemies along the journey
    tscn += """[node name="Enemies" type="Node2D" parent="."]

[node name="FireDemon1" parent="Enemies" instance=ExtResource("18_fdemon")]
position = Vector2(440, 420)

[node name="FlyingBat1" parent="Enemies" instance=ExtResource("17_bat")]
position = Vector2(660, 240)

[node name="ShadowMonster1" parent="Enemies" instance=ExtResource("16_sm")]
position = Vector2(1180, 420)

[node name="FlyingBat2" parent="Enemies" instance=ExtResource("17_bat")]
position = Vector2(1780, 240)

[node name="FireDemon2" parent="Enemies" instance=ExtResource("18_fdemon")]
position = Vector2(2340, 420)

"""

    # Boss Arena (X = 2600 to 3800)
    tscn += """[node name="BossArena" type="Node2D" parent="."]

[node name="BossTrigger" parent="BossArena" instance=ExtResource("15_btrig")]
position = Vector2(2580, 360)
boss_node = NodePath("../BossUltimateOverlord")

[node name="BarrierLeft" type="StaticBody2D" parent="BossArena"]
position = Vector2(2640, 340)
collision_layer = 1
collision_mask = 6

[node name="Sprite2D" type="Sprite2D" parent="BossArena/BarrierLeft"]
texture = ExtResource("8_barr")

[node name="CollisionShape2D" type="CollisionShape2D" parent="BossArena/BarrierLeft"]
shape = SubResource("Shape_Barrier")

[node name="BarrierRight" type="StaticBody2D" parent="BossArena"]
position = Vector2(3820, 340)
collision_layer = 1
collision_mask = 6

[node name="Sprite2D" type="Sprite2D" parent="BossArena/BarrierRight"]
texture = ExtResource("8_barr")

[node name="CollisionShape2D" type="CollisionShape2D" parent="BossArena/BarrierRight"]
shape = SubResource("Shape_Barrier")

[node name="BossUltimateOverlord" parent="BossArena" instance=ExtResource("19_boss")]
position = Vector2(3240, 400)
arena_bounds_min_x = 2660.0
arena_bounds_max_x = 3800.0
ground_y = 448.0

[node name="LevelPortal" parent="BossArena" instance=ExtResource("24_port")]
position = Vector2(3760, 436)

"""

    # Player & UI
    tscn += """[node name="Player" parent="." instance=ExtResource("9_player")]
position = Vector2(60, 410)

[node name="HUD" parent="." instance=ExtResource("20_hud")]

[node name="PauseMenu" parent="." instance=ExtResource("21_pmenu")]

[node name="GameOverMenu" parent="." instance=ExtResource("22_gomenu")]
"""
    # Write to final_battle.tscn AND level_8.tscn
    with open("scenes/levels/final_battle.tscn", "w") as f:
        f.write(tscn)
    with open("scenes/levels/level_8.tscn", "w") as f:
        f.write(tscn)
    print("Built scenes/levels/final_battle.tscn and level_8.tscn successfully!")

if __name__ == "__main__":
    build_final_battle()
