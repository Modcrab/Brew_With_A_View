package red.game.witcher3.hud.modules.statbars
{
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	
	import red.game.witcher3.constants.HudBloodMessType;

	public class HudStatBarBlood extends UIComponent
	{
	
	//{region Internal properties
	// ------------------------------------------------
	
		private var _MinBloodLevel:Number = 0.2;
		private var _MaxBloodLevel:Number = 0.7;
		private var _BloodState : uint = HudBloodMessType.EMPTY;
		
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
			
			if ( _percent == clampedValue )
			{
				return;
			}
			
			_newPercent = clampedValue;
			invalidateData();			
		}
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudStatBarBlood()
		{
			super();
		}
	
	//{region Public functions
	// ------------------------------------------------
	
		public function reset():void
		{
			_percent = _newPercent = _oldPercent = NaN			
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

			updateBlood();
		}
		
		private function updateBlood() : void
		{
			var NewBloodState : uint = HudBloodMessType.EMPTY;
			if (_percent < _MinBloodLevel )
			{
				NewBloodState = HudBloodMessType.BIG;
			}
			else if( _percent < _MaxBloodLevel )
			{
				NewBloodState = HudBloodMessType.SMALL;
			}
			if (NewBloodState != _BloodState )
			{
				SetBloodState(NewBloodState);
			}
		}
		
		private function SetBloodState(BloodState : uint) : void
		{
			_BloodState = BloodState;
			gotoAndStop(_BloodState);
		}
	}
}