/***********************************************************************
/** Later
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	
	public class StatsTooltip extends UIComponent
	{
		public var tfItemName:TextField;
		public var tfItemDescription:TextField;
	
		public var dataBindingKey : String = "stats";
		
		public function StatsTooltip()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			mouseEnabled = mouseChildren = false; //#B to avoid flickering
			dispatchEvent( new GameEvent(GameEvent.REGISTER, dataBindingKey+".title", [SetTitle]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER,  dataBindingKey+".description", [SetDescription]));
		}
		
		override public function toString():String
		{
			return "[W3 StatsTooltip: ]";
		}
		
		public function SetTitle( value : String ) : void
		{
			tfItemName.htmlText = value;
		}
		
		public function SetDescription( value : String ) : void
		{
			tfItemDescription.htmlText = value;
		}
	}
}