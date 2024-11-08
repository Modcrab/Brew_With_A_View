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
	
	public class PreparationMutagensMenu extends PreparationMenuBase
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcToxicityBarModule : PreparationToxicityBarModule;
		public var mcMutagensSubList : PreparationMutagensSubListModule;
		
		public var mcAnchor_Module_ToxicityBar : MovieClip;
		public var mcAnchor_MODULE_MutagensSubList : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationMutagensMenu()
		{
			super();
		}

		override protected function get menuName():String
		{
			return "PreparationMutagensMenu";
		}
		
		override protected function configUI():void
		{
			_inputHandlers.push(mcMutagensSubList);
			super.configUI();
			
			focusList.push(mcMutagensSubList);
		}
		
		override function LoadModules() : void
		{
			var modules : Vector.<MovieClip>  = mcPanelModuleManager.GetModules();
			
			mcButtonContainerModule = modules[3] as ButtonContainerModule;
			mcButtonContainerModule.validateNow();
			_inputHandlers.push(mcButtonContainerModule);
			
			mcFloatingTooltipsModule = modules[4] as FloatingTooltipModule;
			mcFloatingTooltipsModule.validateNow();
			
			setChildIndex(mcFloatingTooltipsModule, numChildren-1); //#B Tooltips are always displayed in foreground
		}
	}
}
