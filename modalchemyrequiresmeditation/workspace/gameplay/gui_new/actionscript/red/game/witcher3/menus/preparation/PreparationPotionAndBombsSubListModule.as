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
	
	public class PreparationPotionAndBombsSubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var tfPotionsDescription : TextField;
		public var tfPocketsDescription : TextField;
		public var mcPotionsGrid : InventoryGrid;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationPotionAndBombsSubListModule()
		{
			dataBindingKey = "preparation.potionsandbombs.sublist";
			dataBindingKeyReward = "preparation.bombs.equipped.items";
			
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			var indexNavigation:Boolean = true;
			mcPotionsGrid.indexNavigation = indexNavigation;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "preparation.potions.equipped.items", [handlePotionsDataSet]));
			mcPotionsGrid.resetRenderers();
			mcPotionsGrid.addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
		}
		
		override protected function Init() : void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.name', [handleModuleNameSet]));
			focused = 0;
			if(tfPotionsDescription)
			{
				tfPotionsDescription.htmlText = "[[panel_preparation_potions_slots_description]]";
			}
			if(tfPocketsDescription)
			{
				tfPocketsDescription.htmlText = "[[panel_preparation_bombs_slots_description]]";
			}
		}

		override public function toString() : String
		{
			return "[W3 PreparationPotionAndBombsSubListModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function GetDataBindingKey() : String // ?
		{
			return dataBindingKey;
		}
		
		protected function handlePotionsDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			
			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcPotionsGrid.populateData(dataArray);
				}
			}
			else if (gameData)
			{
				mcPotionsGrid.populateData(dataArray);
			}
		}
		
		override public function set focused(value:Number):void
		{
            if (value == _focused || !_focusable)
			{
				return;
			}
            super.focused = value;

			//mcList.focused = value;
		}
		
		override public function SetAsActiveContainer( value : Boolean )
		{
			super.SetAsActiveContainer( value );
			if ( !value )
			{
				mcPotionsGrid.selectedIndex = -1;
				mcPotionsGrid.focused = 0;
			}
			else
			{
				mcPotionsGrid.selectedIndex = 0;
				mcPotionsGrid.focused = 0;
				mcRewardGrid.focused = 1;
				mcRewardGrid..selectedIndex = -1;
			}
		}
		
		override public function handleInput( event:InputEvent ):void 
		{
			if ( event.handled )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
						
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.LEFT:
						if (mcRewardGrid.focused)
						{
							if ( mcRewardGrid.selectedIndex == 0 || mcRewardGrid.selectedIndex == 2 )
							{
								mcPotionsGrid.focused = 1;
								mcPotionsGrid.selectedIndex = mcRewardGrid.selectedIndex + 1;
								mcRewardGrid.focused = 0;
								mcRewardGrid.selectedIndex = -1;
							}
						}
						if (mcPotionsGrid.focused)
						{
							if ( mcPotionsGrid.selectedIndex == 0 || mcPotionsGrid.selectedIndex == 2 )
							{
								mcRewardGrid.focused = 1;
								mcRewardGrid.selectedIndex = mcPotionsGrid.selectedIndex + 1;
								mcPotionsGrid.focused = 0;
								mcPotionsGrid.selectedIndex = -1;
							}
						}
						return;
					case NavigationCode.RIGHT:
						if (mcRewardGrid.focused)
						{
							if ( mcRewardGrid.selectedIndex == 1 || mcRewardGrid.selectedIndex == 3 )
							{
								mcPotionsGrid.focused = 1;
								mcPotionsGrid.selectedIndex = mcRewardGrid.selectedIndex - 1;
								mcRewardGrid.focused = 0;
								mcRewardGrid.selectedIndex = -1;
							}
						}
						if (mcPotionsGrid.focused)
						{
							if ( mcPotionsGrid.selectedIndex == 1 || mcPotionsGrid.selectedIndex == 3 )
							{
								mcRewardGrid.focused = 1;
								mcRewardGrid.selectedIndex = mcPotionsGrid.selectedIndex - 1;
								mcPotionsGrid.focused = 0;
								mcPotionsGrid.selectedIndex = -1;
							}
						}
						return;

				}
			}
		}
	}
}
