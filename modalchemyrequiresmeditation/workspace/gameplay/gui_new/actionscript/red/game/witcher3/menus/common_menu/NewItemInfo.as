/***********************************************************************
/** MenuHub - Item Info
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3UILoader
	import scaleform.clik.core.UIComponent;

	public class NewItemInfo extends UIComponent
	{
		public var mcLoader : W3UILoader;
		public var tfItemName : TextField;
		public var tfItemType : TextField;
		private var _gap : Number;

		override protected function configUI():void
		{
			visible = false;
			//_gap = tfItemType.y - tfItemName.y + tfItemName.textHeight;
			_gap = 10;
			super.configUI();
			mcLoader.addEventListener(Event.COMPLETE, handleComplete, false, 0, true);
		}

		public function SetItemIcon( value : String ) : void
		{
			mcLoader.source =  "img://" + value;
		}

		public function SetItemName( value : String ) : void
		{
			tfItemName.htmlText = value;
		}
		
		public function handleComplete(event:Event):void
		{
			if (tfItemName.textHeight <  mcLoader.content.height)
			{
				tfItemName.y = mcLoader.y + mcLoader.content.height / 2 - tfItemName.textHeight / 2;
			}
			else
			{
				tfItemName.y = mcLoader.y;
			}
		}

		public function SetItemType( value : String ) : void
		{
			//tfItemType.htmlText = value;
			//tfItemType.y = tfItemName.y + tfItemName.textHeight + _gap;
		}
	}
}
