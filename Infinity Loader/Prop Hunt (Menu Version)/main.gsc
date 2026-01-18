/*
    Welcome to Prop Hunt!
        by Warn Trxgic

    /////////////////////////////////////////////////////////////////////////
    |                                                                       |
    |   Credits:                                                            |
    |   * Menu Base by Leafized                                             |
    |   * Prop Names from FreeTheTech 101                                   |
    |       https://github.com/FreeTheTech101/IW4-Dump-Files/blob/master    |
    |   * xhju for help w/ autoassign, rotate binds, and decoy destroying   |
    |                                                                       |                  
    /////////////////////////////////////////////////////////////////////////
*/

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;

init()
{
    level.strings = [];
    level.currentGametype      = getDvar("g_gametype");
    level.currentMapName       = getDvar("mapName");

    if(level.currentGametype != "sd")
        return;

    level.callDamage           = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::modifyPlayerDamage;
    level.callKilled           = level.callbackPlayerKilled;
    level.callbackPlayerKilled = ::modifyPlayerKilled;
    setDvar("teamProps", self.team);
    setDvar("teamHunters", self.team);
    setDvar("scr_game_graceperiod", .5);
    setDvar("scr_sd_winlimit", 4); //change if you want more rounds (sets round win limit)
    setDvar("scr_sd_timelimit", 6); //change if you want longer rounds (sets round time limit)
    setDvar("scr_sd_roundswitch", 1); //change if you want more rounds as props (makes teams switch after every round)
    setDvar("ui_allow_classchange", 0);
    setDvar("ui_allow_teamchange", 0);
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

        player SetClientDvar("motd", "Welcome to ^2Prop ^1Hunt^7! ^7|| Made By: ^1Warn Trxgic");
        player thread doTeamCheck();
        player thread isMapSupported();
        player thread doTeamNames();
        player thread getPropsAliveCount();
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

        self thread isMapSupported();

        if(level.supportedMap)
        {
            if(self.pers["team"] == game["defenders"])
            {
                setDvar("teamProps", self.team);
                self thread initmenu();
                self thread teamSetup("props");
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

isMapSupported()
{
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

teamSetup(team)
{
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
        self thread spinLeftBind();
        self thread spinRightBind();
        self thread freezeBind();
        self thread spawnDecoyBind();
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
        self takeAllWeapons();
    }
    else if(team == "hunters")
    {
        self VisionSetNakedForPlayer("blacktest", 0.5);
        self freezeControls(true);
        self thread lastPropPing();
        self thread maps\mp\gametypes\_hud_message::hintMessage("Welcome to ^2Prop ^1Hunt^7!");
        wait 1;
        self thread maps\mp\gametypes\_hud_message::hintMessage("You're a ^1Hunter^7!");
        self clearPerks();
        level waittill("huntersReleased");
        self VisionSetNakedForPlayer(level.currentMapName, 2);
        self takeAllWeapons();
        self doHunterLoadout();
        self freezeControls(false);
    }
}

modifyPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{        
    if(sMeansOfDeath == "MOD_FALLING")
        iDamage = 0;

    thread maps\mp\gametypes\_damage::Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

modifyPlayerKilled( eInflictor, eattacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
    if(self.team == getDvar("teamProps") && isDefined(self.propModel))
        self.propModel delete();

    thread maps\mp\gametypes\_damage::Callback_PlayerKilled( eInflictor, eattacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
}

TimerStart()
{
	self endon("disconnect");

    level.TimerText = level createServerFontString("objective", 1.5);
	level.TimerText setPoint("CENTER", "CENTER", 0, -60, 0);

	for(;;)
	{
		level waittill("prematch_over");

		level.Timer = 45;
		while(level.Timer > 0)
		{
            level.TimerText setText("^1Hunters ^7released in: ^2" + level.Timer);
			wait 1;
			level.Timer--;
		}
        level notify("huntersReleased");
		level.TimerText setText("^1Hunters ^7Released!");
		wait 3;
        level.TimerText setText("");
        wait 1;
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
    
    level waittill("prematch_over");
    waittillframeend;
    
    level.customTimer.hidewheninkillcam = 1;
    level.customTimer = createServerTimer("hudbig", 1);
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
    return getDvarFloat( "scr_" + level.currentGametype + "_timelimit" );
}

disablePlayerCollisions()
{
    #ifdef MW2
        WriteInt(0x821D29A0, 0x60000000); //Push back when passing through another player(ClientEndFrame -> call to StuckInClient)
        WriteInt(0x8225FB04, 0x60000000); //Player collision with other players(SV_ClipMoveToEntity -> call to CM_TransformedCapsuleTrace)
    #endif
}