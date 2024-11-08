package red.game.witcher3.menus.gwint
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ScrollIndicator;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IScrollBar;
	
	// #J Don't care how half assed this class is, it shouldn't have to exist.........!
	
	public class GwintCardGridList extends SlotsListBase
	{
		private var _widthPadding:int = 0;
		private var _heightPadding:int = 0;
		private var _baseXOffset:int = 0;
		private var _baseYOffset:int = 0;
		
		protected var _maxOffset:Number = 0;
		protected var _scrollBarValue:Object;
		protected var _scrollBar:IScrollBar;
		
		[Inspectable(defaultValue = "true")]
		public function get widthPadding():int { return _widthPadding }
		public function set widthPadding(value:int):void
		{
			_widthPadding = value;
		}
		
		[Inspectable(defaultValue = "true")]
		public function get heightPadding():int { return _heightPadding }
		public function set heightPadding(value:int):void
		{
			_heightPadding = value;
		}
		
		[Inspectable(defaultValue = "true")]
		public function get baseXOffset():int { return _baseXOffset }
		public function set baseXOffset(value:int):void
		{
			_baseXOffset = value;
		}
		
		[Inspectable(defaultValue = "true")]
		public function get baseYOffset():int { return _baseYOffset }
		public function set baseYOffset(value:int):void
		{
			_baseYOffset = value;
		}
		
		protected var _gridRenderHeight:int = 520;
		
		protected var _gridMask : MovieClip = null;
		protected function get gridMask() : MovieClip
		{
			if (_gridMask == null)
			{
				_gridMask = parent.getChildByName("mcGridMask") as MovieClip;
			}
			return _gridMask;
		}
		
		override protected function configUI():void 
		{
			super.configUI();
 
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll, false, 0, true);
			
			if (gridMask)
			{
				_gridRenderHeight = gridMask.height;
			}
			
			addEventListener(ListEvent.INDEX_CHANGE, handleSlotChanged, false, 0 , true);
		}
		
		private var _numColums:uint;
		[Inspectable(defaultValue = "3")]
		override public function get numColumns():uint { return _numColums; }
		public function set numColumns(value:uint):void
		{
			_numColums = value;
		}
		
		private var _numRowsVisible:uint;
		[Inspectable(defaultValue = "2")]
		public function get numRowsVisible():uint { return _numRowsVisible; }
		public function set numRowsVisible(value:uint):void
		{
			_numRowsVisible = value;
		}
		
		[Inspectable(type="String")]
        public function get scrollBar():Object { return _scrollBar }
        public function set scrollBar(value:Object):void
		{
            _scrollBarValue = value;
            invalidate(InvalidationType.SCROLL_BAR);
        }
		
		protected var _rows:uint;
		public function get rows():uint {	return _rows }
		public function set rows(value:uint):void
		{
			_rows = value;
		}
		
		override public function getColumn( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return index % (numColumns - 1);
		}
			
		override public function getRow( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return Math.abs(index / numColumns);
		}
		
		override protected function populateData():void
		{	
			setupRenderers();
		}
		
		public function addRenderer(rendererData:Object):void
		{
			spawnRenderer(rendererData);
			
			_renderersCount = _renderers.length;
			rows = Math.floor(_renderers.length / numColumns);
			
			data.push(rendererData);
			
			positionRenderers();
			
			updateScrollBar();
		}
		
		public function removeRenderer(targetRenderer:SlotBase):void
		{
			var indexOf:int = _renderers.indexOf(targetRenderer);
			
			var oldSelection:int = selectedIndex;
			selectedIndex = -1;
			
			if (indexOf != -1)
			{
				targetRenderer.cleanup();
				_canvas.removeChild(targetRenderer as DisplayObject);
				_renderers.splice(indexOf, 1);
				_renderersCount = _renderers.length;
			}
			
			rows = Math.floor(_renderers.length / numColumns);
			
			indexOf = -1;
			
			for (var i:int = 0; i < data.length; ++i)
			{
				if (data[i] == targetRenderer.data)
				{
					indexOf = i;
					break;
				}
			}
			
			if (indexOf != -1)
			{
				data.splice(indexOf, 1);
			}
			
			positionRenderers();
			
			if (oldSelection >= _renderers.length)
			{
				selectedIndex = _renderers.length - 1;
			}
			else
			{
				selectedIndex = oldSelection;
			}
			
			if (getSelectedRenderer() != null)
			{
				getSelectedRenderer().selected = true;
			}
			
			updateScrollBar();
		}
		
		override public function set selectedIndex(value:int):void
		{
			super.selectedIndex = value;
		}
		
		private function setupRenderers():void
		{
			// Step 1, make sure we have the right number of renderers
			adjustRendererCount();
			
			// Step 2, position all the renderers
			positionRenderers();
			
			// Step 3, make sure all the renderers have the right data
			updateRendererData();
			
			if (InputManager.getInstance().isGamepad())
			{
				selectedIndex = 0;
			}
		}
		
		protected function spawnRenderer(data:Object = null) : SlotBase
		{
			var newRenderer:SlotBase = new _slotRendererRef() as SlotBase;
					
			if (newRenderer)
			{
				setupRenderer(newRenderer);
				newRenderer.useContextMgr = false;
				_canvas.addChild(newRenderer);
				newRenderer.index = _renderers.length; // OMEGA
				_renderers.push(newRenderer); // << Super important to call !AFTER! line tagged OMEGA for proper indexes
				
				if (data != null)
				{
					newRenderer.setData(data);
				}
				
				newRenderer.activeSelectionEnabled = _activeSelectionVisible;
			}
			else
			{
				throw new Error("GFX - unsupported _slotRendererRef() used: " + _slotRendererRef);
			}
			
			return newRenderer;
		}
		
		private function adjustRendererCount():void
		{
			var numRenderers:int = _data == null ? 0 : _data.length;
			if (numRenderers < 0)
			{
				throw new Error("GFX - adjusting renderer count to an invalid value: " + numRenderers);
			}
			
			while (_renderers.length != numRenderers)
			{
				if (_renderers.length > numRenderers)
				{
					var curRdr:SlotBase = _renderers.pop() as SlotBase;
					if (curRdr) 
					{
						curRdr.cleanup();
						_canvas.removeChild(curRdr as DisplayObject);
					}
					else
					{
						throw new Error("GFX - trying to remove a slotRenderer of invalid type. Will NOT be properly removed!");
					}
				}
				else if (_renderers.length < numRenderers)
				{
					spawnRenderer();
				}
				else
				{
					throw new Error("GFX - something has gone horribly wrong!");
				}
			}
			
			_renderersCount = _renderers.length;
			
			rows = Math.floor(_renderersCount / numColumns);
		}
		
		public function positionRenderers():void
		{
			var rendererIdx:int;
			var curCol:int = 0;
			var curRow:int = 0;
			var currentRenderer:SlotBase;
			
			for (rendererIdx = 0; rendererIdx < _renderers.length; ++rendererIdx)
			{
				currentRenderer = _renderers[rendererIdx] as SlotBase;
				currentRenderer.index = rendererIdx; // Need to do this because removing renderers may have made the currently set indexes invalid
				curCol = rendererIdx % numColumns;
				curRow = Math.floor(rendererIdx / numColumns);
				currentRenderer.x = baseXOffset + curCol * _widthPadding;
				currentRenderer.y = baseYOffset + curRow * _heightPadding;
			}
		}
		
		private function updateRendererData():void
		{
			var rendererIdx:int;
			var curCol:int = 0;
			var curRow:int = 0;
			var currentRenderer:SlotBase;
			
			// TEST, REMOVE US before submitting
			var numVisible:int = 0;
			var numHidden:int = 0;
			// END TEST
			
			for (rendererIdx = 0; rendererIdx < _renderers.length; ++rendererIdx)
			{
				currentRenderer = _renderers[rendererIdx] as SlotBase;
				currentRenderer.setData(_data[rendererIdx]);
			}
		}
		
		override public function applySelectionContext():void
		{
			
		}
		
		protected var _offset:uint;
		public function get offset():uint { return _offset }
		public function set offset(value:uint):void
		{
			if ( value > -1 )
			{
				_offset = value;
			}
			_canvas.y = -_offset;
			updateScrollBar();
		}
		
		public function get scrollPosition() : uint { return offset }
		public function set scrollPosition( value : uint ) : void
		{
			offset = value;
		}
		
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
		
		protected function onScroll( event : MouseEvent ) : void
		{
			if (gridMask && gridMask.hitTestPoint(event.stageX, event.stageY))
			{
				if ( _maxOffset > 0 )
				{
					if ( event.delta > 0 )
					{
						_scrollBar.position -= heightPadding;
					}
					else
					{
						_scrollBar.position += heightPadding;
					}
				}
			}
		}
		
		protected function handleSlotChanged(event:ListEvent):void
		{
			var currentSlot:SlotBase = event.itemRenderer as SlotBase;
			
			if (currentSlot)
			{
				var curScrollValue:Number = scrollBar.position;
				var targetScrollPosition:Number = Math.floor(event.itemRenderer.index / numColumns) * heightPadding;
				
				if (targetScrollPosition >= (curScrollValue + numRowsVisible * heightPadding))
				{
					// to bottom edge
					scrollBar.position = targetScrollPosition - ((numRowsVisible - 1) * heightPadding);
				}
				else if (targetScrollPosition < curScrollValue)
				{
					scrollBar.position = targetScrollPosition;
				}
			}
			
			updateScrollBar();
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
		
		protected function handleScroll(event:Event):void
		{
			scrollPosition = _scrollBar.position;
        }
		
		protected function updateScrollBar():void
		{
			if (_scrollBar != null)
			{
				var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
				
				_maxOffset = (Math.round(Math.ceil(_renderersCount / numColumns) - numRowsVisible)) * heightPadding;
				_maxOffset = Math.max(0, _maxOffset);
				
				if (_maxOffset <= 0 || !visible)
				{
					scrollIndicator.visible = false;
				}
				else
				{
					scrollIndicator.visible = true;
					scrollIndicator.setScrollProperties( numRowsVisible * heightPadding, 0, _maxOffset);
				}
				_scrollBar.position = scrollPosition;
				_scrollBar.validateNow();
			}
		}
	}
}