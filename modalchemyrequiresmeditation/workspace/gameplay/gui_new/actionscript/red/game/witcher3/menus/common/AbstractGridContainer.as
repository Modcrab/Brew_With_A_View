/***********************************************************************
/** Abstract container, common for player grid, paperdoll, skill tree, perk tree
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/


package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import scaleform.clik.controls.ListItemRenderer;
	
	import scaleform.clik.core.UIComponent; // #B change to witcher3.controls.MenuItem - where
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import scaleform.gfx.MouseEventEx;
	
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.ButtonEvent;
	
	import red.game.witcher3.events.GridEvent;
	import red.core.events.GameEvent;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	
	
	[Event(name = "change", type = "flash.events.Event")]
    [Event(name = "itemClick", type = "scaleform.clik.events.ListEvent")]
    [Event(name = "itemPress", type = "scaleform.clik.events.ListEvent")]
    [Event(name = "itemDoubleClick", type = "scaleform.clik.events.ListEvent")]
	[Event(name = "gridItemChange", type="red.game.witcher3.events.GridEvent")]
	public class AbstractGridContainer extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		protected var _slotContainer:Sprite;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		protected var _renderers : Vector.<IGridItemRenderer>;
		protected var _dataSize : int = 0;
				
		/********************************************************************************************************************
			COMPONENT PROPERTIES
		/ ******************************************************************************************************************/
		protected var _selectedIndex : int = -1;
        // The latest internal selectedIndex. Will be pushed to _selectedIndex next time updateSelectedIndex() is called.
        protected var _newSelectedIndex : int = -1;
        protected var _offset : uint = 0;
		protected var _indexNavigation : Boolean;  // #B check that one.
		protected var _dataProvider : DataProvider;
		protected var _defaultSelectedIndex : int = 0;
		protected var _slotRendererRef : Class;
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
	
		public function AbstractGridContainer()
		{
			super();
		}
				
		override protected function configUI():void
		{
			super.configUI();
		}
		
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/
	
		public function get defaultSelectedIndex() : int
		{
			return _defaultSelectedIndex;
		}
		
		public function set defaultSelectedIndex( value : int )
		{
			_defaultSelectedIndex = value;
		}
	
		public function get indexNavigation() : Boolean // #B check that one.
		{
			return _indexNavigation;
		}
		
		public function set indexNavigation( value : Boolean ) : void // #B check that one.
		{
			if ( _indexNavigation != value )
			{
				// FIXME: Don't think the commented out stuff below is really necessary, plus I don't
				// want to reset the selectedIndex to 0, but -1
				//defaultSelectedIndex = 0;
				//selectedIndex = 0; // Set before, so we unfocus components etc
				_indexNavigation = value;
			}
		}
		
		public function get offset() : uint
		{
			return _offset;
		}
		
		public function set offset( value : uint ) : void
		{
			if ( value > 0 )
			{
				_offset = value;
			}
			populateData(_dataProvider);
			
			// update scrollbar and data
			// probably move selectedIndex
		}
		
		public function get dataSize( ) : int
		{
			return _dataSize;
		}
		
        public function get selectedIndex() : int
		{
			return _selectedIndex;
		}

		public function set selectedIndex( value : int ) : void
		{
            if ( value == _selectedIndex || value == _newSelectedIndex)
			{
				return;
			}
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [(" selectedIndex _newSelectedIndex "+ _newSelectedIndex )]));
			
			_newSelectedIndex = value;
			invalidateSelectedIndex();
        }
		
		 /**
         * Enable/disable focus management for the component. Setting the focusable property to
         * {@code focusable=false} will remove support for tab key, direction key and mouse
         * button based focus changes.
         */
        [Inspectable(defaultValue="true")]
        override public function get focusable():Boolean { return _focusable; }
        override public function set focusable(value:Boolean):void {
            super.focusable = value;
        }
		
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean
		{
			return super.enabled;
		}

		override public function set enabled( value : Boolean ) : void
		{
            super.enabled = value;

            //setState(super.enabled ? "default" : "disabled");

            // Pass enabled on to renderers
			for each ( var renderer in _renderers )
			{
                renderer.enabled = enabled;
            }
        }
	
		public function get dataProvider() : DataProvider
		{
			return _dataProvider;
		}

		public function set dataProvider( value : DataProvider ) : void
		{
            if ( _dataProvider == value )
			{
				return;
			}

			if ( _dataProvider != null )
			{
				_dataProvider.removeEventListener( Event.CHANGE, handleDataChange, false );
			}

            _dataProvider = value;
            if (_dataProvider == null)
			{
				return;
			}
			
			_dataProvider.addEventListener( Event.CHANGE, handleDataChange, false, 0, true );
			_dataProvider.addEventListener( ListEvent.INDEX_CHANGE, handleSelectedNewIndex, false, 0, true );
			_dataProvider.addEventListener(ListEvent.ITEM_PRESS, handleListItemPress, false, 0, true);
			invalidateData();
        }
				
		/********************************************************************************************************************
			PUBLIC FUNCTIONS
		/ ******************************************************************************************************************/

		public function getRendererAt( index : int ) : IGridItemRenderer
		{
			if ( index < 0 || index >= _renderers.length )
			{
				return null;
			}
			
			var renderer:IGridItemRenderer = _renderers[ index ];
			
			while ( renderer && renderer.uplink )
			{
				renderer = renderer.uplink;
			}
			return renderer;
		}
	
		public function invalidateSelectedIndex() : void
		{
            invalidate(InvalidationType.SELECTED_INDEX);
        }
		
		protected function handleDataChange( event : Event ) : void
		{
			invalidate( InvalidationType.DATA );
		}
		
		protected function handleItemClick( event : MouseEvent ) : void
		{
			var gridSlot : ListItemRenderer;
			gridSlot = event.currentTarget as ListItemRenderer;
			if( gridSlot != null )
            {
				var index:Number = gridSlot.index;
			
				// If the data has not been populated, but the listItemRenderer is clicked, it will have no index.
				if ( isNaN( index ) )
				{
					return;
				}
				if ( dispatchItemEvent( event ) )
				{
					selectedIndex = index;
					_defaultSelectedIndex = selectedIndex;
				}
			}
        }
		
		protected function handleSelectedNewIndex( event : ListEvent ) : Boolean
		{
			var gridSlot :  ListItemRenderer;
			gridSlot = event.itemRenderer as ListItemRenderer;
			
/*			if ( checkShowTooltip(gridSlot) )
			{
				var hideEvent:GridEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, gridSlot.index, -1, -1, gridSlot, gridSlot.data );
				dispatchEvent(hideEvent);
			}
			else
			{*/
				trace("INVENTORY handleSelectedNewIndex  DISPLAY_TOOLTIP abstract grid container");
				var displayEvent:GridEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, gridSlot.index, -1, -1, gridSlot, gridSlot.data );
				dispatchEvent(displayEvent);
			//}
			return true;
		}
		
		protected function checkShowTooltip( renderer : ListItemRenderer ) : Boolean
		{
			//if()
			return true;
		}
		
		protected function handleListItemPress( event : ListEvent ) : Boolean
		{
			//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItem', [CHARACTERSlot.data.id, CHARACTERSlot.data.slotType ] )); / or whateva
			return true;
		}
			
		protected function dispatchItemEvent( event : Event) : Boolean
		{
			var type:String;
			switch (event.type)
			{
				case ButtonEvent.PRESS:
					type = ListEvent.ITEM_PRESS;
					break;
				case ButtonEvent.CLICK:
					type = ListEvent.ITEM_CLICK;
					break;
				//case MouseEvent.ROLL_OVER:
				//	type = ListEvent.ITEM_ROLL_OVER;
				//	break;
				//case MouseEvent.ROLL_OUT:
				//	type = ListEvent.ITEM_ROLL_OUT;
				//	break;
				case MouseEvent.DOUBLE_CLICK:
					type = ListEvent.ITEM_DOUBLE_CLICK;
					break;
				default:
					return true;
			}

			var renderer:IGridItemRenderer = event.currentTarget as IGridItemRenderer;

			// Propogate the controller / mouse index.
			var controllerIdx : uint = 0;
			var buttonIdx : uint = 0;
			var isKeyboard : Boolean = false;
			
			if( event is ButtonEvent )
			{
				controllerIdx = (event as ButtonEvent).controllerIdx;
				buttonIdx = (event as ButtonEvent).buttonIdx;
				// Propogate whether the keyboard / gamepad generated this event.
				isKeyboard = (event as ButtonEvent).isKeyboard;
			}
			else if( event is MouseEventEx )
			{
				controllerIdx = (event as MouseEventEx).mouseIdx;
				buttonIdx = (event as MouseEventEx).buttonIdx;
			}

			var index:uint = renderer.index;
			var columnIndex:int = getColumn( index );
			var rowIndex:int = getRow( index );
			var newEvent:ListEvent = new ListEvent(type, false, true, index, columnIndex, rowIndex, renderer, renderer.data, controllerIdx, buttonIdx, isKeyboard);
			return dispatchEvent(newEvent);
		}
		
		/********************************************************************************************************************
			PLUG FUNCTIONS
		/ ******************************************************************************************************************/
				
		public function populateData( data : Array ) : void
		{
		}
		
		public function getRow( index : int ) : int
		{
			return -1;
		}
		
		public function getColumn( index : int ) : int
		{
			return -1;
		}
				
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
		override protected function draw() : void
		{
			if ( isInvalid( InvalidationType.SELECTED_INDEX ) )
			{
                updateSelectedIndex();
            }
			
			if ( isInvalid( InvalidationType.DATA ) )
			{
				refreshData();
			}
			
			super.draw();
		}
		
