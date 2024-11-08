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
	
	public class KeybindItemRenderer extends BaseListItem
	{
		public var txtKeybind:TextField;
		public var isReset:Boolean;
		public var mcLockedIcon:MovieClip;

		protected var _safetiesEnabled:Boolean = true;
		public function set safetiesEnabled(value:Boolean):void
		{
			_safetiesEnabled = value;
			
			if (data && data.locked)
			{
				mcLockedIcon.visible = _safetiesEnabled || data.permaLocked;
			}
			else
			{
				mcLockedIcon.visible = false;
			}
		}
		
		override public function setData( data:Object ):void
		{
			super.setData(data);
			
			if (data)
			{
				if (data.label == "resetToDefault")
				{
					label = "";
					isReset = true;
				}
				else
				{
					label = data.label;
					isReset = false;
				}
				
				if (mcLockedIcon)
				{
					mcLockedIcon.visible = data.locked && (_safetiesEnabled || data.permaLocked);
				}
			}
			else
			{
				if (mcLockedIcon)
				{
					mcLockedIcon.visible = false;
				}
				label = "";
				isReset = false;
			}
		}
		
		override protected function updateText():void 
		{
			super.updateText();
			
			if (data)
			{
				txtKeybind.htmlText = data.value;
			}
			else
			{
				txtKeybind.htmlText = "";
			}
		}
	}
}