package red.game.witcher3.menus.overlay 
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	
	/**
	 * Context menu. Inventory, etc..
	 * @author Yaroslav Getsevich
	 */
	public class ContextMenuPopup extends BasePopup
	{
		public var actionList:W3ScrollingList;
		
		function ContextMenuPopup():void
		{
			visible = false;
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			actionList.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 0 , true );
			actionList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleListDoubleClick, false, 0, true);
		}
		
		override protected function populateData():void 
		{
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			actionList.dataProvider = new DataProvider( _data.ActionsList as Array);
			this.x = _data.positionX;
			this.y = _data.positionY;
			visible = true;
			actionList.focused = 1;
			actionList.selectedIndex = 0;
		}
		
		protected function handleSelectChange(event:ListEvent):void
		{
			trace("GFX **  handleSelectChange", event.itemData.NavCode);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnContextActionChange', [event.itemData.NavCode, false] ) );
		}
		
		protected function handleListDoubleClick(event:ListEvent):void
		{
			trace("GFX ** handleListDoubleClick", event.itemData.NavCode);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnContextActionChange', [event.itemData.NavCode, true] ) );
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			super.handleInput(event);
			actionList.handleInput(event);
		}
	}
}