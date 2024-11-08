package red.game.witcher3.menus.preparation_menu 
{
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	
	/**
	 * Category item renderer for preporation menu
	 * @author Getsevich Yaroslav
	 */
	public class PreparationDropdownMenuListItem extends W3DropdownMenuListItem
	{
		protected var _isOpened:Boolean; // #Y move to base class
		
		public function PreparationDropdownMenuListItem()
		{
			_isOpened = false;
			super();
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			open();
			
			var grid:SlotsListGrid = _dropdownRef as SlotsListGrid;
			if (grid)
			{
				grid.initFindSelection = false;
				grid.selectedIndex = -1;
			}
		}
		
		override public function close():void
		{
			if (_isOpened)
			{
				_isOpened = false;
				super.close();
			}
		}
		
		override public function open():void
		{
			if (!_isOpened)
			{
				_isOpened = true;
				super.open();
			}
		}
		
		override public function set selected(value:Boolean):void 
		{
			if (value != _selected && _dropdownRef)
			{
				var slotsGrid:SlotsListBase = _dropdownRef as SlotsListGrid;
				if (slotsGrid)
				{
					slotsGrid.selectedIndex = -1;				
					if (value)
					{
						slotsGrid.focused = 1;
					}
				}
			}
			super.selected = value;
		}
		
	}
}