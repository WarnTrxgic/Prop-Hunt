loadMenus()
{
    self addMenu("Main", "none", self.menu["vars"]["currOpt"]);

    for(a=0;a<level.propIDs.size;a++)
        self addOption("Main", level.propNames[a], a, ::setProp, level.propIDs[a]);
}
