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