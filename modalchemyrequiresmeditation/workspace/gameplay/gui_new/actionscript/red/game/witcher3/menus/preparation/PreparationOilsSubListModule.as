/***********************************************************************
/** Journal tabs module : Base Version
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
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.menus.inventory.InventoryGrid;
	import red.game.witcher3.menus.common.JournalRewardModule;
	
	public class PreparationOilsSubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var tfSteelDescription : TextField;
		public var tfSilverDescription : TextField;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationOilsSubListModule()
		{
			dataBindingKey = "preparation.oils.sublist";
			dataBindingKeyReward = "preparation.oils.equipped.items";
			
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		override protected function Init() : void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.name', [handleModuleNameSet]));
			focused = 0;
			if(tfSteelDescription)
			{
				tfSteelDescription.htmlText = "[[panel_inventory_paperdoll_slotname_steel]]";
			}
			if(tfSilverDescription)
			{
				tfSilverDescription.htmlText = "[[panel_inventory_paperdoll_slotname_silver]]";
			}
		}

		override public function toString() : String
		{
			return "[W3 PreparationOilsSubListModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function GetDataBindingKey() : String // ?
		{
			return dataBindingKey;
		}
	}
}
