
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
 
