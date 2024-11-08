/***********************************************************************
/** PANEL Inventory main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.preparation
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	
	//import red.game.witcher3.menus.character.CharacterTabsModule; 
	import red.game.witcher3.menus.inventory.ButtonContainerModule;
	import red.game.witcher3.menus.inventory.FloatingTooltipModule;
	
	public class PreparationOilsMenu extends PreparationMenuBase
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcOilsSubList : PreparationOilsSubListModule;
		
		public var mcAnchor_MODULE_OilsSubList : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationOilsMenu()
		{
			super();
		}

		override protected function get menuName():String
		{
			return "PreparationOilsMenu";
		}
		
		override protected function configUI():void
		{
			_inputHandlers.push(mcOilsSubList);
			super.configUI();
			
			focusList.push(mcOilsSubList);
		}
		
		override function LoadModules() : void
		{
			var modules : Vector.<MovieClip>  = mcPanelModuleManager.GetModules();
			
			mcButtonContainerModule = modules[2] as ButtonContainerModule;
			mcButtonContainerModule.validateNow();
			_inputHandlers.push(mcButtonContainerModule);
			
			mcFloatingTooltipsModule = modules[3] as FloatingTooltipModule;
			mcFloatingTooltipsModule.validateNow();
			
			setChildIndex(mcFloatingTooltipsModule, numChildren-1); //#B Tooltips are always displayed in foreground
		}
	}
}
