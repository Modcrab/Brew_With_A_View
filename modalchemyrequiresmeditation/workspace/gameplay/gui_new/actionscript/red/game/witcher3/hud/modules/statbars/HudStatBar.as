package red.game.witcher3.hud.modules.statbars
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class HudStatBar extends UIComponent
	{
		
	//{region Art clips
	// ------------------------------------------------
	
		public var mcMask:MovieClip;
		public var mcBar:MovieClip;
		public var mcSelection:MovieClip;
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
	//{region Internal properties
	// ------------------------------------------------
	
		protected var _originalMaskPosX:Number = -1.0;
		protected var _animationPeriodMS:int = 0;
		
	//{region Component properties
	// ------------------------------------------------
		
		protected var _percent:Number = NaN;
		protected var _oldPercent:Number = NaN;
		protected var _newPercent:Number = NaN;
		protected var _moreIsBetter:Boolean = true;
		
		protected var _lerpDuration:int = 500;
	
	//{region Component setters/getters
	// ------------------------------------------------
	
		public function get percent():Number
		{
			return _percent;
		}
		public function set percent( value:Number ):void
		{
			var clampedValue:Number = Math.min( 1.0, Math.max( 0.0, value ) );
			
			if ( _percent == clampedValue )
			{
				return;
			}
			
			_newPercent = clampedValue;
			invalidateData();			
		}
		
		[Inspectable(defaultValue="true")]
		public function get moreIsBetter():Boolean
		{
			return _moreIsBetter;
		}
		public function set moreIsBetter( value:Boolean ):void
		{
			_moreIsBetter = value;
		}
		
		[Inspectable(defaultValue = "1000")]		
		public function get lerpDuration():int
		{
			return _lerpDuration;
		}
		public function set lerpDuration( value:int ):void
		{
			_lerpDuration = lerpDuration;
		}
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudStatBar()
		{
			super();
			
			_originalMaskPosX = mcMask.x;
		}
	
	//{region Public functions
	// ------------------------------------------------
	
		public function reset():void
		{
			_percent = _newPercent = _oldPercent = NaN			
			TweenEx.pauseTweenOn( mcMask );
			if ( mcSelection )
			{
				TweenEx.pauseTweenOn( mcSelection );
			}
		}
	
	//{region Overrides
	// ------------------------------------------------
		
		override protected function configUI():void
		{
			super.configUI();
			reset();
		}
		
		override protected function draw():void
		{
			if ( isInvalid( InvalidationType.DATA ) )
			{
				if ( ! isNaN( _newPercent ) )
				{
					_oldPercent = _percent;
					_percent = _newPercent;
					_newPercent = NaN;
					updatePercent();
				}
			}
			super.draw();
		}
	
	//{region Updates
	// ------------------------------------------------
		
		private function updatePercent():void
		{	
			if ( isNaN( _percent ) )
			{
				throw new Error( "_percent was updated with NaN" );
			}
			
			var newPosX:Number = _originalMaskPosX - ( 1.0 - _percent ) * mcMask.width;
			
			TweenEx.pauseTweenOn( mcMask );
			TweenEx.pauseTweenOn( mcSelection ); //#B
			
			// Don't lerp if the player should see dangerous changes ASAP or if the bar is being set for the first time
			var giveImmediateFeedback:Boolean = isNaN( _oldPercent ) || _moreIsBetter ? ( _percent < _oldPercent ) : ( _percent > _oldPercent );
			
			giveImmediateFeedback = true; // # FIXME BIDON - > when we allow tweening bar start to acts strange (like shaking - > jump from 65 to 51 then to 66 etc :P )
			
			if ( giveImmediateFeedback )
			{
				if ( !mcSelection )
				{
					trace("Minimap !mcSelection");
				}
				if ( !mcMask )
				{
					trace("Minimap !mcMask");
				}
				mcMask.x = newPosX;
				mcSelection.x = newPosX + mcMask.width;
			}
			else
			{
				// FIXME: Try some easing and see how it looks
				TweenEx.to( _lerpDuration, mcMask, { x:newPosX }, { paused:false } );
				TweenEx.to( _lerpDuration, mcSelection, { x:newPosX+mcMask.width }, { paused:false } );
			}			
		}
	}
}