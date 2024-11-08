/***********************************************************************
/** PANEL Crafting  main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.crafting
{
	import flash.display.MovieClip;
	import red.core.CoreMenu;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.menus.common.TextAreaModule;
	
	public class BaseCraftingMenu extends CoreMenu
	{
		public var 		mcAnchor_Tooltip		: MovieClip;
		
		public var      mcDropdownListModule	: DropdownListModuleBase;
		public var		mcCraftngModule			: CraftingSubListModule;
		public var      mcDescriptionModule 	: TextAreaModule;
		
		public function BaseCraftingMenu()
		{
			super();
			
			if (mcDropdownListModule)
				mcDropdownListModule.menuName = menuName;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			_contextMgr.defaultAnchor = mcAnchor_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
		}
	}

}