/*		override protected function changeFocus() : void
		{
			super.changeFocus();
			
			var renderer : IGridItemRenderer = getRendererAt( _selectedIndex );
            if ( renderer != null )
			{
                renderer.displayFocus = (focused > 0);
                renderer.validateNow();
            }
        }*/
		
		override public function toString() : String
		{
			return "[W3 AbstractGridContainer " + name + "]";
		}
		
		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
				
		private function refreshData() : void
		{
			updateSelectedIndex(); 
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [(" refreshData " )]));

			var oldRenderer:IGridItemRenderer = getRendererAt( _selectedIndex );
			var oldData:Object = oldRenderer ? oldRenderer.data : null; // Get the old data now before the renderer replaces it
			
			//var items:Array = _dataProvider ? _dataProvider.requestAllItems( populateData ) : [];
			
			populateData(_dataProvider);
			
			var newRenderer:IGridItemRenderer = getRendererAt( _selectedIndex );
			var newData:Object = newRenderer ? newRenderer.data : null;
			
			if ( _dataProvider )
			{
				_dataProvider.selectedIndex = _selectedIndex;
				
			}
			
			if ( oldData != newData )
			{
				var rowIndex:int = getRow( _selectedIndex );
				var columnIndex:int = getColumn( _selectedIndex );
				dispatchEvent( new GridEvent( GridEvent.ITEM_CHANGE, true, false, _selectedIndex, columnIndex, rowIndex, newRenderer, newData ) );
			}
		}
		
		/********************************************************************************************************************
			INTERNAL UPDATES
		/ ******************************************************************************************************************/
		
		// TBD: Highlight empty grid space when "selected"
		// FIXME: Make this more like core list where the event only happens here instead of in the subclass
		protected function updateSelectedIndex() : void
		{
			//trace("INVENTORY &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
            if ( _selectedIndex == _newSelectedIndex )
			{
				return;
			}
			
			// Clear old renderer
			var oldRenderer:IGridItemRenderer = getRendererAt( _selectedIndex );
			var oldData:Object = oldRenderer ? oldRenderer.data : null;
			//trace("INVENTORY oldeRenderer");
            if ( oldRenderer != null )
			{
                oldRenderer.selected = false; // Only reset items in range
                oldRenderer.validateNow();
            }
			
			// Set new renderer
            //_selectedIndex = _newSelectedIndex; // Reset the new selected index value if we found a renderer instance
            _selectedIndex = _newSelectedIndex; // Reset the new selected index value if we found a renderer instance
			var newRenderer:IGridItemRenderer = getRendererAt( _selectedIndex );
			var newData:Object = newRenderer ? newRenderer.data : null;
			
			var rowIndex:int = getRow( _selectedIndex );
			var columnIndex:int = getColumn( _selectedIndex );
			
			dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false, _selectedIndex, columnIndex, rowIndex, newRenderer, newRenderer ? newRenderer.data : null ) );
			//trace("INVENTORY ListEvent");
			if ( oldData != newData )
			{
				//trace("INVENTORY dispatchEvent");
				dispatchEvent( new GridEvent( GridEvent.ITEM_CHANGE, true, false, _selectedIndex, columnIndex, rowIndex, newRenderer, newData ) );
			}
			if ( CheckSelectNewRender() )
			{
				if ( newRenderer != null )
				{
					newRenderer.selected = true; // Item is in range. Just set it.
					newRenderer.validateNow();
				}
			}
        }
		
		protected function CheckSelectNewRender() : Boolean // #B will be overrided by child classes
		{
			return true;
		}

		/********************************************************************************************************************
			RENDERERS SETUP
		/ ******************************************************************************************************************/
		
		protected function setupRenderer( renderer:IGridItemRenderer ):void
		{
            renderer.owner = this;
			renderer.focusTarget = this;
			renderer.tabEnabled = false; // Children can still be tabEnabled, or the renderer could re-enable this. //LM: There is an issue with this. Setting disabled could automatically re-enable. Consider alternatives.
            renderer.doubleClickEnabled = true;
            renderer.addEventListener( ButtonEvent.PRESS, dispatchItemEvent, false, 0, true );
            renderer.addEventListener( MouseEvent.CLICK, handleItemClick, false, 0, true );
            renderer.addEventListener( MouseEvent.DOUBLE_CLICK, dispatchItemEvent, false, 0, true );

			//renderer.addEventListener( MouseEvent.ROLL_OVER, handleRollOver, false, 0, true );
            //renderer.addEventListener( MouseEvent.ROLL_OUT, handleRollOut, false, 0, true );
        }

        protected function cleanUpRenderer( renderer : IGridItemRenderer ) : void
		{
            renderer.owner = null;
            renderer.focusTarget = null;
            // renderer.tabEnabled = true;
            renderer.doubleClickEnabled = false;
            renderer.removeEventListener( ButtonEvent.PRESS, dispatchItemEvent );
            renderer.removeEventListener( ButtonEvent.CLICK, handleItemClick );
            renderer.removeEventListener( MouseEvent.DOUBLE_CLICK, dispatchItemEvent );
            //renderer.removeEventListener( MouseEvent.ROLL_OVER, handleRollOver );
            //renderer.removeEventListener( MouseEvent.ROLL_OUT, handleRollOut );
        }
	}
}