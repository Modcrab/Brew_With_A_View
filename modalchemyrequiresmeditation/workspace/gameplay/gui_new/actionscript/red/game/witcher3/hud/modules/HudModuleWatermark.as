package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	
	
	public class HudModuleWatermark extends HudModuleBase
	{
		public function HudModuleWatermark()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "WatermarkModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			
			/*x = 470.55;
			y = 55.05;
			z = 100;
			scaleX = 1;
			scaleY = 1;*/
			visible = true;
			alpha = 0;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
	}
	
}
