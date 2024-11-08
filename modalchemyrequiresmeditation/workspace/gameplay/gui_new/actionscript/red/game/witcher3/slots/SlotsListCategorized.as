package red.game.witcher3.slots 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.menus.character_menu.SkillsGroupTitle;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Slots grid with categories
	 * @author Getsevich Yaroslav
	 */
	public class SlotsListCategorized extends SlotsListBase
	{
		protected static const ITEM_PADDING:Number = 4;
		protected static const GROUP_TITLE_PADDING:Number = 10;
		protected static const GROUP_TITLE_REF:String = "SkillGroupTitleRef";
		
		protected var _rendererWidth:Number;
		protected var _rendererHeight:Number;
		protected var _columnsCount:int;
		protected var _dataCount:int;
		protected var _disableGroupTitle:Boolean = true;
		protected var _itemPadding:Number = 4;
		
		[Inspectable(defaultValue="true")]
		public function get disableGroupTitle():Boolean { return _disableGroupTitle }
		public function set disableGroupTitle(value:Boolean):void
		{
			_disableGroupTitle = value;
		}
		
		[Inspectable(defaultValue="true")]
		public function get itemPadding():Number { return _itemPadding }
		public function set itemPadding(value:Number):void 
		{
			_itemPadding = value;
		}
		
		override public function get numColumns():uint
		{
			return _columnsCount;
		}
		
		override public function get rendererHeight():Number
		{
			return _rendererHeight;
		}
		
		override protected function populateData():void 
		{
			super.populateData();
			var sortedData:Array = _data;
			sortedData.sort(sortSkills);
			cleanupRenderers();
			populateRenderers(sortedData);
		}
		
		protected function sortSkills(a:Object, b:Object):int
		{
			if (a.skillSubPath == b.skillSubPath)
			{
				if (a.requiredPointsSpent > b.requiredPointsSpent)
				{
					return 1;
				}
				else
				if (a.requiredPointsSpent < b.requiredPointsSpent)
				{
					return -1;
				}
				else
				{
					return 0;
				}
			}
			else
			{
				if (a.skillSubPath > b.skillSubPath)
				{
					return 1;
				}
				else
				if (a.skillSubPath < b.skillSubPath)
				{
					return -1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		protected function cleanupRenderers():void
		{
			while (_renderers.length > 0)
			{
				var curRdr:IBaseSlot = _renderers.pop();
				cleanUpRenderer(curRdr);
				_canvas.removeChild(curRdr as DisplayObject);
			}
		}
		
		override public function GetDropdownListHeight() : Number 
		{
			if (_dataCount != 0 && _columnsCount != 0)
			{
				var heightPerRow:int = ITEM_PADDING + _rendererHeight
				var totalItemHeight = Math.ceil(_dataCount / _columnsCount ) * heightPerRow;
				return totalItemHeight + ITEM_PADDING;
			}
			return _canvas.height;
		}
		
		override public function findSelection():void
		{ 
			selectedIndex = 0;
		}
		
		override public function set focused(value:Number):void
		{
			if (value > 0 && value != focused)
			{
				if (selectedIndex < 0) findSelection();
			}
			super.focused = value;
		}
		
		protected function populateRenderers(dataList:Array):void
		{
			var currentCategory:String;
			_dataCount = dataList.length;
			var curPositionY:Number = _disableGroupTitle ? ITEM_PADDING : 0;
			var curPositionX:Number = 0;
			var curColumn:int = 0;
			
			calcRendererSize();
			
			_renderersCount = _dataCount;
			for (var i:int = 0; i < _dataCount; i++)
			{
				var curItemData:Object = dataList[i];
				if (!_disableGroupTitle)
				{
					
					if (curItemData.skillSubPath != currentCategory)
					{
						currentCategory = curItemData.skillSubPath;	
						if (curPositionY != 0) 
						{
							// next line
							curPositionY += _rendererHeight;
						}
						curPositionY += createCategoryTitle(currentCategory, curItemData.skillPath, curPositionY);
						curColumn = 0;
						curPositionX = 0;
					}
					
				}
				
				var newItem:IBaseSlot = new _slotRendererRef() as IBaseSlot;
				curItemData.gridSize = 1;
				newItem.data = curItemData;
				newItem.y = curPositionY;
				newItem.x = curPositionX;
				if (curColumn >= _columnsCount - 1)
				{
					curColumn = 0;
					curPositionX = 0;
					curPositionY += _rendererHeight + ITEM_PADDING;
				}
				else
				{
					curColumn++;
					curPositionX += (_rendererWidth + ITEM_PADDING);
				}
				newItem.index = i;				
				setupRenderer(newItem);
				_canvas.addChild(newItem as DisplayObject);
				_renderers.push(newItem);
				newItem.validateNow();
			}
			
			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION)); // #Y Fuuu
		}
		
		protected function createCategoryTitle(titleText:String, group:String, curPosition:Number):Number
		{
			var groupRef:Class = getDefinitionByName(GROUP_TITLE_REF) as Class;
			var	groupTitle:SkillsGroupTitle = new groupRef as SkillsGroupTitle;
			groupTitle.title = titleText;
			groupTitle.skillGroup = group;
			groupTitle.y = curPosition + GROUP_TITLE_PADDING;
			_canvas.addChild(groupTitle);
			return GROUP_TITLE_PADDING * 2 + groupTitle.actualHeight;
		}
		
		protected function calcRendererSize():void
		{
			if (_slotRendererRef)
			{
				var testItem:IBaseSlot = new _slotRendererRef() as IBaseSlot;
				var slotRect:Rectangle = testItem.getSlotRect();
				_rendererWidth = slotRect.width;
				_rendererHeight = slotRect.height;
				_columnsCount = Math.floor(this.actualWidth / (_rendererWidth + ITEM_PADDING));
			}
		}
		
		override public function getColumn( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return index % (_columnsCount - 1);
		}
			
		override public function getRow( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return Math.abs(index / _columnsCount);
		}
	}

}