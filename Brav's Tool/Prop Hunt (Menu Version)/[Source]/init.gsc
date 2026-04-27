/*
    Welcome to Prop Hunt!
        by akaTrxgic

    /////////////////////////////////////////////////////////////////////////////
    |                                                                           |
    |   Credits:                                                                |
    |   * Menu Base by Leafized                                                 |
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
            player thread MonitorButtons();
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
            self definesMenu();
            self optSizes();

            self waittill("spawned_player");

            if( level.supportedMap && level.supportedMode )
            {
                if(self.pers["team"] == game["defenders"])
                {
                    setDvar("teamProps", self.team);
                    self thread initmenu();
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
            self.allowedChanges = 3;
            self.allowedStuns = 2;
            self.allowedDecoys = 3;
            self thread propDeathCheck();
            self thread spinLeftBind();
            self thread spinRightBind();
            self thread freezeBind();
            self thread spawnDecoyBind();
            self thread nearPropNotif();
            self thread stunBind();
            self thread propBindInst();
            self thread menuInst();
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
        bindInst setText("Freeze Prop = [{+melee}]\nSpawn Decoy = [{+frag}]\nStun = [{+smoke}]\nRotate Left: [{+speed_throw}]\nRotate Right: [{+attack}]");
    }

    menuInst()
    {
        self endon("disconnect");
        self endon("game_ended");

        menuInst = self createFontString("objective", 1);
        menuInst.x = 330;
        menuInst.y = 425;
        menuInst.alpha = 1; 
        menuInst.hidewheninmenu = 1;
        menuInst.hidewheninkillcam = 1;
        menuInst settext("[{+speed_throw}] + [{+actionslot 2}] = Prop Menu");
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

            if (!self.frozen && !self.menu["vars"]["open"])
            {
                self.frozen = 1;
                self notify("stop_freeze_pos");
                self thread freezePositionOnly();
            }
            else if (self.frozen && !self.menu["vars"]["open"])
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

            if (self.allowedDecoys > 0 && !self.menu["vars"]["open"] && isAlive(self))
            {
                decoy = spawn("script_model", self.origin);
                decoy setModel(self.propModelName);
                decoy.angles = self.propModel.angles;
                decoy Solid();

                decoy thread monitorDecoyDamage(self);

                self.allowedDecoys--;
                self iprintln("Decoys Remaining: ^1" + self.allowedDecoys);
            }
            else if (self.allowedDecoys == 0 && !self.noDecoyNotif && !self.menu["vars"]["open"])
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

            if(self.allowedStuns != 0 && !self.menu["vars"]["open"] && isAlive(self))
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
            else if(self.allowedStuns == 0 && !self.noStunNotif && !self.menu["vars"]["open"])
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

    loadMenus()
    {
        self addMenu("Main", "none", self.menu["vars"]["currOpt"]);

        for(a=0;a<level.propIDs.size;a++)
            self addOption("Main", level.propNames[a], a, ::setProp, level.propIDs[a]);
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

    buttons()
    {
        self endon("death");
        
        while(1)
        {
            if(!self.menu["vars"]["open"] && self isButtonPressed("+actionslot 2") && self adsButtonPressed())
            {
                self playLocalSound(self.scrollsounder);
            
                if(self.menuDesign == "simple")
                {
                    self.cursnumber  = 13;
                    self.cursnumber2 = 18;
                    self.cursnumber3 = 13;

                    self.menu["ui"]["bgMain"] = drawRect("CENTER", "CENTER", 300, 0, 175, 200, (0,0,0), 0, 0, "white");
                    self.menu["ui"]["sb"] = drawRect("CENTER", "CENTER", 300, 1000, 175, 15, self.menuColor, 1, 0, self.scrollerDefault);
                    self.menu["ui"]["bgTopLine"] = drawRect("CENTER", "CENTER", 300, 114, 175, 27, self.menuColor, 1, 0, "white");
                    self.menu["ui"]["bgTopLine1"] = drawRect("CENTER", "CENTER", 300, -114, 175, 27, self.menuColor, 1, 0, "white");
                    self.menu["ui"]["title"] = drawText(self.menuname, "CENTER", "CENTER", 302, -115, 2, (1,1,1), 2, 0, "objective");

                    if(self.menu["vars"]["currMenu"]!="none")
                        self thread drawMenu(self.menu["vars"]["currMenu"], self.menu["vars"]["currOpt"]);
                    else
                        self thread drawMenu("Main", self.menu["vars"]["currOpt"]);

                    self thread scrollFunc(false);
                    self.menu["ui"]["bgMain"] elemManage(.5,undefined,undefined,0.8);
                    self.menu["ui"]["sb"] elemManage(.5,undefined,undefined,1);
                    self.menu["ui"]["bgTopLine"] elemManage(.5,undefined,undefined,1);
                    self.menu["ui"]["bgTopLine1"] elemManage(.5,undefined,undefined,1);
                    self.menu["ui"]["title"] elemManage(.5,undefined,undefined,1);
                    self thread dod(self.menu["ui"]["bgMain"]);
                    self thread dod(self.menu["ui"]["sb"]);
                    self thread dod(self.menu["ui"]["bgTopLine"]);
                    self thread dod(self.menu["ui"]["bgTopLine1"]);
                    self thread dod(self.menu["ui"]["title"]);
                    wait 0.4;
                    self.menu["vars"]["open"] = true;
            
                    }
            
            }

            if(self.menu["vars"]["open"])
            {
                if(self useButtonPressed())
                {
                    self playLocalSound(self.scrollsounder);
                    self thread[[self.func[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]]]](self.input[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]], self.input2[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]], self.input3[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]], self.input4[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]]);
                    wait 0.2;
                }
                if(self isButtonPressed("+actionslot 1") || self isButtonPressed("+actionslot 2"))
                {
                    opt = self.menu["vars"]["currOpt"];
                    opt += self isButtonPressed("+actionslot 2");
                    opt -= self isButtonPressed("+actionslot 1");
                    self thread doScroll(opt);
                    wait 0.2;
                    self playLocalSound(self.scrollsounder);
                }
                if(self meleeButtonPressed())
                {
                    self playLocalSound(self.scrollsounder);
                    if(self.backMenu[self.menu["vars"]["currMenu"]]=="none")
                    {   
                        self notify("UpdateNotify");
                        self.menu["ui"]["bgMain"] elemManage(.5,undefined,undefined,0);
                        self.menu["ui"]["sb"] elemManage(.5,undefined,undefined,0);
                        self.menu["ui"]["bgTopLine"] elemManage(.5,undefined,undefined,0);
                        self.menu["ui"]["bgTopLine1"] elemManage(.5,undefined,undefined,0);
                        self.menu["ui"]["title"] elemManage(.5,undefined,undefined,0);
                        self.menu["ui"]["dev"] elemManage(.5,undefined,undefined,0);
                        wait .3;
                        self.menu["ui"]["bgMain"] Destroy();
                        self.menu["ui"]["sb"] Destroy();
                        self.menu["ui"]["bgTopLine"] Destroy();
                        self.menu["ui"]["bgTopLine1"] Destroy();
                        self.menu["ui"]["title"] Destroy();
                        self.menu["ui"]["dev"] Destroy();
                        self.menu["vars"]["open"] = false;
                    }
                    else
                    {
                        self thread goBack();
                        wait 0.2;
                    }
                }
            }
            wait 0.05;
        }
    }

    MonitorButtons()
    {
        if(isDefined(self.MonitoringButtons))
            return;
        self.MonitoringButtons = true;
        
        if(!isDefined(self.buttonAction))
            self.buttonAction = strtok("+stance;+gostand;weapnext;+actionslot 1;+actionslot 2;+actionslot 3;+actionslot 4", ";");
        if(!isDefined(self.buttonPressed))
            self.buttonPressed = [];
        
        for(a=0;a<self.buttonAction.size;a++)
            self thread ButtonMonitor(self.buttonAction[a]);
    }

    ButtonMonitor(button)
    {
        self endon("disconnect");
        
        self.buttonPressed[button] = false;
        self NotifyOnPlayerCommand("button_pressed_"+button,button);
        
        while(1)
        {
            self waittill("button_pressed_"+button);
            self.buttonPressed[button] = true;
            wait .025;
            self.buttonPressed[button] = false;
        }
    }

    isButtonPressed(button)
    {
        return self.buttonPressed[button];
    }

    drawMenu(menu, selOpt)
    {
        if(self.menuDesign == "simple")
        {
            self notify("UpdateNotify");
            self.menu["vars"]["currMenu"] = menu;
            self.menu["vars"]["currOpt"] = selOpt;
            self.menu["ui"]["menuText"] = [];
            
            for(m = 0; m < self.cursnumber3; m++)
            {
                self.menu["ui"]["menuText"][m] = drawText(self.opt[self.menu["vars"]["currMenu"]][m], "CENTER", "CENTER", 300, 15*m-90, 1.2, (1,1,1), 2, 0, "objective");
                self.menu["ui"]["menuText"][m] elemManage(0.2,undefined,undefined,1);
                self thread UpdateNotify(self.menu["ui"]["menuText"][m]);
                self thread dod(self.menu["ui"]["menuText"][m]);
            }

            self thread UpdateNotify(self.menu["ui"]["menuTitle"]);
            self thread dod(self.menu["ui"]["menuTitle"]);
            self thread scrollFunc(true);
        }
    }

    optSizes()
    {
        if(self.menuDesign == undefined || self.menuDesign == "simple")
        {
            self.cursnumber  = 13;
            self.cursnumber2 = 18;
            self.cursnumber3 = 13;
        }
    }

    definesMenu()
    {
        if(self.scrollsounder == undefined)
            self.scrollsounder = "mouse_over";
        
        if(self.scrollerDefault == undefined)
            self.scrollerDefault = "gradient_center";

        if(self.menuColor == undefined)
            self.menuColor = dividecolor(79, 0, 121);

        if(self.menuDesign == undefined)
            self.menuDesign = "simple";
    }

    initMenu()
    {
        self.menuname    = "Prop Hunt";
        self.creatorname = "by Warn Trxgic";
        self endon("death");

        self.menu["vars"]["open"] = false;
        self.menu["vars"]["currMenu"] = "none";
        self.menu["vars"]["currOpt"] = 0;
        self thread buttons();
        self thread colors();
        self thread loadMenus();
    }

    drawRect(a,r,x,y,w,h,c,s,al,sh)
    {
        rect = newClientHudElem(self);
        rect.elemType = "bar";
        rect.children = [];
        rect.sort = s;
        rect.color = c;
        rect.alpha = al;
        rect setShader(sh,w,h);
        rect setPoint(a,r,x,y);
        return rect;
    }

    drawText(t,a,r,x,y,fs,c,s,al,f)
    {
        rect = createFontString(f,fs);
        rect setPoint(a,r,x,y);
        rect setText(t);
        rect.sort = s;
        rect.color = c;
        rect.alpha = al;
        rect.children = [];
        return rect;
    }

    goBack()
    {
        newMenu = self.backMenu[self.menu["vars"]["currMenu"]];
        newOpt = self.backOpt[self.menu["vars"]["currMenu"]];
        self.menu["vars"]["currMenu"] = newMenu;
        self.menu["vars"]["currOpt"] = newOpt;
        self thread drawMenu(self.menu["vars"]["currMenu"], self.menu["vars"]["currOpt"]);
    }

    UpdateNotify(elem)
    {
        self waittill("UpdateNotify");
        elem elemManage(0.2, undefined, undefined, 0);
        wait 0.2;
        elem Destroy();
    }

    reColorBools()
    {
        self endon("death");
        
        for(;;)
        {
            i = self.menu["vars"]["currOpt"];
            if(self.boolOpt[self.menu["vars"]["currMenu"]][i] == 0)
                self.menu["ui"]["menuText"][i].color = (1,25/255,25/255);
            if(self.boolOpt[self.menu["vars"]["currMenu"]][i] == 1)
                self.menu["ui"]["menuText"][i].color = (25/255,1,25/255);
            if(self.boolOpt[self.menu["vars"]["currMenu"]][i] != 1 && self.boolOpt[self.menu["vars"]["currMenu"]][i] != 0)
                self.menu["ui"]["menuText"][i].color = (1,1,1);
            for(x=0;x<10;x++)
            {
                if(x!=self.menu["vars"]["currOpt"])
                    self.menu["ui"]["menuText"][x].color = (1,1,1);
            }
            wait 0.05;
        }
    }

    doScroll(value)
    {
        self.menu["vars"]["currOpt"] = value;
        self scrollFunc(true);
    }

    test(txt, bold)
    {
        if(bold)
            self iPrintlnBold(txt);
        else
            self iPrintln(txt);
    }

    colors()
    {
        self endon("death");
        while(1)
        {
            self.menu["ui"]["title"] elemManage(0,undefined,undefined,1);
            self.menu["ui"]["title"].color = (1,1,1);
            wait 2;
        }
    }

    addMenu(menuName, bMenuName, bMenuOpt) 
    {
        self.opt[menuName] = [];
        self.backMenu[menuName] = bMenuName;
        self.backOpt[menuName] = bMenuOpt;
        self.func[menuName] = [];
        self.boolOpt[menuName] = [];
        self.input[menuName] = [];
        self.input2[menuName] = [];
        self.input3[menuName] = [];
        self.input4[menuName] = [];
    }

    addOption(menuName, option, optbool, function, input, input2, input3, input4)
    {
        i = self.opt[menuName].size;
        self.opt[menuName][i] = option;
        self.func[menuName][i] = function;
        self.boolOpt[menuName][i] = optbool;
        if(isDefined(input))
            self.input[menuName][i] = input;
        if(isDefined(input2))
            self.input2[menuName][i] = input2;
        if(isDefined(input3))
            self.input3[menuName][i] = input3;
        if(isDefined(input4))
            self.input4[menuName][i] = input4;
    }

    elemManage(time,x,y,a,w,h,txt)
    {
        if(isDefined(time)&&(isDefined(x)||isDefined(y)))
        {
            self moveOverTime(time);
            if(isDefined(x)) self.x = x;
            if(isDefined(y)) self.y = y;
        }
        if(isDefined(time)&&isDefined(a))
        {
            self fadeOverTime(time);
            self.alpha = a;
        }
        if(isDefined(time)&&(isDefined(w)&&isDefined(h)))
            self scaleOverTime(time, w, h);
        if(isDefined(txt))
            self setText(txt);
    }

    dod(elem)
    {
        self waittill("death");
        elem destroy();
    }

    divideColor(c1,c2,c3)
    {
        return(c1/255,c2/255,c3/255);
    }

    scrollFunc(yesorno)
    { 
        if(self.menuDesign == "simple")
        {
        if(self.menu["vars"]["currOpt"] < 0)
            self.menu["vars"]["currOpt"] = self.opt[self.menu["vars"]["currMenu"]].size-1;
        if(self.menu["vars"]["currOpt"] > self.opt[self.menu["vars"]["currMenu"]].size-1)
            self.menu["vars"]["currOpt"] = 0;
        if(!isDefined(self.opt[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]-self.cursnumber]) || self.opt[self.menu["vars"]["currMenu"]].size <= self.cursnumber3)
        {
            for(m=0;m<self.cursnumber3;m++)
                self.menu["ui"]["menuText"][m] setText(self.opt[self.menu["vars"]["currMenu"]][m]);

            if(isDefined(yesorno))
            {
                self.menu["ui"]["sb"] elemManage(0,undefined,15*self.menu["vars"]["currOpt"]-90);
                wait 0.2;
            }
            else
            self.menu["ui"]["sb"].y = 15*self.menu["vars"]["currOpt"]-90;
        }
        else
        {
            if(isDefined(self.opt[self.menu["vars"]["currMenu"]][self.menu["vars"]["currOpt"]+self.cursnumber]))
            {
                optNum=0;
                for(m=self.menu["vars"]["currOpt"]-self.cursnumber;m<self.menu["vars"]["currOpt"]+self.cursnumber2;m++)
                {
                    if(!isDefined(self.opt[self.menu["vars"]["currMenu"]][m]))
                        self.menu["ui"]["menuText"][optNum] setText("");
                    else
                        self.menu["ui"]["menuText"][optNum] setText(self.opt[self.menu["vars"]["currMenu"]][m]);
                    optNum++;
                }
                if(isDefined(yesorno))
                {
                    self.menu["ui"]["sb"] elemManage(0,undefined,40);//y value of sb at self.cursnumber
                    wait 0.2;
                }
                else
                    self.menu["ui"]["sb"].y = 40;
            }
            else
            {
                for(m=0;m<self.cursnumber3;m++)
                    self.menu["ui"]["menuText"][m] setText(self.opt[self.menu["vars"]["currMenu"]][self.opt[self.menu["vars"]["currMenu"]].size+(m-self.cursnumber3)]);
                if(isDefined(yesorno))
                {
                    self.menu["ui"]["sb"] elemManage(0,undefined,15*((self.menu["vars"]["currOpt"]-self.opt[self.menu["vars"]["currMenu"]].size)+self.cursnumber3)-90);
                    wait 0.2;
                }
                else
                self.menu["ui"]["sb"].y = 15*((self.menu["vars"]["currOpt"]-self.opt[self.menu["vars"]["currMenu"]].size)+self.cursnumber3)-90;
            }
        }
        }
    }

    modelPrecache()
    {
        level.propIDs   = [];
        level.propNames = [];

        if (level.currentMapName == "mp_afghan")
        {
            level.propIDs = strtok("machinery_oxygen_tank01;foliage_pacific_bushtree02_animated;foliage_cod5_tree_jungle_02_animated;machinery_oxygen_tank02;com_barrel_russian_fuel_dirt;com_locker_double;foliage_pacific_bushtree02_halfsize_animated;com_plasticcase_black_big_us_dirt;foliage_pacific_bushtree01_halfsize_animated;vehicle_uaz_open_destructible;vehicle_hummer_destructible;foliage_cod5_tree_pine05_large_animated;utility_transformer_ratnest01;utility_water_collector;", ";");

            level.propNames = strtok("Oxygen Tank - Orange;Big Bush;Tree;Oxygen Tank - Green;Fuel Barrel;Locker;Small Desert Bush;Ammo Crate;Small Green Bush;Military Vehicle Open;Hummer;Tree 2;Transformer;Water Collector;", ";");
        }

        else if (level.currentMapName == "mp_derail")
        {
            level.propIDs = strtok("com_roofvent2_animated;com_filecabinetblackclosed;com_tv1_testpattern;usa_gas_station_trash_bin_02;prop_photocopier_destructible_02;machinery_oxygen_tank01;com_trashbin01;vehicle_pickup_destructible_mp;furniture_gaspump01_damaged;vehicle_uaz_winter_destructible;com_propane_tank02;crashed_satellite;vehicle_bm21_cover_destructible;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Roof Ventilator;File Cabinet;TV;Trash Bin;Photocopier;Oxygen Tank - Orange;Trash Bin 2;Pickup;Gas Pump;Winter Vehicle;Big Propane Tank;Crashed Satellite;Military Truck;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_boneyard")
        {
            level.propIDs = strtok("foliage_tree_oak_1_animated2;machinery_oxygen_tank01;com_filecabinetblackclosed;machinery_oxygen_tank02;com_electrical_transformer_large_dam;vehicle_moving_truck_destructible;foliage_pacific_bushtree02_animated;vehicle_pickup_destructible_mp;com_trashbin02;vehicle_bm21_mobile_bed_destructible;foliage_cod5_tree_jungle_02_animated;com_firehydrant;machinery_generator;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Tree;Oxygen Tank - Orange;File Cabinet;Oxygen Tank - Green;Large Transformer;Truck;Bush;Pickup;Trash Bin;Military Truck;Tree 2;Fire Hydrant;Generator;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_underpass")
        {
            level.propIDs = strtok("foliage_pacific_bushtree01_halfsize_animated;utility_water_collector;com_propane_tank02;foliage_pacific_bushtree01_animated;vehicle_van_slate_destructible;com_locker_double;machinery_oxygen_tank01;prop_photocopier_destructible_02;usa_gas_station_trash_bin_02;machinery_oxygen_tank02;com_filecabinetblackclosed;vehicle_pickup_destructible_mp;foliage_cod5_tree_jungle_02_animated;foliage_tree_oak_1_animated2;foliage_pacific_palms08_animated;chicken_black_white;utility_transformer_ratnest01;utility_transformer_small01;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Small Green Bush;Water Collector;Large Propane Tank;Big Green Bush;Blue Van;Locker;Oxygen Tank - Orange;Photocopier;Trash Bin;Oxygen Tank - Green;File Cabinet;White Pickup;Tall Tree;Tree;Small Green Bush 2;Chicken Black & White;Transformer;Small Transformer;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_highrise")
        {
            level.propIDs = strtok("ma_flatscreen_tv_wallmount_01;com_trashbin02;com_filecabinetblackclosed;prop_photocopier_destructible_02;machinery_oxygen_tank01;machinery_oxygen_tank02;com_electrical_transformer_large_dam;com_roofvent2_animated;com_propane_tank02;highrise_fencetarp_04;highrise_fencetarp_05;com_barrel_benzin;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Flatscreen TV;Black Trash Bin;File Cabinet;Photocopier;Oxygen Tank - Orange;Oxygen Tank - Green;Electrical Transformer;Roof Ventilator;Large Propane Tank;Large green fence;Small orange fence;Benzin barrel;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_estate")
        {
            level.propIDs = strtok("machinery_generator;vehicle_pickup_destructible_mp;vehicle_coupe_white_destructible;vehicle_suburban_destructible_dull;vehicle_luxurysedan_2008_destructible;com_electrical_transformer_large_dam;machinery_oxygen_tank01;com_filecabinetblackclosed;ma_flatscreen_tv_on_wallmount_02;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Small generator;White pickup;Small white car;Big black car;Small black car;Electrical Transformer;Oxygen Tank - Orange;File cabinet;Flatscreen TV;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_terminal")
        {
            level.propIDs = strtok("com_tv1;com_barrel_benzin;foliage_pacific_fern01_animated;ma_flatscreen_tv_wallmount_02;com_roofvent2_animated;ma_flatscreen_tv_on_wallmount_02_static;vehicle_policecar_lapd_destructible;com_vending_can_new2_lit;usa_gas_station_trash_bin_01;foliage_cod5_tree_pine05_large_animated;com_filecabinetblackclosed;com_plasticcase_black_big_us_dirt;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("TV;Benzin barrel;Small Bush;Flatscreen TV;Roof ventilator;Flatscreen TV On;Police car;Vending machine;Trash bin;Tree;File cabinet;Ammo crate;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_subbase")
        {
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_trashcan_metal_closed;com_tv1;com_filecabinetblackclosed;com_locker_double;vehicle_uaz_winter_destructible;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Oxygen Tank - Orange;Oxygen Tank - Green;Metal trash bin;TV;File cabinet;Locker;Military vehicle;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_checkpoint")
        {
            level.propIDs = strtok("prop_photocopier_destructible_02;com_filecabinetblackclosed;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;com_tv1;vehicle_moving_truck_destructible;chicken_black_white;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Photocopier;File cabinet;Fire hydrant;Red newspaper box;Blue newspaper box;TV;Truck;Chicken black-white;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_invasion")
        {
            level.propIDs = strtok("com_trashbin01;com_trashbin02;com_firehydrant;com_newspaperbox_blue;com_newspaperbox_red;furniture_gaspump01_damaged;vehicle_80s_wagon1_red_destructible_mp;vehicle_hummer_destructible;vehicle_taxi_yellow_destructible;vehicle_uaz_open_destructible;utility_transformer_small01;foliage_tree_palm_tall_1;foliage_tree_palm_bushy_1;", ";");

            level.propNames = strtok("Green trash bin;Black trash bin;Fire hydrant;Blue newspaper box;Red newspaper box;Gas pump;Red car;Hummer;Taxi;Military vehicle open;Transformer;Palm tree tall;Palm tree bushy;", ";");
        }

        else if (level.currentMapName == "mp_quarry")
        {
            level.propIDs = strtok("foliage_pacific_bushtree02_animated;foliage_tree_oak_1_animated2;foliage_cod5_tree_jungle_02_animated;com_filecabinetblackclosed;machinery_generator;machinery_oxygen_tank01;machinery_oxygen_tank02;utility_transformer_small01;com_locker_double;com_barrel_russian_fuel_dirt;com_tv1;vehicle_van_green_destructible;vehicle_van_white_destructible;vehicle_pickup_destructible_mp;vehicle_small_hatch_turq_destructible_mp;vehicle_uaz_open_destructible;vehicle_moving_truck_destructible;usa_gas_station_trash_bin_02;prop_photocopier_destructible_02;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Small bush;Big bush;Tree;File cabinet;Small generator;Oxygen Tank - Orange;Oxygen Tank - Green;Small transformer;Locker;Fuel barrel;TV;Green van;White van;White pickup;Small white car;Military vehicle;White truck;Trash bin;Photocopier;Broken File Cabinet;", ";");
        }

        // Add the remaining maps in the same style (following the exact same pattern):

        else if (level.currentMapName == "mp_nightshift")
        {
            level.propIDs = strtok("com_trashbin01;com_trashbin02;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;vehicle_uaz_open_destructible;vehicle_van_white_destructible;vehicle_bm21_cover_destructible;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Green trash bin;Black trash bin;Fire hydrant;Red newspaper box;Blue newspaper box;Military vehicle open;White car;Military truck;File cabinet;Broken File Cabinet;", ";");
        }

        else if (level.currentMapName == "mp_favela")
        {
            level.propIDs = strtok("utility_transformer_small01;vehicle_small_hatch_white_destructible_mp;vehicle_small_hatch_blue_destructible_mp;vehicle_pickup_destructible_mp;utility_water_collector;com_tv2;machinery_oxygen_tank01;machinery_oxygen_tank02;utility_transformer_ratnest01;foliage_tree_palm_bushy_3;com_firehydrant;com_newspaperbox_red;com_newspaperbox_blue;com_trashbin01;com_trashbin02;", ";");

            level.propNames = strtok("Small Transformer;Small white car;Small blue car;White pickup;Water Collector;TV;Oxygen Tank - Orange;Oxygen Tank - Green;Transformer;Palm tree;Fire hydrant;Red newspaperbox;Blue newspaperbox;Green trash bin;Black trash bin;", ";");
        }
        else if(level.currentMapName == "mp_rundown")
        {
            level.propIDs = strtok("com_tv1;com_tv2;com_trashbin01;com_trashbin02;com_trashcan_metal_closed;vehicle_small_hatch_white_destructible_mp;vehicle_small_hatch_blue_destructible_mp;vehicle_uaz_open_destructible;vehicle_bm21_mobile_bed_destructible;machinery_oxygen_tank01;machinery_oxygen_tank02;com_firehydrant;foliage_tree_palm_bushy_1;foliage_pacific_fern01_animated;utility_transformer_small01;utility_water_collector;utility_transformer_ratnest01;chicken_black_white;", ";");

            level.propNames = strtok("TV;TV 2;Green trash bin;Black trash bin;Metal trash bin;White car;Blue car;Russian military vehicle;Military truck;Oxygen Tank - Orange;Oxygen Tank - Green;Fire hydrant;Palm tree;Small bush;Small transformer;Water Collector;Transformer;Chicken black-white;", ";");
        }

        else if(level.currentMapName == "mp_crash")
        {
            level.propIDs = strtok("com_tv1;com_tv2;ma_flatscreen_tv_wallmount_01;ma_flatscreen_tv_wallmount_02;foliage_tree_river_birch_xl_a_animated;foliage_tree_palm_bushy_3;foliage_tree_river_birch_med_a_animated;utility_transformer_ratnest01;utility_transformer_small01;vehicle_80s_sedan1_brn_destructible_mp;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_pickup_destructible_mp;", ";");

            level.propNames = strtok("TV;TV 2;Flatscreen;Flatscreen 2;Birch Tree Tall;Palm Tree;Birch Tree Small;Transformer;Small Transformer;Brown Sedan;Green Sedan;Red Sedan;White Pickup;", ";");
        }

        else if(level.currentMapName == "mp_complex")
        {
            level.propIDs = strtok("usa_gas_station_trash_bin_02;usa_gas_station_trash_bin_02_base;ma_flatscreen_tv_on_02;ma_flatscreen_tv_on_wallmount_02_static;arcade_machine_1;arcade_machine_2;pinball_machine_1;pinball_machine_2;foliage_tree_green_pine_lg_b_animated;foliage_tree_green_pine_lg_a_animated;foliage_pacific_palms06_animated;foliage_pacific_tropic_shrub01_animated;vehicle_subcompact_black_destructible;vehicle_subcompact_slate_destructible;vehicle_pickup_destructible_mp;vehicle_coupe_blue_destructible;vehicle_coupe_white_destructible;vehicle_policecar_lapd_destructible;vehicle_moving_truck_destructible;", ";");

            level.propNames = strtok("Trashbin;Trashbin 2;Flatscreen;Flatscreen static;Arcade Machine;Arcade Machine 2;Pinball Machine;Pinball Machine 2;Pine;Pine 2;Small Palm;Tropic Palms;Black Car;Blue Car;White Pickup;Blue Coupe;White Coupe;Police Car;White Truck;", ";");
        }

        else if(level.currentMapName == "mp_overgrown")
        {
            level.propIDs = strtok("foliage_tree_river_birch_xl_a_animated;foliage_tree_river_birch_lg_a_animated;foliage_red_pine_xl_animated;foliage_red_pine_xxl_animated;foliage_red_pine_med_animated;foliage_tree_grey_oak_xl_a_animated;com_propane_tank02;furniture_gaspump01_damaged;", ";");

            level.propNames = strtok("Birch;Birch 2;Pine;Pine Tall;Pine Small;Tall Tree;Big Propane Tank;Gaspump;", ";");
        }

        else if(level.currentMapName == "mp_compact")
        {
            level.propIDs = strtok("com_locker_double;machinery_generator;com_filecabinetblackclosed;com_propane_tank02;machinery_oxygen_tank01;me_rooftop_tank_01;com_electrical_transformer_large_dam;com_tv1;com_filecabinetblackclosed_dam;", ";");

            level.propNames = strtok("Locker;Small Generator;File Cabinet;Big Propane Tank;Oxygentank Orange;Tank rooftop;Large Transformer;TV;Broken File Cabinet;", ";");
        }

        else if(level.currentMapName == "mp_trailerpark")
        {
            level.propIDs = strtok("prop_trailerpark_beer_keg;foliage_dead_pine_med_animated;foliage_dead_pine_lg_animated;com_propane_tank02;com_propane_tank03;machinery_oxygen_tank01;machinery_oxygen_tank02;com_trashbin02;machinery_generator;com_firehydrant;utility_transformer_ratnest01;utility_transformer_small01;vehicle_subcompact_gray_destructible;vehicle_coupe_white_destructible;vehicle_80s_hatch1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_delivery_truck_white;", ";");

            level.propNames = strtok("Beer keg;Tree;Tree 2;Big Propane Tank;Propane Tank;Orange Oxygen Tank;Green Oxygen Tank;Trashbin;Generator;Fire hydrant;Transformer;Small Transformer;Gray Car;White Coupe;Green Car;Red Car;White Truck;", ";");
        }

        else if(level.currentMapName == "mp_abandon")
        {
            level.propIDs = strtok("popcorn_cart;prop_trailerpark_beer_keg;usa_gas_station_trash_bin_01;trashcan_clown;foliage_tree_river_birch_xl_a_animated;arcade_machine_1;arcade_machine_1_des;arcade_machine_2;pinball_machine_1;pinball_machine_2;pinball_machine_2_des;fortune_machine;vehicle_theme_park_truck;", ";");

            level.propNames = strtok("Popcorn cart;Beer keg;Trashbin;Clown trashbin;Birch;Arcade Machine;Destroyed Arcade Machine;Arcade Machine 2;Pinball Machine;Pinball Machine 2;Destroyed Pinball Machine 2;Fortune Machine;Park Truck;", ";");
        }

        else if(level.currentMapName == "mp_storm")
        {
            level.propIDs = strtok("com_tv1;com_trashbin01;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;foliage_dead_pine_lg_animated;foliage_dead_pine_med_animated;foliage_tree_oak_1_animated2;vehicle_80s_wagon1_green_destructible_mp;vehicle_80s_sedan1_silv_destructible_mp;vehicle_80s_hatch2_yel_destructible_mp;vehicle_moving_truck_destructible;vehicle_mack_truck_short_white_destructible;", ";");

            level.propNames = strtok("TV;Trash bin;File cabinet;Broken File Cabinet;Tree;Tree 2;Tree 3;Green car;Silver car;Yellow car;White Truck;Big Truck;", ";");
        }

        else if(level.currentMapName == "mp_vacant")
        {
            level.propIDs = strtok("machinery_generator;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;foliage_tree_birch_red_1_animated;foliage_tree_river_birch_xl_a_animated;com_locker_double;utility_transformer_small01;vehicle_80s_sedan1_silv_destructible_mp;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_red_destructible_mp;vehicle_80s_sedan1_yel_destructible_mp;vehicle_uaz_hardtop_destructible_mp;com_propane_tank02;", ";");

            level.propNames = strtok("Generator;Green Oxygen tank;File cabinet;Broken File Cabinet;Birch;Birch 2;Locker;Small transformer;Silver car;Green car;Red car;Yellow car;Military vehicle;Big Propane tank;", ";");
        }

        else if(level.currentMapName == "mp_fuel2")
        {
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;com_trashbin02;machinery_generator;foliage_tree_palm_med_2;foliage_tree_palm_bushy_2;utility_transformer_small01;com_electrical_transformer_large_dam;com_propane_tank02_small;vehicle_uaz_hardtop_destructible_mp;vehicle_bm21_mobile_bed_destructible;", ";");

            level.propNames = strtok("Orange Oxygen tank;Green Oxygen tank;File cabinet;Broken File Cabinet;Trashbin;Generator;Palm;Bushy palm;Small transformer;Large transformer;Small Propane tank;Military vehicle;Military truck;", ";");
        }

        else if(level.currentMapName == "mp_strike")
        {
            level.propIDs = strtok("machinery_oxygen_tank01;machinery_oxygen_tank02;com_filecabinetblackclosed;com_filecabinetblackclosed_dam;machinery_generator;foliage_tree_river_birch_xl_a_animated;foliage_tree_palm_bushy_2;usa_gas_station_trash_bin_01;com_locker_double;com_trashcan_metal_closed;com_firehydrant;prop_photocopier_destructible_02;com_vending_can_new1_lit;com_vending_can_new2_lit;vehicle_80s_sedan1_green_destructible_mp;vehicle_80s_sedan1_brn_destructible_mp;vehicle_hummer_destructible;", ";");

            level.propNames = strtok("Orange oxygen tank;Green oxygen tank;Filecabinet;Broken filecabinet;Generator;Tree;Tall palm tree;Trashbin;Locker;Metal trashcan;Fire hydrant;Photocopier;Vending machine;Vending machine 2;Green car;Brown car;Hummer;", ";");
        }

        for(a=0;a<level.propIDs.size;a++) 
            precachemodel(level.propIDs[a]);
    }
