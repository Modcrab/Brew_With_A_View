package red.game.witcher3.menus.blacksmith 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.core.CoreMenuModule;
	import red.game.witcher3.controls.W3ScrollingList;	
	import red.game.witcher3.menus.common.IconItemRenderer;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.events.ListEvent;
	
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	/**
	 * red.game.witcher3.menus.blacksmith.EnchantingItemsListModule
	 * @author Getsevich Yaroslav
	 */
	public class EnchantingItemsListModule extends CoreMenuModule
	{
		public var mcEmptyList:MovieClip;
		public var mcScrollbar:ScrollBar;
		public var mcScrollingList:W3ScrollingList;
		
		protected var _data:Array;
		protected var _itemRendererClassName:String;
		
		public var filterFunction:Function;
		
		public function EnchantingItemsListModule() 
		{
			dataBindingKey = "EnchantingItemsListModule";
			mcEmptyList.visible = false;
			mcScrollingList.addEventListener(ListEvent.ITEM_CLICK, handleItemClick, false, 0, true);
		}
		
		// InventoryItemRendererRef
		[Inspectable(name = "itemRenderer", defaultValue = "DefaultListItemRenderer")]
		public function get itemRendererClassName():String { return _itemRendererClassName }
		public function set itemRendererClassName(value:String):void
		{
			_itemRendererClassName = value;
			mcScrollingList.itemRendererName = _itemRendererClassName;
		}
		
		private function handleItemClick(event:ListEvent):void
		{
			dispatchEvent(new Event(EVENT_MOUSE_FOCUSE));
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			updateActiveSelectionEnabled();
		}
		
		override public function set focused(value:Number):void 
		{
			super.focused = value;
			
			var isFocused:Boolean = value == 1;
			
			updateActiveSelectionEnabled()
			
			mcScrollingList.focusable = false;
			mcScrollingList.focused = value;
			mcScrollbar.alpha = (isFocused ? 1 : 0.4);
			
			_inputHandlers.push(mcScrollingList);
		}
		
		protected function updateActiveSelectionEnabled():void
		{
			var renderers:Vector.<IListItemRenderer> = mcScrollingList.getRenderers();
			var count:int = renderers.length;
			var curRenderer:IconItemRenderer;
			var isFocused:Boolean = _focused == 1;
			
			for (var i:int = 0; i < count; i++)
			{
				curRenderer = renderers[i] as IconItemRenderer;
				if (curRenderer)
				{
					curRenderer.activeSelectionEnabled = isFocused;
				}
			}
		}
		
		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			
			if (filterFunction != null)
			{
				_data = filterFunction(value);
			}
			else
			{
				_data = value;
			}
			
			if (!_data || _data.length < 1)
			{
				mcScrollingList.dataProvider = new DataProvider([]);
				mcEmptyList.visible = true;
				return;
			}
			
			mcEmptyList.visible = false;
			
			var curDataProvider:DataProvider = new DataProvider(_data);
			mcScrollingList.dataProvider = curDataProvider;
			mcScrollingList.selectedIndex = 0;
			
			mcScrollingList.validateNow();
			
			updateActiveSelectionEnabled();
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			//trace("GFX --- handleInput [", this, "] h ", event.handled, " f ", focused, " e ", enabled, " v ", visible );
			
			if ( event.handled || !focused || !enabled || !visible)
			{
				return;
			}
		
			for each ( var handler:UIComponent in _inputHandlers )
			{
				handler.handleInput( event );

				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
			}
		}
		
	}

}
