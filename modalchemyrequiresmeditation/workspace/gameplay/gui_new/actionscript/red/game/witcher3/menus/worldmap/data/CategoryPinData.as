package red.game.witcher3.menus.worldmap.data 
{
	public class CategoryPinData
	{
		public var _name : String;
		public var _translation : String;
		public var _priority : int;
		public var _index : int;
		public var _instances : Array = new Array;
		
		public function CategoryPinData( name : String, translation : String, priority : int )
		{
			_name = name;
			_translation = translation;
			_priority = priority;
		}
	}
}