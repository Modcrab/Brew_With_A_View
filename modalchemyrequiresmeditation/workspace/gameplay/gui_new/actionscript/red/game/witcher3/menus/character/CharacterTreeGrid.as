/***********************************************************************
/** CHaracter Tree Grid List
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import flash.events.Event;
	import scaleform.clik.events.ListEvent;
	
	import flash.utils.getDefinitionByName;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.game.witcher3.data.GridData;
	import red.game.witcher3.events.GridEvent;
	//import red.game.witcher3.menus.common.ItemDataStub; // kill
	import red.game.witcher3.interfaces.IGridItemRenderer;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.SkillDataStub;
	
	import red.game.witcher3.menus.common.AbstractGridContainer;

	[Event(name="change", type="flash.events.Event")]
    [Event(name="itemClick", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemPress", type="scaleform.clik.events.ListEvent")]
    [Event(name = "itemDoubleClick", type = "scaleform.clik.events.ListEvent")]
	
	public class CharacterTreeGrid extends AbstractGridContainer
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var tfCurrentState : TextField;
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		private var _totalRenderers : int;
	
		// Internally useful for key navigation to make interating over a row more convenient if 1x2 items are above it.
		protected var _actualSelectedIndex:int = -1;
		protected var _newActualSelectedIndex:int = -1;
		protected var _defaultActualSelectedIndex:int = 0;
		protected var _gridName : String;
				
		/********************************************************************************************************************
			COMPONENT PROPERTIES
		/ ******************************************************************************************************************/

		/** The size of each grid square. Can be bigger than the icon so it fits inside and you still see the grid lines. */
		protected var _gridSquareSize:Number;
		/** The offset of each element relative to its grid square */
		protected var _elementGridSquareOffset:Number;
		
		protected var _slotRenderer:String;
	
		protected var _rows:uint;
		protected var _columns:uint;
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
	
		public function CharacterTreeGrid()
		{
			super();
		}
		
		override protected function configUI() : void
		{
			super.configUI();
			addEventListener( InputEvent.INPUT, handleInput, false, 10, true );
			
			_totalRenderers = _rows * _columns;
			createRenderers();
		}
				
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/
		
		override public function set selectedIndex( value : int ) : void
		{
            if ( value == _selectedIndex || value == _newSelectedIndex)
			{
				return;
			}
			
			// Use the "uplinked" index, which getRendererAt provides us with
			// Find where the item starts and make that the actual index that's selected, so we can rely
			// on this when doing other math with item indices.
			var renderer:IGridItemRenderer = getRendererAt( value )
			_newSelectedIndex = renderer ? renderer.index : value;
			_newActualSelectedIndex = value;
			invalidateSelectedIndex();
        }
		
		[Inspectable(defaultValue="0")]
		public function get rows() : uint
		{
			return _rows;
		}
		
		public function set rows( value : uint ) : void
		{
			if ( _rows != value )
			{
				_rows = value;
			}
		}
		
		public function handleGridNameSet(  name : String ):void
		{
			if (tfCurrentState)
			{
				tfCurrentState.htmlText = name;
				_gridName = name;
			}
		}
		
		[Inspectable(defaultValue="0")]
		public function get columns() : uint
		{
			return _columns;
		}
		
		public function set columns( value : uint ) : void
		{
			if ( _columns != value )
			{
				_columns = value;
			}
		}
		
		[Inspectable(defaultValue="0")]
		public function get gridSquareSize() : Number
		{
			return _gridSquareSize;
		}
		
		public function set gridSquareSize( value : Number ) : void
		{
			if ( _gridSquareSize != value )
			{
				_gridSquareSize = value;
			}
		}
		
		[Inspectable(defaultValue="0")]
		public function get elementGridSquareOffset() : Number
		{
			return _elementGridSquareOffset;
		}
		
		public function set elementGridSquareOffset( value : Number ) : void
		{
			if ( _elementGridSquareOffset != value )
			{
				_elementGridSquareOffset = value;
			}
		}
		
		[Inspectable(name="slotRenderer", defaultValue="PerkItemRenderer")]
		public function get slotRendererName() : String
		{
			return _slotRenderer;
		}
		
		public function set slotRendererName( value : String ) : void
		{
			if ( _slotRenderer != value )
			{
				_slotRenderer = value;
				_slotRendererRef = getDefinitionByName( _slotRenderer ) as Class;
				if ( ! _slotRendererRef )
				{
					throw new Error("Can't find class definition in your library for " + _slotRenderer );
				}
			}
		}
				
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
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
	
		override public function populateData( data : Array ) : void
		{
			var renderer:IGridItemRenderer;
			for each ( renderer in _renderers ) // kill that
			{
				renderer.setListData( null );
				renderer.setData( null );
				//renderer.enabled = false;
			}
			
			_dataSize = data.length;
			
			var tempHack : int = 0;
			for each ( var skillDataStub : SkillDataStub in data ) // change
			{
				tempHack ++;
				trace("CHARACTER: ( skillDataStub tempHack "+tempHack );
				if ( skillDataStub == null )
				{
					trace("CHARACTER: ( skillDataStub == null )" );
					continue;
				}
				var index:int = skillDataStub.positonID;
				var gridData:GridData = new GridData( 0, "", _selectedIndex == index, skillDataStub.iconPath, 1 );
				
				renderer = getRendererAt( index );
				if ( renderer )
				{
					//renderer.uplink = null;
					renderer.enabled = true;
					DisplayObject(renderer).visible = true;
					renderer.setListData( gridData );
					renderer.setData( skillDataStub );
				}
				else
				{
					trace("CHARACTER GRID POPULTATE DATA RENDERER IS NULL");
				}
			}
			
			
			
		/*	if ( selectedIndex >= _dataSize ) // kill
			{
				selectedIndex = 0;
			}*/
			
			var newRenderer:IGridItemRenderer = getRendererAt( _selectedIndex );
			if ( newRenderer != null )
			{
                newRenderer.selected = true; // Item is in range. Just set it.
                newRenderer.validateNow();
            }
		}
		
		override protected function updateSelectedIndex() : void
		{
			super.updateSelectedIndex();
			_actualSelectedIndex = _newActualSelectedIndex;
        }
		
		override protected function CheckSelectNewRender() : Boolean // #B will be overrided by child classes
		{
			return !(_selectedIndex < 0 || _selectedIndex >= _totalRenderers );
		}
		
		override public function handleInput( event : InputEvent ) : void
		{
			// Already Handled.
            if ( event.handled )
			{
				return;
			}
			
            // Pass on to selected renderer first
            var renderer : IGridItemRenderer = getRendererAt( _selectedIndex );
			var bCorr : Boolean = false; // remove bCorr
			
/*		  	if ( renderer != null )
			{
				// Since we are just passing on the event, it won't bubble, and should properly stopPropagation.
                renderer.handleInput( event );
                if ( event.handled )
				{
					return;
				}
            }*/

            // Only allow actions on key down, but still set handled=true when it would otherwise be handled.
            var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			var newSelectedIndex : int;
			switch( details.navEquivalent )
			{
                case NavigationCode.UP:
					if ( keyPress && indexNavigation )
					{
						if ( _selectedIndex < 0 )
						{
							selectedIndex = _totalRenderers - 1;
						}
						else
						{
							newSelectedIndex = ( _selectedIndex - _columns );
							
							if ( newSelectedIndex < 0 )
							{
								_offset -= _columns;
								if ( _offset < 0 )
								{
									_offset =  (Math.ceil( _dataSize / _columns ) * _columns) - _totalRenderers;
									selectedIndex = ( newSelectedIndex + _totalRenderers ) % _totalRenderers;
								}
								invalidateData();
							}
							else
							{
								selectedIndex = ( _selectedIndex - _columns + _totalRenderers ) % _totalRenderers;
							}
						}
					}
                    break;

                case NavigationCode.DOWN:
					if ( keyPress && indexNavigation  )
					{
						if ( _selectedIndex < 0 )
						{
							selectedIndex = 0;
						}
						else
						{
							// Note we've contrained the _selectedIndex to be either on an empty grid square of the square where the top
							// of the item is
							var gridSize:int = renderer ? renderer.gridSize : 1;
							if ( gridSize > 3 )
							{
								gridSize = 2;
							}
							newSelectedIndex = ( _selectedIndex + gridSize * _columns );
							
							if ( newSelectedIndex >= _totalRenderers )
							{
								_offset += _columns;
								var maxOffset : Number = (Math.ceil( _dataSize / _columns ) * _columns) - _totalRenderers;
								if ( _offset > maxOffset )
								{
									_offset = 0;
									selectedIndex = newSelectedIndex % _totalRenderers;
								}
								invalidateData();
							}
							else
							{
								selectedIndex = ( _selectedIndex + gridSize * _columns ) % _totalRenderers;
							}
						}
					}
                    break;
					
				case NavigationCode.LEFT:
					if ( keyPress && indexNavigation  )
					{
						if ( _selectedIndex < 0 )
						{
							selectedIndex = _totalRenderers - 1;
						}
						else
						{
							renderer = getRendererAt(_actualSelectedIndex);
							if ( renderer.index != _actualSelectedIndex )
							{
								bCorr = true;
							}
							selectedIndex = (( _actualSelectedIndex - GetHorizontalMoveStep( renderer.gridSize, bCorr ) + _totalRenderers ) % _columns) + ( getRow(selectedIndex) * _columns ); //#B
						}
					}
                    break;
					
				case NavigationCode.RIGHT:
					if ( keyPress && indexNavigation  )
					{
						if ( _selectedIndex < 0 )
						{
							selectedIndex = 0;
						}
						else
						{
							renderer = getRendererAt(_actualSelectedIndex);
							bCorr  = true;
							if ( renderer.index != _actualSelectedIndex )
							{
								bCorr = false;
							}
							selectedIndex = (( _actualSelectedIndex + GetHorizontalMoveStep(renderer.gridSize,bCorr) ) %  _columns) + ( getRow(selectedIndex) * _columns ); //#B
						}
					}
                    break;

                case NavigationCode.END:
                    if ( ! keyPress && indexNavigation  )
					{
                        selectedIndex = _totalRenderers - 1;
                    }
                    break;

                case NavigationCode.HOME:
                    if ( ! keyPress && indexNavigation  )
					{
						selectedIndex = 0;
					}
                    break;

                default:
                    return;
            }

			// Neccessary or else the selectedness state can stay on another item if going back and forth too fast
			// Apparently not enough to validate in the item changed event either.
			validateNow();
			//event.stopImmediatePropagation();
            event.handled = true;
        }
		
		private function GetHorizontalMoveStep( gridSize : int, bCorr : Boolean ) : int // kill
		{
			if ( gridSize > 3 && bCorr )
			{
				return 2;
			}
			return 1;
		}
		
		override public function toString():String
		{
			return "[W3 InventoryGrid " + name + "]";
		}
		
		/********************************************************************************************************************
			RENDERERS SETUP
		/ ******************************************************************************************************************/
	
		private function createRenderers() : void
		{
			_renderers = new Vector.<IGridItemRenderer>( _totalRenderers, true );
			_slotContainer = new Sprite();
			addChild( _slotContainer );
			// Create bottom to top so when 1x2 it will be overtop the bottom renderer
			for ( var index:int = _totalRenderers - 1; index >= 0; --index )
			{
				var obj:Object = new _slotRendererRef();
				var renderer:IGridItemRenderer = IGridItemRenderer( obj );
				renderer.index = index;
				renderer.enabled = false;
				DisplayObject(renderer).visible = false;
				_slotContainer.addChild( DisplayObject( obj ) );
				
				var rendererColumn:int = getColumn( index );
				var rendererRow:int = getRow( index );
				renderer.x = rendererColumn * _gridSquareSize + _elementGridSquareOffset * rendererColumn;
				renderer.y = rendererRow * _gridSquareSize + _elementGridSquareOffset * rendererRow;
				setupRenderer( renderer );
				
				_renderers[ index ] = renderer;
			}
		}
		
		public function resetRenderers() : void
		{
			if ( _slotContainer )
			{
				for ( var i : int = _slotContainer.numChildren - 1; i >= 0; --i )
				{
					_slotContainer.removeChildAt(i);
				}
				removeChild(_slotContainer);
				_slotContainer = null;
			}
			_totalRenderers = _rows * _columns;
			createRenderers();
		}
		
		public function changeState( value : String ) : void
		{
			gotoAndPlay(value);
			handleGridNameSet(_gridName);
		}
	}
}