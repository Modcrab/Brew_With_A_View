/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.BaseListItem;
	
	public class InstalledDLCMItemRenderer extends BaseListItem
	{
		override public function setData( data:Object ):void
		{
			super.setData(data);
		}
		
		public function getDLCDescription():String
		{
			if (data)
			{
				return data.desc;
			}
			
			return "";
		}
	}
}