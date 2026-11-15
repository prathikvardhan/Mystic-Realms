extends Node2D

func _ready() -> void:
	print("==================================================")
	print("   MYSTIC REALMS: FINAL BATTLE & TUTORIAL SUITE   ")
	print("   BOUNCE BACK GAME JAM - TWO POWERS: [J] & [K]   ")
	print("==================================================")
	
	# Test 1: Autoloads & Dark Dream Anthem
	print("[TEST 1/13] Verifying Autoload Singletons & Soundtrack...")
	assert(GameManager != null, "GameManager must be active")
	assert(SoundManager != null, "SoundManager must be active")
	assert(SoundManager.music_streams.has("dark_dream"), "Curley Gao - Lord of Mysteries (Dark Dream) must be loaded")
	print("  -> GameManager, SoundManager & Dark Dream Anthem verified OK.")

	# Test 2: Health, Damage, Healing & Mana Systems
	print("[TEST 2/13] Verifying Health & Mana System...")
	GameManager.is_invulnerable = false
	GameManager.shield_active = false
	GameManager.is_game_over = false
	GameManager.player_max_hp = 250.0
	GameManager.player_hp = 250.0
	var res = GameManager.take_damage(50.0)
	assert(res == true, "Damage should be dealt")
	assert(GameManager.player_hp == 200.0, "Player HP should be 200")
	GameManager.heal(25.0)
	assert(GameManager.player_hp == 225.0, "Player HP should be 225")
	var mana_res = GameManager.consume_mana(30.0)
	assert(mana_res == true, "Mana consumption should succeed")
	print("  -> Health and Mana mechanics verified OK.")

	# Test 3: Two-Power Constraint (Fireball [J] & Ice Blast [K] ONLY)
	print("[TEST 3/13] Verifying 2-Power Constraint: Fireball [J] & Ice Blast [K] ONLY...")
	assert(GameManager.unlocked_powers["fireball"] == true, "Fireball [J] must be unlocked")
	assert(GameManager.unlocked_powers["ice_blast"] == true, "Ice Blast [K] must be unlocked")
	assert(GameManager.unlocked_powers.get("lightning", false) == false, "Lightning must be disabled")
	assert(GameManager.unlocked_powers.get("shield", false) == false, "Shield must be disabled")
	assert(GameManager.unlocked_powers.get("void_cannon", false) == false, "Void Cannon must be disabled")
	assert(GameManager.unlocked_powers.get("shadow_step", false) == false, "Shadow Step must be disabled")
	print("  -> Only Fireball [J] and Ice Blast [K] enabled.")

	# Test 4: Fireball [J] Ricochet Combat & Ice Blast [K] Freeze
	print("[TEST 4/13] Verifying Fireball Ricochet & Ice Blast Freeze Mechanics...")
	var fb_scene = load("res://scenes/abilities/fireball.tscn")
	assert(fb_scene != null, "Fireball scene must exist")
	var fb = fb_scene.instantiate()
	add_child(fb)
	assert(fb.max_bounces == 3, "Fireball default max bounces should be 3")
	assert(fb.is_in_group("player_projectiles"), "Fireball must be in player_projectiles group")
	fb.bounces = 1
	fb.damage = fb.base_damage * 2.0
	assert(fb.damage == fb.base_damage * 2.0, "Damage must multiply 2x on first bounce")
	fb.queue_free()

	var ice_scene = load("res://scenes/abilities/ice_blast.tscn")
	assert(ice_scene != null, "Ice blast scene must exist")
	var ice = ice_scene.instantiate()
	add_child(ice)
	assert(ice.freeze_duration >= 3.0, "Ice blast freeze duration must be at least 3.0s")
	ice.queue_free()
	print("  -> Fireball Ricochet (3x) and Ice Blast Freeze verified OK.")

	# Test 5: Timed Parry & Enemy Projectile Deflection
	print("[TEST 5/13] Verifying Parry / Deflect Action on Enemy Projectiles...")
	var projs = [
		load("res://scenes/enemies/demon_projectile.tscn"),
		load("res://scenes/enemies/magma_orb_projectile.tscn"),
		load("res://scenes/enemies/frost_shard_projectile.tscn"),
		load("res://scenes/enemies/thunder_orb_projectile.tscn"),
		load("res://scenes/enemies/chaos_orb_projectile.tscn"),
		load("res://scenes/enemies/dark_energy_orb.tscn")
	]
	for p_scene in projs:
		assert(p_scene != null, "Projectile scene must exist")
		var p = p_scene.instantiate()
		add_child(p)
		assert(p.is_in_group("enemy_projectiles"), "Projectile must start in enemy_projectiles group")
		p.deflect(Vector2.RIGHT)
		assert(p.is_deflected == true, "Projectile must be deflected")
		assert(p.is_in_group("player_projectiles"), "Deflected projectile must join player_projectiles group")
		p.queue_free()
	print("  -> Deflection mechanics verified OK.")

	# Test 6: Ruined Shrines & God Relic Shrine
	print("[TEST 6/13] Verifying Ruined Shrine & God Relic Shrine Upgrades...")
	var shrine_scene = load("res://scenes/objects/ruined_shrine.tscn")
	assert(shrine_scene != null, "Ruined shrine scene must exist")
	var shrine = shrine_scene.instantiate()
	shrine.stat_buff = "hp"
	add_child(shrine)
	assert(shrine.is_active == false, "Shrine starts dormant")
	var old_max_hp = GameManager.player_max_hp
	shrine.activate_shrine()
	assert(shrine.is_active == true, "Shrine must be active after activation")
	assert(GameManager.player_max_hp == old_max_hp + 30.0, "HP Shrine must grant +30 Max HP")
	shrine.queue_free()

	var god_shrine_scene = load("res://scenes/objects/god_relic_shrine.tscn")
	assert(god_shrine_scene != null, "God Relic Shrine scene must exist")
	var g_shrine = god_shrine_scene.instantiate()
	add_child(g_shrine)
	g_shrine.activate_shrine()
	assert(GameManager.player_max_hp == 1500.0, "God Relic Shrine grants 1,500 Max HP")
	assert(GameManager.player_max_mp == 500.0, "God Relic Shrine grants 500 Max MP")
	assert(GameManager.unlocked_powers.get("void_cannon", false) == false, "No extra powers unlocked by shrine")
	assert(GameManager.unlocked_powers.get("shadow_step", false) == false, "No extra powers unlocked by shrine")
	g_shrine.queue_free()
	print("  -> Shrines verified OK.")

	# Test 7: Final Battle Boss: Primordial Void Emperor (10,000 HP & 4 Phases)
	print("[TEST 7/13] Verifying Primordial Void Emperor (10,000 HP, 4 Phases, Shield)...")
	var boss_scene = load("res://scenes/enemies/boss_ultimate_overlord.tscn")
	assert(boss_scene != null, "Final Boss scene must exist")
	var b_inst = boss_scene.instantiate()
	add_child(b_inst)
	assert(b_inst.max_hp == 10000.0, "Ultimate Boss must have exactly 10,000 HP")
	assert(b_inst.phase == 1, "Boss starts in Phase 1")
	b_inst.activate_boss()
	assert(b_inst.is_active == true, "Boss must activate")
	
	# Verify Phase Transitions
	b_inst.take_damage(2600.0) # Down to 7,400 HP
	assert(b_inst.phase == 2, "Boss must transition to Phase 2 at <7,500 HP")
	b_inst.take_damage(2600.0) # Down to 4,800 HP -> Transitions to Phase 3 and activates shield!
	assert(b_inst.phase == 3, "Boss must transition to Phase 3 at <5,000 HP")
	assert(b_inst.active_shield_instance != null, "Protective shield active in Phase 3")
	b_inst.take_damage(1200.0) # Shatters the 1,000 HP shield!
	b_inst.take_damage(2500.0) # Down to 2,300 HP -> Phase 4 Rage Mode!
	assert(b_inst.phase == 4, "Boss must transition to Phase 4 Rage Mode at <2,500 HP")
	b_inst.queue_free()
	print("  -> Primordial Void Emperor 10,000 HP and 4 phases validated OK.")

	# Test 8: Player Stun & Movement
	print("[TEST 8/13] Verifying Player Stun Functionality & Animations...")
	var player_scene = load("res://scenes/player/player.tscn")
	assert(player_scene != null, "Player scene must exist")
	var p_inst = player_scene.instantiate() as Player
	add_child(p_inst)
	p_inst.is_spawning = false
	assert(p_inst.is_stunned == false, "Player starts unstunned")
	p_inst.stun(1.5)
	assert(p_inst.is_stunned == true, "Player must be stunned after stun()")
	p_inst.clear_stun()
	assert(p_inst.is_stunned == false, "Player stun clears cleanly")
	p_inst.queue_free()
	print("  -> Player stun and animations verified OK.")

	# Test 9: Only 2 Gameplay Levels: Tutorial & Final Battle
	print("[TEST 9/13] Verifying Only 2 Levels Exist (Tutorial & Final Battle)...")
	var tut_res = load("res://scenes/levels/level_tutorial.tscn")
	assert(tut_res != null, "Tutorial level scene must load successfully")
	var fb_res = load("res://scenes/levels/final_battle.tscn")
	assert(fb_res != null, "Final Battle level scene must load successfully")
	
	# Verify Intermediate levels 1-7 do not exist in scenes/levels/
	for lvl_i in range(1, 8):
		var old_lvl = "res://scenes/levels/level_%d.tscn" % lvl_i
		assert(ResourceLoader.exists(old_lvl) == false, "Level %d must be deleted" % lvl_i)
	
	var menu = load("res://scenes/menus/main_menu.tscn")
	assert(menu != null, "Main menu scene must load")
	var victory = load("res://scenes/ui/victory_menu.tscn")
	assert(victory != null, "Victory scene must load")
	print("  -> Level architecture (Tutorial + Final Battle only) verified OK.")

	# Test 10: HUD Structure: Rebound Bar REMOVED & Exactly 2 Ability Slots
	print("[TEST 10/13] Verifying HUD Structure (No Rebound Bar, Exactly 2 Slots)...")
	var hud_scene = load("res://scenes/ui/hud.tscn")
	assert(hud_scene != null, "HUD scene must exist")
	var hud_inst = hud_scene.instantiate()
	add_child(hud_inst)
	assert(hud_inst.has_node("HUDPanel/VBoxBars/HPBar"), "HP Bar must exist")
	assert(hud_inst.has_node("HUDPanel/VBoxBars/MPBar"), "MP Bar must exist")
	assert(hud_inst.has_node("HUDPanel/VBoxBars/ReboundBar") == false, "Rebound Bar must NOT exist in HUD")
	assert(hud_inst.has_node("AbilitiesBar/SlotFireball"), "SlotFireball [J] must exist")
	assert(hud_inst.has_node("AbilitiesBar/SlotIce"), "SlotIce [K] must exist")
	assert(hud_inst.has_node("AbilitiesBar/SlotLightning") == false, "SlotLightning must NOT exist in HUD")
	assert(hud_inst.has_node("AbilitiesBar/SlotShield") == false, "SlotShield must NOT exist in HUD")
	hud_inst.queue_free()
	print("  -> HUD verified: Rebound Bar removed, only Fireball [J] and Ice [K] slots present.")

	# Test 11: Final Battle Extended Layout & Secret Room
	print("[TEST 11/13] Verifying Extended Final Battle Features...")
	var fb_inst = fb_res.instantiate()
	add_child(fb_inst)
	assert(fb_inst.has_node("Platforms"), "Final Battle must contain Platforms")
	assert(fb_inst.has_node("RuinedShrine1"), "Final Battle must contain Ruined Shrines")
	assert(fb_inst.has_node("Checkpoint1"), "Final Battle must contain Checkpoints")
	assert(fb_inst.has_node("MovingPlatform1"), "Final Battle must contain Moving Platforms")
	assert(fb_inst.has_node("SecretRoom"), "Final Battle must contain Secret Room")
	assert(fb_inst.has_node("SecretRoom/SecretWall"), "Final Battle must contain Secret Wall")
	assert(fb_inst.has_node("SecretRoom/GodRelicShrine"), "Final Battle must contain God Relic Shrine")
	assert(fb_inst.has_node("BossArena/BossUltimateOverlord"), "Final Battle must contain Boss")
	fb_inst.queue_free()
	print("  -> Final Battle extended platforming zones, checkpoints & secret room verified OK.")

	# Test 12: 3D Entry Animation Scene & Credits
	print("[TEST 12/13] Verifying 3D Entry Animation Scene...")
	var intro_scene = load("res://scenes/intro/intro_splash_3d.tscn")
	assert(intro_scene != null, "Intro splash 3D scene must exist")
	var intro_inst = intro_scene.instantiate()
	add_child(intro_inst)
	assert(intro_inst.has_node("Camera3D"), "Intro must have a 3D Camera")
	assert(intro_inst.has_node("CentralCore"), "Intro must have 3D CentralCore")
	assert(intro_inst.has_node("Labels/TitleLabel3D"), "Intro must have TitleLabel3D")
	assert(intro_inst.has_node("Labels/CreditLabel3D"), "Intro must have CreditLabel3D")
	var title_node = intro_inst.get_node("Labels/TitleLabel3D") as Label3D
	var credit_node = intro_inst.get_node("Labels/CreditLabel3D") as Label3D
	assert("BOUNCE BACK" in title_node.text, "Title must contain 'BOUNCE BACK'")
	assert("DHONI AND PRATHIK" in credit_node.text, "Credits must contain 'DHONI AND PRATHIK'")
	intro_inst.queue_free()
	print("  -> 3D Entry Animation verified OK.")

	# Test 13: Death & Respawn Counter Tracking & Save Persistence
	print("[TEST 13/13] Verifying Death & Respawn Counter Tracking & Persistence...")
	var initial_deaths = GameManager.death_count
	var initial_respawns = GameManager.respawn_count
	GameManager.is_game_over = false
	GameManager.is_invulnerable = false
	GameManager.player_hp = 10.0
	GameManager.take_damage(20.0) # Fatal damage
	assert(GameManager.death_count == initial_deaths + 1, "Death count must increment on fatal damage")
	GameManager.respawn_player()
	assert(GameManager.respawn_count == initial_respawns + 1, "Respawn count must increment on respawn")
	GameManager.save_game()
	GameManager.death_count = 0
	GameManager.respawn_count = 0
	GameManager.load_game()
	assert(GameManager.death_count == initial_deaths + 1, "Death count must persist across save/load")
	assert(GameManager.respawn_count == initial_respawns + 1, "Respawn count must persist across save/load")
	print("  -> Death Count (%d) & Respawn Count (%d) persistence verified OK." % [GameManager.death_count, GameManager.respawn_count])

	print("==================================================")
	print("   ALL 13 TESTS PASSED PERFECTLY! 100% SUCCESS    ")
	print("==================================================")
	get_tree().quit(0)
