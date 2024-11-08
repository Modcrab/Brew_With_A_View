/***********************************************************************
/** Base scrolling list
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.game.witcher3.interfaces.IScrollingList;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.controls.DropdownMenu;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	import scaleform.clik.constants.WrappingMode;
    import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.controls.ScrollIndicator;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	
	import red.game.witcher3.menus.mainmenu.IngameMenu;

	//DEBUG
	import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.interfaces.IListItemRenderer;
	import flash.display.DisplayObject;
	import scaleform.clik.data.ListData;

    [Event(name="change", type="flash.events.Event")]
    [Event(name="itemClick", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemPress", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemRollOver", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemRollOut", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemDoubleClick", type="scaleform.clik.events.ListEvent")]

	public class W3ScrollingList extends ScrollingList implements IScrollingList
	{
		private var _UpAction : int				=	38;
		private var _DownAction : int			=	40;
		private var _PCUpAction : int			=   87;
		private var _PCDownAction : int			=   83;

		public var textField : TextField;
		public static var REPOSITION		: String =	"Recalculate position of list items";

		public var bAlwaysHandleDirectionActions : Boolean = false;
		public var bSkipFocusCheck : Boolean = false;
		public var bIsOptionList : Boolean = false; // For edge cases with disabled option components. I want to avoid breaking existing code in other places.

		private var _lastDir : int = 0;

		public function W3ScrollingList()
		{
			super();
		}

		// Protected Methods:
        override protected function configUI():void
		{
            super.configUI();
			addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
        }

		[Inspectable(defaultValue = 38)]
        public function get UpAction():int { return _UpAction; }
        public function set UpAction(value:int):void
		{
            _UpAction = value;
        }

		[Inspectable(defaultValue = 40)]
        public function get DownAction():int { return _DownAction; }
        public function set DownAction(value:int):void
		{
            _DownAction = value;
        }

		[Inspectable(defaultValue = 87)]
        public function get PCUpAction():int { return _PCUpAction; }
        public function set PCUpAction(value:int):void
		{
            _PCUpAction = value;
        }

		[Inspectable(defaultValue = 83)]
        public function get PCDownAction():int { return _PCDownAction; }
        public function set PCDownAction(value:int):void
		{
            _PCDownAction = value;
        }
		
		private var _selectOnOver:Boolean = false;
		[Inspectable(defaultValue = false)]
		public function get selectOnOver():Boolean { return _selectOnOver }
		public function set selectOnOver(value:Boolean):void
		{
			_selectOnOver = value;
		}

		private var _reverseMouseWheel:Boolean = false;
		[Inspectable(defaultValue = false)]
		public function get reverseMouseWheel():Boolean { return _reverseMouseWheel }
		public function set reverseMouseWheel(value:Boolean):void
		{
			_reverseMouseWheel = value;
		}

		public function clearLastDir()
		{
			_lastDir = 0;
		}

		public function getLastDir() : int
		{
			return _lastDir;
		}
		
		public function get TotalRenderers() : int
		{
			return _totalRenderers;
		}

		public function get numRenderers() : int
		{
			if (_renderers)
			{
				return _renderers.length;
			}

			return 0;
		}

		public function clearRenderers() : void
		{
			var i:int;
			for (i = 0; i < _renderers.length; ++i)
			{
				cleanUpRenderer(_renderers[i]);
				if (_renderers[i] is W3DropdownMenuListItem)
				{
					(_renderers[i] as W3DropdownMenuListItem).clearRenderers();
				}
				(_renderers[i] as UIComponent).parent.removeChild(_renderers[i] as UIComponent);
			}

			_renderers.length = 0;
			_totalRenderers = 0;
		}

		public function GenerateRenderers():void
		{
			clearRenderers();

			var i:int;
			var curY:int = 0;
			for (i = 0; i < dataProvider.length; ++i)
			{
				var currentRenderer:ListItemRenderer = createRenderer(i) as ListItemRenderer;
				if (currentRenderer)
				{
					addChild(currentRenderer);
					currentRenderer.enabled = true;
					currentRenderer.y = curY;
					currentRenderer.index = i;
					curY += currentRenderer.height;
					currentRenderer.setData(dataProvider[i]);
					_renderers.push(currentRenderer);
					currentRenderer.validateNow();
					++_totalRenderers;
				}
				else
				{
					trace("GFX - W3ScrollingList failed to generate a renderer");
				}
			}

		}
		
		public var ignoreHeightForRendererCreation:Boolean = false;
		override protected function calculateRendererTotal(width:Number, height:Number):uint
		{
			var value:uint = super.calculateRendererTotal(width, height);
			
			if (ignoreHeightForRendererCreation)
			{
				return dataProvider ? dataProvider.length : NaN;
			}
			
			return value;
        }

		public function ShowRenderers(value:Boolean):void
		{
			var renderer:ListItemRenderer;
			var i : int;

			visible = value;
			for ( i = 0; i < Math.min(_dataProvider.length,_totalRenderers); i++ )
			{
				renderer = getRendererAt(i) as ListItemRenderer; //, _scrollPosition));
				if ( renderer )
				{
					renderer.visible = value;
				}
				else
				{
					//trace("Bidon: ASSERT ShowRenderers renderer error "+this.name+" i "+i+" _scrollPosition "+_scrollPosition);
				}
			}
			if (_dataProvider)
			{
				for ( i = _dataProvider.length; i < _totalRenderers; i++ )
				{
					var mc : MovieClip;
					mc = getRendererAt(i) as MovieClip;
					if ( mc )
					{
						mc.visible = false;
					}
				}
			}
			if (textField)
			{
				UpdateEmptyStateFeedback( (_dataProvider.length < 1) );
			}
        }

		public function UpdateEmptyStateFeedback( value : Boolean )
		{
			if ( value )
			{
				textField.htmlText = "[[panel_journal_quest_empty_description]]";
				textField.visible = true;
			}
			else
			{
				textField.visible = false;
			}
		}

		public function moveUp(allowWrap:Boolean = true):void
		{
			var renderer : ListItemRenderer;
			var nextLeftIndex = -1;
			var i:int;
			var controlType : uint = 0;

			if (bIsOptionList)
			{
				for (i = selectedIndex - 1; i >= 0; --i)
				{
					controlType = dataProvider[i].type;

					if ( !dataProvider[i].disabled && (controlType != IngameMenu.IGMActionType_Separator && controlType != IngameMenu.IGMActionType_SubtleSeparator) )
					{
						nextLeftIndex = i;
						break;
					}
				}
			}
			else
			{
				for (i = selectedIndex - 1; i >= 0; --i)
				{
					renderer = getRendererAt(i) as ListItemRenderer;
					controlType = dataProvider[i].type;

					if ( ( !renderer || renderer.enabled ) && (controlType != IngameMenu.IGMActionType_Separator || controlType != IngameMenu.IGMActionType_SubtleSeparator) )
					{
						nextLeftIndex = i;
						break;
					}
				}
			}

			if (selectedIndex == -1)
			{
				selectedIndex = scrollPosition + _totalRenderers - 1;
			}
			else if (nextLeftIndex != -1)
			{
				selectedIndex = nextLeftIndex;
			}
			else if (wrapping == WrappingMode.STICK)
			{
				// Nothing.
			}
			else if (wrapping == WrappingMode.WRAP && allowWrap)
			{
				for (i = _dataProvider.length - 1; i >= 0; --i)
				{
					renderer = getRendererAt(i) as ListItemRenderer;
					controlType = dataProvider[i].type;
					if ( ( !renderer || renderer.enabled ) && (controlType != IngameMenu.IGMActionType_Separator || controlType != IngameMenu.IGMActionType_SubtleSeparator) )
					{
						selectedIndex = i;
						break;
					}
				}

				updateSelectedIndex();

				if (renderer != null)
					renderer.invalidate();

				CheckSubListSelection();
				//selectedIndex = _totalRenderers - 1;
				//GameInterface.playSound('gui_journal_select_item');
			}
			else
			{
				//selectedIndex = -1;
				return;
			}

			validateNow();

			// #J Hack for category lists so the wrap grabs last sub element. Ideally not done here, but with design, currently best spot
			// {
			var dropRenderer:W3DropdownMenuListItem = getRendererAt(selectedIndex) as W3DropdownMenuListItem;
			if (dropRenderer && dropRenderer.isOpen())
			{
				dropRenderer.SelectLastSubListItem();
			}
			// }

			renderer = getRendererAt(selectedIndex) as BaseListItem;
			dispatchIndexChanged(selectedIndex, renderer);
		}

		public function moveDown(allowWrap:Boolean = true):void
		{
			var renderer : ListItemRenderer;
			var nextRightIndex = -1;
			var i:int;
			var controlType : uint = 0;

			if (bIsOptionList)
			{
				for (i = selectedIndex + 1; i < _dataProvider.length; ++i)
				{
					controlType = dataProvider[i].type;

					if ( !dataProvider[i].disabled && (controlType != IngameMenu.IGMActionType_Separator && controlType != IngameMenu.IGMActionType_SubtleSeparator) )
					{				
						nextRightIndex = i;
						break;
					}
				}
			}
			else
			{
				for (i = selectedIndex + 1; i < _dataProvider.length; ++i)
				{
					renderer = getRendererAt(i) as ListItemRenderer;
					controlType = dataProvider[i].type;

					if ( ( !renderer || renderer.enabled ) && (controlType != IngameMenu.IGMActionType_Separator && controlType != IngameMenu.IGMActionType_SubtleSeparator) )
					{				
						nextRightIndex = i;
						break;
					}
				}
			}

			if (nextRightIndex != -1)
			{
				selectedIndex = nextRightIndex;
			}
			else if (wrapping == WrappingMode.STICK)
			{
				// Nothing
			}
			else if (wrapping == WrappingMode.WRAP && allowWrap)
			{
				// To properly supporting wrapping with 1 dropdown item
				if (selectedIndex == 0)
				{
					var dropdownRenderer:W3DropdownMenuListItem = getRendererAt(0) as W3DropdownMenuListItem;

					if (dropdownRenderer && dropdownRenderer.selectedIndex != -1)
					{
						dropdownRenderer.SelectSubListItem( -1);
					}
				}
				else
				{
					for (i = 0; i < _dataProvider.length; ++i)
					{
						renderer = getRendererAt(i) as ListItemRenderer;
						controlType = dataProvider[i].type;

						if ( !renderer || (renderer.enabled && (controlType != IngameMenu.IGMActionType_Separator || controlType != IngameMenu.IGMActionType_SubtleSeparator)) )
						{
							selectedIndex = i;
							break;
						}
					}

					updateSelectedIndex();
				}
			}

			validateNow();
			
			renderer = getRendererAt(selectedIndex) as BaseListItem;
			dispatchIndexChanged(selectedIndex, renderer);
		}

        override public function handleInput(event:InputEvent):void
		{
			if ( event.handled || (!bSkipFocusCheck) && (!focused && focusable) )
			{
				trace("FOCUS W3SL HI focused "+focused+" focusable "+focusable+" and return !!!");
				return;
			}

			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			var i:int;
			var oldSelection:int;

			var renderer:UIComponent = getRendererAt(_selectedIndex, _scrollPosition) as UIComponent;
			if (!(renderer is IListItemRenderer))
			{
				renderer = null;
			}

            if (renderer != null) {
                renderer.handleInput(event); // Since we are just passing on the event, it won't bubble, and should properly stopPropagation.
                if (event.handled) { return; }
            }
			
			if ((details.code == KeyCode.PAD_DIGIT_DOWN || KeyCode.PAD_DIGIT_UP || details.code == KeyCode.PAD_DIGIT_LEFT || details.code == KeyCode.PAD_DIGIT_RIGHT) &&
				details.code != UpAction && details.code != DownAction && details.code != PCUpAction && details.code != PCDownAction)
			{
				return;
			}
			switch( details.code )
			{
                case UpAction:
                case PCUpAction:
					if (keyPress)
					{
						_lastDir = -1;
						oldSelection = selectedIndex;
						moveUp(details.value != InputValue.KEY_HOLD);

						if (oldSelection != selectedIndex)
						{
							renderer = getRendererAt(selectedIndex) as BaseListItem;
							dispatchIndexChanged(selectedIndex, renderer);
							event.handled = true;
						}
						
						//corner case when the first renderer was unable to select but we should scroll up to it
						if ( oldSelection == 1 && selectedIndex == 1 )
							scrollPosition = 0;
					}
                    break;

                case DownAction:
				case PCDownAction:
					if (keyPress)
					{
						_lastDir = 1;
						oldSelection = selectedIndex;
						
						moveDown(details.value != InputValue.KEY_HOLD);

						if (oldSelection != selectedIndex)
						{
							renderer = getRendererAt(selectedIndex) as BaseListItem;
							dispatchIndexChanged(selectedIndex, renderer);
							event.handled = true;
						}
					}
                    break;
                case KeyCode.LEFT:
				case KeyCode.RIGHT:
                    break;
                default:
                    return;
            }
        }

		private function dispatchIndexChanged(index:int, renderer:UIComponent)
		{
			if (renderer is BaseListItem)
			{
				var baseListItemRenderer:BaseListItem = renderer as BaseListItem;
				dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, index, -1, -1, renderer as IListItemRenderer, baseListItemRenderer ? baseListItemRenderer.data : null ) );
			}
			else if (renderer is DropdownMenu)
			{
				var dropdownMenuRenderer:DropdownMenu = renderer as DropdownMenu;
				dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, index, -1, -1, renderer as IListItemRenderer, dropdownMenuRenderer ? dropdownMenuRenderer.data : null ) );
			}
			else
			{
				dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, index, -1, -1, null, renderer ) );
			}
		}

		override protected function updateScrollBar():void
		{
            if (_scrollBar == null) { return; }
			if ( _dataProvider.length <= _totalRenderers )
			{
				scrollBar.visible = false;
			}
			else
			{
				scrollBar.visible = true;
			}

            var max:Number = Math.max(0, _dataProvider.length - _totalRenderers);
            if (_scrollBar is ScrollIndicator) {
                var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
                scrollIndicator.setScrollProperties(_totalRenderers, 0, _dataProvider.length-_totalRenderers);
            } else {
                // Min/max
            }
            _scrollBar.position = _scrollPosition;
            _scrollBar.validateNow();
		}
		
		override protected function populateData(data:Array):void
		{
			super.populateData(data);
			ShowRenderers(true);
			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
		}

		public function updateData(data:Array):void
		{
			if ( !data )
			{
				return;
			}
			populateData(data);
			invalidateData();
		}

		override protected function drawLayout():void
		{
			super.drawLayout();
			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
		}

		override public function toString():String
		{
			return "[W3 W3ScrollingList "+ this.name+" ]";
		}
		
		public function getRenderers():Vector.<IListItemRenderer>
		{
			return _renderers;
		}

		public function GetDropdownListHeight() : Number
		{
			var tempHeight : Number = 0;
			var tempItemRenderer : BaseListItem;

			for (var i : int = 0; i < dataProvider.length; i++ )
			{
				tempItemRenderer = getRendererAt(i) as BaseListItem;

				if( tempItemRenderer )
				{
					tempHeight += tempItemRenderer.actualHeight;
				}
				else
				{
					//trace("DROPDOWN "+this+" updatePosition here is crush i "+i);
				}
			}

			return tempHeight
		}
		
	    override protected function dispatchItemEvent(event:Event):Boolean
		{
			if (selectOnOver && event.type == MouseEvent.ROLL_OVER)
			{
				var targetRenderer:IListItemRenderer = event.currentTarget as IListItemRenderer;
				
				if (targetRenderer)
				{
					trySelectingIndex( targetRenderer.index );
				}
			}
			
			if (event.type == MouseEvent.DOUBLE_CLICK)
			{
				// bubble it
				var renderer:IListItemRenderer = event.currentTarget as IListItemRenderer;
				var newEvent:ListEvent = new ListEvent(ListEvent.ITEM_DOUBLE_CLICK, true, true, renderer.index, 0, renderer.index, renderer, dataProvider.requestItemAt(renderer.index), 0, 0, false);
            	return dispatchEvent(newEvent);
			}
			else
			{
				return super.dispatchItemEvent(event);
			}
		}
		
		public function trySelectingIndex( index : int )
		{
			selectedIndex = index;
		}
		
		override public function set selectedIndex(value:int):void
		{
            if (value == _selectedIndex || value == _newSelectedIndex)
				return;
			
			if (value >= 0 && value < dataProvider.length && 
				(dataProvider[value].disabled || dataProvider[value].type == IngameMenu.IGMActionType_SubtleSeparator))
			{
				// [dsl] This fixes the "selection box" appearing one frame when clicking a disabled item.
				super.selectedIndex = -1;
				return;
			}

			// #J not ideal way to handle this but what can you do :S
			if (this is W3DropDownList)
			{
				var currentRenderer:W3DropdownMenuListItem = getRendererAt(value) as W3DropdownMenuListItem;
				
				if (currentRenderer && !currentRenderer.isOpen())
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
				}
			}
			else
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
			}
			
			super.selectedIndex = value;
        }
		
		override protected function handleMouseWheel(event:MouseEvent):void
		{
			if ( reverseMouseWheel )
			{
				scrollList(event.delta < 0 ? 1 : -1);
			}
			else
			{
				scrollList(event.delta > 0 ? 1 : -1);
			}
        }

		public function CheckSubListSelection() : void { }

		override public function set focused(value:Number):void
		{
			super.focused = value;
			trace("FOCUS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			trace("FOCUS W3SL " + this.name+" focused " + value);
			trace("FOCUS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		}
		
		override protected function updateSelectedIndex():void 
		{
			var renderer:ListItemRenderer = getRendererAt(_newSelectedIndex, scrollPosition) as ListItemRenderer;
			
			if ( renderer != null && !renderer.selectable )
				return;
				
			super.updateSelectedIndex();
		}
	}
}
