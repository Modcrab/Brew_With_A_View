package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.StatusIndicator;
	import red.game.witcher3.utils.CommonUtils;

	public class HudModuleHorsePanicBar extends HudModuleBase
	{
		public var 				mcPanicBar:StatusIndicator;
		public var 				textField:TextField;
		private static const BAR_LERP_SPEED:Number = 1000;
		private static const FADE_IN_DURATION:Number = 1000;

		public function HudModuleHorsePanicBar()
		{
			super();
			isAlwaysDynamic = true;
		}

		override public function get moduleName():String
		{
			return "HorsePanicBarModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			visible = true;
			alpha = 0.0;
			textField.htmlText = "[[panel_hud_horse_panic]]";
			textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setPanic( _Percentage:Number ):void
		{
			mcPanicBar.value = _Percentage * 100;
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function reset():void
		{
			mcPanicBar.value = 0;
		}
	}

}
