package red.game.witcher3.menus.worldmap.data 
{
	import flash.geom.Point;
	
	public class CategoryPinInstanceData
	{
		public var _id;
		public var _worldPosition;
		public var _distance;
		
		public function CategoryPinInstanceData( id : uint, worldPosition : Point, distance : Number )
		{
			_id = id;
			_worldPosition = worldPosition;
			_distance = distance;
		}
	}
}