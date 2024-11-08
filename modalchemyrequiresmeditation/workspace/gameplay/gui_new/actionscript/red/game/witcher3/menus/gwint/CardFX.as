package red.game.witcher3.menus.gwint
{
	import scaleform.clik.core.UIComponent;
	
	public class CardFX extends UIComponent
	{
		public var instanceID:int;
		public var associatedCardInstance:CardInstance;
		public var finalFinishCallback:Function;
		public var cardFXManagerFinishCallback:Function;
		public var midFXPointCallback:Function;
		
		protected var _onCard:Boolean = true;
		[Inspectable(defaultValue=false)]
		public function get onCard() : Boolean { return _onCard }
		public function set onCard( value : Boolean ) : void
		{
			_onCard = value;
		}
		
		public function playFX():void
		{
			gotoAndPlay("play");
		}
		
		// #J Sometimes called from last frame of FX
		public function fxEnded():void
		{
			if (cardFXManagerFinishCallback != null)
			{
				cardFXManagerFinishCallback(this);
			}
		}
		
		// #J used by mushroom fx to mark half way point
		public function midFXPoint():void
		{
			if (midFXPointCallback != null)
			{
				midFXPointCallback(associatedCardInstance);
			}
		}
	}
}