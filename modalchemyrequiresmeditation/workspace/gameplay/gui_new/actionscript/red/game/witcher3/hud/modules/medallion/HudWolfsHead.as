package red.game.witcher3.hud.modules.medallion
{

	import scaleform.clik.core.UIComponent;
	import flash.display.MovieClip;
	
	import scaleform.clik.constants.InvalidationType;
	import flash.events.Event;

	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;
	
	import red.game.witcher3.constants.HudBloodMessType;
	
	public class HudWolfsHead extends UIComponent
	{
	
	//{region Art clips
	// ------------------------------------------------
	
		public var mcWolfsHeadIcon			: MovieClip;
		public var mcWolfsHeadIconBlured	: MovieClip;
		
	//{region Private constants
	// ------------------------------------------------
	
		private static const FADE_IN_DURATION : Number = 1000;

	//{region Internal properties
	// ------------------------------------------------
		private var _MinBloodLevel 	: Number = 0.2;
		private var _MaxBloodLevel 	: Number = 0.7;
		private var _BloodState		: uint;
		
		private var thresholdX		: Number = 4.0;
		private var thresholdY		: Number = 4.0;
		private var thresholdRotX	: Number = 10.0;
		private var thresholdRotY	: Number = 10.0;
		
		private var thresholdBluredX	: Number = 10.0;
		private var thresholdBluredY	: Number = 10.0;
		private var thresholdBluredRotX	: Number = 12.0;
		private var thresholdBluredRotY	: Number = 12.0;
		
		private var shakeSpeed 			: int = 210;
		private var shakeBluredSpeed 	: int = 70;
	//{region Component properties
	// ------------------------------------------------
		
		protected var _percent:Number = NaN;
		protected var _oldPercent:Number = NaN;
		protected var _newPercent:Number = NaN;	
		
	//{region Initialization
	// ------------------------------------------------

		public function HudWolfsHead() 
		{
			addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			//addEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true );
		}
		
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
		
	//{region Public functions
	// ------------------------------------------------
	
		public function reset():void
		{
			_percent = _newPercent = _oldPercent = NaN			
		}
		
		public function ShakeIt(bShake : Boolean) : void
		{
			if (bShake)
			{
				mcWolfsHeadIconBlured.visible = true;
				shakeBlured(mcWolfsHeadIconBlured);
				shake(mcWolfsHeadIcon);
			}
			else
			{
				mcWolfsHeadIconBlured.visible = false;
				TweenEx.pauseTweenOn(mcWolfsHeadIconBlured);
				mcWolfsHeadIconBlured.x = 0;
				mcWolfsHeadIconBlured.y = 0; 
				
				
				TweenEx.pauseTweenOn(mcWolfsHeadIcon);
				mcWolfsHeadIcon.x = 0;
				mcWolfsHeadIcon.y = 0; 
			}
		}
	
	//{region Updates
	// ------------------------------------------------
	
		private function handleAddedToStage( event:Event ):void
		{
			effectFadeIn( this );
		}
	
		/*private function handleRemovedFromStage( event:Event ):void
		{
		}*/
		
		private function updatePercent():void
		{	
			if ( isNaN( _percent ) )
			{
				throw new Error( "_percent was updated with NaN" );
			}
			
			updateBlood();
		}
		
		private function updateBlood():void
		{				
			var NewBloodState : uint = HudBloodMessType.EMPTY;
			
			if (_percent < _MinBloodLevel )
			{
				NewBloodState = HudBloodMessType.BIG;
			}
			else if( _percent < _MaxBloodLevel )
			{
				NewBloodState = HudBloodMessType.SMALL;;
			}
			
			if (NewBloodState != _BloodState )
			{
				SetBloodState(NewBloodState);
			}
		}
		
	//{region Overrides
	// ------------------------------------------------
		
		override protected function configUI():void
		{
			_BloodState = HudBloodMessType.EMPTY;
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
	
	//{region Effects
	// ------------------------------------------------
		
		private function effectFadeIn( target:MovieClip ):void
		{
			target.alpha = 0;
			TweenEx.to( FADE_IN_DURATION, target, { alpha:1.0 }, { paused:false, ease:Strong.easeOut } );
		}
		
		private function shakeBlured( target:MovieClip ):void
		{
			var randX : Number;
			var randY : Number;
			var randRotY : Number;
			var randRotX : Number;
			
			randX = target.x + ((Math.random() * thresholdBluredX ) - thresholdBluredX/2.0);
			randY = target.y + ((Math.random() * thresholdBluredY ) - thresholdBluredY/2.0);
			randRotX = target.rotationX +((Math.random() * thresholdBluredRotX ) - thresholdBluredRotX/2.0);
			randRotY = target.rotationY +((Math.random() * thresholdBluredRotY ) - thresholdBluredRotY/2.0);
			
			TweenEx.to( shakeBluredSpeed, target, { x:randX, y:randY, rotationX:randRotX, rotationY:randRotY }, 
			{ paused:false, ease:Strong.easeIn ,onComplete:shakeBluredAgain} );
		}
		
		private function shakeBluredAgain(handledTween: TweenEx)
		{
			mcWolfsHeadIconBlured.x = 0;
			mcWolfsHeadIconBlured.y = 0;
			mcWolfsHeadIconBlured.rotationX = 0;
			mcWolfsHeadIconBlured.rotationY = 0;

			
			TweenEx.pauseTweenOn(mcWolfsHeadIconBlured);
			if (mcWolfsHeadIconBlured.visible)
			{
				shakeBlured( mcWolfsHeadIconBlured );
			}
		}
		
		private function shake( target:MovieClip ):void
		{
			var randX : Number;
			var randY : Number;
			var randRotY : Number;
			var randRotX : Number;
			
			randX = target.x + ((Math.random() * thresholdX ) - thresholdX/2.0);
			randY = target.y + ((Math.random() * thresholdY ) - thresholdY/2.0);
			randRotX = target.rotationX +((Math.random() * thresholdRotX ) - thresholdRotX/2.0);
			randRotY = target.rotationY +((Math.random() * thresholdRotY ) - thresholdRotY/2.0);
			
			TweenEx.to( shakeSpeed, target, { x:randX, y:randY, rotationX:randRotX, rotationY:randRotY }, 
			{ paused:false, ease:Strong.easeIn ,onComplete:shakeAgain} );
		}
		
		private function shakeAgain(handledTween: TweenEx)
		{
			mcWolfsHeadIcon.x = 0;
			mcWolfsHeadIcon.y = 0;
			mcWolfsHeadIcon.rotationX = 0;
			mcWolfsHeadIcon.rotationY = 0;
			
			TweenEx.pauseTweenOn(mcWolfsHeadIcon);
			shake( mcWolfsHeadIcon);
		}
	
	//{region Private functions
	// ------------------------------------------------
	
		private function SetBloodState(BloodState : uint) : void
		{
			_BloodState = BloodState;
			mcWolfsHeadIcon.mcWolfsHeadGraphic.gotoAndStop(_BloodState);
		}
	}
}