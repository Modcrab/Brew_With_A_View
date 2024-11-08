package red.game.witcher3.menus.common_menu
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;

	/**
	 * Tabs container for common menu
	 * @author Getsevich Yaroslav
	 */
	public class MenuTabsContainer extends UIComponent
	{
		protected var _itemsList:Vector.<MenuTab> = new Vector.<MenuTab>;
		protected var _activeList:Vector.<MenuTab> = new Vector.<MenuTab>;
		protected var _selectedIndex:int = -1;
		protected var _inited:Boolean;
		protected var _data:Array;
		protected var _subTabIndex:int = -1; // #B
		protected var debugCiastko:String = "Main"; // #B
		
		public function next():void	{ selectedIndex++; }
		public function prior():void { selectedIndex--;	}
		public function getItemsCount():int	{ return _itemsList.length;	}
		public function getActiveItemsCount():int	{ return _activeList.length; }
		public function getSubTabIndex():int{return _subTabIndex;	} // #B
		
		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			_data = value;
			if (_data)
			{
				populateData();
			}
		}

		public function get selectedIndex():int { return _selectedIndex }
		public function set selectedIndex(value:int):void
		{
			if (_activeList.length)
			{
				if (value >= _activeList.length)
				{
					value = 0;
				}
				else
				if (value < 0)
				{
					value = _activeList.length - 1;
				}
				if (_selectedIndex != value)
				{
					if (_selectedIndex != -1)
					{
						_activeList[_selectedIndex].selected = false;
					}
					_selectedIndex = value;
					_activeList[_selectedIndex].selected = true;					
					onIndexChanged();
				}
			}
		}
		
		public function getCurrentTab():MenuTab
		{
			return _activeList[_selectedIndex];	
		}

		/**
		 * Select tab by name
		 * @param	tabId tab name
		 * @return	-1 if tab found or sub menu index with this name
		 */

		protected var _bufTabId:uint;
		protected var _bufMenuState:String;
		public function selectTab(tabId:uint, menuState:String = "None"):void
		{
			_subTabIndex = -1;
			
			var len:int = _activeList.length;
			if (!len)
			{
				_bufTabId = tabId;
				_bufMenuState = menuState;
				return;
			}
			for (var i:int = 0; i < len; i++)
			{
				if (_activeList[i].data.id == tabId && (_activeList[i].data.state == menuState || menuState == "None" || menuState == ""))
				{
					_subTabIndex = -1;
					selectedIndex = i;
					return;
				}
				else
				{
					var subData:Array = _activeList[i].data.subItems as Array;
					if (subData)
					{
						for (var k:int = 0; k < subData.length; k++)
						{
							var subDataItem:Object = subData[k];

							if ((subDataItem.id == tabId) && subDataItem.visible && subDataItem.enabled && (subDataItem.state == menuState || menuState == "None"))
							{
								dispatchEvent( new GameEvent(GameEvent.CALL, 'OnBreakPoint', ["selectTab selectedIndex " + selectedIndex + " k " + k+" debugCiastko "+debugCiastko]));
								_subTabIndex = k;
								selectedIndex = i;
								return;
							}
						}
					}
				}
			}
			//dispatchEvent( new GameEvent(GameEvent.CALL, 'OnBreakPoint', [" selectTab END -1"]));
			//return -1;
			_subTabIndex = -1;
		}

		protected function populateData():void
		{
			var dataCount:int = _data.length;
			var rendererIdx:int = 0;
			while (_activeList.length)
			{
				_activeList.pop().visible = false;
			}
			for (var i:int = 0; i < dataCount; i++)
			{
				var curData:Object = _data[i];
				if (curData.visible)
				{
					var curRenderer:MenuTab = _itemsList[rendererIdx];
					curRenderer.visible = true;
					curRenderer.data = curData;
					curRenderer.label = curData.label;
					if (curData.state != "None" )
					{
						curRenderer.iconName = curData.name + curData.state;
					}
					else
					{
						curRenderer.iconName = curData.name;
					}

					if (curData.enabled)
					{
						_activeList.push(curRenderer);
					}
					else
					{
						curRenderer.enabled = curData.enabled;
					}
					rendererIdx++;
				}
			}
			if (_bufTabId && _activeList.length)
			{
				selectTab(_bufTabId, _bufMenuState);
				_bufTabId = 0;
				_bufMenuState = "None";
			}
		}

		protected function onIndexChanged():void
		{
			var idxEvent:ListEvent = new ListEvent(ListEvent.INDEX_CHANGE);
			idxEvent.index = _selectedIndex;
			idxEvent.itemRenderer = _activeList[_selectedIndex];
			dispatchEvent(idxEvent);
			updatePositions();			
		}
		
		// #Y const for now; TODO: Transition animation
		const selectedTabWidth:Number = 245;
		const tabWidth:Number = 80;
		protected function updatePositions():void
		{
			var len:int = _itemsList.length;
			var curPos:int = 0;
			for (var i:int = 0;  i < len; i++)
			{
				var curItem:MenuTab = _itemsList[i];
				curItem.x = curPos;
				curPos += (curItem.selected ? selectedTabWidth : tabWidth);
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			tabEnabled = true;
			focusable = true;
			tabChildren = false;
			displayFocus = true;
		}

		override protected function draw():void
		{
			super.draw();
			if (isInvalid(InvalidationType.DATA))
			{
				initItems();
			}
		}

		protected function initItems():void
		{
			var i:int = 0;
			var limit:int = numChildren;
			var childToSelect:DisplayObject;

			while (_itemsList.length)
			{
				releaseItem(_itemsList.pop())
			};

			for (i; i < limit; i++)
			{
				var curChild:MenuTab = getChildAt(i) as MenuTab;
				if (curChild)
				{
					_itemsList.push(curChild);
					curChild.visible = false;
					setupItem(curChild);
				}
			}
			_itemsList.sort(sortModules);
			_inited = true;
		}

		protected function setupItem(target:MenuTab):void
		{
			target.owner = this;
			target.focusTarget = this;
            target.tabEnabled = false;
			target.focusable = false;
			target.displayFocus = true;
			target.addEventListener(MouseEvent.CLICK, handleItemEvent, false, 0, true);
		}

		protected function releaseItem(target:MenuTab):void
		{
			target.owner = null;
			target.removeEventListener(MouseEvent.CLICK, handleItemEvent);
		}

		protected function handleItemEvent(event:Event):void
		{
			var curTarget:Button = event.currentTarget as MenuTab;
			if (curTarget)
			{
				var idx:int = _itemsList.indexOf(curTarget);
				if (idx > -1) selectedIndex = idx;
			}
		}

		protected function sortModules(a:DisplayObject, b:DisplayObject):Number
		{
			return (a.x > b.x)? 1 : -1;
		}

	}
}
