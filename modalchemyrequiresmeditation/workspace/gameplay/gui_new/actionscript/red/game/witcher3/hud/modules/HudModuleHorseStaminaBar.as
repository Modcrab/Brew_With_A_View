package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.StatusIndicator;
	import red.game.witcher3.utils.CommonUtils;

	public class HudModuleHorseStaminaBar extends HudModuleBase
	{
		public var 				mcStaminaBar:StatusIndicator;
		public var 				textField:TextField;
		private static const BAR_LERP_SPEED:Number = 1000;
		private static const FADE_IN_DURATION:Number = 1000;

		public function HudModuleHorseStaminaBar()
		{
			super();
			isAlwaysDynamic = true;
		}

		override public function get moduleName():String
		{
			return "HorseStaminaBarModule";
		}

		override protected function configUI():void
		{
			super.configUI();

			visible = false;
			alpha = 0.0;

			//var horseStaminaStr : String = "[[panel_hud_horse_stamina]]";
			textField.htmlText = "[[panel_hud_horse_stamina]]";
			textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setStamina( _Percentage:Number ):void
		{
			mcStaminaBar.value = _Percentage * 100;
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function reset():void
		{
			mcStaminaBar.value = 100;
		}

		public function ShowStaminaIndicator( value : Number, maxValue : Number ) : void
		{
			//mcStaminaBar.percentNeeded =  maxValue > 0.0 ? value / maxValue : 0.0;
		}
	}

}
