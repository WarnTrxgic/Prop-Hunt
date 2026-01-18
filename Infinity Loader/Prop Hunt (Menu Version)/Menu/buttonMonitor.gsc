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
        self.buttonAction = ["+stance","+gostand","weapnext","+actionslot 1","+actionslot 2","+actionslot 3","+actionslot 4"];
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