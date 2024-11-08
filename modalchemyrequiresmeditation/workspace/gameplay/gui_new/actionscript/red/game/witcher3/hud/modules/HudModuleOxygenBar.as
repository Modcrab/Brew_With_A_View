package red.game.witcher3.hud.modules
{
	import fl.motion.easing.*;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.StatusIndicator;
	import red.game.witcher3.utils.CommonUtils;

	public class HudModuleOxygenBar extends HudModuleBase
	{
		public var mcOxygeneBar:StatusIndicator;
		public var textField : TextField;

		private static const BAR_LERP_SPEED:Number = 1000;
		private static const FADE_IN_DURATION:Number = 1000;

		public function HudModuleOxygenBar()
		{
			super();
			isAlwaysDynamic = true;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "OxygenBarModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();

			visible = false;
			alpha = 0;
			textField.htmlText = "[[panel_hud_breath]]";
			textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setOxygene( _Percentage:Number ):void
		{
			mcOxygeneBar.value = _Percentage * 100;
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function reset():void
		{
			mcOxygeneBar.value = 100;
		}

	}

}

