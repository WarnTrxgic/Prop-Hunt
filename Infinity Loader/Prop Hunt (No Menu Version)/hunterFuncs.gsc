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