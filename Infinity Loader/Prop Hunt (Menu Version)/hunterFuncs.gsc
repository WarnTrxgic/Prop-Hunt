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
    hunters = getDvar("teamHunters");
    initialTime = int( (getTimeRemaining() / 1000.0) - 1 );

    level waittill("prematch_over");

    if(!spawnWaitOver)
    {
        wait 5;
        spawnWaitOver = 1;
    }

    if(self.team == hunters)
    {
        if(getPropsAliveCount() == 1 || initialTime == 30 || !self.hunterUAVDone)
        {
            self thread maps\mp\killstreaks\_uav::launchUav(self, hunters, 5, false);
            self.hunterUAVDone = 1;
        }
    }
}

getPropsAliveCount()
{
    propCount = 0;
    
    foreach(player in level.players)
    {
        if(player.team == getDvar("teamProps") && isAlive(player))
            propCount++;
    }
    
    return propCount;
}