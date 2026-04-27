// FILE: init.gsc
    /*
        Welcome to Prop Hunt!
            by akaTrxgic

        /////////////////////////////////////////////////////////////////////////////
        |                                                                           |
        |   Credits:                                                                |                                               |
        |   * Prop Names from FreeTheTech 101                                       |
        |       https://github.com/FreeTheTech101/IW4-Dump-Files/blob/master        |
        |   * xhju for help w/ autoassign, rotate binds, and decoy destroying       |
        |   * Huge shout out to Snowman and offhost_cfw for helping with testing    |
        |                                                                           |                  
        /////////////////////////////////////////////////////////////////////////////
    */

    init()
    {
        level.strings = [];
        level.currentGametype      = getDvar("g_gametype");
        level.currentMapName       = getDvar("mapName");
        level.callbackPlayerDamage = ::modifyPlayerDamage;
        level.callbackPlayerKilled = ::modifyPlayerKilled;
        level.gameTweaks["graceperiod"].value = 0.5;

        setDvar("scr_sd_winlimit", 4); //change if you want more rounds (sets round win limit)
        setDvar("scr_sd_timelimit", 6); //change if you want longer rounds (sets round time limit)
        setDvar("scr_sd_roundswitch", 2); //change if you want more rounds as props
        setDvar("teamProps", self.team);
        setDvar("teamHunters", self.team);
        setDvar("scr_game_graceperiod", .5);
        setDvar("ui_allow_classchange", 0);
        setDvar("ui_allow_teamchange", 0);
        setDvar( "scr_player_healthregentime", 1337 );
        setDvar("g_hardcore", 1);
        setDvar("didyouknow", "^2Prop ^1Hunt");

        precacheshader("gradient_center");
        modelPrecache();
        level thread TimerStart();
        level thread forceAutoAssign();
        level thread customGameTimer();
        level thread disablePlayerCollisions();
        level thread onPlayerConnect();
    }

    onPlayerConnect()
    {
        for(;;)
        {
            level waittill("connected",player);

            player SetClientDvar("motd", "Welcome to ^2Prop ^1Hunt^7! ^7|| Made By: ^1akaTrxgic");

            player thread doTeamCheck();
            player thread checkGameSettings();
            player thread doTeamNames();
            player thread onPlayerSpawned();
        }
    }

    forceAutoAssign()
    {
        level endon("game_ended");
        for(;;)
        {
            level waittill("connecting", player);
            player thread autoAssign();
        }
    }

    autoAssign()
    {
        self endon("disconnect");
    
        while(!isDefined(self.pers["team"]))
            wait 0.05;

        wait 0.1; 
        self closeMenu();
        self closeInGameMenu();
        self notify("menuresponse", game["menu_team"], "autoassign");
        wait 0.5;
        self notify("menuresponse", game["menu_changeclass"], "class1");
    }

    doTeamCheck()
    {
        self endon("disconnect");

        for(;;)
        {
            self waittill("spawned_player");

            if( level.supportedMap && level.supportedMode )
            {
                if(self.pers["team"] == game["defenders"])
                {
                    setDvar("teamProps", self.team);
                    self thread teamSetup("props");
                    
                    if( !isDefined( level.propsAliveCount ))
                        level.propsAliveCount = 1;
                    
                    else
                        level.propsAliveCount++;
                }
                else if(self.pers["team"] == game["attackers"])
                {
                    self thread teamSetup("hunters");
                    setDvar("teamHunters", self.team);
                }
            }
        }
    }

    onPlayerSpawned()
    {
        self endon("disconnect");
        level endon("game_ended");

        for(;;)
        {
            self waittill("spawned_player");
            self disableusability();
        }
    }

    doTeamNames()
    {
        self endon("disconnect");

        for(;;)
        {
            self waittill("spawned_player");

            if(self.pers["team"] == game["attackers"])
            {
                if (self.sessionteam == "allies")
                {
                    setDvar("g_TeamName_Allies", "^1Hunters");
                    setDvar("g_TeamName_Axis", "^2Props");
                }
                else if (self.sessionteam == "axis")
                {
                    setDvar("g_TeamName_Allies", "^2Props");
                    setDvar("g_TeamName_Axis", "^1Hunters");
                }
            }
            else if(self.pers["team"] == game["defenders"])
            {
                if (self.sessionteam == "allies")
                {
                    setDvar("g_TeamName_Allies", "^2Props");
                    setDvar("g_TeamName_Axis", "^1Hunters");
                }
                else if (self.sessionteam == "axis")
                {
                    setDvar("g_TeamName_Allies", "^1Hunters");
                    setDvar("g_TeamName_Axis", "^2Props");
                }
            }
            wait 3;
        }
    }

    checkGameSettings()
    {
        if( level.currentGametype != "sd" )
        {
            level.supportedMode = 0;
            iprintlnbold("^1CURRENT MODE NOT SUPPORTED");
            wait 3;
            iprintlnbold("^1EXITING LEVEL...");
            wait 3;
            level thread maps\mp\gametypes\_gamelogic::forceEnd();
        }
        else
        {
            level.supportedMode = 1;

            if(level.currentMapName == "mp_rust" || level.currentMapName == "mp_brecourt")
            {
                level.supportedMap = 0;
                iprintlnbold("^1CURRENT MAP NOT SUPPORTED");
                wait 3;
                iprintlnbold("^1EXITING LEVEL...");
                wait 3;
                level thread maps\mp\gametypes\_gamelogic::forceEnd();
            }
            else
                level.supportedMap = 1;
        }
    }

    teamSetup(team)
    {
        self thread drawHealthVal();

        if(team == "props")
        {
            self takeAllWeapons();
            self freezecontrols(false);
            self setClientDvar("cg_thirdperson", 1);
            self setClientDvar("cg_thirdPersonRange", 160);
            self VisionSetNakedForPlayer(level.currentMapName);
            self.allowedChanges = 4;
            self.allowedStuns = 2;
            self.allowedDecoys = 3;
            self takeAllWeapons();
            self thread propSystem();
            self thread propDeathCheck();
            self thread spinLeftBind();
            self thread spinRightBind();
            self thread freezeBind();
            self thread spawnDecoyBind();
            self thread nearPropNotif();
            self thread stunBind();
            self thread propBindInst();
            self takeAllWeapons();
            self thread maps\mp\gametypes\_hud_message::hintMessage("Welcome to ^2Prop ^1Hunt^7!");
            wait 1;
            self thread maps\mp\gametypes\_hud_message::hintMessage("You're a ^2Prop^7!");      
            self clearPerks();
            self setperk("specialty_quieter");
            self setperk("specialty_coldblooded");
            self setperk("specialty_lightweight");
            self SetClientDvar( "scr_player_maxhealth", 100);
            level waittill("huntersReleased");
            level notify("preTimerDone");
            level.TimerText setText("");
            self takeAllWeapons();
        }
        else if(team == "hunters")
        {
            self.hunterUAVDone = undefined;
            self VisionSetNakedForPlayer("blacktest", 0.5);
            self freezeControls(true);
            self thread lastPropPing();
            self thread maps\mp\gametypes\_hud_message::hintMessage("Welcome to ^2Prop ^1Hunt^7!");
            wait 1;
            self thread maps\mp\gametypes\_hud_message::hintMessage("You're a ^1Hunter^7!");
            self clearPerks();
            level waittill("huntersReleased");
            level notify("preTimerDone");
            level.TimerText setText("");
            self VisionSetNakedForPlayer(level.currentMapName, 2);
            self takeAllWeapons();
            self doHunterLoadout();
            self freezeControls(false);
        }
    }

    propDeathCheck()
    {
        self waittill_any("death", "disconnect", "joined_spectators");
        
        level.propsAliveCount--;
    }

    modifyPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
    {        
        if(sMeansOfDeath == "MOD_FALLING")
            iDamage = 0;

        [[level.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
    }

    modifyPlayerKilled( eInflictor, eattacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
    {
        if(self.team == getDvar("teamProps") && isDefined(self.propModel))
            self.propModel delete();

        [[level.callbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
    }

    TimerStart()
    {
        self endon("disconnect");
        level endon("preTimerDone");

        level.TimerText = level createServerFontString("objective", 1.5);
        level.TimerText setPoint("CENTER", "CENTER", 0, -60, 0);

        for(;;)
        {
            level.Timer = 45;
            while(level.Timer > 0)
            {
                level.TimerText setText("^1Hunters ^7released in: ^2" + level.Timer);
                wait 1;
                level.Timer--;
            }
            level notify("huntersReleased");
            level.TimerText setText("^1Hunters ^7Released!");
            wait 2;
        }
    }

    updateCustomTimer()
    {
        level endon("game_ended");
        
        while(1)
        {
            timeLeft = getTimeRemaining() / 1000;

            if (timeLeft > 0 && timeLeft != level.customTimer.timeRemaining)
                level.customTimer setTimer(timeLeft);

            wait 1;
        }
    }

    customGameTimer()
    {
        level endon("game_ended");
        
        level.customTimer = level createservertimer("hudbig", 1);
        level.customTimer setPoint("CENTER", "CENTER", 0, -215);

        initialTime = int( (getTimeRemaining() / 1000.0) - 1 );
        level.customTimer setTimer(initialTime);
        
        level thread watchGameEnd(level.customTimer);
    }

    watchGameEnd(hud)
    {
        level waittill("game_ended");

        if (isDefined(hud))
            hud destroy();
    }

    getTimePassed()
    {
        if ( !isDefined( level.startTime ) )
            return 0;

        if ( level.timerStopped )
            return (level.timerPauseTime - level.startTime) - level.discardTime;
        else
            return (getTime() - level.startTime) - level.discardTime;
    }

    getTimeRemaining()
    {
        return (getTimeLimit() * 60 * 1000) - getTimePassed();
    }

    getTimeLimit()
    {
        gametype = toLower( getDvar( "g_gametype" ) );
        return getDvarFloat( "scr_" + gametype + "_timelimit" );
    }

    disablePlayerCollisions()
    {   
        WriteByte( "0x821D29A0", 0x60);
        WriteByte( "0x821D29A1", 0x00);
        WriteByte( "0x821D29A2", 0x00);
        WriteByte( "0x821D29A3", 0x00);

        WriteByte( "0x8225FB04", 0x60);
        WriteByte( "0x8225FB05", 0x00);
        WriteByte( "0x8225FB06", 0x00);
        WriteByte( "0x8225FB07", 0x00);
    }

    drawHealthVal()
    {
        self endon("disconnect");
        self endon("death");

        hpLabel = newClientHudElem(self);
        hpLabel.horzAlign = "left";
        hpLabel.vertAlign = "bottom";
        hpLabel.alignX = "left";
        hpLabel.alignY = "bottom";
        hpLabel.x = -15;
        hpLabel.y = -25;
        hpLabel.fontScale = 0.5;
        hpLabel.color = (1, 1, 0);
        hpLabel.alpha = 1.0;
        hpLabel.font = "bigfixed";
        hpLabel setText("HEALTH");

        hpText = newClientHudElem(self);
        hpText.horzAlign = "left";
        hpText.vertAlign = "bottom";
        hpText.alignX = "left";
        hpText.alignY = "bottom";
        hpText.x = 40;
        hpText.y = -20;
        hpText.fontScale = 1.4;
        hpText.color = (1, 1, 0);
        hpText.alpha = 1.0;
        hpText.font = "bigfixed";
        hpText setValue(self.health);
        
        for(;;)
        {
            wait 0.05;

            hp = self.health;
            if(hp < 0) hp = 0;

            hpText setValue(hp);

            if(hp <= 25)
            {
                hpLabel.color = (1, 0, 0);
                hpText.color = (1, 0, 0);
            }
            else
            {
                hpLabel.color = (1, 1, 0);
                hpText.color = (1, 1, 0);
            }
        }
    }

    setProp(prop)
    {
        if(prop != self.propModelName)
        {
            if (self.allowedChanges <= 0)
            {
                if (!self.noChangesNotif)
                {
                    self iprintln("^1No Prop Changes Left!");
                    self.noChangesNotif = 1;
                }
                return;
            }

            self hide();

            if (isDefined(self.propModel))
                self.propModel delete();

            self.allowedChanges--;
            self iprintln("Changes Remaining: ^1" + self.allowedChanges);

            self.propModelName = prop;

            self.propModel = spawnScriptModel(self.origin, prop, self.angles);

            self thread linkPropToPlayer();
        }
    }

    linkPropToPlayer() 
    { 
        self endon("disconnect"); 
        self endon("death"); 
        
        while(isDefined(self.propModel)) 
        { 
            self.propModel.origin = self.origin; 
            wait 0.001; 
        } 
    }

    propBindInst()
    {
        self endon("disconnect");
        self endon("game_ended");
        
        bindInst = self createFontString("objective", 1.2);
        bindInst.x = 5;
        bindInst.y = 110;
        bindInst.alpha = 1;
        bindInst.hidewheninmenu = 1;
        bindInst.hidewheninkillcam = 1;
        bindInst setText("Change Prop = [{+actionslot 2}]\nFreeze Prop = [{+melee}]\nSpawn Decoy = [{+frag}]\nStun = [{+smoke}]\nRotate Left: [{+speed_throw}]\nRotate Right: [{+attack}]");
    }

    spinLeftBind()
    {
        self endon("disconnect");
        self endon("death");

        self notifyOnPlayerCommand("spinLeft_down", "+attack");
        self notifyOnPlayerCommand("spinLeft_up",   "-attack");

        for (;;)
        {
            self waittill("spinLeft_down");

            if (!isDefined(self.propModel))
                continue;

            self notify("stop_spin");
            self thread spinHeld(-1); // -1 = left
        }
    }

    spinRightBind()
    {
        self endon("disconnect");
        self endon("death");

        self notifyOnPlayerCommand("spinRight_down", "+speed_throw");
        self notifyOnPlayerCommand("spinRight_up",   "-speed_throw");

        for (;;)
        {
            self waittill("spinRight_down");

            if (!isDefined(self.propModel))
                continue;

            self notify("stop_spin");
            self thread spinHeld(1); // 1 = right
        }
    }

    spinHeld(dir)
    {
        self endon("disconnect");
        self endon("death");
        self endon("stop_spin");

        if (dir == -1) self endon("spinLeft_up");
        else           self endon("spinRight_up");

        tick = 0.02;
        step = 4;

        for (;;)
        {
            if (!isDefined(self.propModel)) break;

            self.propModel rotateYaw(step * dir, tick);
            wait tick;
        }
    }

    freezeBind()
    {
        self endon("disconnect");
        self notifyonplayercommand("freezeProp", "+melee");

        for (;;)
        {
            self waittill("freezeProp");

            if (!self.frozen)
            {
                self.frozen = 1;
                self notify("stop_freeze_pos");
                self thread freezePositionOnly();
            }
            else if (self.frozen)
            {
                self.frozen = 0;
                self notify("stop_freeze_pos");
                self unlink();
            }

            wait 0.2;
        }
    }

    freezePositionOnly()
    {
        self endon("disconnect");
        self endon("death");
        self endon("stop_freeze_pos");

        UFO = spawn("script_model", self.origin);

        for (;;)
        {
            self playerlinkto(UFO);
            wait .02;
        }
    }

    spawnDecoyBind()
    {
        self endon("disconnect");
        self notifyonplayercommand("spawnDecoy", "+frag");

        for(;;)
        {
            self waittill("spawnDecoy");

            if (!isDefined(self.propModelName))
                continue;

            if (self.allowedDecoys > 0 && isAlive(self))
            {
                decoy = spawn("script_model", self.origin);
                decoy setModel(self.propModelName);
                decoy.angles = self.propModel.angles;
                decoy Solid();

                decoy thread monitorDecoyDamage(self);

                self.allowedDecoys--;
                self iprintln("Decoys Remaining: ^1" + self.allowedDecoys);
            }
            else if (self.allowedDecoys == 0 && !self.noDecoyNotif)
            {
                self iprintln("^1No decoys remaining!");
                self.noDecoyNotif = 1;
            }
        }
    }

    monitorDecoyDamage( owner )
    {
        self endon("death");

        self.health = 75;
        self.maxhealth = self.health;
        self setCanDamage(true);

        for(;;)
        {
            self waittill("damage", damage, attacker, direction_vec, point, type);

            if( isPlayer(attacker) && (type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET") )
            {
                self.health -= damage;

                if (self.health <= 0)
                {
                    attacker.health -= 20;
                    playFx( level._effect["money"], self.origin);

                    self delete();
                    return;
                }
            }
        }
    }

    stunBind(allowedStuns,nearestPlayer)
    {
        self endon ("disconnect");
        self notifyonplayercommand("dropStun", "+smoke");

        for(;;)
        {
            self waittill("dropStun");

            if(self.allowedStuns != 0 && isAlive(self))
            {
                nearestDist = 400;
                
                foreach(player in level.players)
                {
                    if(player != self)
                    {
                        dist = distance(player.origin, self.origin);

                        if(dist < nearestDist)
                        {
                            nearestDist = dist;
                            nearestPlayer = player;
                        }
                    }

                    if(nearestPlayer.team != getDvar("teamProps"))
                        nearestPlayer thread maps\mp\_flashgrenades::applyflash(3.5, 0);
                }
                
                self.allowedStuns--;
                self iprintln("Stuns Remaining: ^1" + self.allowedStuns);
            }
            else if(self.allowedStuns == 0 && !self.noStunNotif)
            {
                self iprintln("^1No stuns remaining!");
                self.noStunNotif = 1;
            }
        }   
    }

    SpawnScriptModel(origin,model,angles,time,clip)
    {
        if(isDefined(time))
            wait time;
        ent = spawn("script_model",origin);
        ent SetModel(model);
        if(isDefined(angles))
            ent.angles = angles;
        if(isDefined(clip))
            ent CloneBrushModelToScriptModel(clip);
        return ent;
    }

    propSystem()
    {
        self endon( "disconnect" );

        if( !isDefined( self.propModel ))
            self setProp( pickRandomProp() );

        self notifyonplayercommand("changeProp", "+actionslot 2");

        for(;;)
        {
            self waittill("changeProp");

            self setProp( pickRandomProp() );
            wait .5;
        }   
    }

    pickRandomProp()
    {
        if( isDefined( self.propModel ))
            removeValueFromArray( level.propIDs, self.propModel );

        for( a = 0; a < level.propIDs.size; a++)
            return level.propIDs[RandomInt(level.propIDs.size)];
    }

    removeValueFromArray(array, valueToRemove)
    {
        newArray = [];
        for (i = 0; i < array.size; i++)
        {
            if (array[i] != valueToRemove)
                newArray[newArray.size] = array[i];
        }
        return newArray;
    }

    doHunterLoadout()
    {
        hntrPrimaries = strtok("m4_gl_mp;scar_gl_mp;tavor_gl_mp;masada_gl_mp;ak47_gl_mp", ";");
        pickedPrimary = hntrPrimaries[RandomInt(hntrPrimaries.size - 1)];

        hntrSecondaries = strtok("usp_tactical_mp;coltanaconda_tactical_mp;beretta_tactical_mp;deserteagle_tactical_mp", ";");
        pickedSecondary = hntrSecondaries[RandomInt(hntrSecondaries.size - 1)];

        camo = randomintrange(1,8);

        self giveweapon(pickedPrimary, camo);
        self GiveMaxAmmo(pickedPrimary);
        wait .1;
        self giveweapon(pickedSecondary);
        self GiveMaxAmmo(pickedSecondary);
        wait .1;
        self switchtoweapon(pickedPrimary);
    }

    lastPropPing()
    {
        self endon( "disconnect" );
        self endon( "death" );
        
        while( true )
        {
            if( self.team == getDvar( "teamHunters" ) && !isDefined( self.hunterUAVDone ) )
            {
                if( isDefined( level.propsAliveCount ) && level.propsAliveCount == 1 )
                {
                    self thread maps\mp\killstreaks\_uav::launchUav( self, getDvar( "teamHunters" ), 15, false );
                    wait 10;
                    self.hunterUAVDone = true; 
                    break; 
                }
            }
            
            wait 1; 
        }
    }

    nearPropNotif()
    {
        self endon("disconnect");
        level endon("game_ended");

        for(;;)
        {
            wait 0.1;

            foreach(player in level.players)
            {
                if(player.pers["team"] != getDvar("teamHunters"))
                    continue;

                dist = distance(self.origin, player.origin);

                if(dist < 500)
                {
                    
                    player playlocalsound( randomSound() );
                    wait 5;
                }
            }
        }
    }

    randomSound()
    {
        nearbyNotifs = [
                    "NS_1mc_boost",
                    "PG_1mc_boost",
                    "RU_1mc_boost",
                    "UK_1mc_boost",
                    "US_1mc_boost",
                    "ab_losing_music",
                    "ab_spawn_music",
                    "ab_winning_music",
                    "mp_bonus_end",
                    "mp_bonus_start",
                    "mp_challenge_complete",
                    "mp_defcon_down",
                    "mp_defcon_one",
                    "mp_killstreak_emp",
                    "mp_killstreak_nuclearstrike",
                    "mp_killstreak_radar",
                    "mp_killstreak_sentrygun",
                    "mp_level_up",
                    "mp_obj_captured",
                    "mp_obj_taken",
                    "mp_time_running_out_losing",
                    "mp_war_objective_lost",
                    "mp_war_objective_taken",
                    "ns_losing_music",
                    "nuke_explosion_boom_local",
                    "nuke_wave",
                    "plr_new_rank",
                    "AB_1mc_enemy_ac130",
                    "AB_1mc_enemy_emergairdrop",
                    "AB_1mc_enemy_tnuke",
                    "AB_1mc_goodtogo",
                    "AB_1mc_use_tnuke",
                    "NS_1mc_enemy_tnuke",
                    "NS_1mc_use_tnuke",
                    "PG_1mc_enemy_tnuke"
                    ];

        return nearbyNotifs[RandomInt(nearbyNotifs.size)];
    }

    modelPrecache()
    {
        level.propIDs   = [];

        if (level.currentMapName == "mp_afghan")
            level.propIDs = strtok("machinery_oxygen_tank01;foliage_pacific_bushtree02_animated;foliage_cod5_tree_jungle_02_animated;machinery_oxygen_tank02;com_barrel_russian_fuel_dirt;com_locker_double;foliage_pacific_bushtree02_halfsize_animated;com_plasticcase_black_big_us_dirt;foliage_pacific_bushtree01_halfsize_animated;vehicle_uaz_open_destructible;vehicle_hummer_destructible;foliage_cod5_tree_pine05_large_animated;utility_transformer_ratnest01;utility_water_collector;", ";");

        else if (level.currentMapName == "mp_derail")
            level.propIDs = strtok("com_roofvent2_animated;com_filecabinetblackclosed;com_tv1_testpattern;usa_gas_station_trash_bin_02;prop_photocopier_destructible_02;machinery_oxygen_tank01;com_trashbin01;vehicle_pickup_destructible_mp;furniture_gaspump01_damaged;vehicle_uaz_winter_destructible;com_propane_tank02;crashed_satellite;vehicle_bm21_cover_destructible;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_boneyard")
            level.propIDs = strtok("foliage_tree_oak_1_animated2;machinery_oxygen_tank01;com_filecabinetblackclosed;machinery_oxygen_tank02;com_electrical_transformer_large_dam;vehicle_moving_truck_destructible;foliage_pacific_bushtree02_animated;vehicle_pickup_destructible_mp;com_trashbin02;vehicle_bm21_mobile_bed_destructible;foliage_cod5_tree_jungle_02_animated;com_firehydrant;machinery_generator;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_underpass")
            level.propIDs = strtok("foliage_pacific_bushtree01_halfsize_animated;utility_water_collector;com_propane_tank02;foliage_pacific_bushtree01_animated;vehicle_van_slate_destructible;com_locker_double;machinery_oxygen_tank01;prop_photocopier_destructible_02;usa_gas_station_trash_bin_02;machinery_oxygen_tank02;com_filecabinetblackclosed;vehicle_pickup_destructible_mp;foliage_cod5_tree_jungle_02_animated;foliage_tree_oak_1_animated2;foliage_pacific_palms08_animated;chicken_black_white;utility_transformer_ratnest01;utility_transformer_small01;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_highrise")
            level.propIDs = strtok("ma_flatscreen_tv_wallmount_01;com_trashbin02;com_filecabinetblackclosed;prop_photocopier_destructible_02;machinery_oxygen_tank01;machinery_oxygen_tank02;com_electrical_transformer_large_dam;com_roofvent2_animated;com_propane_tank02;highrise_fencetarp_04;highrise_fencetarp_05;com_barrel_benzin;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_estate")
            level.propIDs = strtok("machinery_generator;vehicle_pickup_destructible_mp;vehicle_coupe_white_destructible;vehicle_suburban_destructible_dull;vehicle_luxurysedan_2008_destructible;com_electrical_transformer_large_dam;machinery_oxygen_tank01;com_filecabinetblackclosed;ma_flatscreen_tv_on_wallmount_02;com_filecabinetblackclosed_dam;", ";");
        
        else if (level.currentMapName == "mp_terminal")
            level.propIDs = strtok("com_tv1;com_barrel_benzin;foliage_pacific_fern01_animated;ma_flatscreen_tv_wallmount_02;com_roofvent2_animated;ma_flatscreen_tv_on_wallmount_02_static;vehicle_policecar_lapd_destructible;com_vending_can_new2_lit;usa_gas_station_trash_bin_01;foliage_cod5_tree_pine05_large_animated;com_filecabinetblackclosed;com_plasticcase_black_big_us_dirt;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_subbase")
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_trashcan_metal_closed;com_tv1;com_filecabinetblackclosed;com_locker_double;vehicle_uaz_winter_destructible;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_checkpoint")
            level.propIDs = strtok("prop_photocopier_destructible_02;com_filecabinetblackclosed;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;com_tv1;vehicle_moving_truck_destructible;chicken_black_white;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_invasion")
            level.propIDs = strtok("com_trashbin01;com_trashbin02;com_firehydrant;com_newspaperbox_blue;com_newspaperbox_red;furniture_gaspump01_damaged;vehicle_80s_wagon1_red_destructible_mp;vehicle_hummer_destructible;vehicle_taxi_yellow_destructible;vehicle_uaz_open_destructible;utility_transformer_small01;foliage_tree_palm_tall_1;foliage_tree_palm_bushy_1;", ";");

        else if (level.currentMapName == "mp_quarry")
            level.propIDs = strtok("foliage_pacific_bushtree02_animated;foliage_tree_oak_1_animated2;foliage_cod5_tree_jungle_02_animated;com_filecabinetblackclosed;machinery_generator;machinery_oxygen_tank01;machinery_oxygen_tank02;utility_transformer_small01;com_locker_double;com_barrel_russian_fuel_dirt;com_tv1;vehicle_van_green_destructible;vehicle_van_white_destructible;vehicle_pickup_destructible_mp;vehicle_small_hatch_turq_destructible_mp;vehicle_uaz_open_destructible;vehicle_moving_truck_destructible;usa_gas_station_trash_bin_02;prop_photocopier_destructible_02;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_nightshift")
            level.propIDs = strtok("com_trashbin01;com_trashbin02;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;vehicle_uaz_open_destructible;vehicle_van_white_destructible;vehicle_bm21_cover_destructible;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;", ";");

        else if (level.currentMapName == "mp_favela")
            level.propIDs = strtok("utility_transformer_small01;vehicle_small_hatch_white_destructible_mp;vehicle_small_hatch_blue_destructible_mp;vehicle_pickup_destructible_mp;utility_water_collector;com_tv2;machinery_oxygen_tank01;machinery_oxygen_tank02;utility_transformer_ratnest01;foliage_tree_palm_bushy_3;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;com_trashbin01;com_trashbin02;", ";");

        else if(level.currentMapName == "mp_rundown")
            level.propIDs = strtok("com_tv1;com_tv2;com_trashbin01;com_trashbin02;com_trashcan_metal_closed;vehicle_small_hatch_white_destructible_mp;vehicle_small_hatch_blue_destructible_mp;vehicle_uaz_open_destructible;vehicle_bm21_mobile_bed_destructible;machinery_oxygen_tank01;machinery_oxygen_tank02;com_firehydrant;foliage_tree_palm_bushy_1;foliage_pacific_fern01_animated;utility_transformer_small01;utility_water_collector;utility_transformer_ratnest01;chicken_black_white;", ";");

        else if(level.currentMapName == "mp_crash")
            level.propIDs = strtok("com_tv1;com_tv2;ma_flatscreen_tv_wallmount_01;ma_flatscreen_tv_wallmount_02;foliage_tree_river_birch_xl_a_animated;foliage_tree_palm_bushy_3;foliage_tree_river_birch_med_a_animated;utility_transformer_ratnest01;utility_transformer_small01;vehicle_80s_sedan1_brn_destructible_mp;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_pickup_destructible_mp;", ";");

        else if(level.currentMapName == "mp_complex")
            level.propIDs = strtok("usa_gas_station_trash_bin_02;usa_gas_station_trash_bin_02_base;ma_flatscreen_tv_on_02;ma_flatscreen_tv_on_wallmount_02_static;arcade_machine_1;arcade_machine_2;pinball_machine_1;pinball_machine_2;foliage_tree_green_pine_lg_b_animated;foliage_tree_green_pine_lg_a_animated;foliage_pacific_palms06_animated;foliage_pacific_tropic_shrub01_animated;vehicle_subcompact_black_destructible;vehicle_subcompact_slate_destructible;vehicle_pickup_destructible_mp;vehicle_coupe_blue_destructible;vehicle_coupe_white_destructible;vehicle_policecar_lapd_destructible;vehicle_moving_truck_destructible;", ";");

        else if(level.currentMapName == "mp_overgrown")
            level.propIDs = strtok("foliage_tree_river_birch_xl_a_animated;foliage_tree_river_birch_lg_a_animated;foliage_red_pine_xl_animated;foliage_red_pine_xxl_animated;foliage_red_pine_med_animated;foliage_tree_grey_oak_xl_a_animated;com_propane_tank02;furniture_gaspump01_damaged;", ";");

        else if(level.currentMapName == "mp_compact")
            level.propIDs = strtok("com_locker_double;machinery_generator;com_filecabinetblackclosed;com_propane_tank02;machinery_oxygen_tank01;me_rooftop_tank_01;com_electrical_transformer_large_dam;com_tv1;com_filecabinetblackclosed_dam;", ";");

        else if(level.currentMapName == "mp_trailerpark")
            level.propIDs = strtok("prop_trailerpark_beer_keg;foliage_dead_pine_med_animated;foliage_dead_pine_lg_animated;com_propane_tank02;com_propane_tank03;machinery_oxygen_tank01;machinery_oxygen_tank02;com_trashbin02;machinery_generator;com_firehydrant;utility_transformer_ratnest01;utility_transformer_small01;vehicle_subcompact_gray_destructible;vehicle_coupe_white_destructible;vehicle_80s_hatch1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_delivery_truck_white;", ";");

        else if(level.currentMapName == "mp_abandon")
            level.propIDs = strtok("popcorn_cart;prop_trailerpark_beer_keg;usa_gas_station_trash_bin_01;trashcan_clown;foliage_tree_river_birch_xl_a_animated;arcade_machine_1;arcade_machine_1_des;arcade_machine_2;pinball_machine_1;pinball_machine_2;pinball_machine_2_des;fortune_machine;vehicle_theme_park_truck;", ";");

        else if(level.currentMapName == "mp_storm")
            level.propIDs = strtok("com_tv1;com_trashbin01;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;foliage_dead_pine_lg_animated;foliage_dead_pine_med_animated;foliage_tree_oak_1_animated2;vehicle_80s_wagon1_green_destructible_mp;vehicle_80s_sedan1_silv_destructible_mp;vehicle_80s_hatch2_yel_destructible_mp;vehicle_moving_truck_destructible;vehicle_mack_truck_short_white_destructible;", ";");


        else if(level.currentMapName == "mp_vacant")
            level.propIDs = strtok("machinery_generator;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;foliage_tree_birch_red_1_animated;foliage_tree_river_birch_xl_a_animated;com_locker_double;utility_transformer_small01;vehicle_80s_sedan1_silv_destructible_mp;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_80s_sedan1_yel_destructible_mp;vehicle_uaz_hardtop_destructible_mp;com_propane_tank02;", ";");

        else if(level.currentMapName == "mp_fuel2")
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;com_trashbin02;machinery_generator;foliage_tree_palm_med_2;foliage_tree_palm_bushy_2;utility_transformer_small01;com_electrical_transformer_large_dam;com_propane_tank02_small;vehicle_uaz_hardtop_destructible_mp;vehicle_bm21_mobile_bed_destructible;", ";");


        else if(level.currentMapName == "mp_strike")
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;machinery_generator;foliage_tree_river_birch_xl_a_animated;foliage_tree_palm_bushy_2;usa_gas_station_trash_bin_01;com_locker_double;com_trashcan_metal_closed;com_firehydrant;prop_photocopier_destructible_02;com_vending_can_new1_lit;com_vending_can_new2_lit;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_brn_destructible_mp;vehicle_hummer_destructible;", ";");

        for(a=0;a<level.propIDs.size;a++) 
            precachemodel(level.propIDs[a]);
    }

