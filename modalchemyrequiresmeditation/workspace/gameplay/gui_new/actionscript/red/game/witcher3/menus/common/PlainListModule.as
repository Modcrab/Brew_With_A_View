package red.game.witcher3.menus.common 
{
	import flash.display.MovieClip;
	import red.core.CoreMenuModule;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	/**	
	 * @author Getsevich Yaroslav
	 */
	public class PlainListModule extends CoreMenuModule 
	{
		public var mcEmptyList:MovieClip;
		public var mcScrollbar:ScrollBar;
		public var mcScrollingList:W3ScrollingList;
		
		protected var _data:Array;
		
		public function PlainListModule() 
		{
			mcScrollingList.focusable = false;
			mcEmptyList.visible = false;
		}
		
		override public function set focused(value:Number):void 
		{
			super.focused = value;
			
			var isFocused:Boolean = value == 1;
			var renderers:Vector.<IListItemRenderer> = mcScrollingList.getRenderers();
			var curRenderer:IconItemRenderer;
			var count:int = renderers.length;
			for (var i:int = 0; i < count; i++)
			{
				curRenderer = renderers[i] as IconItemRenderer;
				if (curRenderer)
				{
					curRenderer.activeSelectionEnabled = isFocused;
				}
			}
			
			mcScrollingList.focusable = false;
			//mcScrollingList.focused = value;
			mcScrollbar.alpha = (isFocused ? 1 : 0.4);
			
			_inputHandlers.push(mcScrollingList);
		}
		
		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			_data = value;			
			
			if (!_data || _data.length < 1)
			{
				mcScrollingList.dataProvider = new DataProvider([]);
				mcEmptyList.visible = true;
				return;
			}
			
			mcEmptyList.visible = false;
			
			var curDataProvider:DataProvider = new DataProvider(_data);
			curDataProvider.sort(sortList);
			mcScrollingList.dataProvider = curDataProvider;
			mcScrollingList.selectedIndex = 0;
		}
		
		private function sortList(element1:Object, element2:Object):int
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (CommonUtils.toUpperCaseSafe(element1.label) > CommonUtils.toUpperCaseSafe(element2.label))
			{
				return 1;
			}
			else
			{
				return -1;
			}
			
			return 0;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !focused || !enabled || !visible)
			{
				return;
			}

			//trace("DROPDOWN _inputHandlers.length "+_inputHandlers.length);
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
