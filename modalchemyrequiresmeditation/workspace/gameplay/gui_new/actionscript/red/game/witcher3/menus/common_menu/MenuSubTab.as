package red.game.witcher3.menus.common_menu 
{
	import scaleform.clik.controls.ListItemRenderer
	
	/**
	 * Common menu tabs
	 * @author Getsevich Yaroslavc
	 */
	public class MenuSubTab extends ListItemRenderer
	{
		protected var _targetMenuIdx:uint;
		
		[Inspectable(defaultValue="")]
		public function get targetMenuIdx():int { return _targetMenuIdx };
		public function set targetMenuIdx(value:int)
		{
			_targetMenuIdx = value;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			preventAutosizing = true;
			focusable = false;
			displayFocus = true;
		}
	}

}