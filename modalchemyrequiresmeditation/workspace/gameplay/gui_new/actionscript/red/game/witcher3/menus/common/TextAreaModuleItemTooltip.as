/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.game.witcher3.tooltips.TooltipItem;
	import red.core.events.GameEvent;
	
	public class TextAreaModuleItemTooltip extends TextAreaModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcCraftedItemTooltip : TooltipItem;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function TextAreaModuleItemTooltip()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			mcCraftedItemTooltip.lockFixedPosition = true;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.item.data', [handleCraftedItemDataSet]));
		}

		override public function toString() : String
		{
			return "[W3 W3TextAreaItemTooltip]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		
		protected function handleCraftedItemDataSet( gameData:Object, index:int ):void
		{
			mcCraftedItemTooltip.data = gameData;
		}
	}
}
