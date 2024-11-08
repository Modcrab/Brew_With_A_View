package red.game.witcher3.hud.modules
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import scaleform.clik.controls.StatusIndicator;
	
	public class HudModuleTimeLeft extends HudModuleBase
	{
		public var mcDialogueBar:StatusIndicator;

		public function HudModuleTimeLeft()
		{
			super();
		}

		override public function get moduleName():String
		{
			return "TimeLeftModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		public function setTimeOutPercent( timeOutPercent : Number )
		{
			mcDialogueBar.value = timeOutPercent;
		}
	}
}