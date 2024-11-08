package red.game.witcher3.hud.modules.statbars
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class HudStatBarToxicity extends HudStatBar
	{
		
	//{region Art clips
	// ------------------------------------------------
	
	/*	public var mcMask:MovieClip;
		public var mcBar:MovieClip;
		public var mcSelection:MovieClip;*/
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
		private var _maxMaskRot : Number = 55;
	
	//{region Internal properties
	// ------------------------------------------------		
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudStatBarToxicity()
		{
			super();
		}
	
	//{region Updates
	// ------------------------------------------------
		
		private function updatePercent():void
		{	
			if ( isNaN( _percent ) )
			{
				throw new Error( "_percent was updated with NaN" );
			}
			
			var newRotZ:Number = _maxMaskRot -  _percent * _maxMaskRot;
			
			TweenEx.pauseTweenOn( mcMask );
			
			// Don't lerp if the player should see dangerous changes ASAP or if the bar is being set for the first time
			var giveImmediateFeedback:Boolean = isNaN( _oldPercent ) || _moreIsBetter ? ( _percent < _oldPercent ) : ( _percent > _oldPercent );
			
			giveImmediateFeedback = true; // # FIXME BIDON - > when we allow tweening bar start to acts strange (like shaking - > jump from 65 to 51 then to 66 etc :P )
			
			if ( giveImmediateFeedback )
			{
				mcMask.rotationZ = newRotZ;
			}
			else
			{
				// FIXME: Try some easing and see how it looks
				TweenEx.to( _lerpDuration, mcMask, { rotationZ:newRotZ }, { paused:false } );
			}			
		}
	}
}