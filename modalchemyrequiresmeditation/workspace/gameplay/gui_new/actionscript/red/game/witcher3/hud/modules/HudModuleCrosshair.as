package red.game.witcher3.hud.modules
{
	import red.core.events.GameEvent;

	public class HudModuleCrosshair extends HudModuleBase
	{
		public function HudModuleCrosshair()
		{
			super();
		}

		override public function get moduleName():String
		{
			return "CrosshairModule";
		}

		override protected function configUI():void
		{
			super.configUI();

			visible = true;
			alpha = 0;

			//registerDataBinding('hud.questupdate', OnQuestUpdate);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		override public function SetScaleFromWS( scale : Number ) : void
		{
		}
	}

}
