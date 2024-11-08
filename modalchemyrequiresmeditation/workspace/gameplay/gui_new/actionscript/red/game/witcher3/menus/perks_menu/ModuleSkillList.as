package red.game.witcher3.menus.perks_menu
{
	import flash.text.TextField;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.slots.SlotsListCategorized;
	
	/**
	 * Tile list for skills
	 * @author Yaroslav Getsevich
	 */
	public class ModuleSkillList extends CoreMenuModule
	{
		public var mcPlayerGrid:SlotsListCategorized;
		public var textField: TextField;
		
		public function ModuleSkillList()
		{
			mcPlayerGrid.disableGroupTitle = true;
			mcPlayerGrid.itemPadding = 0;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".name", [handleTitleSet]));
		}
		
		protected function handleDataSet(dataList:Object):void
		{
			mcPlayerGrid.data = dataList as Array;
		}
				
		protected function handleTitleSet(name:String):void
		{
			textField.htmlText = name;
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			mcPlayerGrid.focused = _focused;
			if (mcPlayerGrid.selectedIndex < 0)
			{
				mcPlayerGrid.selectedIndex = 0;
			}
			if (this.focused > 0)
			{
				bindModule();
			}
		}
		
		protected function bindModule():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnModuleSelected", [this.dataBindingKey] ) );
		}
		
	}
}