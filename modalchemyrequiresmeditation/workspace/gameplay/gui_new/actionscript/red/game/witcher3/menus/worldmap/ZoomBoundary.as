package red.game.witcher3.menus.worldmap
{
	public class ZoomBoundary
	{
		public var _min : Number;
		public var _max : Number;

		public function ZoomBoundary( min : Number, max : Number )
		{
			_min = min;
			_max = max;
		}
	
		public function IsValid() : Boolean
		{
			return ( _min > 0 && _max > 0 && _min < _max )
		}
	
		public function IsInside( val : Number ) : Boolean
		{
			return val >= _min && val <= _max;
		}
	}
}
