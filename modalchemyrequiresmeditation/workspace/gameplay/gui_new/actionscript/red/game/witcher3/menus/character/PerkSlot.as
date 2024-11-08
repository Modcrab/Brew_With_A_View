/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	
	import red.game.witcher3.data.GridData;
	import scaleform.clik.events.DragEvent;
	import scaleform.clik.constants.NavigationCode;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3BaseSlot;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	
	public class PerkSlot extends W3BaseSlot implements IGridItemRenderer
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		//public var tfSlotName : TextField;
		//public var mcAccept:MovieClip;
		//public var mcSlotHighlight:MovieClip;
		public var mcBackground : MovieClip;
		
    	/********************************************************************************************************************
			COMPONENT PROIPERTIES
		/ ******************************************************************************************************************/
		
    	/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PerkSlot()
		{
			super();
		}
		
		override protected function configUI() : void
		{
			super.configUI();
		}
		
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/
					
		public function get uplink():IGridItemRenderer
		{
			return null;
		}
		
		public function set uplink( value:IGridItemRenderer ):void
		{
		}
		
		public function get gridSize():int
		{
			return 1;
		}
				
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
		override protected function update():void
		{
			if ( data )
			{
				updateAcquired();
			}
		}
		
		protected function updateAcquired()
		{
			if ( mcBackground )
			{
				if(data.acquired)
				{
					mcBackground.gotoAndStop('acquired');
				}
				else
				{
					mcBackground.gotoAndStop('available');
				}
			}
		}
		
		override public function toString():String
		{
			return "[W3 PerkSlot: " + ", index " + _index + "]";
		}

		/********************************************************************************************************************
			UPDATES & CALLBACKS
		/ ******************************************************************************************************************/

	}
}