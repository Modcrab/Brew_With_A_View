package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.interfaces.IScrollingList;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.Math2;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.managers.FocusHandler;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusManager;
	import scaleform.gfx.MouseEventEx;

	/**
	 * Base class for all slot lists (grids, paperdols, etc)
	 * @author Yaroslav Getsevich
	 */
	public class SlotsListBase extends UIComponent implements IScrollingList
	{
		protected var _canvas:Sprite;
		protected var _selectedIndex:int = -1;
		protected var _data:Array;
		protected var _renderers:Vector.<IBaseSlot>;
		protected var _cachedSelection:int;
		protected var _mouseContext:IBaseSlot;
		protected var _selectionContext:IBaseSlot;

		protected var _slotRenderer:String;
		protected var _slotRendererRef:Class;
		protected var _renderersCount:int;
		
		protected var _lastLeftAxisX:Number;
		protected var _lastLeftAxisY:Number;
		
		public var ignoreSelectable:Boolean = false;
		
		public var filterKeyCodeFunction:Function;
		public var filterNavCodeFunction:Function;
		
		public function SlotsListBase()
		{
			_data = [];
			_renderers = new Vector.<IBaseSlot>;
			_canvas = new Sprite();
			addChild(_canvas);
			focusable = true;

			_selectedIndex = -1;
			_renderersCount = 0;

			tabEnabled = false;
			tabChildren = false;
		}

		public function getRenderersCount():int
		{
			return _renderersCount;
		}
		
		public function getRenderersLength():int
		{
			return _renderers.length;
		}

		override protected function configUI():void
		{
			super.configUI();
			addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		[Inspectable(name="slotRenderer", defaultValue="DefaultInventorySlot")]
		public function get slotRendererName() : String	{ return _slotRenderer }
		public function set slotRendererName( value : String ) : void
		{
			if (_slotRenderer != value)
			{
				_slotRenderer = value;
				try
				{
					_slotRendererRef = getDefinitionByName( _slotRenderer ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + _slotRenderer );
				}
			}
		}

		/*
		 * 							- API -
		 */

		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			_data = value;
			invalidateData();
		}

		public function stableDataUpdate(dataset:Array):void
		{

		}

		public function get numColumns():uint
		{
			return 0;
		}
		
		public function get numRows():uint
		{
			return Math.ceil(_renderers.length / numColumns);
		}

		public function get rendererHeight():Number
		{
			if (_renderers.length > 0)
			{
				return _renderers[0].height;
			}
			return 0;
		}

		// #J returns -1 when the selection is not a valid column
		public function get selectedColumn():int
		{
			if (selectedIndex >= 0 && numColumns > 0)
			{
				return selectedIndex % numColumns;
			}

			return -1;
		}

		// virtual
		public function updateItemData(itemData:Object):void {}
		public function removeItem(itemId:uint, keepSelectionIdx:Boolean = false):void { }
		public function updateItems(itemsList:Array):void { }
		public function findSelection():void
		{
			var newSelection:int = _cachedSelection ? _cachedSelection : selectedIndex;
			var newRenderer:IBaseSlot = getRendererAt(newSelection) as IBaseSlot;
			if (!newRenderer || (newRenderer && !newRenderer.selectable))
			{
				newSelection = -1;
				
				var len:int = _renderers.length;
				for (var i:int = 0; i < len; i++)
				{
					if (_renderers[i] && _renderers[i].selectable)
					{
						newSelection = i;
						break;
					}
				}
			}
			else
			{
				newSelection = newRenderer.index;
			}
			selectedIndex =  newSelection;
		}
		public function GetDropdownListHeight() : Number { return 0; }

		public function getSelectedRenderer():IListItemRenderer
		{
			if (_selectedIndex < 0 || _selectedIndex >= _renderers.length)
				return null;
				
			return _renderers[_selectedIndex] as IListItemRenderer;
		}
		
		public function getRendererIndex(renderer:IListItemRenderer) : int
		{
			return _renderers.indexOf(renderer);
		}
		
		public function getRendererAt(index:uint, offset:int=0):IListItemRenderer
		//public function getRendererAt(index:int):IBaseSlot
		{
			if ( index < 0 || index >= _renderers.length )
			{
				return null;
			}
			else
			{
				return _renderers[index];
			}
		}

		/*
		 * 							- CORE -
		 */

		override protected function draw() : void
		{
			if (isInvalid(InvalidationType.DATA))
			{
				populateData();
			}
		}

		protected function populateData():void { }
		
		protected var _activeSelectionVisible:Boolean = true;
		public function get activeSelectionVisible():Boolean { return _activeSelectionVisible; }
		public function set activeSelectionVisible(value:Boolean):void
		{
			if (_activeSelectionVisible != value)
			{
				_activeSelectionVisible = value;
				updateActiveSelectionVisible();
				
				applySelectionContext();
			}
		}
		
		public function updateActiveSelectionVisible():void
		{
			var i:int;
			
			for (i = 0; i < _renderers.length; ++i)
			{
				var currentSlot:SlotBase = _renderers[i] as SlotBase;
				
				if (currentSlot)
				{
					currentSlot.activeSelectionEnabled = _activeSelectionVisible;
				}
			}
		}

		/*
		 * 					- NAVIGATION AND INPUT HANDLING -
		 */
		
		public var allowSimpleNavDPad:Boolean = true;
		
		public function handleInputPreset(event:InputEvent):void
		{
			//trace("GFX handleInputPreset ", event.handled);
			
			if (event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			// #J start wierd hack to avoid dpad
			// {
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			var navCommand:String = (details.fromJoystick || allowSimpleNavDPad) ? details.navEquivalent : NavigationCode.INVALID;
			if (keyPress)
			{
				switch (navCommand)
				{
					case NavigationCode.UP:
					case NavigationCode.DOWN:
					case NavigationCode.LEFT:
					case NavigationCode.RIGHT:
						
						var slot:SlotBase = getSelectedRenderer() as SlotBase;
						
						if (slot)
						{
							var targetIndex = slot.GetNavigationIndex(navCommand);
							
							//trace("GFX *[", _selectedIndex, "]* navCommand ", navCommand, "; targetIndex ", targetIndex);
							
							if (targetIndex != -1)
							{
								var targetSlot:SlotBase = getRendererAt(targetIndex) as SlotBase;
								
								//trace("GFX * targetSlot ", targetSlot, targetSlot.selectable, ignoreSelectable);
								
								if (targetSlot.selectable || ignoreSelectable)
								{
									selectedIndex = targetIndex;
									event.handled = true;
								}
								else
								{
									
									targetIndex = SearchForNearestSelectableIndexInDirection(navCommand);
									
									//trace("GFX * targetIndex ", targetIndex);
									
									if (targetIndex != -1)
									{
										selectedIndex = targetIndex;
										event.handled = true;
									}
								}
							}
						}
						break;
				}
			}
		}
		
		public function SearchForNearestSelectableIndexInDirection(navCode:String):int
		{
			var minXValue:Number = -1;
			var maxXValue:Number = -1;
			var minYValue:Number = -1;
			var maxYValue:Number = -1;
			
			//trace("GFX - Searching for nearest Selectable index with direction:" + navCode);
			
			var currentSelectedSlot:SlotBase = getSelectedRenderer() as SlotBase;
			
			if (!currentSelectedSlot)
			{
				return -1;
			}
			
			switch (navCode)
			{
			case NavigationCode.UP:
				maxYValue = currentSelectedSlot.y;
				break;
			case NavigationCode.DOWN:
				minYValue = currentSelectedSlot.y;
				break;
			case NavigationCode.LEFT:
				maxXValue = currentSelectedSlot.x;
				break;
			case NavigationCode.RIGHT:
				minXValue = currentSelectedSlot.x;
				break;
			}
			
			var currentSlot:SlotBase;
			var i:int;
			var currentDistance:Number = 0;
			var closestDistance:Number = Number.MAX_VALUE;
			var closestSlot:SlotBase = null;
			
			// in this case we will jump to a bigger item on scrolling down, even if it is on the same position
			var isSmallItemSelected:Boolean = false;
			
			if (currentSelectedSlot.data && currentSelectedSlot.data.hasOwnProperty("gridSize"))
			{
				isSmallItemSelected = currentSelectedSlot.data.gridSize < 2;
			}
			
			for (i = 0; i < _renderers.length; ++i)
			{
				currentSlot = _renderers[i] as SlotBase;
				
				// Step 1 validate its in the right direction
				if (currentSlot != currentSelectedSlot &&
					(currentSlot.selectable || ignoreSelectable) &&
					(maxYValue == -1 || currentSlot.y < maxYValue) &&
					(minYValue == -1 || currentSlot.y > minYValue || ( currentSlot.y == minYValue && isSmallItemSelected && currentSlot.data.gridSize > 1 )) &&
					(maxXValue == -1 || currentSlot.x < maxXValue) &&
					(minXValue == -1 || currentSlot.x > minXValue))
				{
					currentDistance = Math.sqrt(Math.pow(currentSelectedSlot.x - currentSlot.x, 2) + Math.pow(currentSelectedSlot.y - currentSlot.y, 2));
					
					if (currentDistance < closestDistance)
					{
						closestDistance = currentDistance;
						closestSlot = currentSlot;
					}
				}
			}
			
			if (closestSlot != null)
			{
				return _renderers.indexOf(closestSlot);
			}
			
			return -1;
		}
		
		public function handleInputNavSimple(event:InputEvent):void
		{
			//trace("GFX -[", this, "]- handleInputNavSimple  ", event.details.code, event.details.navEquivalent);
			
			if (event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			
			//trace("GFX *** ", details.code, "; allowSimpleNavDPad ", allowSimpleNavDPad);
			
			// #J don't use this information but keep it in mind for the next time we get a static navigation code to skew the haduken in its favor
			if (details.code == KeyCode.PAD_LEFT_STICK_AXIS)
			{
				_lastLeftAxisX = details.value.xvalue;
				_lastLeftAxisY = details.value.yvalue;
				return;
			}
			
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			// #J start wierd hack to avoid dpad
			// {
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			var navCommand:String = (details.fromJoystick || allowSimpleNavDPad) ? details.navEquivalent : NavigationCode.INVALID;
			if (!allowSimpleNavDPad)
			{
				switch (details.code)
				{
					case KeyCode.W:
					case KeyCode.UP:
						navCommand = NavigationCode.UP;
						break;
					case KeyCode.S:
					case KeyCode.DOWN:
						navCommand = NavigationCode.DOWN;
						break;
					case KeyCode.A:
					case KeyCode.LEFT:
						navCommand = NavigationCode.LEFT;
						break;
					case KeyCode.D:
					case KeyCode.RIGHT:
						navCommand = NavigationCode.RIGHT;
						break;
				}
			}
			// } END OF WIERD HACK

			
			//trace("GFX ** navCommand ", navCommand);
			
			var startingRow:int = (_selectedIndex == -1) ? (-1) : (Math.floor(_selectedIndex / numColumns));
			var startingCol:int = (_selectedIndex == -1) ? (-1) : (_selectedIndex - (startingRow * numColumns));
			
			var curRow:int = 0;
			var curCol:int = 0;
			
			var foundSelection:int = -1;
			
			var maxOffset = 1;

			if (keyPress)
			{
				// #J TODO: this can probably be refactored to be a lot lighter and save duplicate code
				switch( navCommand )
				{
				case NavigationCode.UP:
					{
						if (_selectedIndex == -1)
						{
							findSelection();
						}
						else
						{
							//trace("GFX ----------------------------- Starting up search from (", startingRow, ",", startingCol, ") -------------------------------");
							//traceGrid();
							//trace("GFX ------------------------------------------------------------------------------------------------");
							
							// This is now dubbed the Haduken navigation search algorithm
							for (curRow = startingRow - 1; curRow >= 0; --curRow)
							{
								if (searchUpDown(curRow, startingCol, startingRow, maxOffset))
								{
									event.handled = true;
									break;
								}
								
								++maxOffset;
							}
							
							//trace("GFX ================================== Search Ended in failure =======================================");
							
							// Fallback in case haduken fails
							if (!event.handled)
							{
								foundSelection = SearchForNearestSelectableIndexInDirection(navCommand);
								if (foundSelection != -1 && selectRendererAtIndexIfValid(foundSelection))
								{
									event.handled = true;
								}
							}
						}
					}
					break;

				case NavigationCode.DOWN:
					{
						if (_selectedIndex == -1)
						{
							findSelection();
						}
						else
						{
							//trace("GFX ----------------------------- Starting Down search from (", startingRow, ",", startingCol, ") -------------------------------");
							//traceGrid();
							//trace("GFX ------------------------------------------------------------------------------------------------");
							
							// This is now dubbed the Haduken navigation search algorithm
							if ((_renderers[_selectedIndex] is SlotInventoryGrid) && (_renderers[_selectedIndex] as SlotInventoryGrid).data.gridSize > 1)
							{
								startingRow += 1;
							}
							
							for (curRow = startingRow + 1; curRow < numRows; ++curRow)
							{
								if (searchUpDown(curRow, startingCol, startingRow, maxOffset))
								{
									event.handled = true;
									break;
								}
								
								++maxOffset;
							}
							
							// Fallback in case haduken fails
							if (!event.handled)
							{
								foundSelection = SearchForNearestSelectableIndexInDirection(navCommand);
								if (foundSelection != -1 && selectRendererAtIndexIfValid(foundSelection))
								{
									event.handled = true;
								}
							}
							
							//trace("GFX ================================== Search Ended in failure =======================================");
						}
					}
					break;

				case NavigationCode.LEFT:
					{
						if (_selectedIndex == -1)
						{
							findSelection();
						}
						else
						{
							//trace("GFX ----------------------------- Starting Left search from (", startingRow, ",", startingCol, ") -------------------------------");
							//traceGrid();
							//trace("GFX ------------------------------------------------------------------------------------------------");
							
							// This is now dubbed the Haduken navigation search algorithm
							for (curCol = startingCol - 1; curCol >= 0; --curCol)
							{
								if (searchLeftRight(curCol, startingCol, startingRow, maxOffset))
								{
									event.handled = true;
									break;
								}
								
								++maxOffset;
							}
							
							// Fallback in case haduken fails
							if (!event.handled)
							{
								foundSelection = SearchForNearestSelectableIndexInDirection(navCommand);
								if (foundSelection != -1 && selectRendererAtIndexIfValid(foundSelection))
								{
									event.handled = true;
								}
							}
							
							//trace("GFX ================================== Search Ended in failure =======================================");
						}
					}
					break;

				case NavigationCode.RIGHT:
					{
						if (_selectedIndex == -1)
						{
							findSelection();
						}
						else
						{
							//trace("GFX ----------------------------- Starting Right search from (", startingRow, ",", startingCol, ") -------------------------------");
							//traceGrid();
							//trace("GFX ------------------------------------------------------------------------------------------------");
							
							// This is now dubbed the Haduken navigation search algorithm
							for (curCol = startingCol + 1; curCol < numColumns; ++curCol)
							{
								if (searchLeftRight(curCol, startingCol, startingRow, maxOffset))
								{
									event.handled = true;
									break;
								}
								
								++maxOffset;
							}
							
							// Fallback in case haduken fails
							if (!event.handled)
							{
								foundSelection = SearchForNearestSelectableIndexInDirection(navCommand);
								if (foundSelection != -1 && selectRendererAtIndexIfValid(foundSelection))
								{
									event.handled = true;
								}
							}
							
							//trace("GFX ================================== Search Ended in failure =======================================");
						}
					}
					break;
				}
			}
			else if (details.code == KeyCode.PAD_RIGHT_STICK_AXIS)
			{
				handleRightJoystick(details.value.yvalue);
			}
			
			if (!event.handled && details.value == InputValue.KEY_UP)
			{
				if (filterKeyCodeFunction != null && filterNavCodeFunction != null)
				{
					if ( !filterKeyCodeFunction(event.details.code) || !filterNavCodeFunction(event.details.navEquivalent) )
					{
						return;
					}
				}
				
				var curRenderer:SlotBase = _renderers[_selectedIndex] as SlotBase;
				if (curRenderer && !curRenderer.isEmpty())
				{
					curRenderer.executeAction(details.code, event);
				}
			}
		}
		
		protected function searchLeftRight(curCol:int, startingCol:int, startingRow:int, maxOffset:int) : Boolean
		{
			var offset:int = 0;
			
			var offsetIndex1:int = 0;
			var offsetIndex2:int = 0;
			
			var selectedItemSize:int = 1;
			
			if (_renderers[_selectedIndex] != null && _renderers[_selectedIndex] is SlotInventoryGrid)
			{
				selectedItemSize = (_renderers[_selectedIndex] as SlotInventoryGrid).data.gridSize;
			}
			
			while (true)
			{
				if (offset > maxOffset)
				{
					break;
				}
				else if (offset == 0)
				{
					//trace("GFX Checking renderer at (", startingRow, ",", curCol, ") with index:", getIndexFromCoordinates(startingRow, curCol));
					if ( selectRendererAtIndexIfValid(getIndexFromCoordinates(startingRow, curCol)) ||
						 (selectedItemSize > 1 && selectRendererAtIndexIfValid(getIndexFromCoordinates(startingRow + 1, curCol))) )
					{
						return true;
					}
				}
				else
				{
					if (_lastLeftAxisY < 0)
					{
						offsetIndex1 = getIndexFromCoordinates(selectedItemSize > 1 ? startingRow + offset + 1 : startingRow + offset, curCol);
						offsetIndex2 = getIndexFromCoordinates(startingRow - offset, curCol);
					}
					else
					{
						offsetIndex1 = getIndexFromCoordinates(startingRow - offset, curCol);
						offsetIndex2 = getIndexFromCoordinates(selectedItemSize > 1 ? startingRow + offset + 1 : startingRow + offset, curCol);
					}
					
					//trace("GFX Checking renderer at (", startingRow, ",", curCol, ") with offset:", offset, ", and index1:", offsetIndex1, ", and index2:", offsetIndex2);
					
					if (offsetIndex1 < 0 && offsetIndex2 < 0)
					{
						break; // End the while loop since no more valid offsets
					}
					else if ( (offsetIndex1 >= 0 && selectRendererAtIndexIfValid(offsetIndex1)) ||
							  (offsetIndex2 >= 0 && selectRendererAtIndexIfValid(offsetIndex2)) )
					{
						return true;
					}
				}
				
				++offset;
			}
			
			return false;
		}
		
		protected function searchUpDown(curRow:int, startingCol:int, startingRow:int, maxOffset:int) : Boolean
		{
			var offset:int = 0;
			
			var offsetIndex1:int = 0;
			var offsetIndex2:int = 0;
			
			var selectedItemSize:int = 1;
			
			if (_renderers[_selectedIndex] != null && _renderers[_selectedIndex] is SlotInventoryGrid)
			{
				selectedItemSize = (_renderers[_selectedIndex] as SlotInventoryGrid).data.gridSize;
			}
					
			while (true)
			{
				if (offset > maxOffset)
				{
					break;
				}
				else if (offset == 0)
				{
					//trace("GFX Checking renderer at (", curRow, ",", startingCol, ") with index:", getIndexFromCoordinates(curRow, startingCol));
					if (selectRendererAtIndexIfValid(getIndexFromCoordinates(curRow, startingCol)))
					{
						return true;
					}
				}
				else
				{
					if (_lastLeftAxisX < 0)
					{
						offsetIndex1 = getIndexFromCoordinates(curRow, startingCol - offset);
						offsetIndex2 = getIndexFromCoordinates(curRow, startingCol + offset);
					}
					else
					{
						offsetIndex1 = getIndexFromCoordinates(curRow, startingCol + offset);
						offsetIndex2 = getIndexFromCoordinates(curRow, startingCol - offset);
					}
					
					//trace("GFX Checking renderer at (", curRow, ",", startingCol, ") with offset:", offset, ", and index1:", offsetIndex1, ", and index2:", offsetIndex2);
					
					if (offsetIndex1 < 0 && offsetIndex2 < 0)
					{
						break; // End the while loop
					}
					else if ( (offsetIndex1 >= 0 && selectRendererAtIndexIfValid(offsetIndex1)) ||
							  (offsetIndex2 >= 0 && selectRendererAtIndexIfValid(offsetIndex2)) )
					{
						return true;
					}
				}
				
				++offset;
			}
			
			return false;
		}
		
		// returns -1 if no valid matching index possible
		public function getIndexFromCoordinates(row:int, col:int):int
		{
			if (row >= 0 && row < numRows && col >= 0 && col < numColumns)
			{
				return numColumns * row + col;
			}
			
			return -1;
		}
		
		// Returns true if selection occurred
		public function selectRendererAtIndexIfValid(index:int):Boolean
		{
			var targetRenderer:SlotBase = getRendererAt(index) as SlotBase;
			var selectedRenderer:SlotBase = getRendererAt(_selectedIndex) as SlotBase;
			
			if (targetRenderer && !targetRenderer.isEmpty() && selectedRenderer != targetRenderer)
			{
				var inventoryRenderer:SlotInventoryGrid = _renderers[index] as SlotInventoryGrid;
				
				if (inventoryRenderer && inventoryRenderer.uplink != null)
				{
					if ((inventoryRenderer.uplink as SlotInventoryGrid) != selectedRenderer)
					{
						inventoryRenderer = inventoryRenderer.uplink as SlotInventoryGrid;
						selectedIndex = inventoryRenderer.index;
						dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false,  inventoryRenderer.index, -1, -1, inventoryRenderer, this.data ) );
					}
					else
					{
						return false;
					}
				}
				else
				{
					selectedIndex = index;
					dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, index, -1, -1, targetRenderer, this ) );
				}
				return true;
			}
			
			return false;
		}
		
		public function traceGrid():void
		{
			var traceString:String;
			var traceIndex:int = 0;
			var r:int = 0;
			var c:int = 0;
			
			for (r = 0; r < numRows; ++r)
			{
				traceString = "GFX - |";
				
				for (c = 0; c < numColumns; ++c)
				{
					traceIndex = getIndexFromCoordinates(r, c);
					
					var invRenderer:SlotInventoryGrid = getRendererAt(traceIndex) as SlotInventoryGrid;
					
					if (traceIndex == -1 || traceIndex >= _renderers.length)
					{
						traceString += " e |";
					}
					else if (traceIndex == _selectedIndex)
					{
						traceString += " s |";
					}
					else if (invRenderer)
					{
						if ((_renderers[traceIndex] as IInventorySlot).uplink != null)
						{
							traceString += " u |";
						}
						else if (invRenderer.isEmpty())
						{
							traceString += " o |";
						}
						else
						{
							traceString += " y |";
						}
					}
					else if (!(getRendererAt(traceIndex) as SlotBase).isEmpty())
					{
						traceString += " x |";
					}
					else
					{
						traceString += " o |";
					}
				}
				trace(traceString);
			}
			
			for (var i:int = 0; i < _renderersCount; ++i)
			{
				if (_renderers[i] is IInventorySlot && (_renderers[i] as IInventorySlot).uplink != null)
				{
					trace("GFX - found uplink on object: ", _renderers[i], ", pointing to: ", (_renderers[i] as IInventorySlot).uplink);
				}
			}
		}

		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_UP);

			//trace("GFX [SlotsListBase] handleInput ", event.handled, keyPress, "; details.value ", details.value, ";_selectedIndex ", _selectedIndex);
			// TODO: Use context manager for this!
			
			if (keyPress && !event.handled)
			{
				if (_selectedIndex > -1 && _renderers.length && _selectedIndex < _renderers.length)
				{
					var curRenderer:SlotBase = _renderers[_selectedIndex] as SlotBase;
					if (curRenderer)
					{
						curRenderer.executeAction(details.code, event);
					}
				}
			}
		}
		
		protected function navigateTo(sourceRenderer:IBaseSlot, angle:Number):IBaseSlot
		{
			var sourceX:Number = sourceRenderer.x + sourceRenderer.width / 2;
			var sourceGridSize:Number = sourceRenderer.data ? sourceRenderer.data.gridSize : 2;
			var sourceY:Number = sourceRenderer.y + sourceRenderer.height * sourceGridSize / 2;
			var sourceLoc:Point = new Point(sourceX, sourceY);
			var distances:Dictionary = new Dictionary(true);
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++)
			{
				var curRenderer:IBaseSlot = _renderers[i] as IBaseSlot;
				if (curRenderer && curRenderer != sourceRenderer && (curRenderer.selectable || ignoreSelectable))
				{
					var curGridSize:Number = curRenderer.data ? curRenderer.data.gridSize : 2;
					var curPosX:Number = curRenderer.x + curRenderer.width / 2;
					var curPosY:Number = curRenderer.y + curRenderer.height * curGridSize / 2;
					var dx:Number = sourceX - curPosX;
					var dy:Number = sourceY - curPosY;
					var curAngle:Number = Math.atan2(dy, dx);

					// Handle zero angle point and rotate coordinates system
					if (curAngle > -Math.PI / 2 && curAngle <= Math.PI) curAngle -= Math.PI / 2;
					else if (curAngle >= -Math.PI && curAngle <= -Math.PI / 2) curAngle += Math.PI * 3 / 2;

					// If item is in sector Math.PI/4 it is on our way :)
					var trAngle:Number = getSector(angle, curAngle);
					if (trAngle <= Math.PI / 4)
					{
						var lineDistance:Number = Math2.getSegmentLength(sourceLoc, new Point(curPosX, curPosY));
						var normalDistance:Number = Math.sin(trAngle) * lineDistance;
						var distanceFactor:Number = (lineDistance + normalDistance) / 2;
						distances[curRenderer] = distanceFactor;
					}
				}
			}
			var minDist:Number = -1;
			var nearItem:IBaseSlot;
			for (var keyValue in distances)
			{
				if ((minDist > distances[keyValue]) || (minDist == -1))
				{
					minDist = distances[keyValue];
					nearItem = keyValue as IBaseSlot;
				}
			}
			
			return nearItem;
		}

		protected function getSector(checkAngle:Number, targetAngel:Number):Number
		{
			var normCheck:Number = checkAngle >= 0  ? checkAngle : checkAngle + Math.PI * 2;
			var normTarget:Number = targetAngel >= 0  ? targetAngel : targetAngel + Math.PI * 2;
			var result:Number = Math.abs(normTarget - normCheck);
			if (result > Math.PI)
			{
				result = Math.abs(result - Math.PI / 2);
			}
			return result;
		}

		protected function handleRightJoystick(yValue:Number) {}

		public function tryExecuteAction(event:InputEvent):void
		{
			
			if (filterKeyCodeFunction != null && filterNavCodeFunction != null)
			{
				if ( !filterKeyCodeFunction(event.details.code) || !filterNavCodeFunction(event.details.navEquivalent) )
				{
					return;
				}
			}
			
			if (event.details.code == KeyCode.PAD_A_CROSS || event.details.code == KeyCode.PAD_X_SQUARE) // TODO: Pass all inputs
			{
				if (_selectedIndex >= 0 && _selectedIndex < _renderers.length)
				{
					var currentRdr:SlotBase = _renderers[_selectedIndex] as SlotBase;
					if (currentRdr && !currentRdr.isEmpty())
					{
						currentRdr.executeAction(event.details.code, event);
						return;
					}
				}
			}
			event.handled = false;
		}

		protected function isNavigationKeyCode(keyCode:uint):Boolean
		{
			switch (keyCode)
			{
				case KeyCode.UP:
				case KeyCode.DOWN:
				case KeyCode.RIGHT:
				case KeyCode.LEFT:
				case KeyCode.PAD_DIGIT_UP:
				case KeyCode.PAD_DIGIT_DOWN:
				case KeyCode.PAD_DIGIT_RIGHT:
				case KeyCode.PAD_DIGIT_LEFT:
					return true;
			}
			return false;
		}

		/*
		 * 							- UNDERHOOD -
		 */

		// TODO: Use context manager for this!
		public function applySelectionContext():void
		{
			var dragManager:SlotsTransferManager = SlotsTransferManager.getInstance();
			
			if (!InputManager.getInstance().isGamepad())
			{
				return;
			}
			
			if (_selectedIndex <= -1 || (focused < 1 && _focusable) || !enabled)
			{
				dragManager.hideDropTargets();
				return;
			}
			else
			{
				if (_selectedIndex > -1 && _selectedIndex < _renderers.length)
				{
					var targetSelection:IBaseSlot = _renderers[_selectedIndex];
					var isSelectable:Boolean = targetSelection.selectable || ignoreSelectable;

					if (!isSelectable || !targetSelection.activeSelectionEnabled)
					{
						dragManager.hideDropTargets();
						return;
					}
					else
					{
						dragManager.showDropTargets(targetSelection as IDragTarget);
						return;
					}
				}
			}
		}
		
		protected function setupRenderer( renderer:IBaseSlot ):void
		{
			renderer.owner = this;
			renderer.enabled = enabled;
			renderer.addEventListener( MouseEvent.MOUSE_DOWN, handleItemClick, false, 0, true );
			renderer.addEventListener( MouseEvent.MOUSE_UP, handleItemMouseUp, false, 0, true );
			renderer.addEventListener( MouseEvent.MOUSE_OVER, handleItemMouseOver, false, 0, true );
			renderer.addEventListener( MouseEvent.MOUSE_OUT, handleItemMouseOut, false, 0, true );
        }
		
        protected function cleanUpRenderer( renderer : IBaseSlot ) : void
		{
			renderer.owner = null;
			renderer.removeEventListener( MouseEvent.MOUSE_DOWN, handleItemClick );
			renderer.removeEventListener( MouseEvent.MOUSE_UP, handleItemMouseUp );
			renderer.removeEventListener( MouseEvent.MOUSE_OVER, handleItemMouseOver );
			renderer.removeEventListener( MouseEvent.MOUSE_OUT, handleItemMouseOut );
        }
		
		public function clearRenderers() : void
		{
			var i:int;
			for (i = 0; i < _renderers.length; ++i)
			{
				cleanUpRenderer(_renderers[i]);
				(_renderers[i] as UIComponent).parent.removeChild(_renderers[i] as UIComponent);
			}
			
			_renderers.length = 0;
			_renderersCount = 0;
		}
		
		public function get itemClickEnabled():Boolean
		{
			return true;
		}
		
		protected function handleItemClick(event:MouseEvent) : void
		{
			if (!itemClickEnabled)
			{
				return;
			}
			
			var targetRenderer:IBaseSlot = event.currentTarget as IBaseSlot;
			
			if (!targetRenderer && event.currentTarget && event.currentTarget.parent)
			{
				// event from a child
				targetRenderer = event.currentTarget.parent as IBaseSlot;
			}
			
			if (targetRenderer)
			{
				dispatchItemClickEvent(targetRenderer);
			}
		}
		
		protected function handleItemMouseOver(event:MouseEvent):void
		{
			if (enabled)
			{
				var targetRendere:IListItemRenderer =  event.currentTarget as IListItemRenderer;
				
				if (targetRendere)
				{
					dispatchEvent( new ListEvent( ListEvent.ITEM_ROLL_OVER, true, false,  targetRendere.index, -1, -1, targetRendere, this.data ) );
				}
			}
		}
		
		protected function handleItemMouseOut(event:MouseEvent):void
		{
			if (enabled)
			{
				var targetRendere:IListItemRenderer =  event.currentTarget as IListItemRenderer;
				
				if (targetRendere)
				{
					dispatchEvent( new ListEvent( ListEvent.ITEM_ROLL_OUT, true, false,  targetRendere.index, -1, -1, targetRendere, this.data ) );
				}
			}
		}
		
		protected function handleItemMouseUp(event:MouseEvent):void
		{
			if (!itemClickEnabled)
			{
				return;
			}
			
			var targetRenderer:IBaseSlot = event.currentTarget as IBaseSlot;
			
			if (!targetRenderer && event.currentTarget && event.currentTarget.parent)
			{
				// event from a child
				targetRenderer = event.currentTarget.parent as IBaseSlot;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			var inventorySlot:SlotInventoryGrid = targetRenderer as SlotInventoryGrid;
			
			if (inventorySlot && eventEx && eventEx.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				inventorySlot.tryExecuteAssignedAction();
			}
		}
		
		public function dispatchItemClickEvent(targetRenderer:IBaseSlot):void
		{
			selectedIndex = targetRenderer.index;
			
			if (focused < 1) focused = 1;
			
			var clickEvent:ListEvent = new ListEvent(ListEvent.ITEM_CLICK, true);
			clickEvent.itemData = targetRenderer.data as Object;
			clickEvent.index = targetRenderer.index;
			clickEvent.itemRenderer = targetRenderer;
			
			dispatchEvent(clickEvent);
		}
		
		override public function set enabled(value:Boolean):void
		{
			// disable renderers and hide tooltips first
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++ )
			{
				_renderers[i].enabled = value;
			}
			
			super.enabled = value;
			applySelectionContext();
		}

		override public function set focused(value:Number):void
		{
			//trace("GFX [SlotListBase] focused = ", value, "; ", _focused, _focusable);
			
			if (value == _focused || !_focusable) { return; }
            _focused = value;

			if (Extensions.isScaleform)
			{
				if (_focused > 0)
				{
					FocusManager.setFocus(this, 0);
					FocusHandler.getInstance().setFocus( this );
					if (selectedIndex > -1 && enabled)
					{
						// TODO: Use context manager for this
						(_renderers[selectedIndex] as SlotBase).showTooltip();
					}
				}
			}
			else
			{
				if (stage != null && _focused > 0)
				{
                    stage.focus = this;
                }
			}
		}
		
		public function trySelectClosestItem(anchorPoint:Point):Boolean
		{
			return trySelectClosestItemFromList(anchorPoint, _renderers);
		}
		
		protected function trySelectClosestItemFromList(anchorPoint:Point, list:Vector.<IBaseSlot>):Boolean
		{
			var closestRenderer:IBaseSlot = CommonUtils.getClosestSlot(anchorPoint, list);
			
			if (closestRenderer)
			{
				selectedIndex = closestRenderer.index;
				return true;
			}
			
			return false;
		}
		
		public function NumNonEmptyRenderers():int
		{
			var i:int;
			var count:int = 0;
			
			for (i = 0; i < _renderers.length; ++i)
			{
				if (!_renderers[i].isEmpty())
				{
					++count;
				}
			}
			
			return count;
		}
		
		public function ReselectIndexIfInvalid(targetIndex:int = -1):void
		{
			var i:int;
			var curRenderer:SlotBase;
			var searchStartIndex:int;
			var selectedRenderer:SlotBase;
			
			if (targetIndex >= 0 && targetIndex < _renderers.length)
			{
				selectedRenderer = _renderers[targetIndex] as SlotBase;
				searchStartIndex = targetIndex;
			}
			else
			{
				selectedRenderer = getSelectedRenderer() as SlotBase;
				targetIndex = selectedIndex;
				searchStartIndex = selectedIndex;
			}
			
			if (selectedRenderer)
			{
				if (!selectedRenderer.selectable)
				{
					// Search the grid for the closest one
					var closestRendererIndex:int = -1;
					var curDistance:Number = Number.MAX_VALUE;
					var closestDistance:Number = Number.MAX_VALUE;
					
					if (searchStartIndex > 0)
					{
						curRenderer = _renderers[searchStartIndex - 1] as SlotBase;
						
						if (curRenderer && curRenderer.selectable)
						{
							curDistance = Math.sqrt(Math.pow(curRenderer.x - selectedRenderer.x, 2) + Math.pow(curRenderer.y - selectedRenderer.y, 2));
							
							if (closestDistance > curDistance ||
								(curDistance == closestDistance && curRenderer.y == selectedRenderer.y && curRenderer.x > selectedRenderer.x))
							{
								closestDistance = curDistance;
								closestRendererIndex = searchStartIndex - 1;
							}
						}
					}
					
					if (searchStartIndex < (_renderers.length - 1))
					{
						curRenderer = _renderers[searchStartIndex + 1] as SlotBase;
						
						if (curRenderer && curRenderer.selectable)
						{
							curDistance = Math.sqrt(Math.pow(curRenderer.x - selectedRenderer.x, 2) + Math.pow(curRenderer.y - selectedRenderer.y, 2));
							
							if (closestDistance > curDistance ||
								(curDistance == closestDistance && curRenderer.y == selectedRenderer.y && curRenderer.x > selectedRenderer.x))
							{
								closestDistance = curDistance;
								closestRendererIndex = searchStartIndex + 1;
							}
						}
					}
					
					for (i = 0; i < _renderers.length; ++i)
					{
						curRenderer = _renderers[i] as SlotBase;
						
						if (curRenderer && curRenderer.selectable)
						{
							curDistance = Math.sqrt(Math.pow(curRenderer.x - selectedRenderer.x, 2) + Math.pow(curRenderer.y - selectedRenderer.y, 2));
							
							if (closestDistance > curDistance ||
								(curDistance == closestDistance && curRenderer.y == selectedRenderer.y && curRenderer.x > selectedRenderer.x))
							{
								closestDistance = curDistance;
								closestRendererIndex = i;
							}
						}
					}
					
					if (closestRendererIndex != -1)
					{
						selectedIndex = closestRendererIndex;
						return;
					}
				}
				else if (targetIndex != -1)
				{
					selectedRenderer = _renderers[targetIndex] as SlotBase;
					if (selectedRenderer && selectedRenderer.selectable)
					{
						selectedIndex = targetIndex;
						return;
					}
				}
			}
			findSelection();
		}

		public function get selectedIndex():int { return _selectedIndex }
		public function set selectedIndex(value:int):void
		{
			//trace("GFX [****", this , "***] selectedIndex ", value, "; ", _renderers.length, _data.length, "; cur ", _selectedIndex);
			
			if (_renderers.length <= 0/* || _renderersCount <= 0*/) //#J _renderersCount is stupid variable I hope it dies painfully
			{
				if (_selectedIndex != -1)
				{
					value = -1;
				}
				else
				{
					applySelectionContext();
					return;
				}
			}
			
			if (_selectedIndex > -1 && _selectedIndex < _renderers.length)
			{
				//trace("GFX selectable? ", _renderers[_selectedIndex].selectable);
			}
			
			if (_selectedIndex != value)
			{
				_cachedSelection = value;
				if (value > -1 && value < _renderers.length && !_renderers[value].selectable && !ignoreSelectable)
				{
					applySelectionContext();
					return;
				}
				if (_selectedIndex > -1 && _selectedIndex < _renderers.length)
				{
					_renderers[_selectedIndex].selected = false;
				}
				_selectedIndex = value;
				if (_selectedIndex > -1 && _selectedIndex < _renderers.length)
				{
					var targetRenderer:IBaseSlot = _renderers[_selectedIndex];
					targetRenderer.selected = true;
					fireListEvent(_renderers[_selectedIndex]);
				}
				else
				{
					fireListEvent(null);
				}
			}
			else if (_selectedIndex > -1 && _selectedIndex < _renderers.length && !_renderers[_selectedIndex].selectable && !ignoreSelectable)
			{
				var selectedRenderer:SlotBase = _renderers[_selectedIndex] as SlotBase;
				if (selectedRenderer)
				{
					selectedRenderer.showTooltip();
				}
			}
			applySelectionContext();
		}

		protected function fireListEvent(targetRenderer:IBaseSlot):void
		{
			var indexChangeEvent:ListEvent = new ListEvent(ListEvent.INDEX_CHANGE);
			if (targetRenderer)
			{
				indexChangeEvent.itemRenderer = targetRenderer;
				indexChangeEvent.itemData = targetRenderer.data as Object;
				indexChangeEvent.index = targetRenderer.index;
			}
			else
			{
				indexChangeEvent.index = -1;
			}
			dispatchEvent(indexChangeEvent);
		}

		protected function getDataIndex(targetData:ItemDataStub):int
		{
			if (targetData)
			{
				return getIdIndex( targetData.id );
			}
			
			return -1;
		}

		protected function getIdIndex(targetId:uint, groupId:int = -1):int
		{
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++)
			{
				if (_renderers[i].data is ItemDataStub)
				{
					var curDataStub:ItemDataStub = _renderers[i].data as ItemDataStub;
					if (curDataStub && (curDataStub.id == targetId && (groupId < 0 || curDataStub.groupId == groupId) ))
					{
						return i;
					}
				}
			}
			return -1;
		}

		public function getRow(index:int):int
		{
			return -1;
		}

		public function getColumn(index:int):int
		{
			return -1;
		}
		
		override public function get scaleX():Number
		{
			return super.actualScaleX;
		}
		
		override public function get scaleY():Number
		{
			return super.actualScaleY;
		}
		
		override public function toString() : String
		{
			return "[SlotListBase " + name + "]";
		}
	}

}
