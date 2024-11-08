/***********************************************************************
/** Inventory Player grid module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.preparation
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.menus.character.CharacterTabsModule;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	
	public class PreparationTabsModule extends CharacterTabsModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var mcTabListItem3 : TabListItem;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationTabsModule()
		{
			super();
			dataBindingKey = "preparation.main.tabs";
			filterEventName = "OnPreparationTabSelected";
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function Init() : void
		{
			mcTabList.dataProvider = new DataProvider( [ { icon:"POTIONS" }, { icon:"QUEST_ITEMS" }, { icon:"WEAPONS" }] );
			mcTabList.ShowRenderers(true);
			mcTabList.addEventListener( ListEvent.INDEX_CHANGE, OnTabListItemClick, false, 0, true ); // #B maybe shuld be Event change ?
			mcTabList.selectedIndex = 0;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".tab.selected", [handleForceSelectTab]));
			
			_inputHandlers.push(mcTabList);;
			focused = 1;
		}

		override public function toString() : String
		{
			return "[W3 PreparationTabsModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
	}
}
