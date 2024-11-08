/***********************************************************************
/** Inventory Player grid module : Base Version
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
 * 				Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.inventory_menu
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.interfaces.IAbstractItemContainerModule;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.modules.CollapsableTabbedListModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Sine;

	public class InventoryTabbedListModule extends CollapsableTabbedListModule implements IAbstractItemContainerModule
	{
		private const SECTION_BORDER_REF:String = "GridSegmentationRef";
		private const SECTION_BORDER_SIDE_PADDING:Number = 3;
		private const SECTION_BORDER_TOP_PADDING:Number = 9;
		
		var maskClip:MovieClip;
		protected var _gridRenderHeight:int = 520;
		
		public var mcSectionTitlesAnchor:MovieClip;
		public var mcPlayerGrid:SlotsListGrid;
		
		protected var _sectionTitlesContainer:MovieClip;
		protected var _sectionTitlesList:Vector.<TextField> = new Vector.<TextField>;
		protected var _sectionBordersList:Vector.<MovieClip> = new Vector.<MovieClip>;
		protected var _itemSectionsList:GridTabSections;
		
		private var isHorse:Boolean = false;
		
		// sometimes we use bigger mask, to show some elements which are out of the border
		// use this value to remove offset from scrolling logic
		public var gridMaskOffset:Number = 0;

		protected override function configUI():void
		{
			super.configUI();
			
			_initialSelectedIndex = 4; // it needs to be after super.configUI()

			maskClip = getChildByName("mcGridMask") as MovieClip;
			if (maskClip)
			{
				trace("GFX - updating list height from mask to: ", maskClip.height);
				_gridRenderHeight = maskClip.height - gridMaskOffset;
			}

			dataBindingKey = "inventory.grid.player";

			addToListContainer(mcPlayerGrid);
			
			stage.addEventListener(SlotBase.NEW_FLAG_CLEARED, onNewFlagCleared, true, 0, true);

			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + ".itemUpdate", [handleItemUpdate]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + ".itemsUpdate", [handleItemsUpdate]));

			if (mcPlayerGrid)
			{
				mcPlayerGrid.gridMaskOffset = gridMaskOffset;
				mcPlayerGrid.focusable = false;
				mcPlayerGrid.handleScrollBar = true;
				mcPlayerGrid.ignoreGridPosition = false;
				_inputHandlers.push(mcPlayerGrid);
				mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
			}
			
			bToCloseEnabled = true;
		}
				
		public function setItemSections(sectionsList:GridTabSections):void
		{
			_itemSectionsList = sectionsList;
		}
		
		override protected function onTabListItemSelected( event:ListEvent ):void
		{
			var columnSize:Number = mcPlayerGrid.gridSquareSize;
			var sectionPadding:Number = SlotsListGrid.SECTION_PADDING;
			var curSectionsList:Array;
			
			trace("GFX --------------- onTabListItemSelected, new index ", event.index, "; old index ", currentlySelectedTabIndex);
			trace("GFX update columns...");
			
			if (event.index != currentlySelectedTabIndex)
			{
				curSectionsList = _itemSectionsList.getTabSections(event.index);
				
				// update grid's sections
				
				if (curSectionsList)
				{
					mcPlayerGrid.setItemSections(curSectionsList);
				}
			}
			
			//  update data
			
			super.onTabListItemSelected(event);
			
			// align grid
			
			var gridWidth:Number = 0;
			if (curSectionsList && curSectionsList.length)
			{
				gridWidth = mcPlayerGrid.columns * columnSize + (curSectionsList.length - 1) * SlotsListGrid.SECTION_PADDING;
				mcPlayerGrid.x = - gridWidth / 2;
				//mcScrollbar.x = mcListContainer.x + gridWidth / 2;
			}
			else
			{
				gridWidth = mcPlayerGrid.actualWidth;
			}
			
			// update titles
			
			if (curSectionsList && mcSectionTitlesAnchor)
			{
				
				if (_sectionTitlesContainer)
				{
					while (_sectionTitlesList.length)
					{
						_sectionTitlesContainer.removeChild(_sectionTitlesList.pop());
					}
					
					while (_sectionBordersList.length)
					{
						var curBorder:MovieClip =  _sectionBordersList.pop();
						
						GTweener.removeTweens(curBorder);
						_sectionTitlesContainer.removeChild(curBorder);
					}
					
					removeChild(_sectionTitlesContainer);
					
					_sectionTitlesContainer = null;
				}
				
				if (curSectionsList.length)
				{
					var borderRef:Class = getDefinitionByName(SECTION_BORDER_REF) as Class;
					var len:int = curSectionsList.length;
					var curPosition:Number = 0;
					var gridPos:Point = mcListContainer.localToGlobal( new Point(mcPlayerGrid.x, mcPlayerGrid.y) );
					
					_sectionTitlesContainer = new MovieClip();
					_sectionTitlesContainer.y = mcSectionTitlesAnchor.y;
					_sectionTitlesContainer.x = mcSectionTitlesAnchor.x - gridWidth / 2;
					
					addChild(_sectionTitlesContainer);
					_sectionTitlesContainer.mouseChildren = _sectionTitlesContainer.mouseEnabled = false;
					
					// GridSegmentationRef
					
					// for debug
					// _sectionTitlesContainer.graphics.clear();
					
					for (var i:int = 0; i < len; ++i)
					{
						var curSectionData:ItemSectionData = curSectionsList[i] as ItemSectionData;
						
						if (curSectionData)
						{
							var curBlockWidth:Number = (curSectionData.end - curSectionData.start + 1) * columnSize;
							
							if (curBlockWidth < 0)
							{
								throw new Error("Invalid grid sections structure. Check MenuInventory.as or InventoryTabbedListModule.as ;-)");
							}
							
							// Create text filed for title
							
							var curBlockMiddle:Number = curBlockWidth / 2;
							var newTextField:TextField = CommonUtils.spawnTextField(21);
							
							newTextField.text = curSectionData.label;
							//newTextField.text = CommonUtils.toUpperCaseSafe(newTextField.text);
							CommonUtils.toSmallCaps(newTextField);
							
							newTextField.width = newTextField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
							newTextField.x = curPosition + curBlockMiddle - newTextField.width / 2;
							
							_sectionTitlesContainer.addChild(newTextField);
							
							// create border
							
							var newBorder:MovieClip = new borderRef() as MovieClip;
							
							newBorder.x = curPosition - SECTION_BORDER_SIDE_PADDING;
							newBorder.y = -SECTION_BORDER_TOP_PADDING;
							newBorder.width = curBlockWidth + SECTION_BORDER_SIDE_PADDING * 2;
							_sectionTitlesContainer.addChild(newBorder);
							
							curSectionData.border = newBorder;
							newBorder.alpha = CommonConstants.BORDER_ALPHA_UNSELECTED;
							mcPlayerGrid.lastSelectedSection = -1;
							
							/*
							 * for debug
							 *
							var tmpEnd:Number = curPosition + curBlockWidth;
							
							_sectionTitlesContainer.graphics.beginFill(Math.random() * 0xFFFFFF, .3);
							_sectionTitlesContainer.graphics.moveTo(curPosition, 0);
							_sectionTitlesContainer.graphics.lineTo(tmpEnd, 0);
							_sectionTitlesContainer.graphics.lineTo(tmpEnd, 10);
							_sectionTitlesContainer.graphics.lineTo(curPosition, 10);
							_sectionTitlesContainer.graphics.endFill();
							*/
							/*
							_sectionTitlesContainer.graphics.lineStyle(1, 0xFF00000, 1);
							_sectionTitlesContainer.graphics.moveTo( tmpEnd / 2, -10 );
							_sectionTitlesContainer.graphics.lineTo( tmpEnd / 2, 10 );
							_sectionTitlesContainer.graphics.lineStyle(0, 0, 0);
							*/
							
							curPosition += (sectionPadding + curBlockWidth);
						}
					}
				}
			}
		}
		
		override protected function handleMouseMove(event:MouseEvent):void
		{
			if (!_lastMoveWasMouse) // ???
			{
				_lastMoveWasMouse = true;
			}
			
			open();
		}

		override protected function requestTabdata(index:int):void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, tabDataEventName, [index, isHorse]) );
		}

		override protected function setAllowSelectionHighlight(allowed:Boolean):void
		{
			super.setAllowSelectionHighlight(allowed);

			var currentSlotItem:SlotBase;
			var i:int;

			if (mcPlayerGrid)
			{
				mcPlayerGrid.activeSelectionVisible = allowed;
			}
		}

		override protected function state_Open_begin():void
		{
			super.state_Open_begin();
			invalidate(INVALIDATE_CONTEXT);

			if (mcPlayerGrid.selectedIndex == -1)
			{
				mcPlayerGrid.findSelection();
			}

			mcPlayerGrid.applySelectionContext();
			
			checkTabNewFlag(mcPlayerGrid.getSelectedRenderer() as SlotBase);
		}

		protected function handleSlotChanged(event:ListEvent):void
		{
			invalidate(INVALIDATE_CONTEXT);
			
			checkTabNewFlag(mcPlayerGrid.getSelectedRenderer() as SlotBase);
		}
		
		protected function onNewFlagCleared(event:Event):void
		{
			if (event.target is SlotBase)
			{
				checkTabNewFlag(event.target as SlotBase);
			}
		}
		
		protected function checkTabNewFlag(targetSlot:SlotBase):void
		{
			if (targetSlot && targetSlot._unprocessedNewFlagRemoval)
			{
				targetSlot._unprocessedNewFlagRemoval = false;
				validateTabNewFlag(mcTabList.selectedIndex);
			}
		}
		
		protected function validateTabNewFlag(tabIndex:int):void
		{
			var selectedTab:AdvancedTabListItem = mcTabList.getRendererAt(tabIndex) as AdvancedTabListItem;
			
			if (selectedTab && selectedTab.hasNewFlag())
			{
				var currentData:Array = subDataDictionary[tabIndex];
				
				if (currentData)
				{
					var i:int = 0;
					var hasNew:Boolean = false;
					for (i = 0; i < currentData.length; ++i)
					{
						if (currentData[i].isNew)
						{
							hasNew = true;
							break;
						}
					}
					
					if (!hasNew)
					{
						selectedTab.setNewFlag(false);
					}
				}
			}
		}

		protected function handleItemUpdate( itemData:Object ):void
		{
			var tstDataObj:ItemDataStub = itemData as ItemDataStub;
			var targetIndex:int = mcTabList.selectedIndex;
			
			if (tstDataObj.tabIndex != -1)
			{
				targetIndex = tstDataObj.tabIndex;
			}

			mcTabList.validateNow();

			var dataArray:Array = new Array();
			dataArray.push(tstDataObj);
			updateDataSurgicallyInCurrentTab(targetIndex, dataArray);

			mcPlayerGrid.updateItemData(itemData);
			
			invalidate(INVALIDATE_CONTEXT);

			open();
			
			if (tstDataObj.isNew)
			{
				var selectedTab:AdvancedTabListItem = mcTabList.getRendererAt(tstDataObj.tabIndex) as AdvancedTabListItem;
				
				if (selectedTab)
				{
					selectedTab.setNewFlag(true);
				}
			}
		}
		
		// !! items should be on the same tab
		protected function handleItemsUpdate( items:Array ):void
		{
			var i, len   : int;
			var dataArray : Array = new Array();
			var targetIndex:int = mcTabList.selectedIndex;
			var isNew:Boolean = false;
			
			if (items)
			{
				len = items.length;
				
				for (i = 0; i < len; i++ )
				{
					var itemData   : Object = items[i];
					var tstDataObj : ItemDataStub = itemData as ItemDataStub;
					
					if (tstDataObj.tabIndex != -1)
					{
						targetIndex = tstDataObj.tabIndex;
					}
					if (tstDataObj.isNew)
					{
						isNew = true;
					}
					
					dataArray.push(tstDataObj);
				}
				
				mcPlayerGrid.updateItems(dataArray);
				
				updateDataSurgicallyInCurrentTab(targetIndex, dataArray);
				mcTabList.validateNow();
				invalidate(INVALIDATE_CONTEXT);
				open();
				
				if (isNew)
				{
					var selectedTab:AdvancedTabListItem = mcTabList.getRendererAt(targetIndex) as AdvancedTabListItem;
					if (selectedTab)
					{
						selectedTab.setNewFlag(true);
					}
				}
			}
		}

		override protected function draw():void
		{
			super.draw();

			if (isInvalid(INVALIDATE_CONTEXT))
			{
				updateActiveContext();
			}
		}

		protected function updateActiveContext():void
		{
			var slotType:uint = 0;
			var targetId:uint = 0;
			var targetPoint:Point = new Point();
			var currentSlot:SlotBase = mcPlayerGrid.getSelectedRenderer() as SlotBase;
			
			if (focused == 0)
			{
				return;
			}

			if (currentSlot && mcPlayerGrid.enabled)
			{
				var slotData:ItemDataStub = currentSlot.data as ItemDataStub;
				if (slotData)
				{
					targetId = slotData.id;
					slotType = slotData.slotType;
				}
				var targetX:Number = currentSlot.x + currentSlot.getSlotRect().width;
				var targetY:Number = currentSlot.y + currentSlot.getSlotRect().height;
				targetPoint = currentSlot.parent.localToGlobal(new Point(targetX, targetY));
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectInventoryItem", [targetId, slotType, targetPoint.x, targetPoint.y]));
		}

		public function forceSelectItem( itemPosition : int ) : void // #B
		{
			if ( mcPlayerGrid )
			{
				mcPlayerGrid.selectedIndex = itemPosition;
			}
		}

		override public function set focused(value:Number):void
		{
			if (value > 0 && value != _focused)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCurrentPlayerGrid', [dataBindingKey] ) );
			}
			
			super.focused = value;
			invalidate(INVALIDATE_CONTEXT);

			if (isOpen)
			{
				mcPlayerGrid.applySelectionContext();
				
				checkTabNewFlag(mcPlayerGrid.getSelectedRenderer() as SlotBase);
			}
		}

		public function SetOverburdened(value:Boolean):void
		{
			var i:int;
			var curRenderer:SlotInventoryGrid;

			for (i = 0; i < mcPlayerGrid.getRenderersLength(); i += 1)
			{
				curRenderer = mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;

				if (curRenderer)
				{
					curRenderer.setOverburdened(value);
				}
			}
		}

		override public function getDataShowerForTab(index:int):UIComponent
		{
			return mcPlayerGrid;
		}

		public function get CurrentItemDataStub():ItemDataStub
		{
			return null;
		}

		override protected function setSubData(index:int, data:Array):void
		{
			super.setSubData(index, data);
		}

		public function inventoryRemoveItem( itemId:int, keepSelectionIdx : Boolean = false):void
		{
			mcTabList.validateNow();
			
			mcPlayerGrid.removeItem(itemId, keepSelectionIdx);

			var dataArray:Array = new Array();
			dataArray.push(itemId);
			removeDataSurgicallyInCurrentTab(mcTabList.selectedIndex, dataArray);
		}

		public function getSlotByID( slotID:int ) : SlotInventoryGrid
		{
			return mcPlayerGrid.getSlotByID(slotID) as SlotInventoryGrid;
		}

		protected var maskTweener:GTween;
		protected function handleMaskTweenComplete( curTween : GTween ):void
		{
			maskTweener = null;
		}

		override protected function ApplyCloseAnimationToMask()
		{
			maskClip = getChildByName("mcGridMask") as MovieClip;
			if (maskClip)
			{
				if (maskTweener)
				{
					maskTweener.paused = true;
					GTweener.removeTweens(maskClip);
				}

				maskTweener = GTweener.to(maskClip, 0.2, { height: ClosedListScale * _gridRenderHeight }, {onComplete:handleMaskTweenComplete, ease:Sine.easeOut} );
			}
		}

		override protected function ApplyOpenAnimationToMask()
		{
			maskClip = getChildByName("mcGridMask") as MovieClip;
			if (maskClip)
			{
				if (maskTweener)
				{
					maskTweener.paused = true;
					GTweener.removeTweens(maskClip);
				}

				maskTweener = GTweener.to(maskClip, 0.2, { height: _gridRenderHeight }, {onComplete:handleMaskTweenComplete, ease:Sine.easeOut} );
			}
		}
		
		
		override public function handleInput( event:InputEvent ):void
		{
			if (!InputManager.getInstance().isGamepad() && event.details.code == KeyCode.ESCAPE )
			{
				// close menu
				return;
			}
			else
			{
				super.handleInput(event);
			}
		}
		
	}
}
