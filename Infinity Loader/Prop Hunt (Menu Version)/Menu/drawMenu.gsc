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