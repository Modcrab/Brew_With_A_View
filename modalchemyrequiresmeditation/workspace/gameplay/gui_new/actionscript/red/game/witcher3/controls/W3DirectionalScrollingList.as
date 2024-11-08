/***********************************************************************
/** Base scrolling list
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListPreset;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;

	// red.game.witcher3.controls.W3DirectionalScrollingList
	// #Y We shouldn't use custom list class for this screen!
	public class W3DirectionalScrollingList extends SlotsListPreset
	{
		
		override public function set focused(value:Number):void
		{
			// always in focus
			super.focused = 1;
		}
		
		override public function SearchForNearestSelectableIndexInDirection(navCode:String):int
		{
			var minXValue:Number = -1;
			var maxXValue:Number = -1;
			var minYValue:Number = -1;
			var maxYValue:Number = -1;
			
			var currentSelectedSlot:SlotBase = getSelectedRenderer() as SlotBase;
			
			if (!currentSelectedSlot)
			{
				return -1;
			}
			
			var currentSlot:SlotBase = currentSelectedSlot;
			var closestSlot:SlotBase = null;
			var nextIdx:int = 0;
			
			while (closestSlot == null && currentSlot != null && nextIdx != -1)
			{
				nextIdx = currentSlot.GetNavigationIndex(navCode);
				
				if (nextIdx != -1)
				{
					closestSlot = getRendererAt(nextIdx) as SlotBase;
					currentSlot = closestSlot;
				}
				
				if (closestSlot && !closestSlot.selectable)
				{
					closestSlot = null;
				}
			}
			
			if (closestSlot != null)
			{
				return _renderers.indexOf(closestSlot);
			}
			
			return super.SearchForNearestSelectableIndexInDirection(navCode);
		}
		
	}
}

