/***********************************************************************
/** Navigation Module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.core.CoreComponent;
	import scaleform.clik.data.DataProvider;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	
	public class MessageModule extends CoreComponent
	{
		public var mcContainer : MovieClip;
		
		public function MessageModule()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "message.text", [handleSetMessage]));
		}
		
		public function handleSetMessage( value : String ) : void
		{
			if (mcContainer)
			{
				if (mcContainer.tfMessage)
				{
					mcContainer.tfMessage.htmlText = value;
					mcContainer.gotoAndPlay(2);
				}
			}
		}
	}
}
