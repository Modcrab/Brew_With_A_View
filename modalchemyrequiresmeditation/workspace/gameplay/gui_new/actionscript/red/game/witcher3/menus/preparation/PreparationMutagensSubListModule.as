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
	
	public class PreparationMutagensSubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var tfDescription : TextField;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationMutagensSubListModule()
		{
			dataBindingKey = "preparation.mutagens.sublist";
			dataBindingKeyReward = "preparation.mutagens.equipped.items";
			
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
			if(tfRewards)
			{
				tfRewards.htmlText = "[[panel_preparation_mutagens_slots_description]]";
			}
		}

		override public function toString() : String
		{
			return "[W3 PreparationMutagensSubListModule]"
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
