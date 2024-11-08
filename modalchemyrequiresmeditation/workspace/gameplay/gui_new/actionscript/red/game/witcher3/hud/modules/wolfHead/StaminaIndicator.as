package red.game.witcher3.hud.modules.wolfHead
{
	import flash.display.MovieClip;
	import red.game.witcher3.hud.modules.wolfHead.W3StatIndicator;

	public class StaminaIndicator extends W3StatIndicator
	{
		public var mcAmount : MovieClip;
		public var mcStaminaBarFill : MovieClip;

		public function ShowAmountNeeded( percent : Number )
		{
			mcAmount.gotoAndStop( Math.floor( percent * 100 ) );
		}

		public function HideAmountNeeded()
		{
			mcAmount.gotoAndStop( 1 );
		}

		public function SetStaminaBarGraphic( value : String )
		{
			mcStaminaBarFill.gotoAndStop( value );
		}
	}
}