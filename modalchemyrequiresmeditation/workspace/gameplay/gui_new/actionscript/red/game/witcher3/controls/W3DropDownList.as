package red.game.witcher3.controls
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.ScrollIndicator;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	
	public class W3DropDownList extends W3ScrollingList
	{
		public var smoothScrolling      : Boolean = false;
		public var itemRendererClass	: String = "";
		protected var _inputHandlers 	: Vector.<UIComponent>;
		public var previousSelectedIndex : int = -1;
		private var _dropdownMenuScrollingList 	: String;
		private	var _dropdownMenuItemRenderer 	: String;
		public var	_scrollSpeed				: Number = 40;
		public var _listWidth					: Number = 1200;
		public var _listHeight 					: Number = 810;

		protected var _handleKeyUpInput			: Boolean;
		protected var m_currentListHeight		: Number = 0;
		protected var m_defaultPosition			: Number;
		protected var m_lastScrollPosition		: uint		=	 	0;
		public var mcMask						: MovieClip;
		public var mcEmptyListFeedback			: MovieClip;
		private var lastSelectedColumn			: uint = 0;
		public var menuName 					: String = "";
		public var restoreSelectionByTag		: Boolean = false;
		public var updateSurgicallyOnDataSet	: Boolean = false;
		protected var dataSetOnce				: Boolean = false;

		public function W3DropDownList()
		{
			super();
			_inputHandlers =  new Vector.<UIComponent>();
		}

		override protected function configUI():void
		{
			super.configUI();
			//mouseEnabled = false;
			mouseChildren = true;
			stage.addEventListener(W3ScrollingList.REPOSITION, updatePosition, false, 0, true);
			CreateMask();
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll, false, 0, true);
			m_defaultPosition = y;

			addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 0 , true );
		}
		
		public function setMask( value : MovieClip ):void
		{
			mcMask = value;
		}

		override public function UpdateEmptyStateFeedback( value : Boolean )
		{
			if (textField)
			{
				textField.visible = value;
				if (value)
				{
					textField.htmlText = GetPanelEmptyStateFeedbackDescription();
					textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
				}
			}

			if (mcEmptyListFeedback)
			{
				mcEmptyListFeedback.visible = value;
				if ( value && mcEmptyListFeedback.mcIcon && menuName)
				{
					mcEmptyListFeedback.mcIcon.gotoAndStop(menuName);
				}
			}
		}

		protected function GetPanelEmptyStateFeedbackDescription() : String
		{
			trace("menuName " + menuName );
			return "[[panel_menu_empty_list_" + (menuName ? menuName.toLowerCase() : "") + "]]";
		}

		override public function toString():String
		{
			return "[W3 W3DropDownList "+ this.name+" ]";
		}

		[Inspectable(type = "String", defaultValue = "W3ScrollingListNoBG")]
		public function get dropdownMenuScrollingList( ) : String
		{
			return _dropdownMenuScrollingList;
		}
		public function set dropdownMenuScrollingList( value : String ) : void
		{
			_dropdownMenuScrollingList = value;
		}

		[Inspectable(type = "String", defaultValue = "W3BaseListItem")]
		public function get dropdownMenuItemRenderer( ) : String
		{
			return _dropdownMenuItemRenderer;
		}
		public function set dropdownMenuItemRenderer( value : String ) : void
		{
			_dropdownMenuItemRenderer = value;
		}

		[Inspectable(defaultValue = 40)]
		public function get scrollSpeed( ) : Number
		{
			return _scrollSpeed;
		}
		public function set scrollSpeed( value : Number ) : void
		{
			_scrollSpeed = value;
		}

		[Inspectable(defaultValue = 200)]
		public function get listWidth( ) : Number
		{
			return _listWidth;
		}
		public function set listWidth( value : Number ) : void
		{
			_listWidth = value;
		}

		[Inspectable(defaultValue = 843)]
		public function get listHeight( ) : Number
		{
			return _listHeight;
		}
		public function set listHeight( value : Number ) : void
		{
			_listHeight = value;
		}

		[Inspectable(defaultValue = "false")]
		public function get handleKeyUpInput():Boolean { return _handleKeyUpInput }
		public function set handleKeyUpInput(value:Boolean):void
		{
			_handleKeyUpInput = value;
		}

		private var _activeSelectionEnabled:Boolean = true;
		public function set activeSelectionEnabled(value:Boolean):void
		{
			_activeSelectionEnabled = value;
			updateActiveSelectionEnabled();
		}

		protected function updateActiveSelectionEnabled():void
		{
			var i:int;
			var currentItem:W3DropdownMenuListItem;

			for (i = 0; i < numRenderers; ++i)
			{
				currentItem = getRendererAt(i) as W3DropdownMenuListItem;

				if (currentItem)
				{
					currentItem.activeSelectionEnabled = _activeSelectionEnabled;
				}
			}
		}

		// Update data without renderers recreation
		// May be used for per-item update if the number of renderers doesn't change
		public function stableUpdateData(data:Array):void
		{
			var renderersCount:int = _renderers.length;
			for (var i:int = 0; i < renderersCount; i++)
			{
				var curRenderer:W3DropdownMenuListItem = _renderers[i] as W3DropdownMenuListItem;
				if (curRenderer)
				{
					var dropdownViewer:UIComponent = curRenderer.GetDropdownGridRef();
					var dataSet:Array = selectCategoryData(data, curRenderer.label);
					if (dataSet.length > 0)
					{
						if (!dropdownViewer)
						{
							curRenderer.setData(dataSet);
							curRenderer.updateDropdownData(dataSet);
						}
						else
						{
							// Save position or per-item update
							//curRenderer.setData(dataSet);
							curRenderer.updateDropdownData(dataSet);
						}
					}
				}
			}
		}

		/*
		 * Save/restore state of dropdowns
		 */

		protected var _openRenderersList:Dictionary;
		protected var _bufScrollPos:Number;
		protected var _selectionIdx:int;
		protected var _subSelectionIdx:int;
		protected var _subSelectionTag:uint;
		protected var _bufSmoothScrolling:Boolean;
		protected var _selectTargetDownView:UIComponent;

		public function saveSelectionState():void
		{
			var len:int = _renderers.length;
			var renderersCount:int = _renderers.length;

			_openRenderersList = new Dictionary(true);
			_bufScrollPos = _scrollBar.position;
			_bufSmoothScrolling = smoothScrolling;
			smoothScrolling = false;

			for (var i:int = 0; i < len; i++)
			{
				var curRenderer:W3DropdownMenuListItem = _renderers[i] as W3DropdownMenuListItem;
				if (curRenderer)
				{
					var dropDownView:UIComponent =  curRenderer.GetDropdownGridRef();
					var isOpen:Boolean = dropDownView != null;
					if (curRenderer.label)
					{
						_openRenderersList[CommonUtils.toUpperCaseSafe(curRenderer.label)] = isOpen;
					}
					if (isOpen && curRenderer.selected)
					{
						_selectionIdx = i;
						if (dropDownView is CoreList)
						{
							_subSelectionTag = 0;
							var scrollingList:W3ScrollingList = dropDownView as W3ScrollingList;
							if (scrollingList && scrollingList.selectedIndex != -1)
							{
								_subSelectionTag = (scrollingList.getSelectedRenderer() as ListItemRenderer).data.tag;
							}
							_subSelectionIdx = (dropDownView as CoreList).selectedIndex;
						}
						else if (dropDownView is  SlotsListBase)
						{
							_subSelectionIdx = (dropDownView as SlotsListBase).selectedIndex;
						}
					}
				}
			}

			trace("GFX - Done saving selectionState, selectionIdx:", _selectionIdx, ", and subSelectionIdx:", _subSelectionIdx);
		}

		public function restoreSelectionState():void
		{
			if (_openRenderersList)
			{
				trace("GFX - restoring selection state, selectionIdx:", _selectionIdx, ", and subSelectionIdx:", _subSelectionIdx);
				var renderersCount:int = _renderers.length;
				for (var i:int = 0; i <  _renderers.length; i++)
				{
					var curRenderer:W3DropdownMenuListItem = _renderers[i] as W3DropdownMenuListItem;
					if (curRenderer && _openRenderersList[CommonUtils.toUpperCaseSafe(curRenderer.label)])
					{
						curRenderer.open(false);
						curRenderer.GetDropdownGridRef().validateNow();
						if (_selectionIdx == i)
						{
							_selectTargetDownView = curRenderer.GetDropdownGridRef();
							if (_selectTargetDownView)
							{
								_selectTargetDownView.validateNow();
							}
							
							if (restoreSelectionByTag)
							{
								var numSubRenderers:int = 0;
								
								var slotsListBaseRef:SlotsListBase = curRenderer.GetDropdownGridRef() as SlotsListBase;
								var scrollingListRef:W3ScrollingList = curRenderer.GetDropdownGridRef() as W3ScrollingList;
								
								if (slotsListBaseRef)
								{
									numSubRenderers = slotsListBaseRef.getRenderersLength();
								}
								else if (scrollingListRef)
								{
									numSubRenderers = scrollingListRef.getRenderers().length;
								}
								
								for (var x:int = 0; x < numSubRenderers; ++x)
								{
									if (slotsListBaseRef)
									{
										if ((slotsListBaseRef.getRendererAt(x) as SlotBase).data.tag == _subSelectionTag)
										{
											_subSelectionIdx = x;
											break;
										}
									}
									else if (scrollingListRef)
									{
										if ((scrollingListRef.getRendererAt(x) as ListItemRenderer).data.tag == _subSelectionTag)
										{
											_subSelectionIdx = x;
											break;
										}
									}
								}
							}
						}
					}
					else
					{
						curRenderer.close();
					}

					if (i == _selectionIdx)
					{
						curRenderer.selectedIndex = _subSelectionIdx;
						curRenderer.validateNow();
					}
				}
			}

			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
			updateSelectedIndex();
			_scrollBar.position = _bufScrollPos;
			selectedIndex = _selectionIdx;
			addEventListener(Event.ENTER_FRAME, handleListValidated, false, 0, true); // #Y: Wait for size validation
			hackCounter = 0;
		}

		var hackCounter:int = 0; // #Y: Yep, we really need to wait TODO: do something with it
		protected function handleListValidated(event:Event):void
		{
			if (hackCounter < 1)
			{
				hackCounter++;
				return;
			}
			removeEventListener(Event.ENTER_FRAME, handleListValidated);

			if (_selectTargetDownView as CoreList)
			{
				(_selectTargetDownView as CoreList).selectedIndex = _subSelectionIdx;
			}
			else if (_selectTargetDownView as  SlotsListBase)
			{
				(_selectTargetDownView as SlotsListBase).validateNow();
				(_selectTargetDownView as SlotsListBase).selectedIndex = _subSelectionIdx;
			}

			_openRenderersList = null;
			_selectionIdx = -1;
			_subSelectionIdx = -1;
			smoothScrolling = _bufSmoothScrolling;
		}

		protected function selectCategoryData(dataSet:Array, categoryId:String):Array
		{
			var resultArray:Array = [];
			var len:int = dataSet.length;

			for (var j:int = 0; j < len; j++)
			{
				var curKey:String = dataSet[j].dropDownLabel;
				if (CommonUtils.toUpperCaseSafe(curKey) == CommonUtils.toUpperCaseSafe(categoryId))
				{
					resultArray.push(dataSet[j]);
				}
			}
			return resultArray;
		}
		
		public function clearDataProvider():void
		{
			resetRenderers();
			dataProvider = new DataProvider();
			//ShowRenderers(false);
			validateNow();
			UpdateEmptyStateFeedback(true);
		}

		override public function updateData(data:Array):void
		{
			var saveSelection:Boolean;
			
			if ( !data )
			{
				return;
			}
			
			var currentCategory : String;
			var Categories  : Array = new Array();
			var dropdownData : Array = new Array();
			var categoryIndex:int;
			var dataIt : int;
			var catIt : int;

			// #J refactored to be simply better by assuming less about data order
			//{
				for( dataIt = 0; dataIt < data.length; dataIt++ )
				{
					currentCategory = data[dataIt].dropDownLabel as String;

					categoryIndex = -1;
					for (catIt = 0; catIt < Categories.length; ++catIt) // See if we've encountered this category before
					{
						if (Categories[catIt] == currentCategory)
						{
							categoryIndex = catIt;
							break;
						}
					}

					if (categoryIndex == -1)
					{
						categoryIndex = Categories.length;

						Categories.push(currentCategory);
						dropdownData.push(new Array());
					}

					dropdownData[categoryIndex].push(data[dataIt]);
				}
			//}
			
			if (updateSurgicallyOnDataSet && dataSetOnce)
			{
				updateDataSurgically(Categories, dropdownData);
				return;
			}
			
			// #J slightly hacky if due to the fact of this gettings called twice (before the renderers have even had a chance to be properly setup
			saveSelection = _renderers && _renderers.length > 0 && (_renderers[0] is W3DropdownMenuListItem) && (_renderers[0] as W3DropdownMenuListItem).label;
			
			if (saveSelection)
			{
				saveSelectionState();
			}
			
			clearRenderers();
			_inputHandlers.length = 0;
			
			if(itemRendererClass)
			{
				itemRendererName = itemRendererClass;
			}
			
			var renderers : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
			var tempRenderer : W3DropdownMenuListItem;
			var i : int;

			_usingExternalRenderers = true;
			dataProvider = new DataProvider(Categories);
			renderers = new Vector.<IListItemRenderer>();
			//trace("!!!!!!!!!! DROPDOWN updateData" + dropdownData.length);

			if (dropdownData.length != Categories.length) // #J made the hack below a little safer while analyzing code
			{
				trace("GFX - ERROR: Unable to properly fill list data since category list size does not match the number of matching data");
			}
			else
			{
				for ( i = 0; i < dropdownData.length; i++ ) // #B a little bit haxy but it works ok, improvements need a lot of investigation @FIXME BIDON
				{
					tempRenderer = createRenderer( i ) as W3DropdownMenuListItem;

					trace("GFX - Created Temp renderer:", tempRenderer);

					addChild(tempRenderer);
					setupRenderer(tempRenderer);
					tempRenderer.y = tempRenderer.height * i;
					tempRenderer.enabled = true;
					tempRenderer.label = Categories[i];
					tempRenderer.setData(dropdownData[i]);
					tempRenderer.setDropdownData(dropdownData[i]);
					tempRenderer.handleKeyUpInput = _handleKeyUpInput;
					tempRenderer.validateNow();
					//tempRenderer.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChangeInternal, false, 0 , true );
					renderers.push(tempRenderer);
				}
			}
			itemRendererList = renderers;

			//validateNow();

			//updateActiveSelectionEnabled();

			if (saveSelection)
			{
				restoreSelectionState();
			}
			else
			{
				SetInitialSelection();
			}
			
			validateNow();
			
			dataSetOnce = true;
		}
		
		// Warning, this function does not work for remove/add categories, it can only update existing ones
		public function updateDataSurgically(categories:Array, dropdownData:Array):void
		{
			var cat_it:int;
			var renderer_it:int;
			var curRenderer:W3DropdownMenuListItem
			var foundRenderer:Boolean = false;
			
			for (cat_it = 0; cat_it < categories.length; ++cat_it)
			{
				foundRenderer = false;
				for (renderer_it = 0; renderer_it < _renderers.length; ++renderer_it)
				{
					curRenderer = _renderers[renderer_it] as W3DropdownMenuListItem;
					trace("GFX --- Checking renderer data: " + curRenderer.data + ", against dropdown tag: " + dropdownData[cat_it][0].dropDownLabel);
					if (curRenderer.data == dropdownData[cat_it][0].dropDownLabel)
					{
						foundRenderer = true;
						break;
					}
				}
				
				trace("GFX ----------------------- Found Renderer: " + foundRenderer);
				if (foundRenderer)
				{
					curRenderer.setData(dropdownData[cat_it].dropDownLabel);
					curRenderer.updateDropdownDataSurgically(dropdownData[cat_it]);
				}
			}
		}

		public function updateCategoryData( data : Object ) : void // #Y : @TODO - check & fix
		{
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++ )
			{
				var curRenderer:W3DropdownMenuListItem = _renderers[i] as W3DropdownMenuListItem;
				var curData:Array = curRenderer.getDropDownData();
				if (curData[0].dropDownLabel == data[0].dropDownLabel) // #Y Same shit
				{
					curRenderer.setDropdownData(data);
					var targetScroll:SlotsListGrid =  curRenderer.GetDropdownGridRef() as SlotsListGrid;
					if (targetScroll)
					{
						targetScroll.data = data as Array;
					}
				}
			}
		}

		public function updateItemData( data : Object ) : void // @TODO - check & fix
		{
			if ( data )
			{
				var i : int;
				var j : int;
				var tempRenderer : W3DropdownMenuListItem;
				var tempBaseRenderer : BaseListItem;
				for ( i = 0; i < dataProvider.length; i++ ) // #B a little bit haxy but it works ok, improvments need a lot of investigation @FIXME BIDON
				{
					tempRenderer = getRendererAt(i) as W3DropdownMenuListItem;
					if ( tempRenderer.label == data.dropDownLabel ) // @FIXME BIDON - it could be done better
					{
						for ( j = 0; j < tempRenderer.dataProvider.length; j++ )
						{
							tempBaseRenderer = tempRenderer.GetDropdownListRef().getRendererAt(j) as BaseListItem;
							if ( tempBaseRenderer.label == data.label )
							{
								tempBaseRenderer.setData(data);
								return;
							}
						}
					}
				}
			}
		}

		public function resetRenderers():void
		{
			if (_renderers)
			{
				var len:int = _renderers.length;
				while (_renderers.length)
				{
					var curRenderer:W3DropdownMenuListItem = _renderers.pop() as W3DropdownMenuListItem;
					if (curRenderer)
					{
						curRenderer.parent.removeChild(curRenderer);
						cleanUpRenderer(curRenderer);
						curRenderer.close();
					}
				}
				itemRendererList = _renderers;
				_inputHandlers.length = 0;
			}
		}

		public function SetInitialSelection()
		{
			var i : int;
			var j : int;
			var foundInitialSelection : Boolean;
			var tempRenderer : W3DropdownMenuListItem;
			var tempBaseRenderer : BaseListItem;
			
			foundInitialSelection = false;
			for ( i = 0; i < dataProvider.length; i++ )
			{
				tempRenderer = getRendererAt(i) as W3DropdownMenuListItem;
				if ( tempRenderer )
				{
					if( tempRenderer.HasInitialSelection() && !foundInitialSelection )
					{
						tempRenderer.open(false);
						selectedIndex = i;
						foundInitialSelection = true;
					}
					else if( tempRenderer.IsOpenedByDefault() )
					{
						tempRenderer.open(false);
					}
				}
			}

			if ( foundInitialSelection )
			{
				return;
			}
			
			// #Y hack to avoid sending event during tick
			removeEventListener(Event.ENTER_FRAME, pendedInitSelection, false);
			addEventListener(Event.ENTER_FRAME, pendedInitSelection, false, 0, true);
		}
		
		protected function pendedInitSelection(event:Event):void
		{
			var tempRenderer : W3DropdownMenuListItem;
			removeEventListener(Event.ENTER_FRAME, pendedInitSelection, false);
			tempRenderer = getRendererAt(0) as W3DropdownMenuListItem;
			if (tempRenderer)
			{
				selectedIndex = 0;
				tempRenderer.open(false);
				tempRenderer.SelectSubListItem(0);
				var dataArray : Array = tempRenderer.getDropDownData();
				if ( dataArray.length > 0 )
				{
					if(dataArray[0].id)
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, tempRenderer.selectionEventName, [dataArray[0].id]));
					}
					else if(dataArray[0].tag)
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, tempRenderer.selectionEventName, [dataArray[0].tag]));
					}
				}
				else
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, tempRenderer.selectionEventName, [0]));
				}
			}
		}
		

		override protected function setupRenderer( renderer : IListItemRenderer ) : void
		{
			//trace("DROPDOWN "+this+" setupRenderer "+renderer);
			//trace("DROPDOWN "+this+" setupRenderer dropdownMenuScrollingList "+dropdownMenuScrollingList);
			//trace("DROPDOWN "+this+" setupRenderer dropdownMenuItemRenderer "+dropdownMenuItemRenderer);
			var tempRend : W3DropdownMenuListItem;
			tempRend = renderer as W3DropdownMenuListItem;
			tempRend.dropdown = dropdownMenuScrollingList;
			tempRend.itemRenderer = dropdownMenuItemRenderer;

			_inputHandlers.push( renderer );
			super.setupRenderer( renderer );

			//trace("DROPDOWN "+this+" setupRenderer END");
        }

		override protected function cleanUpRenderer(renderer:IListItemRenderer):void
		{
			if (_inputHandlers.indexOf(renderer) != -1)
			{
				_inputHandlers.splice(_inputHandlers.indexOf(renderer), 1);
			}

			super.cleanUpRenderer(renderer);
		}

		// #J removed this since it was clashing with the other, smarter handleSelectChange
		// If you need this, call it in the other one when the class type isn't recognized
		/*protected function handleSelectChangeInternal(event:ListEvent):void
		{
			var targetRenderer:IListItemRenderer = event.itemRenderer;

			//trace("GFX handleSelectChangeInternal ", targetRenderer, _scrollBar);
			if (!targetRenderer || !_scrollBar)
			{
				return;
			}

			var parentList:DisplayObject = (targetRenderer as DisplayObject).parent;
			var rndLocalPoint:Point = new Point(targetRenderer.x, targetRenderer.y);
			var globalPoint:Point = parentList.localToGlobal(rndLocalPoint);
			var localPoint:Point = this.globalToLocal(globalPoint);
			var curScrollValue:Number = m_defaultPosition - y;

			if (((localPoint.y + targetRenderer.height) > _listHeight + curScrollValue))
			{
				// to bottom edge
				_scrollBar.position = localPoint.y + targetRenderer.height - _listHeight;
			}
			else
			if (localPoint.y < curScrollValue)
			{
				// to top edge
				_scrollBar.position = localPoint.y;
			}
		}*/

		public function handleSelectChange( e : ListEvent )
		{
			var allowScrollUpdate:Boolean = true;
			updateSelectedIndex();

			var selectedRenderer:UIComponent = e.itemRenderer as UIComponent;
			var slotsList:SlotsListBase = e.itemData as SlotsListBase;

			if (slotsList)
			{
				// #J if -1 then the subrenderer just selected the parent
				if (e.index == -1)
				{
					selectedRenderer = _renderers[selectedIndex] as UIComponent;
				}
				else
				{
					UpdateLastSelectedColumn(slotsList);
				}
			}

			// #J called on selected category every time any selection change occurs to make sure its state is properly updated.
			var currentRenderer = _renderers[selectedIndex] as W3DropdownMenuListItem;

			if (currentRenderer)
			{
				currentRenderer.changeFocus();
			}

			if (!selectedRenderer)
			{
				return;
			}

			trace("GFX - Updating selection to: ", e.index, " for: ", selectedRenderer, "Selected index on record: ", selectedIndex);

			if ( e.itemRenderer is W3DropdownMenuListItem )
			{
				var nextRenderer:W3DropdownMenuListItem = _renderers[selectedIndex] as W3DropdownMenuListItem;

				if ( previousSelectedIndex > -1 && previousSelectedIndex != selectedIndex)
				{
					ResetPreviousDropdownSelection(previousSelectedIndex);

					// #J Hack that makes two item lists not work well with wrap. Could cause problems if theres only two collapse buttons but open they take more than screen
					if (selectedIndex < previousSelectedIndex && Math.abs(previousSelectedIndex - selectedIndex) < 2 && nextRenderer && nextRenderer.isOpen())
					{
						//trace("GFX - Disabling scroll update since W3DropdownMenuListItem when upward and is open");
						allowScrollUpdate = false;
					}
				}

				previousSelectedIndex  = selectedIndex;

				if (nextRenderer.GetDropdownListRef() != null)
				{
					nextRenderer.selectedIndex = nextRenderer.GetDropdownListRef().selectedIndex;
					nextRenderer.validateNow();
				}

				if (nextRenderer.selectedIndex != -1)
				{
					//trace("GFX - Disabling scroll update since W3DropdownMenuListItem had child selected");
					allowScrollUpdate = false;
				}
				else if (selectedIndex != e.index && e.index != -1)
				{
					//trace("GFX - disabling scroll update since W3DropdownMenuListItem is not the currently selected one");
					allowScrollUpdate = false;
				}
			}

			if (selectedRenderer && allowScrollUpdate)
			{
				var itemY:int = 0;
				var height:int = 0;

				itemY = selectedRenderer.y;
				if (!(selectedRenderer is W3DropdownMenuListItem) && selectedIndex < _renderers.length && selectedIndex > -1) // #J Shitty hack but works for now
				{
					itemY += _renderers[selectedIndex].y + _renderers[selectedIndex].height;
				}

				if (selectedRenderer is IBaseSlot)
				{
					height = (selectedRenderer as IBaseSlot).getSlotRect().height;
				}
				else
				{
					height = selectedRenderer.height;
				}

				var curScrollValue:Number = m_defaultPosition - y;

				trace("GFX - Setting scrollbar with itemY: ", itemY, " height: ", height);

				if (((itemY + height) > _listHeight + curScrollValue))
				{
					// to bottom edge
					_scrollBar.position = itemY + height - _listHeight;
				}
				else if (itemY < curScrollValue)
				{
					// to top edge
					_scrollBar.position = itemY;
				}
			}
		}

		public function UpdateLastSelectedColumn(slotsList:SlotsListBase)
		{
			if (slotsList && slotsList.selectedColumn != -1)
			{
				var selectedColumn:int = slotsList.selectedColumn; // #J optimization since selectedColumn COULD be an expensive calculation
				var currentRender:W3DropdownMenuListItem = null;
				var renderersCount:int = _renderers.length;

				for (var i:int = 0; i < renderersCount; i++)
				{
					currentRender = _renderers[i] as W3DropdownMenuListItem;

					if (currentRender)
					{
						currentRender.lastSelectedColumn = selectedColumn;
					}
				}

			}
		}

		public function ResetPreviousDropdownSelection( idx : int ) : void
		{
			var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = getRendererAt( idx ) as W3DropdownMenuListItem;

			if ( tempRenderer )
			{
				trace("GFX - ******************* ResetPreviousDropdownSelection tempRenderer "+tempRenderer+" idx "+idx);
				if ( tempRenderer.isOpen() ) // @FIXME BIDON - grid isn't working with that
				{
					tempRenderer.SelectSubListItem( -1);
				}
			}
		}
		
		public function closeAll( changeSelection:Boolean = false )
		{
			var tempRenderer : W3DropdownMenuListItem = null;
			var newIdx:int = -1;
			
			for ( var i : int = 0; i < dataProvider.length; i++ )
			{
				tempRenderer = getRendererAt(i) as W3DropdownMenuListItem; // Could be even ListItemRenderer
				if (tempRenderer && tempRenderer.isOpen())
				{
					newIdx = tempRenderer.index;
					tempRenderer.close();
				}
			}
			
			if (changeSelection)
			{
				selectedIndex = newIdx;
				validateNow();
			}
		}
		
		public function forceUpdateSelection( newIdx : int )
		{
			selectedIndex = newIdx;
			validateNow();
		}
	
		public function updatePosition( event : Event )
		{
			var tempRenderer : W3DropdownMenuListItem = null; // Could be even ListItemRenderer
			var tempY : Number = 0;

			for ( var i : int = 0; i < dataProvider.length; i++ )
			{
				if ( tempRenderer )
				{
					tempY += tempRenderer.height;
					if ( tempRenderer.isOpen() )
					{
						tempRenderer.SetDropdownListVerticalPosition(tempY);
						tempY += tempRenderer.GetDropdownListHeight();
					}
				}
				tempRenderer = getRendererAt(i) as W3DropdownMenuListItem; // Could be even ListItemRenderer
				if (tempRenderer)
					tempRenderer.y = tempY;
			}

			if ( tempRenderer )
			{
				tempY += tempRenderer.height;
				if ( tempRenderer.isOpen() )
				{
					if ( tempRenderer.isOpen() )
					{
						tempRenderer.SetDropdownListVerticalPosition(tempY);
						tempY += tempRenderer.GetDropdownListHeight();
					}
				}
			}
			m_currentListHeight = tempY;
			updateScrollBar();
		}

		protected function CreateMask()
		{
			if ( mcMask )
			{
				mcMask.width = listWidth;
				mcMask.height = listHeight;
			}
		}

		public function ScrollToSelected( selectedRenderer : IListItemRenderer, additionalOffset : Number = 0 )
		{
			if ( scrollBar == null ) return;

			if ( selectedRenderer == null ) return;

			scrollBar.position = selectedRenderer.y + additionalOffset;
			m_lastScrollPosition = scrollBar.position;
		}

		protected function onScroll( event : MouseEvent ) : void
		{
			//if (!mcMask || mcMask.hitTestPoint(event.stageX, event.stageY))
			if (hitTestPoint(event.stageX, event.stageY, false))
			{
				if ( m_currentListHeight > listHeight )
				{
					if ( event.delta > 0 )
					{
						_scrollBar.position -= scrollSpeed;
					}
					else
					{
						_scrollBar.position += scrollSpeed;
					}
				}
			}
			//trace("onScroll _scrollBar.position " + _scrollBar.position);
		}

		protected var scrollTweener:GTween;
		override protected function handleScroll( event:Event ):void
		{
			var l_delta : int = _scrollBar.position - m_lastScrollPosition;
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
				scrollTweener = GTweener.to(this, .3, { y: targetY }, {onComplete:handleTweenComplete} );
			}
			else
			{
				this.y -= l_delta;
			}

			m_lastScrollPosition = _scrollBar.position;
		}

		protected function handleTweenComplete(curTween:GTween):void
		{
			scrollTweener = null;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || (!_focused && focusable) || !visible || (mcEmptyListFeedback && mcEmptyListFeedback.visible))
			{
				return;
			}

			var details:InputDetails = event.details;
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if (handler)
				{
					handler.handleInput( event );

					if ( event.handled )
					{
						event.stopImmediatePropagation();
						return;
					}
				}
			}
			/*
			if( details.code == KeyCode.PAD_RIGHT_STICK_AXIS && m_currentListHeight > listHeight) // #B scrolling with right stick
			{
				var axisData:InputAxisData;
				var yvalue:Number;
				axisData = InputAxisData(details.value);
				yvalue = axisData.yvalue;
				_scrollBar.position -= scrollSpeed * yvalue;
			}
			*/
			super.handleInput(event); // #B keep scrolling list functionality for now
		}

		override protected function updateScrollBar():void
		{
            if (_scrollBar == null) { return; }

			var l_pixelAboveMask : Number = m_currentListHeight - listHeight;

			/*trace("");
			trace("");

			trace("JOURNAL l_pixelAboveMask " + l_pixelAboveMask);
			trace("JOURNAL m_currentListHeight " + m_currentListHeight);
			trace("JOURNAL listHeight " + listHeight);
			trace("JOURNAL _scrollBar " + _scrollBar);
			trace("JOURNAL mcMask " + mcMask);
			trace("");
			trace("");
			*/

			if ( l_pixelAboveMask <= 0 )
			{
				_scrollBar.position = 0;
				scrollBar.visible = false;
				return;
			}
			else
			{
				scrollBar.visible = true;
			}

			if (_scrollBar is ScrollIndicator) {
				// #J Todo: the scrollbar likely changes height improperly through this codepath. Investigate
                var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
                scrollIndicator.setScrollProperties( listHeight, 0, l_pixelAboveMask , scrollSpeed);
            } else {
                // Min/max
            }

            _scrollBar.validateNow();
		}

		override public function CheckSubListSelection() : void
		{
			var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = getRendererAt( _newSelectedIndex ) as W3DropdownMenuListItem;

			//trace("GFX CheckSubListSelection", tempRenderer.GetDropdownGridRef(), tempRenderer.IsSubListItemSelected());
			if ( tempRenderer && tempRenderer.GetDropdownGridRef() && !tempRenderer.IsSubListItemSelected() )
			{
				tempRenderer.SelectLastSubListItem();
			}
		}
	}
}
