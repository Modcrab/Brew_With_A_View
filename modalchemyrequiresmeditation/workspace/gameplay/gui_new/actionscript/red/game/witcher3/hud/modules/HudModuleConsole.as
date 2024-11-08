package red.game.witcher3.hud.modules
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.console.ConsoleMessagesQueue;
	import red.game.witcher3.hud.modules.console.ConsoleMessageItem;
	import scaleform.gfx.Extensions;
	
	/**
	 * Simple module for displaying text messages
	 * @author Yaroslav Getsevich
	 */
	public class HudModuleConsole extends HudModuleBase
	{
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			alpha = 0;
		}
		
		override public function get moduleName():String
		{
			return "ConsoleModule";
		}
		
		public function /* WitcherScript */ showMessage(msgText:String):void
		{
			if ( visible )
			{
				messagesQueue.pushMessage(msgText);
			}
			
		}
		
		public function /* WitcherScript */ cleanup():void
		{
			//messagesQueue.cleanup();
		}
		
		public function /* WitcherScript */ debugMessage():void
		{
			//"<b>foo</b> <img src='" + "ICO_noonrain" + "'/>"; //
			var postfix:String = "Customized <img src = 'icons/inventory/raspberryjuice_64x64.dds' /> to fit any desired style or theme!"; //The CLIK component tools accelerate the design
			messagesQueue.pushMessage("Some <font color = '#FF5555'>message</font> " + Math.round(Math.random()*1000) + postfix);
		}
	}
}
