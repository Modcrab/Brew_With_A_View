/***********************************************************************
/** Tooltip stats list item renderer
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import red.core.CoreComponent;
	
	public class InventoryStatsListItem extends W3StatisticsListItem
	{
		public var mcIcon:MovieClip;
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			
			if (data)
			{
				if (mcIcon)
				{
					mcIcon.gotoAndStop(data.iconTag);
				}
				
				validateNow();
				
				
			}
		}
		
		override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					textField.htmlText = "<p align=\"right\">" + _label + "</p>";
					return;
				}
                textField.htmlText = _label;
            }
		}
	}
}