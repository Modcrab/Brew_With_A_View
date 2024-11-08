package red.game.witcher3.hud.modules.buffs
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	
	public class HudBuffDurationBar extends UIComponent
	{
		
	//{region Art clips
	// ------------------------------------------------
	
		public var mcMaskLeft		: MovieClip;
		public var mcMaskRight		: MovieClip;
		public var mcBuffShapeLeft	: MovieClip;
		public var mcBuffShapeRight	: MovieClip;
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
	//{region Internal properties
	// ------------------------------------------------
	
		private var _originalMaskLeftRotZ:Number = -1.0;
		private var _originalMaskRightRotZ:Number = -1.0;
		
	//{region Component properties
	// ------------------------------------------------
		
		protected var _percent:Number = NaN;
		protected var _oldPercent:Number = NaN;
		protected var _newPercent:Number = NaN;
	
	//{region Component setters/getters
	// ------------------------------------------------
	
		public function get percent():Number
		{
			return _percent;
		}
		
		public function set percent( value:Number ):void
		{
			var clampedValue:Number = Math.min( 1.0, Math.max( 0.0, value ) );
			
			//trace("HBDB swet percent "+clampedValue);
			
			if ( _percent == clampedValue )
			{
				return;
			}
			
			_newPercent = clampedValue;
			invalidateData();
		}
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudBuffDurationBar()
		{
			super();
			
			_originalMaskLeftRotZ = mcMaskLeft.rotationZ;
			_originalMaskRightRotZ = mcMaskRight.rotationZ;
			//trace();
			//trace(parent.name);
			//trace("_originalMaskRightRotZ "+_originalMaskRightRotZ);
			//trace("_originalMaskLeftRotZ " + _originalMaskLeftRotZ);
		}
	
	//{region Public functions
	// ------------------------------------------------
	
		public function reset():void
		{
			_percent = _newPercent = _oldPercent = NaN			
		}
		
		public function setPositive(value):void
		{
			var str : String;
			if (value == 0 )
			{
				str = "negative"
			}
			else if (value == 1 )
			{
				str = "positive";
			}
			else if (value == 2 )
			{
				str = "neutral";
			}
			
			mcBuffShapeLeft.gotoAndStop(str);
			mcBuffShapeRight.gotoAndStop(str);
		}
	
	//{region Overrides
	// ------------------------------------------------
		
		override protected function configUI():void
		{
			super.configUI();
			//reset();
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
			
			if ( _percent <= 0.5 )
			{
				mcMaskRight.rotationZ = 0;
				mcMaskLeft.rotationZ = - 360 * percent;
			}
			else
			{
				mcMaskRight.rotationZ = - 360 * ( percent - 0.5);
				mcMaskLeft.rotationZ = -180; 
			}
		}
	}
}