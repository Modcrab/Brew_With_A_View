/***********************************************************************
/** Grid Inventory List
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
 * 				Yaroslav Getsevich
/***********************************************************************/

package red.game.witcher3.slots
{
	import adobe.utils.CustomActions;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.inventory_menu.ItemSectionData;
	import red.game.witcher3.menus.inventory_menu.MenuInventory;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollIndicator;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.interfaces.IScrollBar;
	import scaleform.clik.ui.InputDetails;

	public class SlotsListGrid extends SlotsListBase implements IDropTarget
	{
		public static const SECTION_PADDING:Number = 15;
		
		protected static const HIGHLIGHT_REF:String = "SlotHighlightRef";
		protected static const HIGHLIGHT_LABEL_ACCEPT:String = "accept";
		protected static const HIGHLIGHT_LABEL_DENIDED:String = "denided";
		protected static const HIGHLIGHT_LABEL_NONE:String = "none";
		
		//public var smoothScrolling:Boolean = true;
		//protected var m_lastScrollPosition:uint = 0;
		
		// #J if SlotsListGrid is part of a bigger panel, it should probably let something else handle the scrolling logic
		// Ideally, eventually any module that just has a SlotsListGrid will use this flag instead of their own custom implementation
		public var handleScrollBar:Boolean = false;
		protected var _gridRenderHeight:int = 520;
		
		protected var _discardedRendererPool:Vector.<IInventorySlot> = new Vector.<IInventorySlot>();
		
		protected var _specialCachedSelection:int = -1;
		
		protected var _lastSetSort:int = -1;
		
		protected static const ITEM_PADDING:Number = 4;
		protected var _maxOffset:Number = 0;
		protected var _scrollBarValue:Object;
		protected var _offset:uint;
		protected var _scrollBar:IScrollBar;
		
		/** The size of each grid square. Can be bigger than the icon so it fits inside and you still see the grid lines. */
		protected var _gridSquareSize:Number;
		/** The offset of each element relative to its grid square */
		protected var _elementGridSquareOffset:Number;
		
		protected var _rows:uint;
		protected var _columns:uint;
		protected var _totalRenderers:int;
		
		public var handlesRightJoystick:Boolean = false;
		
		public var ignoreValidationOpt:Boolean = false;
		
		protected var _numRowsVisible:uint = 1;
		
		protected var _dropSelection:Boolean;
		protected var _highlightCanvas:Sprite;
		protected var _highlightIndicator:MovieClip;
		
		protected var _cachedItemPositions:Object;
		protected var _initFindSelection:Boolean = true;
		protected var _ignoreGridPosition:Boolean = false;
		public var ignoreNextGridPosition:Boolean = false;
		
		protected var _itemSectionsList:Array;
		protected var _paddingsMap:Object;
		
		protected var highestRowNeeded:uint = 0;
		
		// sometimes we use bigger mask, to show some elements which are out of the border
		// use this value to remove offset from scrolling logic
		public var gridMaskOffset:Number = 0;
		
		// dont save items position during data invalidation
		
		public var mcStateDropTarget:MovieClip;
		
		public function SlotsListGrid()
		{
			if (mcStateDropTarget)
			{
				mcStateDropTarget.visible = false;
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			_totalRenderers = _rows * _columns;
			createInitRenderers();
			
			_canvas.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll, false, 0, true);
			_highlightCanvas = new Sprite();
			_highlightCanvas.mouseChildren = false;
			_highlightCanvas.mouseEnabled = false;
			addChild(_highlightCanvas);
			
			if (gridMask)
			{
				_gridRenderHeight = gridMask.height - gridMaskOffset;
				_numRowsVisible = Math.floor((gridMask.height - gridMaskOffset) / CommonConstants.INVENTORY_GRID_SIZE);
			}
			
			addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
		}
		
		protected var _gridMask : MovieClip = null;
		protected function get gridMask() : MovieClip
		{
			if (_gridMask == null)
			{
				_gridMask = parent.getChildByName("mcGridMask") as MovieClip;
			}
			return _gridMask;
		}
		
		public function setItemSections(sectionsList:Array):void
		{
			_itemSectionsList = sectionsList;
			updateColumnsPaddingMap();
			
			clearRenderers();
		}
		
		private function updateColumnsPaddingMap():void
		{
			if (_itemSectionsList)
			{
				_paddingsMap = {};
				
				var len:int = _itemSectionsList.length;
				
				for (var k:int = 0; k < numColumns; k++ )
				{
					_paddingsMap[k] = 0;
					
					for (var i:int = 0; i < len; i++ )
					{
						if (k >= _itemSectionsList[i].start && k <= _itemSectionsList[i].end)
						{
							_paddingsMap[k] = _itemSectionsList[i].id;
							
							break;
						}
					}
				}
			}
		}
		
		// #Y TODO: Remove, move this logic to the menu level
		// MenuInventory :: IMS_Player, IMS_Shop, IMS_Container
		protected var _dropMode:int;
		public function get dropMode():int { return _dropMode }
		public function set dropMode(value:int):void
		{
			_dropMode = value;
		}
		
		protected var _useContextMgr:Boolean = true;
		public function get useContextMgr():Boolean { return _useContextMgr }
		public function set useContextMgr(value:Boolean):void
		{
			_useContextMgr = value;
		}

		// For preporation only
		public function get initFindSelection() { return _initFindSelection }
		public function set initFindSelection(value:Boolean):void
		{
			_initFindSelection = value;
		}

		public function get ignoreGridPosition() { return _ignoreGridPosition }
		public function set ignoreGridPosition(value:Boolean):void
		{
			_ignoreGridPosition = value;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			updateScrollBar();
		}
		
		override public function set focused(value:Number):void
		{
			if (value > 0 && value != focused)
			{
				if (selectedIndex < 0 && initFindSelection) findSelection();
			}
			super.focused = value;
		}

		override public function get numColumns():uint
		{
			return _columns;
		}

		/*
		 * 					-	Drag & Drop	-
		 */
		
		private var _dropEnabled:Boolean = true;
		public function get dropEnabled():Boolean { return _dropEnabled }
        public function set dropEnabled(value:Boolean):void
		{
			_dropEnabled = value;
		}
		
		public function applyDrop(dragData:IDragTarget):void
		{
			var itemData:ItemDataStub = dragData.getDragData() as ItemDataStub;
			var sourceRenderer:IInventorySlot = dragData as IInventorySlot;
			var isInternal:Boolean = sourceRenderer.owner == this;
			
			// transfer to first empty slot
			if (!_currentDropRenderer)
			{
				if (!isInternal)
				{
					if (_dropMode == MenuInventory.IMS_Shop)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnBuyItem", [ itemData.id, itemData.quantity, -1 ] ) );
					}
					else if (_dropMode == MenuInventory.IMS_Container)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnTransferItem", [ itemData.id, itemData.quantity, -1 ] ) );
					}
					else if (_dropMode == MenuInventory.IMS_Stash)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnTakeFromStash", [ itemData.id ] ) );
					}
					else
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnequipItem", [ itemData.id,  -1 ] ) );
					}
				}
				return;
			}
			
			var targetIdx:int;
			if (_currentDropRenderer.isEmpty())
			{
				targetIdx = getDropIndex(itemData.gridSize);
			}
			else
			{
				targetIdx = _currentDropRenderer.data.gridPosition;
			}
			
			if (isInternal)
			{
				if (_currentDropRenderer.isEmpty())
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnMoveItem", [ itemData.id, targetIdx ] ) );
				}
				else if (_currentDropRenderer.data.id != itemData.id) // Don't call this when moving an item to itself.
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnMoveItems", [ itemData.id, targetIdx, _currentDropRenderer.data.id, sourceRenderer.data.gridPosition] ) );
				}
			}
			else if (_dropMode == MenuInventory.IMS_Shop)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnBuyItem", [ itemData.id, itemData.quantity, targetIdx ] ) );
			}
			else if (_dropMode == MenuInventory.IMS_Container)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnTransferItem", [ itemData.id, itemData.quantity, targetIdx ] ) );
			}
			else if (_dropMode == MenuInventory.IMS_Stash)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnTakeFromStash", [ itemData.id ] ) );
			}
			else
			{
				if (_currentDropRenderer.isEmpty())
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnequipItem", [ uint(itemData.id), int(targetIdx) ] ) );
				}
				else
				{
					if (CommonUtils.checkSlotsCompatibility(_currentDropRenderer.data.slotType, sourceRenderer.data.slotType))
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnSwapItems", [ _currentDropRenderer.data.id, itemData.id, sourceRenderer.data.slotType] ) );
					}
				}
			}
			
			_cachedSelection = _currentDropRenderer.index;
			removeUselessRows();
			
			if (_currentDropRenderer)
			{
				dispatchItemClickEvent(_currentDropRenderer);
			}
		}
		
		public function canDrop(dragData:IDragTarget):Boolean
		{
			return true;
		}
		
		public function get dropSelection():Boolean { return _dropSelection }
        public function set dropSelection(value:Boolean):void
		{
			// Don't sure that we need this in the grid
			_dropSelection = value;
		}
		
		protected var _currentDropRenderer:IInventorySlot;
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			var currentDragIcon:int = SlotDragAvatar.ACTION_NONE;
			var showGridHighlighting:Boolean = false;
			
			trace("GFX ---- processOver -----");
			
			if (avatar)
			{
				var sourceRenderer:IInventorySlot = avatar.getSourceContainer() as IInventorySlot;
				var isInternal:Boolean = sourceRenderer.owner == this;
				
				if (!_highlightIndicator)
				{
					var IndicatorClassRef:Class = getDefinitionByName(HIGHLIGHT_REF) as Class;
					_highlightIndicator = new IndicatorClassRef() as MovieClip;
					_highlightCanvas.addChild(_highlightIndicator);
				}
				
				var gridSize:int = avatar.data.gridSize;
				var dropInx:int = getDropIndex(gridSize);
				
				if (dropInx < 0 || dropInx > _renderers.length)
				{
					// invalid target
					_currentDropRenderer = null;
					return SlotDragAvatar.ACTION_NONE;
				}
				
				var targetRenderer:IInventorySlot = _renderers[dropInx] as IInventorySlot;
				
				_currentDropRenderer = targetRenderer;
				
				if (targetRenderer)
				{
					if (!isSectionCorrect(targetRenderer.index, sourceRenderer.data))
					{
							_currentDropRenderer = null;
							cantUseCurrentPosition = false;
							highlightLabel = HIGHLIGHT_LABEL_DENIDED;
							currentDragIcon = SlotDragAvatar.ACTION_ERROR;
					}
					else
					{
						var cantUseCurrentPosition:Boolean = false;
						var highlightLabel:String = HIGHLIGHT_LABEL_ACCEPT;
						var isTargetEmpty:Boolean = targetRenderer.isEmpty();
						
						currentDragIcon = SlotDragAvatar.ACTION_GRID_DROP;
						
						if (targetRenderer.uplink && targetRenderer.uplink.data.id != sourceRenderer.data.id)
						{
							_currentDropRenderer = null;
							if (isInternal)
							{
								highlightLabel = HIGHLIGHT_LABEL_DENIDED;
								currentDragIcon = SlotDragAvatar.ACTION_ERROR;
							}
							else
							{
								highlightLabel = HIGHLIGHT_LABEL_ACCEPT;
								cantUseCurrentPosition = true;
								
								// shop ?
								currentDragIcon = SlotDragAvatar.ACTION_GRID_DROP;
							}
						}
						else if (!isTargetEmpty)
						{
							currentDragIcon = SlotDragAvatar.ACTION_GRID_SWAP;
							
							if (dropMode == MenuInventory.IMS_Shop && !isInternal)
							{
								// search for empty position
								cantUseCurrentPosition = false;
								currentDragIcon = SlotDragAvatar.ACTION_GRID_DROP; // rrr
							}
							else
							if (sourceRenderer && (sourceRenderer.owner != this || targetRenderer.data.gridSize != sourceRenderer.data.gridSize)  )
							{
								//if (targetRenderer.data.slotType != sourceRenderer.data.slotType)
								if (!CommonUtils.checkSlotsCompatibility(targetRenderer.data.slotType, sourceRenderer.data.slotType))
								{
									_currentDropRenderer = null;
									if (isInternal)
									{
										highlightLabel = HIGHLIGHT_LABEL_DENIDED;
										currentDragIcon = SlotDragAvatar.ACTION_ERROR;
									}
									else
									{
										highlightLabel = HIGHLIGHT_LABEL_ACCEPT;
										cantUseCurrentPosition = true;
										currentDragIcon = SlotDragAvatar.ACTION_GRID_DROP;
									}
								}
							}
						}
					}
					
					if (_currentDropRenderer != null && gridSize > 1)
					{
						
						var linkIdx:int = dropInx + _columns;
						while (linkIdx > _renderers.length) addRow();
						var linkedRenderer:IInventorySlot = _renderers[linkIdx] as IInventorySlot;
						
						if (!linkedRenderer.isEmpty() && ! (linkedRenderer.data.id == sourceRenderer.data.id))
						{
							_currentDropRenderer = null;
							if (isInternal)
							{
								highlightLabel = HIGHLIGHT_LABEL_DENIDED;
								currentDragIcon = SlotDragAvatar.ACTION_ERROR;
							}
							else
							{
								highlightLabel = HIGHLIGHT_LABEL_NONE;
								currentDragIcon = SlotDragAvatar.ACTION_GRID_DROP;
							}
						}
					}
					
					var highlightRenderer:IInventorySlot = targetRenderer;
					
					if (cantUseCurrentPosition)
					{
						// try to find free place
						var freeIndx:int =  findItemPlace(sourceRenderer.data);
						highlightRenderer = _renderers[freeIndx] as IInventorySlot;
					}
					
					if (mcStateDropTarget) mcStateDropTarget.visible = true;
					_highlightIndicator.x = highlightRenderer.x;
					_highlightIndicator.y = highlightRenderer.y;
					_highlightIndicator.width = gridSquareSize;
					_highlightIndicator.height = gridSquareSize * gridSize;
					_highlightIndicator.gotoAndStop(highlightLabel);
					_highlightIndicator.visible = true;
				}
			}
			else if (_highlightIndicator)
			{
				_highlightCanvas.removeChild(_highlightIndicator);
				_highlightIndicator = null;
				if (mcStateDropTarget) mcStateDropTarget.visible = false;
			}
			
			return currentDragIcon;
		}
		
		protected function isSectionCorrect(targetIdx:int, itemData:ItemDataStub):Boolean
		{
			if (itemData.sectionId < 0)
			{
				return true;
			}
			else
			{
				var targetSection:ItemSectionData = getItemSection(itemData.sectionId);
				
				if (targetSection)
				{
					var curColumn:int = getColumn(targetIdx);
					
					if (curColumn < targetSection.start || curColumn > targetSection.end)
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
			
			return true;
		}
		
		protected function handleSlotChanged(event:ListEvent):void
		{
			if (!handleScrollBar)
			{
				return;
			}

			var currentSlot:SlotBase = event.itemRenderer as SlotBase;

			if (currentSlot)
			{
				var curScrollValue:Number = scrollBar.position;
				var itemY:int = currentSlot.y;
				var itemHeight:int = currentSlot.gridSize  * _gridSquareSize; //currentSlot.getSlotRect().height;

				//trace("GFX - SlotsListGrid.handleSelectChange to new index: ", event.index, ", with yValue: ", itemY, ", and height: ", itemHeight, ", and gridHeight: ", _gridRenderHeight, ", and currentScrollValue: ", curScrollValue);

				if (((itemY + itemHeight) > _gridRenderHeight + curScrollValue))
				{
					// to bottom edge
					scrollBar.position = itemY + itemHeight - _gridRenderHeight;
				}
				else if (itemY < curScrollValue)
				{
					// to top edge
					scrollBar.position = itemY;
				}
			}

			var inventorySlot:SlotInventoryGrid = event.itemRenderer as SlotInventoryGrid;
			if (inventorySlot)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnInventoryItemSelected", [inventorySlot.data.id]));
			}

			updateScrollBar();
		}

		// TODO: for red highlighting
		protected function currentDropIsPossible(dropData:ItemDataStub):Boolean
		{
			return true;
		}

		protected function getDropRenderer():IInventorySlot
		{
			return _currentDropRenderer;
		}

		protected function getDropIndex(gridSize : int = 1):int
		{
			var targetCol:int = Math.min(_columns -1,  Math.ceil(mouseX / gridSquareSize) - 1);
			var yOffset:int = gridSize == 2 ? gridSquareSize / 2 : 0;
			var targetRow:int = Math.ceil((mouseY -  yOffset + _offset) / gridSquareSize) - 1;
			var targetIdx:int = targetCol + (targetRow * _columns);
			
			if (targetIdx > -1 && targetIdx < _renderers.length)
			{
				var targetRenderer:IBaseSlot = _renderers[targetIdx] as IBaseSlot;
				if (targetRenderer)
				{
					return targetRenderer.index;
				}
			}
			return -1;
		}

		/*
		 * 					-	PROPERTIES	-
		 */

		[Inspectable(type="String")]
        public function get scrollBar():Object { return _scrollBar }
        public function set scrollBar(value:Object):void
		{
            _scrollBarValue = value;
            invalidate(InvalidationType.SCROLL_BAR);
        }

		public function get scrollPosition() : uint { return offset }
		public function set scrollPosition( value : uint ) : void
		{
			offset = value;
		}

		[Inspectable(defaultValue="0")]
		public function get gridSquareSize():Number { return _gridSquareSize }
		public function set gridSquareSize( value : Number ) : void
		{
			_gridSquareSize = value;
		}

		[Inspectable(defaultValue="0")]
		public function get elementGridSquareOffset():Number { return _elementGridSquareOffset 	}
		public function set elementGridSquareOffset(value:Number):void
		{
			_elementGridSquareOffset = value;
		}

		[Inspectable(defaultValue="0")]
		public function get rows():uint {	return _rows }
		public function set rows(value:uint):void
		{
			_rows = value;
		}

		[Inspectable(defaultValue="0")]
		public function get columns():uint { return _columns }
		public function set columns(value:uint ):void
		{
			_columns = value;
		}

		public function get offset():uint { return _offset }
		public function set offset(value:uint):void
		{
			if ( value > -1 )
			{
				_offset = value;
			}
			
			_canvas.y = -_offset;
			validateRenderersSpecial();
			_highlightCanvas.y = _canvas.y;
			
			updateScrollBar();
		}
		
		public function getRendererNoUplink(index:uint):IListItemRenderer
		{
			if (index < 0 || index >= _renderers.length)
			{
				return null;
			}
			
			return _renderers[index] as IListItemRenderer;
		}
		
		override public function getRendererAt(index:uint, offset:int=0):IListItemRenderer
		{
			if (index < 0 || index >= _renderers.length)
			{
				return null;
			}
			var renderer:IInventorySlot = _renderers[index] as IInventorySlot;
			while(renderer && renderer.uplink)
			{
				renderer = renderer.uplink;
			}
			return renderer as IBaseSlot;
		}
		
		/*
		 * 					- Witcher Script -
		 */
		
		protected function saveItemPosition(targetItem:ItemDataStub):void
		{
			if (!_ignoreGridPosition)
			{
				// only for mouse
				dispatchEvent(new GameEvent(GameEvent.CALL, 'OnSaveItemGridPosition', [targetItem.id, targetItem.gridPosition ]));
			}
		}
		
		/*
		 *						- CORE -
		 */
			
		override protected function draw():void
		{
			super.draw();
			
			if (isInvalid(InvalidationType.SCROLL_BAR))
			{
                createScrollBar(); // ??
				updateScrollBar();
            }
			if (isInvalid(InvalidationType.DATA))
			{
                updateScrollBar();
            }
		}
		
		public function calculateColumnsAndRows(numItems:uint):void
		{
			if (gridSquareSize > 0)
			{
				columns = Math.floor(this.actualWidth / gridSquareSize);
				
				// To prevent infinite row count, force at least one column
				if (columns < 1)
				{
					columns = 1;
				}
			}

			rows = Math.ceil(numItems / columns);

			//trace("GFX - calculating columns and rows, numItems: ", numItems, " width: ", this.actualWidth, ", gridSize: ", gridSquareSize, ", columns: ", columns, ", rows: ", rows);
		}

		public function getSlotByID(slotID:int):SlotBase
		{
			var i:int;
			for ( i = 0; i < _renderers.length; ++i)
			{
				if (_renderers[i].data && _renderers[i].data.id == slotID)
				{
					return _renderers[i] as SlotBase;
				}
			}

			return null;
		}

		//private var _bufferPosition:Object = { }; // ???
		override public function updateItems(itemsList:Array):void
		{
			_specialCachedSelection = _cachedSelection ? _cachedSelection : selectedIndex;
			selectedIndex = -1;
			lastSelectedSection = -1;
			
			//#Y test
			//_bufferPosition = { };
			for each (var curDataStub in itemsList) // If its already in the grid, remove it first for sanity reasons.
			{
				for each (var curRenderer : IBaseSlot in _renderers)
				{
					if (!curRenderer.isEmpty() && curRenderer.data.id == curDataStub.id && curRenderer.data.gridPosition != curDataStub.gridPosition)
					{
						//_bufferPosition = curRenderer.index
						curRenderer.cleanup();
						break;
					}
				}
			}
			
			for each (var moreDataStub in itemsList)
			{
				appendItemData(moreDataStub, InputManager.getInstance().isGamepad());
			}

			if (_specialCachedSelection != -1)
			{
				ReselectIndexIfInvalid(_specialCachedSelection);
				_specialCachedSelection = -1;
			}

			validateNow();
			updateScrollBar();
		}

		override public function updateItemData(itemData:Object):void
		{
			_specialCachedSelection = _cachedSelection ? _cachedSelection : selectedIndex;
			selectedIndex = -1;
			
			appendItemData(itemData);

			if (_specialCachedSelection != -1)
			{
				ReselectIndexIfInvalid(_specialCachedSelection);
				_specialCachedSelection = -1;
			}
			
			validateNow();
			updateScrollBar();
		}

		override public function removeItem(itemId:uint, keepSelectionIdx:Boolean = false):void
		{
			var removedIdx:int = removeItemData(itemId);
			
			if (!keepSelectionIdx)
			{
				_specialCachedSelection = selectedIndex;
				
				if (selectedIndex == removedIdx)
				{
					ReselectIndexIfInvalid(removedIdx);
				}
			}
			
			validateNow();
			updateScrollBar();
		}

		protected function appendItemData(itemData:Object, ignoreCollisions:Boolean = false):void
		{
			var dataStub:ItemDataStub = itemData as ItemDataStub;
			if (dataStub)
			{
				removeItemData(dataStub.id);
				populateItemData(dataStub, !InputManager.getInstance().isGamepad(), ignoreCollisions);
				removeUselessRows();
			}
		}

		protected function removeItemData(itemId:uint):int
		{
			var targetIndex = getIdIndex(itemId);
			if (targetIndex > -1)
			{
				var targetRenderer:IInventorySlot = _renderers[targetIndex] as IInventorySlot;
				removeUplinks(targetRenderer);
				targetRenderer.cleanup();
				targetRenderer.data = null;
				_renderersCount--;
			}
			removeUselessRows();
			return targetIndex;
		}

		// Warning: only 2-cells items support
		protected function removeUplinks(targetRenderer:IInventorySlot):void
		{
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++)
			{
				var curItem:IInventorySlot = _renderers[i] as IInventorySlot;
				if (curItem.uplink == targetRenderer)
				{
					curItem.uplink = null;
				}
			}
		}
		
		override protected function populateData():void
		{
			super.populateData();
			
			if (_data)
			{
				updateColumnsPaddingMap();
				
				// ignoreNextGridPosition is used for when we trigger sorting
				
				var isGamepad:Boolean = InputManager.getInstance().isGamepad();
				var gridPositionsMatter:Boolean = !isGamepad && !ignoreNextGridPosition;
				var oldSelection = selectedIndex;
				
				if (gridPositionsMatter)
				{
					data.sortOn( "gridPosition",  Array.NUMERIC | Array.DESCENDING );
				}
				else
				{
					ignoreNextGridPosition = false;
					sortList(data);
				}
				
				
				cleanUpRenderers();
				
				var neededCellCount:int = 0;
				var curDataStub:ItemDataStub;
				
				for each ( curDataStub in _data )
				{
					neededCellCount += curDataStub.gridSize;
				}
				
				var minRenderersNeeded:int = Math.ceil(neededCellCount / _columns) * _columns;
				
				while (minRenderersNeeded > _renderers.length)
				{
					_renderers.push(spawnRenderer(_renderers.length));
				}
				
				if ( isGamepad )
				{
					// gpad only
					
					var i, k : int;
					var createdRawsCount : int = 0;
					var columnsMap 		 : Object = { };
					var columnsMap_plain : Array;
					var sectionsCount    : int;
					
					sectionsCount = _itemSectionsList ? _itemSectionsList.length : -1;
					
					//trace("GFX ---------------- SUPER-POPULATE  sectionsCount: ", sectionsCount);
					
					if (sectionsCount > 0)
					{
						for (i = 0; i < sectionsCount; i++)
						{
							var curSectionData:ItemSectionData = _itemSectionsList[i];
							var sectionColsCount:int = curSectionData.end - curSectionData.start + 1;
							var columnData:Array = [];
							
							for (k = 0; k < sectionColsCount; k++)
							{
								columnData[k] = 0;
							}
							
							columnsMap[i] = columnData;
						}
					}
					else
					{
						columnsMap_plain = [];
						
						for (k = 0; k < columns; k++)
						{
							columnsMap_plain.push( 0 );
						}
					}
					
					var targetDataStub:ItemDataStub;
					
					for each ( targetDataStub in _data )
					{
						var sectionData : ItemSectionData = getItemSection( targetDataStub.sectionId );
						var targetList  : Array;
						
						if (sectionsCount > 0)
						{
							targetList = columnsMap[ targetDataStub.sectionId ];
						}
						else
						{
							targetList = columnsMap_plain;
						}
						
						if (targetList)
						{
							var len:int = targetList.length;
							var minColumnIdx  : int = 0;
							var minColumnSize : int = targetList[0];
							
							for ( i = 1; i < len; i++ )
							{
								var curSize:int = targetList[i];
								
								if ( minColumnSize > curSize )
								{
									minColumnSize = curSize;
									minColumnIdx = i;
								}
							}
							
							//trace("GFX H1 : ", targetList);
							
							targetList[minColumnIdx] += 1;
							
							var sectionStartIdx 	: int = sectionData ? sectionData.start : 0;
							var targetIdx 			: int = sectionStartIdx + minColumnIdx + minColumnSize * numColumns;
							var rendererInstance 	: IInventorySlot = getRendererNoUplink(targetIdx) as IInventorySlot;
							
							//trace("GFX x : ", minColumnIdx, (" +(" + sectionStartIdx+ ") ; y: "), minColumnSize, " | res ", targetIdx );
							
							while( !rendererInstance )
							{
								addRow();
								rendererInstance = getRendererNoUplink( targetIdx ) as IInventorySlot;
							}
							
							// #Y CPY-PST:
							
							//trace("GFX place; targetIdx:  ", targetIdx, "; ", targetDataStub.gridSize);
							
							targetDataStub.gridPosition = targetIdx;
							rendererInstance.data = targetDataStub;
							
							++_renderersCount;
							
							if (targetDataStub.gridSize > 1)
							{
								targetList[minColumnIdx] += 1;
								
								var linkIdx:int = targetIdx + _columns;
								
								while (linkIdx >= _renderers.length)
								{
									addRow();
								}
								var linkedRenderer:IInventorySlot = _renderers[linkIdx] as IInventorySlot;
								
								linkedRenderer.uplink = rendererInstance;
							}
							
							
						}
						else
						{
							trace("GFX [SlotsListGrid] {WARNING} CAN'T POPULATE DATA --------------- ");
							//populateItemData( targetDataStub, false );
						}
						
					}
					
				}
				else
				{
					// Optimization to make sure we have at least the minimum number of renerers (row based) to support the data (2 sized items increase the change this won't be enough)
					
					var nonPositionedItems:Array = new Array();
					
					for each ( curDataStub in _data )
					{
						if (gridPositionsMatter && curDataStub.gridPosition < 0)
						{
							nonPositionedItems.push(curDataStub);
						}
						else
						{
							populateItemData(curDataStub, gridPositionsMatter);
						}
					}
					
					if (nonPositionedItems.length > 0)
					{
						sortList(nonPositionedItems);
						
						for each ( curDataStub in nonPositionedItems )
						{
							populateItemData(curDataStub, false);
						}
					}
				}
				
				//_initFindSelection = true;
			}
			
			if (_initFindSelection || oldSelection == -1)
			{
				findSelection();
			}
			else
			{
				ReselectIndexIfInvalid(oldSelection);
			}
			
			invalidate(InvalidationType.SCROLL_BAR);
			removeUselessRows();
			
			validateRenderersSpecial();
			//validateNow();
			
		}
		
		public function setCurrentSort(sortIndex:int):void
		{
			if (_lastSetSort != sortIndex)
			{
				_lastSetSort = sortIndex;
			}
		}
		
		protected function sortList(list:Array):void
		{
			if (!list)
			{
				return;
			}
			
			switch (_lastSetSort)
			{
				case MenuInventory.INV_SORT_MODE_INVALID:
				case MenuInventory.INV_SORT_MODE_TYPE:
					trace("GFX ------------ Applying Type sort ---------------------");
					list.sort(inventorySorter_Type);
					break;
				case MenuInventory.INV_SORT_MODE_PRICE:
					trace("GFX ------------ Applying Price sort ---------------------");
					list.sort(inventorySorter_Price);
					break;
				case MenuInventory.INV_SORT_MODE_WEIGHT:
					trace("GFX ------------ Applying Weight sort ---------------------");
					list.sort(inventorySorter_Weight);
					break;
				case MenuInventory.INV_SORT_MODE_DURABILTIY:
					trace("GFX ------------ Applying Durability sort ---------------------");
					list.sort(inventorySorter_Durability);
					break;
				case MenuInventory.INV_SORT_MODE_RARITY:
					trace("GFX ------------ Applying Rarity sort ---------------------");
					list.sort(inventorySorter_Rarity);
					break;
			}
		}
		
		protected function inventorySorter_Type(element1:ItemDataStub, element2:ItemDataStub):Number
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (/*element1.sortGroup != -1 && element2.sortGroup != -1 &&*/ element1.sortGroup != element2.sortGroup)
			{
				return (element1.sortGroup > element2.sortGroup) ? 1 : -1;
			}
			
			if (element1.disableAction && !element2.disableAction)
			{
				return 1;
			}
			else if (!element1.disableAction && element2.disableAction)
			{
				return -1;
			}
			
			// display food at the end of the list
			if (element1.category == "edibles" && element2.category != "edibles")
			{
				return 1;
			}
			else if (element1.category != "edibles" && element2.category == "edibles")
			{
				return -1;
			}
			
			// will work only for blacksmith menu
			if (element1.isEquipped && !element2.isEquipped)
			{
				return -1;
			}
			else if (!element1.isEquipped && element2.isEquipped)
			{
				return 1;
			}
			
			if (element1.slotType != element2.slotType)
			{
				if (element1.slotType == InventorySlotType.InvalidSlot)
				{
					return 1;
				}
				else if (element2.slotType == InventorySlotType.InvalidSlot)
				{
					return -1;
				}
				
				return InventorySlotType.getSortingWeight(element1.slotType) - InventorySlotType.getSortingWeight(element2.slotType);
			}
			
			if (element1.category != element2.category)
			{
				return (element1.category > element2.category) ? -1 : 1;
			}

			if (element1.quality != element2.quality)
			{
				return element2.quality - element1.quality;
			}

			return element1.id - element2.id;
		}
		
		protected function inventorySorter_Price(element1:ItemDataStub, element2:ItemDataStub):Number
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (element1.price != element2.price)
			{
				return element2.price - element1.price;
			}
			
			return inventorySorter_Type(element1, element2);
		}
		
		protected function inventorySorter_Weight(element1:ItemDataStub, element2:ItemDataStub):Number
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (element1.weight != element2.weight)
			{
				return element2.weight - element1.weight;
			}
			
			return inventorySorter_Type(element1, element2);
		}
		
		protected function inventorySorter_Durability(element1:ItemDataStub, element2:ItemDataStub):Number
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (element1.durability != element2.durability)
			{
				return element1.durability - element2.durability;
			}
			
			return inventorySorter_Type(element1, element2);
		}
		
		protected function inventorySorter_Rarity(element1:ItemDataStub, element2:ItemDataStub):Number
		{
			if (element1.isNew && !element2.isNew)
			{
				return -1;
			}
			else if (!element1.isNew && element2.isNew)
			{
				return 1;
			}
			
			if (element1.quality != element2.quality)
			{
				return element2.quality - element1.quality;
			}
			
			return inventorySorter_Type(element1, element2);
		}
		
		protected function tryRestoreItemPosition(targetDataStub:ItemDataStub):int
		{
			if (_cachedItemPositions)
			{
				var cachedPosition:int = _cachedItemPositions[targetDataStub.id];
				if (cachedPosition)
				{
					var curSlot:IBaseSlot = getRendererAt(cachedPosition) as IBaseSlot;
					if (curSlot && curSlot.isEmpty())
					{
						return cachedPosition;
					}
				}
			}
			return -1;
		}
		
		protected function populateItemData(targetDataStub:ItemDataStub, gridPositionMatters:Boolean, ignoreCollisions:Boolean = false):IInventorySlot
		{
			if (targetDataStub.invisible)
			{
				return null;
			}
			
			var startingPosition:int = targetDataStub.gridPosition;
			
			if (targetDataStub.gridPosition < 0 || !gridPositionMatters || !isItemPlaceValid(targetDataStub.gridPosition, targetDataStub.gridSize, targetDataStub.sectionId))
			{
				targetDataStub.gridPosition = findItemPlace(targetDataStub);
			}
			
			var rendererIdx:int = targetDataStub.gridPosition;
			var rendererInstance:IInventorySlot = getRendererAt(rendererIdx) as IInventorySlot;
			
			while (!rendererInstance) // #J The row was likely destroyed since this item was placed. Keep adding rows till it exists again
			{
				addRow();
				rendererInstance = getRendererAt(rendererIdx) as IInventorySlot;
			}
			
			// Causes problems when dragging an item on itself
			if (!rendererInstance.isEmpty() && (rendererInstance.data.id != targetDataStub.id ) && !ignoreCollisions)
			{
				targetDataStub.gridPosition = findItemPlace(targetDataStub);
				rendererInstance = getRendererAt(rendererIdx) as IInventorySlot;
			}
			
			if (targetDataStub.gridPosition != startingPosition)
			{
				saveItemPosition(targetDataStub);
			}
			
			rendererInstance.data = targetDataStub;
			++_renderersCount;
			
			if (targetDataStub.gridSize > 1)
			{
				var linkIdx:int = rendererIdx + _columns;
				while (linkIdx >= _renderers.length)
				{
					addRow();
				}
				var linkedRenderer:IInventorySlot = _renderers[linkIdx] as IInventorySlot;
				
				linkedRenderer.uplink = rendererInstance;
			}
			
			return rendererInstance;
			
		}
		
		protected function isItemPlaceValid(rendererIdx:int, size:int, sectionId:int = -1 ):Boolean
		{
			if (sectionId != -1)
			{
				var targetSection:ItemSectionData = getItemSection(sectionId);
				
				if (targetSection)
				{
					
					var curColumn:int = getColumn(rendererIdx);
					
					if (curColumn < targetSection.start || curColumn > targetSection.end)
					{
						return false;
					}
				}
			}
			
			if (rendererIdx >= _renderers.length)
			{
				return true;
			}
			
			var renderer:SlotBase = _renderers[rendererIdx] as SlotBase;
			
			if (renderer.isEmpty() && (renderer as IInventorySlot).uplink == null)
			{
				if (size > 1) // right now the only other size is 2 (and its always 1 down).... soooo ya haha
				{
					var downIndex = rendererIdx + _columns;
					if (downIndex >= _renderers.length || _renderers[downIndex].isEmpty()) // If its out of bounds, the renderer doesnt exist yet and therefore has to be empty
					{
						return true;
					}
				}
				else
				{
					return true;
				}
			}
			
			return false;
		}
		
		protected function getSectionRenderers(sectionId:int):Vector.<IBaseSlot>
		{
			var count:int = _renderers.length;
			var resultList:Vector.<IBaseSlot> = new Vector.<IBaseSlot>;
			
			for (var i:int = 0; i < count; i++ )
			{
				var curRenderer:IBaseSlot = _renderers[i];
				
				if (!curRenderer.isEmpty() && curRenderer.data.sectionId == sectionId)
				{
					resultList.push(curRenderer);
				}
			}
			
			return resultList;
		}
		
		protected function getSectionByRendererIdx(rendererIdx:int):ItemSectionData
		{
			if (_itemSectionsList)
			{
				var len:int = _itemSectionsList.length;
				var itemCol:int = getColumn(rendererIdx);
				
				for (var i = 0; i < len; i++ )
				{
					var curSectionData:ItemSectionData = _itemSectionsList[i] as ItemSectionData;
					
					if (curSectionData && itemCol >= curSectionData.start && itemCol <= curSectionData.end)
					{
						return curSectionData;
					}
				}
			}
			return null;
		}
		
		protected function getItemSection(sectionId:int):ItemSectionData
		{
			if (_itemSectionsList)
			{
				var len:int = _itemSectionsList.length;
				
				for (var i = 0; i < len; i++ )
				{
					var curSectionData:ItemSectionData = _itemSectionsList[i] as ItemSectionData;
					
					if (curSectionData && curSectionData.id == sectionId)
					{
						return curSectionData;
					}
				}
			}
			return null;
		}
		
		public var lastSelectedSection:int = -1; //temp, just for test
		override public function applySelectionContext():void
		{
			super.applySelectionContext();
			
			if (!_itemSectionsList) return;
			
			var targetSection:ItemSectionData = getSectionByRendererIdx( _selectedIndex );
			var targetSectionId:int = -1;
			
			if (targetSection)
			{
				targetSectionId = targetSection.id;
			}
			
			// #Y just for test, add check to prevent performance overhead
			//if (targetSectionId != lastSelectedSection)
			//{
				lastSelectedSection = targetSectionId;
				
				var len:int = _itemSectionsList.length;
				
				for (var i = 0; i < len; i++ )
				{
					var curSectionData:ItemSectionData = _itemSectionsList[i] as ItemSectionData;
					
					if (curSectionData && curSectionData.border)
					{
						var targetFrame:Number = 1;
						
						if (_activeSelectionVisible)
						{
							targetFrame = (curSectionData.id == lastSelectedSection) ? 2 : 1;
						}
						else
						{
							targetFrame = 1;
						}
						
						curSectionData.border.gotoAndStop(targetFrame);
						
					}
				}
			//}
		}
		
		const DEBUG_REC_LIMIT = 100;
		protected function findItemPlace(targetDataStub:ItemDataStub, depth:uint = 0):int
		{
			// Look from the bottom up if we have already recursively went once as that is the most likely place to find a spot now.
			var placeIdx:int = getFreeRendererIdx(targetDataStub);
			if (placeIdx > -1)
			{
				return placeIdx;
			}
			else
			{
				if (depth > DEBUG_REC_LIMIT)
				{
					throw new Error("Can't find place for item in the grid. Something is realy wrong!");
				}
				else
				{
					addRow();
					
					return findItemPlace(targetDataStub, depth + 1);
				}
			}
			return 0;
		}
		
		protected function getFreeRendererIdx(targetDataStub:ItemDataStub):int
		{
			var len:uint = _renderers.length;
			var reqSize:uint = targetDataStub.gridSize;

			for (var i:int = 0; i < len; i++)
			{
				if (isItemPlaceValid(i, targetDataStub.gridSize, targetDataStub.sectionId))
				{
					return i;
				}
			}
			return -1;
		}

		protected function isUplink(idx:int):Boolean
		{
			var targetRenderer:IInventorySlot = _renderers[idx] as IInventorySlot;
			if (targetRenderer)
			{
				return targetRenderer.uplink != null;
			}
			return false;
		}

		protected function addRow():void
		{
			var idx:int = _renderers.length;
			var count:int = idx + _columns;
			for (idx; idx < count; idx ++)
			{
				_renderers.push(spawnRenderer(_renderers.length));
			}
			invalidate(InvalidationType.SCROLL_BAR);
		}

		protected function removeUselessRows():void
		{
			var minNumRows:uint = _numRowsVisible;
			// Look through the data for an item that needs a row higher than minNumRows (highest value == lower in pixels)
			highestRowNeeded = 0;
			var rdrCount:int = _renderers.length;
			for (var i:int = 0; i < rdrCount; i++)
			{
				var curRenderer:IBaseSlot = _renderers[i];
				if (curRenderer && !curRenderer.isEmpty())
				{
					var curRendererData:ItemDataStub =  curRenderer.data as ItemDataStub;
					highestRowNeeded = curRendererData.gridPosition / _columns + curRendererData.gridSize;
					if (highestRowNeeded > minNumRows)
					{
						minNumRows = highestRowNeeded;
					}
				}

			}
			//trace("GFX - Trying to remove useless (excess) rows. Calculated the amount needed as: ", minNumRows, ", and current renderCount: ", _renderers.length);
			
			highestRowNeeded = minNumRows;
			// keep removing renderers until we have the desired length
			var targetRendererCount = minNumRows * _columns;
			while (targetRendererCount > _renderers.length)
			{
				addRow();
			}

			while (targetRendererCount < _renderers.length)
			{
				var curRdr:IInventorySlot = _renderers.pop() as IInventorySlot;
				_discardedRendererPool.push(curRdr);
				if (curRdr)
				{
					curRdr.cleanup();
					//cleanUpRenderer(curRdr);
					_canvas.removeChild(curRdr as DisplayObject);
				}
			}
			invalidate(InvalidationType.SCROLL_BAR);
		}

		private function createInitRenderers():void
		{
			_totalRenderers = rows * columns;
			_renderers = new Vector.<IBaseSlot>(_totalRenderers);
			// Create bottom to top so when 1x2 it will be overtop the bottom renderer
			for ( var index:int = _totalRenderers - 1; index >= 0; --index )
			{
				var renderer:IInventorySlot = spawnRenderer(index);
				_renderers[ index ] = renderer;
			}
		}
		
		public function updateRendererBounds():void
		{
			if (gridMask)
			{
				_renderBounds = gridMask.getBounds(stage);
				invalidateData();
			}
		}
		
		protected var _renderBounds:Rectangle = null;
		protected function get renderBounds():Rectangle
		{
			if (!ignoreValidationOpt && _renderBounds == null && gridMask)
			{
				_renderBounds = gridMask.getBounds(stage);
			}
			
			return _renderBounds;
		}

		private function spawnRenderer(index:uint):IInventorySlot
		{
			var newRenderer:IInventorySlot;
			
			if (_discardedRendererPool.length > 0)
			{
				newRenderer = _discardedRendererPool.pop();
			}
			else
			{
				newRenderer = new _slotRendererRef() as IInventorySlot;
			}
			
			newRenderer.index = index;
			
			if (newRenderer is SlotBase)
			{
				(newRenderer as SlotBase).name = "Instance: " + String(index);
				(newRenderer as SlotBase).validationBounds = renderBounds;
			}
			
			newRenderer.useContextMgr = _useContextMgr;
			_canvas.addChild(newRenderer as DisplayObject);
			repositionRenderer(index, newRenderer);
			setupRenderer(newRenderer);
			
			return newRenderer;
		}

		private function repositionRenderer(index:int, renderer:IInventorySlot)
		{
			var rendererColumn:int = getColumn( index );
			var rendererRow:int = getRow( index );
			var sectionPadding:uint = 0;
			
			if (_paddingsMap)
			{
				sectionPadding = _paddingsMap[rendererColumn] * SECTION_PADDING;
			}
			
			//trace("GFX repositionRenderer ", index, _paddingsMap, " --> ", sectionPadding);
			
			renderer.x = rendererColumn * _gridSquareSize + _elementGridSquareOffset * rendererColumn + sectionPadding;
			renderer.y = rendererRow * _gridSquareSize + _elementGridSquareOffset * rendererRow;
		}

		private function cleanUpRenderers():void
		{
			var renderer:IInventorySlot;
			for each ( renderer in _renderers )
			{
				if (renderer)
					renderer.cleanup();
			}
			_renderersCount = 0;
		}

		 /*
		 * 						- SCROLLING	-
		 */

		protected function scrollList(delta:int):void
		{
			scrollPosition -= delta
		}

		//protected var scrollTweener:GTween;
		protected function handleScroll(event:Event):void
		{
			// #J did not work as expected due to cyclical nature of variables. Maybe worth looking into fixing it when more time,
			// hence why I just put this system in comments
			/*var l_delta : int = _scrollBar.position - m_lastScrollPosition;

			if (smoothScrolling)
			{
				if (scrollTweener)
				{
					scrollTweener.paused = true;
					var finScrollPosition:Number = scrollTweener.getValue("y") as Number;
					this.y = finScrollPosition;
					GTweener.removeTweens(this);
				}

				var targetY:Number = this.y - l_delta;
				var durationMultiplier:Number = (l_delta / (520));
				if (durationMultiplier < 1.0) durationMultiplier = 1.0;
				scrollTweener = GTweener.to(this, (0.3 * durationMultiplier), { y: targetY }, {onComplete:handleTweenComplete} );
			}
			else
			{*/
				scrollPosition = _scrollBar.position;
			/*}

			m_lastScrollPosition = _scrollBar.position;*/
        }
		
		// Only validates renderes that have no successfully setup their data yet
		protected function validateRenderersSpecial():void
		{
			var currentRenderer:SlotBase;
			var minRowsValidAtStart:int = _numRowsVisible * _columns;
			
			for (var i = 0; i < _renderers.length; ++i)
			{
				currentRenderer = _renderers[i] as SlotBase;
				
				if (currentRenderer && currentRenderer.awaitingCompleteValidation)
				{
					currentRenderer.validateNow();
					
					if (i <= minRowsValidAtStart && currentRenderer && currentRenderer.awaitingCompleteValidation)
					{
						currentRenderer.forceValidateNow();
					}
				}
			}
		}

		/*protected function handleTweenComplete(curTween:GTween):void
		{
			scrollPosition = this.y;
			scrollTweener = null;
		}*/

		protected function onScroll( event : MouseEvent ) : void
		{
			if ( _maxOffset > 0 )
			{
				if ( event.delta > 0 )
				{
					_scrollBar.position -= CommonConstants.INVENTORY_GRID_SIZE;
				}
				else
				{
					_scrollBar.position += CommonConstants.INVENTORY_GRID_SIZE;
				}
			}
		}

		override protected function handleRightJoystick(yValue:Number)
		{
			if (handlesRightJoystick)
			{
				if ( _maxOffset > 0 )
				{
					_scrollBar.position -= yValue * 40;
				}
			}
		}

		protected function createScrollBar():void
		{
			if (!_scrollBar && _scrollBarValue)
			{
				_scrollBar = parent.getChildByName(_scrollBarValue.toString()) as IScrollBar;
				_scrollBar.addEventListener(Event.SCROLL, handleScroll, false, 0, true);
				_scrollBar.addEventListener(Event.CHANGE, handleScroll, false, 0, true);
				_scrollBar.focusTarget = this;
				_scrollBar.tabEnabled = false;
			}
		}

		protected function updateScrollBar():void
		{
			if (_scrollBar != null)
			{
				var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
				var pageSize:Number = _rows * _gridSquareSize ;
				
				_maxOffset = (highestRowNeeded - _rows) * _gridSquareSize;
				_maxOffset = Math.max(0, _maxOffset);
				
				if (!_maxOffset || !visible)
				{
					scrollIndicator.visible = false;
					scrollIndicator.setScrollProperties( 0, 0, 0);
				}
				else
				{
					scrollIndicator.visible = true;
					scrollIndicator.setScrollProperties( pageSize, 0, _maxOffset );
				}
				_scrollBar.position = scrollPosition;
				_scrollBar.validateNow();
			}
		}
		
		override public function handleInputNavSimple(event:InputEvent):void
		{
			if (event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details as InputDetails;
			var result:Boolean = false;
			var isRStick:Boolean = details.navEquivalent == NavigationCode.RIGHT_STICK_LEFT || details.navEquivalent == NavigationCode.RIGHT_STICK_RIGHT;
			
			if (_itemSectionsList && _itemSectionsList.length > 0 && isRStick && (event.details.value != InputValue.KEY_UP))
			{
				var selectedRenderer:IBaseSlot = getSelectedRenderer() as IBaseSlot;
				
				if (selectedRenderer)
				{
					var selectionContainer:Sprite = (selectedRenderer as Sprite).parent as Sprite;
					
					if (selectionContainer)
					{
						var currentSectionData:ItemSectionData = getSectionByRendererIdx(selectedIndex);
						var targetSectionId:int = currentSectionData.id;
						
						while (!result && targetSectionId < _itemSectionsList.length && targetSectionId >= 0)
						{
							switch (details.navEquivalent)
							{
								case NavigationCode.RIGHT_STICK_LEFT:
									targetSectionId--;
									break;
								case NavigationCode.RIGHT_STICK_RIGHT:
									targetSectionId++;
									break;
							}
							
							if (targetSectionId < _itemSectionsList.length && targetSectionId >= 0)
							{
								var renderersList:Vector.<IBaseSlot> = getSectionRenderers(targetSectionId);
								var len:int = renderersList.length;
								
								for (var i:int = 0; i < len; i++)
								{
									const inflateBorder = -10;
									var slotBase:SlotBase = renderersList[i] as SlotBase;
									var slotRenderBounds:Rectangle = slotBase.getGlobalSlotRect();
									
									slotRenderBounds.inflate(inflateBorder, inflateBorder);
									if (slotBase && renderBounds.intersects(slotRenderBounds))
									{
										selectedIndex = slotBase.index;
										result = true;
										break;
									}
								}
								
							}
						}
					}
				}
			}
			
			if (result)
			{
				event.handled = true;
			}
			
			super.handleInputNavSimple(event);
		}
		
		override public function getColumn( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return index % _columns;
		}

		override public function getRow( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return index / columns;
		}

		override public function toString():String
		{
			return "[SlotsListGrid " + name + "]";
		}

		override public function GetDropdownListHeight() : Number
		{
			return _rows * gridSquareSize + ITEM_PADDING;
		}
	}
}
