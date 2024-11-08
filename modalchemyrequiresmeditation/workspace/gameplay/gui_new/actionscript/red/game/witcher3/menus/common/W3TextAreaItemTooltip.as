/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.core.CoreMenuModule;
	import red.game.witcher3.tooltips.TooltipItem;
	import red.game.witcher3.controls.W3TextArea;
	import red.core.events.GameEvent;
	
	public class W3TextAreaItemTooltip extends W3TextArea
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
		
		public function W3TextAreaItemTooltip()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
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
			var parentModule : CoreMenuModule;
			parentModule = parent as CoreMenuModule;
			parentModule.handleDataChanged();
		}
	}
}
