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

    while (isDefined(self.propModel))
    {
        self.propModel.origin = self.origin;
        wait 0.05;
    }
}

propBindInst()
{
    self endon("disconnect");
    self endon("game_ended");
    
    bindInst = self createFontString("objective", 1.2);
    bindInst.x = 5;
    bindInst.y = 15;
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

        if (!isDefined(self.frozen)) self.frozen = 0;

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

        if (self.allowedDecoys > 0 && !self.menu["vars"]["open"])
        {
            decoy = spawn("script_model", self.origin);
            decoy setModel(self.propModelName);
            decoy.angles = self.angles;
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

monitorDecoyDamage(owner)
{
    self endon("death");

    self.health = 75;
    self.maxhealth = self.health;
    self setCanDamage(true);

    for(;;)
    {
        self waittill("damage", damage, attacker, direction_vec, point, type);

        if (isPlayer(attacker) && type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET")
        {
            self.health -= damage;

            if (self.health <= 0)
            {
                playFx( level._effect["money"], self.origin);

                self delete();
                return;
            }
        }
    }
}

stunBind(allowedStuns)
{
    self endon ("disconnect");
    self notifyonplayercommand("dropStun", "+smoke");

    for(;;)
    {
        self waittill("dropStun");

        if(self.allowedStuns != 0 && !self.menu["vars"]["open"])
        {
            nearestDist = 500;
            
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
                    nearestPlayer thread maps\mp\_flashgrenades::applyflash(4, 0);
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
