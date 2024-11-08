package red.game.witcher3.menus.inventory_menu 
{
	import red.game.witcher3.menus.journal.ObjectiveItemRenderer;
	
	public class GridTabSections
	{
		public var sections:Array;
		
		public function GridTabSections():void
		{
			sections = [];
		}
		
		public function push(tabIdx:int, item:ItemSectionData):ItemSectionData
		{
			var newItem:Object = { tabIdx : tabIdx, item : item };
			
			sections.push(newItem);
			return item;
		}
		
		public function getTabSections(tabIdx:int):Array
		{
			var result:Array = [];
			var len:int = sections.length;
			
			for (var i:int = 0; i < len; i++ )
			{
				if (sections[i].tabIdx == tabIdx)
				{
					result.push(sections[i].item);
				}
			}
			
			return result;
		}
		
		public function toString():String
		{
			return "[GridTabSections] contains " + sections.length + " sections";
		}
		
	}
}
