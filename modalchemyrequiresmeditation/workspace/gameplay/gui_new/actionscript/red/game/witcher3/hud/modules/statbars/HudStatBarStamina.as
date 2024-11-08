package red.game.witcher3.hud.modules.statbars
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	import scaleform.clik.constants.InvalidationType;
	
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class HudStatBarStamina extends HudStatBar
	{
		
	//{region Art clips
	// ------------------------------------------------
	
		public var mcBarNeed:MovieClip;
		public var mcMaskNeeded:MovieClip;
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
	//{region Internal properties
	// ------------------------------------------------
	
	//{region Component properties
	// ------------------------------------------------
	
		protected var _percentNeeded : Number = NaN;
	
	//{region Component setters/getters
	// ------------------------------------------------
	
		public function get percentNeeded():Number
		{
			return _percent;
		}
		
		public function set percentNeeded( value:Number ):void
		{
			var clampedValue:Number = Math.min( 1.0, Math.max( 0.0, value ) );
			_percentNeeded = clampedValue;
			
			mcBarNeed.gotoAndPlay(2);
			//trace("Bidon: !!!!!!!!!!! should show indicator for stamina");
			invalidateData();			
		}
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudStatBarStamina()
		{
			super();
		}
	
	//{region Public functions
	// ------------------------------------------------
	
		override public function reset():void
		{
			super.reset();
			/*_percent = _newPercent = _oldPercent = NaN			
			TweenEx.pauseTweenOn( mcMask );
			if ( mcSelection )
			{
				TweenEx.pauseTweenOn( mcSelection );
			}*/
		}
	
	//{region Overrides
	// ------------------------------------------------
				
		override protected function draw():void
		{
			if ( isInvalid( InvalidationType.DATA ) )
			{
				if ( ! isNaN( _percentNeeded ) )
				{
					updateToLowStaminaIndicator();
				}
			}
			super.draw();
		}
	
	//{region Updates
	// ------------------------------------------------
		
		private function updateToLowStaminaIndicator():void
		{	
			if ( isNaN( _percentNeeded ) )
			{
				throw new Error( "_percentNeeded was updated with NaN" );
			}
			
			var newPosX:Number = _originalMaskPosX - ( 1.0 - _percentNeeded ) * mcMaskNeeded.width;
			mcMaskNeeded.x = newPosX;		
		}
	}	
}