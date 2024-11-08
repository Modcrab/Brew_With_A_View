/***********************************************************************
/** Scrolling list item that extends drop down functionality
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.CategoryChangeEvent;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.controls.DropdownMenu;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.ComponentEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	import red.core.CoreComponent;

	public class W3DropdownMenuListItem extends DropdownMenu implements IListItemRenderer
	{
		public static var staticSortedFunction : Function;
		
		// Protected Properties:
        protected var _index:uint = 0; // Index of the ListItemRenderer
        protected var _selectable:Boolean = true;
		protected var _handleKeyUpInput:Boolean;
        protected var dropDownData : Array;
		public var isColapsable : Boolean = true;
		public var mcOpenedState : MovieClip;
		private var categoryTag : uint;
		private var bOpenedByDefault : Boolean = false;
		private var categoryPostfix : String = "";
		protected var bLabelSortingEnabled : Boolean = true;
				
		public var selectionEventName : String = "OnEntrySelected";

		public var lastSelectedColumn:int = 0;

		public function W3DropdownMenuListItem()
		{
			super();
			menuRowsFixed = false;
			preventAutosizing = true;
			constraintsDisabled = true;
			CategoryTag = 0;
		}

		override protected function configUI():void
		{
			super.configUI();
			addEventListener(ButtonEvent.CLICK, handleItemPress, false, 0, true);
		}

		override public function toString():String
		{
			return "[W3 W3DropdownMenuListItem: ]";
		}

        override public function get focusable() : Boolean
		{
			return _focusable;
		}

        override public function set focusable( value : Boolean ) : void { }

		[Inspectable(defaultValue = "false")]
		public function get handleKeyUpInput():Boolean { return _handleKeyUpInput }
		public function set handleKeyUpInput(value:Boolean):void
		{
			_handleKeyUpInput = value;
		}

        public function get index() : uint
		{
			return _index;
		}

        public function set index( value : uint ) : void
		{
			_index = value;
		}

        public function get selectable() : Boolean
		{
			return _selectable;
		}

        public function set selectable( value : Boolean ) : void
		{
			_selectable = value;
		}

        public function get CategoryTag() : uint
		{
			return categoryTag;
		}

        public function set CategoryTag( value : uint ) : void
		{
			categoryTag = value;
		}

        public function setListData(listData:ListData):void
		{
            index = listData.index;
            selected = listData.selected;
        }

		private var _activeSelectionEnabled:Boolean = true;
		public function set activeSelectionEnabled(value:Boolean):void
		{
			_activeSelectionEnabled = value;

			if (_dropdownRef && _dropdownRef is W3ScrollingList)
			{
				var list:W3ScrollingList = _dropdownRef as W3ScrollingList;
				var currentItem:IconItemRenderer;
				var i:int;

				for (i = 0; i < list.numRenderers; ++i)
				{
					currentItem = list.getRendererAt(i) as IconItemRenderer;

					if (currentItem)
					{
						currentItem.activeSelectionEnabled = value;
					}
				}
			}
		}
		
		protected var _my_data:Object;
		override public function get data():Object { return _my_data; }
		override public function set data(val:Object):void { _my_data = val; }
		
        public function setData( data : Object ) : void
		{
			if ( data )
			{
				this.data = data;
				
				var dataArray : Array = data as Array;
				
				if ( dataArray )
				{
					if ( dataArray[0].dropDownTag != null )
					{
						CategoryTag = dataArray[0].dropDownTag;
					}
					if ( dataArray[0].dropDownOpened != null )
					{
						bOpenedByDefault = dataArray[0].dropDownOpened;
					}
					
					trace("GFX ------------ <",dataArray[0].label,"> ", dataArray[0].dropDownLabel, dataArray[0].categoryPostfix);
					
					if ( dataArray[0].categoryPostfix  )
					{
						categoryPostfix = dataArray[0].categoryPostfix;
					}
					else
					{
						categoryPostfix = "";
					}
					
				}
			}
        }

		public function clearRenderers() : void
		{
			if (isOpen())
			{
				close();
			}

			validateNow();
		}

		override public function set label( value : String ) : void
		{
			_label = CommonUtils.toUpperCaseSafe(value);
			updateText();
		}

		override public function get label():String { return _label; }

		override protected function updateText():void
		{
            if ( _label != null && textField != null )
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					textField.htmlText = "<p align=\"right\">" + _label + categoryPostfix + "</p>";
				}
				else
				{
                	textField.htmlText = _label + categoryPostfix;
				}
            }
        }

		public function updateDropdownData(value:Array):void
		{
			dropDownData = value;
			if (_dropdownRef as CoreList)
			{
				(_dropdownRef as CoreList).dataProvider = new DataProvider(value);
			}
			else
			if (_dropdownRef as SlotsListBase)
			{
				(_dropdownRef as SlotsListBase).data = value;
			}
		}

        public function setDropdownData( dropdownDataIn : Object ) : void
		{
            this.dropDownData = dropdownDataIn as Array;
        }
		
		public function updateDropdownDataSurgically( dropdownDataIn : Array ) : void
		{
			// #J Only needed this for scrolling list so far and due to lack of time, only made it work there.
			var scrollingList:W3ScrollingList = _dropdownRef as W3ScrollingList;
			var curRenderer:W3DropDownItemRenderer;
			if (scrollingList)
			{
				for (var data_it:int = 0; data_it < dropdownDataIn.length; ++data_it)
				{
					for (var prev_data_it:int = 0; prev_data_it < dropDownData.length; ++prev_data_it)
					{
						if (isOpen())
						{
							curRenderer = scrollingList.getRendererAt(prev_data_it) as W3DropDownItemRenderer;
							if (curRenderer.data.tag == dropdownDataIn[data_it].tag)
							{
								curRenderer.setData(dropdownDataIn[data_it]);
								curRenderer.validateNow();
								scrollingList.dataProvider[prev_data_it] = dropdownDataIn[data_it];
								dropDownData[prev_data_it] = dropdownDataIn[data_it];
								break;
							}
						}
						else if (dropDownData[prev_data_it].tag == dropdownDataIn[data_it].tag)
						{
							dropDownData[prev_data_it] = dropdownDataIn[data_it];
						}
					}
				}
			}
		}

		public function getDropDownData():Array
		{
			return dropDownData;
		}

		public function HasInitialSelection() : Boolean
		{
			for ( var i : int; i < dropDownData.length; i++ )
			{
				if( dropDownData[i].selected )
				{
					selectedIndex = i;
					dropDownData[i].isNew = false;
					return true;
				}
			}
			return false;
        }

		public function IsOpenedByDefault() : Boolean
		{
			if ( bOpenedByDefault )
			{
				return true;
			}
			return false;
        }

		public function GetDropdownListRef() : ScrollingList // #Y Add typecast for SlotsGrid
		{
			return _dropdownRef as ScrollingList;
		}

		public function GetDropdownGridRef() : UIComponent // #Y merge with previous
		{
			return _dropdownRef as UIComponent;
		}

		public function IsSubListItemSelected() : Boolean
		{
			if ( _dropdownRef )
			{
				return (_dropdownRef.selectedIndex > -1);
			}
			else
			{
				return false;
			}
		}

		public function GetSubSelectedRenderer( ignoreSelectedIndex:Boolean = false ) : UIComponent
		{
			if (_dropdownRef && (selectedIndex != -1 || ignoreSelectedIndex))
			{
				if (_dropdownRef is SlotsListBase)
				{
					return (_dropdownRef as SlotsListBase).getSelectedRenderer() as UIComponent;
				}
				else if (_dropdownRef is ScrollingList)
				{
					return (_dropdownRef as ScrollingList).getSelectedRenderer() as UIComponent;
				}
			}

			return null;
		}

		public function SelectLastSubListItem() : void
		{
			var slotsList:SlotsListBase = _dropdownRef as SlotsListBase;
			if (slotsList)
			{
				var lastIndex:int = (slotsList.getRenderersCount() - 1);
				if (slotsList.numColumns <= 0 || lastIndex < 0) // #J OLD logic, kept for SlotsList system that have not impl numColumns properly
				{
					_dropdownRef.selectedIndex =  lastIndex - slotsList.getColumn(lastIndex);
				}
				else
				{
					var columnOfLastRenderer:uint = lastIndex % slotsList.numColumns;
					if (lastSelectedColumn >= columnOfLastRenderer)
					{
						_dropdownRef.selectedIndex = lastIndex;
					}
					else
					{
						_dropdownRef.selectedIndex = lastIndex + lastSelectedColumn - columnOfLastRenderer
					}
				}
			}
			else
			{
				_dropdownRef.selectedIndex = _dropdownRef.dataProvider.length - 1;
			}

			if (_dropdownRef is W3ScrollingList)
			{
				var renderer:ListItemRenderer = _dropdownRef.getRendererAt(_dropdownRef.selectedIndex) as ListItemRenderer;

				dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, _dropdownRef.selectedIndex, -1, -1, renderer, renderer ? renderer.data : null ) );
			}
			else if (slotsList)
			{
				selectedIndex = slotsList.selectedIndex;
				var eventRenderer:IListItemRenderer = slotsList.getRendererAt(slotsList.selectedIndex);
				dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, slotsList.selectedIndex, -1, -1, eventRenderer, slotsList));
			}
		}

		public function SelectSubListItem( idx : int ) : void
		{
			changeFocus();

			trace("GFX - @@@@@@@@@@@@ SelectSubListItem "+this+" idx "+idx);
			_dropdownRef.selectedIndex = idx;
			selectedIndex = idx;
		}

		public function GetDropdownListHeight() : Number
		{
			var tempHeight : Number = 0;
			var tempItemRenderer : BaseListItem;

			if ( _dropdownRef as W3ScrollingList )
			{
				var tempList : W3ScrollingList = _dropdownRef as W3ScrollingList;
				tempHeight = tempList.GetDropdownListHeight();
			}
			else if  ( _dropdownRef as SlotsListBase )
			{
				var tempGrid : SlotsListBase = _dropdownRef as SlotsListBase;
				tempHeight = tempGrid.GetDropdownListHeight();
			}
			return tempHeight;
		}

		public function SetDropdownListVerticalPosition( value : Number ) : void
		{
			_dropdownRef.y = value;
		}

        override protected function updateLabel(item:Object):void {
            _label = data[0].label as String;
        }

        override protected function populateText(item:Object):void {
            updateLabel(item);
            //dispatchEvent(new Event(Event.CHANGE));
        }

		override protected function updateAfterStateChange():void {
/*            if (!initialized) { return; }
            if (constraints != null && !constraintsDisabled && textField != null) {
                constraints.updateElement("textField", textField); // Update references in Constraints
            }*/
        }

		override protected function draw():void {
            // State is invalid, and has been set (is not the default)
            if (isInvalid(InvalidationType.STATE)) {

				/*if (_newFrame == "selected_up" && _dropdownRef && _dropdownRef.selectedIndex == -1)
				{
					_newFrame = "selected_over";
				}*/
                if (_newFrame) {
                    gotoAndPlay(_newFrame);
                    _newFrame = null;
                }

                if (_newFocusIndicatorFrame) {
                    focusIndicator.gotoAndPlay(_newFocusIndicatorFrame);
                    _newFocusIndicatorFrame = null;
                }

                updateAfterStateChange();
                dispatchEvent(new ComponentEvent(ComponentEvent.STATE_CHANGE));
                // NFM: Should size be invalidated here by default? It can cause problems with timeline animations,
                //      especially tend beyond the size of the original MovieClip. Instead,
                //      perhaps let subclasses call invalidate(InvalidationType.SIZE) as necessary instead.
                invalidate(InvalidationType.DATA, InvalidationType.SIZE);
            }

			/*if (this.selected && _dropdownRef)
			{
				trace("GFX - selection override incoming!");
				if (_dropdownRef._dropdownRef.selectedIndex == -1)
				{
					gotoAndPlay("selected_over");
				}
				else
				{
					gotoAndPlay("selected_up");
				}
			}*/

            // Data is invalid when label or autoSize changes.
            if (isInvalid(InvalidationType.DATA)) {
                updateText();
                if (autoSize != TextFieldAutoSize.NONE) {
                    invalidateSize();
                }
            }

            // Resize and update constraints
            /*if (isInvalid(InvalidationType.SIZE) ) {
                if (!preventAutosizing) {
                    alignForAutoSize();
                    setActualSize(_width, _height);
                }
                if (!constraintsDisabled) {
                    constraints.update(_width, _height);
                }
            }*/
        }

        override protected function showDropdown():void
		{
            if (dropdown == null || _dropdownRef != null) { return; }

            var dd:MovieClip;
            if (dropdown is String && dropdown != "")
			{
                var classRef:Class = getDefinitionByName(dropdown.toString()) as Class;
                if ( classRef != null )
				{
					dd = new classRef();
					if ( dd as CoreList )
					{
						CreateSubList(dd);
					}
					else if( dd as SlotsListBase )
					{
						CreateSubGrid(dd);
					}
				}
            }
        }

		private function CreateSubList( list : MovieClip) : void
		{
			if (itemRenderer is String && itemRenderer != "")
			{
				list.itemRenderer = getDefinitionByName(itemRenderer.toString()) as Class;
			}
			else if (itemRenderer is Class)
			{
				list.itemRenderer = itemRenderer as Class;
			}

			if (scrollBar is String && scrollBar != "")
			{
				list.scrollBar = getDefinitionByName(scrollBar.toString()) as Class;
			}
			else if (scrollBar is Class)
			{
				list.scrollBar = scrollBar as Class;
			}

			list.selectedIndex = _selectedIndex;
			list.width = (menuWidth == -1) ? (width + menuOffset.left + menuOffset.right) : menuWidth;
			list.ignoreHeightForRendererCreation = true;
			
			var curDataProvider:DataProvider = new DataProvider(dropDownData);
			
			if( staticSortedFunction != null )
			{
				staticSortedFunction( curDataProvider );
			}
			else
			if (bLabelSortingEnabled)
			{
				curDataProvider.sortOn("label", Array.CASEINSENSITIVE);
			}
			
			list.dataProvider = curDataProvider;
			
			menuRowCount = dropDownData.length;

			list.padding = menuPadding;
			list.x += 12; // #Y TODO: Remove magic numbers
			list.wrapping = menuWrapping;
			list.margin = menuMargin;
			list.thumbOffset = { top:thumbOffsetTop, bottom:thumbOffsetBottom };
			list.focusTarget = this;
			list.rowCount = menuRowCount;
			list.labelField = _labelField;
			list.labelFunction = _labelFunction;
			list.addEventListener(ListEvent.ITEM_CLICK, handleMenuItemClick, false, 0, true);
			list.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 10, true);
			list.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleMenuItemDoubleClick, false, 0, true);
			list.addEventListener(ListEvent.ITEM_PRESS, handleMenuItemPress, false, 0, true);
			list.focusable = false;
			_dropdownRef = list;

			parent.addChildAt(list, 0);

			if (list && list is W3ScrollingList)
			{
				var convertedList:W3ScrollingList = list as W3ScrollingList;
				convertedList.validateNow();

				var currentItem:IconItemRenderer;
				var i:int;

				for (i = 0; i < convertedList.numRenderers; ++i)
				{
					currentItem = convertedList.getRendererAt(i) as IconItemRenderer;

					if (currentItem)
					{
						currentItem.activeSelectionEnabled = _activeSelectionEnabled;
					}
				}
			}

			/* //#B changed to have mask functionality
			PopUpManager.show(list, x + menuOffset.left,
			(menuDirection == "down") ? y + height + menuOffset.top : y - _dropdownRef.height + menuOffset.bottom,parent);*/
		}

		private function CreateSubGrid( grid : MovieClip ) : void
		{
			if (itemRenderer is String && itemRenderer != "")
			{
				grid.slotRendererName = itemRenderer.toString();
			}
			else if (itemRenderer is Class)
			{
				grid.slotRenderer = itemRenderer as Class;
			}

			if (scrollBar is String && scrollBar != "")
			{
				grid.scrollBar = getDefinitionByName(scrollBar.toString()) as Class;
			}
			else if (scrollBar is Class)
			{
				grid.scrollBar = scrollBar as Class;
			}

			var castedGrid:SlotsListBase = grid as SlotsListBase;

			// #Y find way for grid initialization
			var slotsGrid:SlotsListGrid = castedGrid as SlotsListGrid;
			if (slotsGrid)
			{
				slotsGrid.gridSquareSize = 64;
				slotsGrid.elementGridSquareOffset = 0;
				slotsGrid.ignoreGridPosition = true;
				slotsGrid.initFindSelection = false;
				slotsGrid.calculateColumnsAndRows(dropDownData.length);
			}

			_dropdownRef = castedGrid;

			parent.addChild(castedGrid);
			castedGrid.visible = true;
			castedGrid.validateNow();
			castedGrid.data = dropDownData;
			castedGrid.focusable = false;

			castedGrid.selectedIndex = _selectedIndex;
			castedGrid.addEventListener(ListEvent.ITEM_CLICK, handleMenuItemClick, false, 0, true);
			castedGrid.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 10, true);

			/* //#B changed to have mask functionality
			PopUpManager.show(list, x + menuOffset.left,
			(menuDirection == "down") ? y + height + menuOffset.top : y - _dropdownRef.height + menuOffset.bottom,parent);*/
			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
		}

		protected function handleSelectChange( event : ListEvent ) // #B plug function
		{
			dispatchEvent(event);
		}

		protected function handleItemPress( e : ButtonEvent )  // #B haxed :/ - fix it later
		{
			W3DropDownList(parent).previousSelectedIndex = -3;
			W3DropDownList(parent).ResetPreviousDropdownSelection( W3DropDownList(parent).selectedIndex );
			W3DropDownList(parent).selectedIndex = this.index;

			!isOpen() ? open() : close();
		}

		override protected function handleClick(controllerIndex:uint = 0):void
		{

        }

		private function StoreData()
		{
			if (_dropdownRef as SlotsListBase )
			{

			}
			else
			{
				var i : int;
				var renderer : W3DropdownMenuListItem;
				for ( i = 0; i < dataProvider.length; i++ )
				{
					renderer = _dropdownRef.getRendererAt(i) as W3DropdownMenuListItem;
					dropDownData[i] = renderer.getDropDownData();
				}
			}
		}

		override public function open(allowSound : Boolean = true):void
		{
			/// W3DropDownList(parent).closeAll();
			
            showDropdown();
			
			if (allowSound)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_dropdown_open"]));
			}
			
			if(isColapsable)
			{
				mcOpenedState.gotoAndStop("opened");
			}
			else
			{
				mcOpenedState.gotoAndStop("always_opened");
			}

			var listRef:CoreList = _dropdownRef as CoreList;
			if (listRef)
			{
				listRef.validateNow();
				listRef.selectedIndex = -1;
				listRef.validateNow();
			}
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnCategoryOpened", [CategoryTag,true]));
        }

		override public function close():void
		{
			if( isColapsable )
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnCategoryOpened", [CategoryTag,false]));
				StoreData();
				hideDropdown();
				selectedIndex = -1;
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_dropdown_close"]));
				mcOpenedState.gotoAndStop("closed");
				if (stage) // #Y Sometimes component is not on stage in this moment; TODO: avoid broadcasting events through stage
				{
					stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
				}
			}
        }

		override protected function handleStageClick(event:MouseEvent):void
		{
        }

		override protected function handleMenuItemClick(e:ListEvent):void
		{
			var dropdownList:W3DropDownList = parent as W3DropDownList;
			
			if (dropdownList)
			{
				dropdownList.previousSelectedIndex = -3;
				if (dropdownList.selectedIndex != dropdownList.getRenderers().indexOf(this))
				{
					dropdownList.ResetPreviousDropdownSelection( dropdownList.selectedIndex );
				}
				dropdownList.selectedIndex = this.index;
			}
			
			if ( _dropdownRef as SlotsListBase )
			{
				_dropdownRef.selectedIndex = e.index;
			}
			else
			{
				selectedIndex = e.index;
			}
        }

		protected function handleMenuItemDoubleClick(e:ListEvent):void
		{
        }

		protected function handleMenuItemPress(e:ListEvent):void
		{
        }

		override protected function changeFocus():void //#B overrided as super.super.changeFocus, because we don't want to changeFocus affect if dropDown is opened
		{
            if (!enabled) { return; }
            if (_focusIndicator == null) {
				if ((_focused || _displayFocus))
				{
					if (_dropdownRef && _dropdownRef.selectedIndex != -1)
					{
						setState("up")
					}
					else
					{
						setState("over");
					}
				}
				else
				{
					setState("out");
				}

                if (_pressedByKeyboard && !_focused) {
                    _pressedByKeyboard = false;
                }
            } else {
                if (_focusIndicator.totalframes == 1) {
                    _focusIndicator.visible = _focused > 0;  // Do a simple show/hide on single-frame focus indicators.
                } else {
                    // Check if the focus state exists first, and use it. Otherwise use default behaviour.
                    var focusFrame:String = "state" + _focused;
                    if (_focusIndicatorLabelHash[focusFrame]) {
                        _newFocusIndicatorFrame = "state" + _focused;
                    } else {
                        _newFocusIndicatorFrame = (_focused || _displayFocus) ? "show" : "hide";
                    }
                    invalidateState();
                }
                // If focus is moved on keyboard press, the button needs to reset since it will not recieve a key up event.
                if (_pressedByKeyboard && !_focused) {
                    setState("kb_release");
                    _pressedByKeyboard = false;
                }
            }
        }

		override public function set selected(value:Boolean):void
		{
			if (value != _selected)
			{
				var catChangeEvent:CategoryChangeEvent = new CategoryChangeEvent(CategoryChangeEvent.CATEGORY_CHANGED, true);
				catChangeEvent.categoryIdx = this.index;
				catChangeEvent.categoryItemRenderer = this;
				dispatchEvent(catChangeEvent);
			}
			super.selected = value;
		}

        override public function handleInput(event:InputEvent):void
		{
            if ( event.handled || !_selected || !enabled ) { return; }
			var details:InputDetails = event.details;

			var keyFilter:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD;

			var extendedNavCode:String = details.navEquivalent;

			// #J Did this to match behavior in W3ScrollingList which works off of keycodes instead of nav codes and uses w/s
			switch (details.code)
			{
				case KeyCode.W:
					extendedNavCode = NavigationCode.UP;
					break;
				case KeyCode.S:
					extendedNavCode = NavigationCode.DOWN;
					break;
				case KeyCode.E:
					extendedNavCode = NavigationCode.GAMEPAD_A;
					break;
			}

			var slotsbase:SlotsListBase = _dropdownRef as SlotsListBase;
			var listBase:CoreList = _dropdownRef as CoreList;

			if (listBase && isOpen())
			{
				selectedIndex = listBase.selectedIndex;
				validateNow();
			}

			switch (extendedNavCode)
			{
				case NavigationCode.GAMEPAD_Y:
					
					if (selected && details.value == InputValue.KEY_DOWN)
					{
						if ( isOpen() )
						{
							close();
							
							var mcSelection:MovieClip = getChildByName("mcSelectionHighlight") as MovieClip; // sorry
							if ( mcSelection ) mcSelection.visible = true;
						}
					}
					
					//W3DropDownList(parent).forceUpdateSelection(this.index);
					//W3DropDownList(parent).selectedIndex = this.index;
					event.handled = true;
					
					break;
				case NavigationCode.GAMEPAD_A:
					if (selected && selectedIndex == -1 && details.value == InputValue.KEY_DOWN)
					{
						if ( isOpen() )
						{
							if (_dropdownRef as SlotsListBase )
							{
								_dropdownRef.tryExecuteAction(event);
							}
							else
							{
								_dropdownRef.handleInput(event);
							}
							if (event.handled ) { return; }
							close();
						}
						else
						{
							open();
						}

						event.handled = true;
					}
					break;
				case NavigationCode.UP:
					if (keyFilter)
					{
						if ( isOpen() && selected )
						{
							if (slotsbase)
							{
								if ( slotsbase.selectedIndex <= -1  )
								{
									event.handled = false;
									return;
								}
								else if (slotsbase.selectedIndex < slotsbase.numColumns)
								{
									slotsbase.selectedIndex = -1;
									selectedIndex = -1;
									event.handled = true;
									dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, slotsbase.selectedIndex, -1, -1, null, slotsbase ) );
									return;
								}

							}
							else if (listBase)
							{
								if ( GetDropdownListRef().selectedIndex == 0 )
								{
									GetDropdownListRef().selectedIndex = -1;
									GetDropdownListRef().validateNow();
									selectedIndex = -1;
									event.handled = true;
									dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, selectedIndex, -1, -1, this, this.data ) );
									return;
								}
								else if ( GetDropdownListRef().selectedIndex == -1 )
								{
									event.handled = false;
									//SelectLastSubListItem();
									return;
								}
							}
						}
					}
					break;
				case NavigationCode.DOWN:
					if (keyFilter)
					{
						if (isOpen() && selected)
						{
							if (slotsbase && slotsbase.selectedIndex < 0)
							{
								if (slotsbase.getRenderersCount() > lastSelectedColumn)
								{
									slotsbase.selectedIndex = lastSelectedColumn;
								}
								else
								{
									slotsbase.selectedIndex = slotsbase.getRenderersCount() > 0 ? slotsbase.getRenderersCount() - 1 : 0;
								}

								var eventRenderer:IListItemRenderer = slotsbase.getRendererAt(slotsbase.selectedIndex);
								dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, slotsbase.selectedIndex, -1, -1, eventRenderer, slotsbase ) );
								event.handled = true;
								return;
							}
						}
					}
					break;

				default:
					if ( isOpen() )
					{
						if (_dropdownRef as SlotsListBase )
						{
							_dropdownRef.tryExecuteAction(event);
						}
					}
					break;
			}

			if ( isOpen() )
			{
				if (_dropdownRef is SlotsListBase )
				{
					_dropdownRef.handleInputNavSimple(event);
					selectedIndex = (_dropdownRef as SlotsListBase).selectedIndex;
				}
				else if (keyFilter)
				{
					_dropdownRef.handleInput(event);
				}
			}
        }
	}
}
