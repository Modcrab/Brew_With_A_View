package red.game.witcher3.tooltips 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.game.witcher3.controls.RenderersList;
	
	/**
	 * Tooltip for crafting schematics
	 * @author Getsevich Yaroslav
	 */
	public class TooltipSchematic extends TooltipBase
	{
		public var tfItemName:TextField;
		public var tfItemType:TextField;
		public var tfDescription:TextField;

		public var propsList:RenderersList;
		public var listStats:RenderersList;
		
		public var delTitle:Sprite;
		
		public function TooltipSchematic() 
		{
			visible = false;
		}
		
		override protected function populateData():void
		{
			super.populateData();
			if (!_data) return;
			populateSchematicData();
			visible = true;
		}
		
		private function populateSchematicData():void
		{
			applyTextValue(tfItemType, _data.ItemType, false, true);
			applyTextValue(tfItemName, _data.ItemName, true, true);
			
			
			
		}
		
	}
}
