package red.game.witcher3.controls 
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import scaleform.clik.controls.OptionStepper;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.interfaces.IDataProvider;
	import flash.utils.getDefinitionByName;
	
	public class W3OptionStepper extends OptionStepper 
	{
		public function get hideIndicator():Boolean { return _hideIndicator; }
        public function set hideIndicator(value:Boolean):void {
			_hideIndicator = value;
			rebuild( dataProvider );
			updateSelectedItem();
        }
		
		private var _hideIndicator : Boolean;
		private var _indicators : Vector.<MovieClip>;
		
		public function W3OptionStepper() 
		{
			_indicators = new Vector.<MovieClip>;
			_constraintsDisabled = true;
			_hideIndicator = false;
			super();
		}
		
		override public function set dataProvider( value:IDataProvider ):void {
			rebuild( value );
			super.dataProvider = value;
        }
		
		override protected function updateSelectedItem():void {
			var i : uint;
			var dataLength : uint = (_dataProvider as DataProvider).length;
			
			for ( i = 0; i < _indicators.length; i++ )
			{
				_indicators[i].visible = false;
			}
			
			for ( i = 0; i < dataLength && _indicators.length != 0; i++ )
			{
				_indicators[i].visible = true;
				_indicators[i].gotoAndStop( "inactive" );
			}
			
			if( _selectedIndex < _indicators.length && _selectedIndex >= 0) 
				_indicators[selectedIndex].gotoAndStop( "active" );
				
			if ( _selectedIndex == 0 )
			{
				prevBtn.enabled = false;
				nextBtn.enabled = true;
			}
			else if ( _selectedIndex == (dataProvider as DataProvider).length - 1 )
			{
				prevBtn.enabled = true;
				nextBtn.enabled = false;
			}
			else
			{
				prevBtn.enabled = true;
				nextBtn.enabled = true;
			}
			
            super.updateSelectedItem();
        }
		
		private function rebuild( data : IDataProvider ) : void
		{
			var i : uint;
			var classRef : Class = getDefinitionByName( "StepperIndicator" ) as Class;
			var indicator : MovieClip;
			var dataLength : uint = (data as DataProvider).length;
			
			var xOffset : uint = 140;
			var padding : uint = 5;
			var maxIndicators : uint = 5;
			
			if ( dataLength > maxIndicators || _hideIndicator )
			{
				for ( i = 0; i < _indicators.length; i++ )
					removeChild( _indicators[i] );
					
				_indicators.length = 0
			}
			else
			{
				for ( i = _indicators.length; i < dataLength; i++ )
				{
					indicator = new classRef() as MovieClip;
					addChild( indicator );
					_indicators.push( indicator );
				}
			
				for ( i = 0; i < dataLength && _indicators.length != 0; i++ )
				{
					_indicators[i].x = xOffset;
					_indicators[i].y = -14;
					xOffset += _indicators[i].width + padding;
				}
			}
				
			nextBtn.x = xOffset + nextBtn.width;
			this.width = nextBtn.x + nextBtn.width;
		}
	}
}