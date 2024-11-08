package red.game.witcher3.menus.worldmap.data 
{
	public class CategoryData
	{
		public var _name : String;
		public var _priority : int;
		public var _pins : Array = new Array;
		public var _showUserPins : Boolean;
		public var _showFastTravelPins : Boolean;
		public var _showQuestPins : Boolean;
		
		public function CategoryData( name : String, priority : int, showUserPins : Boolean, showFastTravelPins : Boolean, showQuestPins : Boolean )
		{
			_name				= name;
			_priority			= priority;
			_showUserPins		= showUserPins;
			_showFastTravelPins	= showFastTravelPins;
			_showQuestPins		= showQuestPins;
		}
	}
}