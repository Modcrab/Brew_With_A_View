package red.game.witcher3.slots
{
	import com.gskinner.motion.GTweener;
	import fl.transitions.easing.Strong;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ColorSprite;
	import red.game.witcher3.menus.inventory.InventorySlotOverlay;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;

	/**
	 * Abstract class for all slots
	 * red.game.witcher3.slots.SlotBase
	 * @author Yaroslav Getsevich
	 */
	public class SlotBase extends UIComponent implements IBaseSlot, IDragTarget
	{
		protected static const INVALIDATE_TOOLTIP_HIDE:String = "INVALIDATE_TOOLTIP_HIDE";
		protected static const INVALIDATE_TOOLTIP_SHOW:String = "INVALIDATE_TOOLTIP_SHOW";
		
		protected static const NO_IMAGE_SPRITE_REF:String = "ImageStubRef";
		protected static const DISABLED_ACTION_ALPHA:Number = .6;
		protected static const BOOK_READED_ALPHA:Number = .3;
		protected static const DRAG_ALPHA:Number = .5;
		protected static const DISABLE_ALPHA:Number = .5;
		protected static const OVER_GLOW_COLOR:Number = 0xF3FFC2;
		protected static const OVER_GLOW_BLUR:Number = 15;
		protected static const OVER_GLOW_STRENGHT:Number = .75;
		protected static const INDICATE_ANIM_SCALE:Number = 1;
		protected static const ICON_FILTER_TIMER:Number = 300;
		protected static const RECT_MARGIN:Number = 0; //15;
		
		protected var INDICATE_ANIM_DURATION:Number = 1.5;
		
		public static var NEW_FLAG_CLEARED : String = "New Flag reset on item";
		public static var AUTO_SHOW_COLLAPSED_ICON : Boolean = false;
		public static var OPT_MODE : Boolean = false;

		public var mcSlotOverlays:InventorySlotOverlay;
		public var mcHitArea:MovieClip;
		public var mcSizeAnchor:Sprite;
		public var mcFrame:MovieClip; //!!!!
		public var mcStateSelectedActive:MovieClip;
		public var mcStateSelectedPassive:MovieClip;
		public var mcStateDropTarget:MovieClip;
		public var mcStateDropReady:MovieClip;
		public var mcColorBackground:ColorSprite;
		public var mcBackground:MovieClip;
		public var mcCantEquipIcon:MovieClip;
		
		protected var _indicators:Vector.<MovieClip>;
		protected var _imageLoader:W3UILoaderSlot;
		protected var _imageStub:UIComponent;
		protected var _loadedImagePath:String;
		protected var _data:Object; // ?
		protected var _index:uint;
		protected var _gridSize:int = 1;
		protected var _owner:UIComponent;
		protected var _currentIdicator:MovieClip;

		protected var _ownerFocused:Boolean;
		protected var _selected:Boolean;
		protected var _highlight:Boolean;
		protected var _over:Boolean;
		protected var _dropSelection:Boolean;
		protected var _dragSelection:Boolean;
		protected var _isEmpty:Boolean;
		protected var _isGamepad:Boolean;
		protected var _selectable:Boolean = true;
		protected var _imageLoaded:Boolean;

		protected var _isTargetsSelected:Boolean;
		
		protected var _glowFilter:GlowFilter;
		protected var _desaturateFilter:ColorMatrixFilter;
		protected var _warningFilter:ColorMatrixFilter;
		
		protected var _iconFilterTimer:Timer;
		protected var _defaultTooltipAnchor:String = "tooltipLeftAnchor";
		protected var _tooltipAlignment:String = "Right";
		
		protected var _showCollapsedTooltipIcon:Boolean;
		protected var _mcCollapsedTooltipIcon:MovieClip;
		
		public var awaitingCompleteValidation:Boolean = false;
		
		public function get showCollapsedTooltipIcon():Boolean { return _showCollapsedTooltipIcon; }
		public function set showCollapsedTooltipIcon(value:Boolean):void
		{
			if (_showCollapsedTooltipIcon != value)
			{
				var contextMgr:ContextInfoManager = ContextInfoManager.getInstanse();
				
				_showCollapsedTooltipIcon = value;
				
				if (_mcCollapsedTooltipIcon)
				{
					updateToggledToolipIcon();
					
					contextMgr.removeEventListener(ContextInfoManager.EVENT_TOOLTIP_HIDDEN, handleTooltipHidden);
					contextMgr.removeEventListener(ContextInfoManager.EVENT_TOOLTIP_SHOWN, handleTooltipShown);
					
					if (_showCollapsedTooltipIcon)
					{
						contextMgr.addEventListener(ContextInfoManager.EVENT_TOOLTIP_HIDDEN, handleTooltipHidden, false, 0, true);
						contextMgr.addEventListener(ContextInfoManager.EVENT_TOOLTIP_SHOWN, handleTooltipShown, false, 0, true);
					}
				}
			}
		}
		
		protected function handleTooltipHidden(event:Event):void
		{
			updateToggledToolipIcon();
		}
		
		protected function handleTooltipShown(event:Event):void
		{
			updateToggledToolipIcon();
		}
		
		protected function updateToggledToolipIcon():void
		{
			if (_mcCollapsedTooltipIcon)
			{
				var shouldShow:Boolean = _showCollapsedTooltipIcon && ContextInfoManager.getInstanse().isHidden() && enabled;
				var ownerIsInFocus:Boolean = _owner && (_owner.focused || !_owner.focusable);
				
				_mcCollapsedTooltipIcon.visible = shouldShow && ownerIsInFocus &&  _selected && _activeSelectionEnabled;
			}
		}
		
		
		/*
		 * 		- Properties -
		 */
		protected var _navigationUp:int;
		protected var _navigationRight:int;
		protected var _navigationDown:int;
		protected var _navigationLeft:int;
		
		[Inspectable(defaultValue = "0")]
		public function get navigationUp():int { return _navigationUp }
		public function set navigationUp( value:int ):void	{ _navigationUp = value; }
		
		[Inspectable(defaultValue = "0")]
		public function get navigationRight():int { return _navigationRight }
		public function set navigationRight( value:int ):void	{ _navigationRight = value; }
		
		[Inspectable(defaultValue = "0")]
		public function get navigationDown():int { return _navigationDown }
		public function set navigationDown( value:int ):void	{ _navigationDown = value; }
		
		[Inspectable(defaultValue = "0")]
		public function get navigationLeft():int {	return _navigationLeft	}
		public function set navigationLeft( value:int ):void { _navigationLeft = value; }

		[Inspectable(defaultValue = "1")]
		public function get gridSize():int { return _gridSize }
		public function set gridSize(value:int):void
		{
			_gridSize = value;
			invalidateSize();
		}

		[Inspectable(defaultValue = "true")]
		public function get selectable():Boolean { return _selectable; }
		public function set selectable(value:Boolean):void
		{
			_selectable = value;
		}

		public function get index():uint { return _index }
        public function set index(value:uint):void
		{
			_index = value;
		}

		protected var _draggingEnabled:Boolean = true;
		[Inspectable(defaultValue = "true")]
		public function get draggingEnabled():Boolean { return _draggingEnabled; }
		public function set draggingEnabled(value:Boolean):void
		{
			_draggingEnabled = value;
		}
		
		public function get selected():Boolean { return _selected }
        public function set selected(value:Boolean):void
		{
			if (_selected && _selected != value)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
			}
			
			_selected = value;
			
			if (mcSlotOverlays)
			{
				if (activeSelectionEnabled)
				{
					clearNewFlag();
				}
			}
			
			if ( selectingTooltipShowCheck() )
			{
				if (_selected)
				{
					showTooltip();
				}
				else
				{
					hideTooltip();
				}
			}
			
			invalidateState();
		}
		
		protected function selectingTooltipShowCheck():Boolean
		{
			return InputManager.getInstance().isGamepad();
		}
		
		public var _unprocessedNewFlagRemoval:Boolean = false;
		protected function clearNewFlag():void
		{
			if (_data && _data.hasOwnProperty("isNew") && _data.isNew)
			{
				_data.isNew = false;
				_unprocessedNewFlagRemoval = true;
				
				mcSlotOverlays.SetIsNew(false);
				mcSlotOverlays.updateIcons();
				dispatchEvent( new Event(NEW_FLAG_CLEARED) );
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnClearSlotNewFlag', [data.id] ) );
			}
		}

		public function get dragSelection():Boolean { return _dragSelection }
        public function set dragSelection(value:Boolean):void
		{
			_dragSelection = value;
			invalidateState();
			
			if (_dragSelection && _tooltipRequested)
			{
				fireTooltipHideEvent();
			}
			
			_over = false;
			invalidateState();
		}
		
		protected var _useContextMgr:Boolean = true;
		public function get useContextMgr():Boolean { return _useContextMgr }
		public function set useContextMgr(value:Boolean):void
		{
			_useContextMgr = value;
		}
		
		public function get owner():UIComponent { return _owner }
		public function set owner(value:UIComponent):void
		{
			if (_owner != value)
			{
				if (_owner)
				{
					_owner.removeEventListener(FocusEvent.FOCUS_IN, handelOwnerFocusIn);
					_owner.removeEventListener(FocusEvent.FOCUS_OUT, handelOwnerFocusOut);
				}
				_owner = value;
				
				if (_owner)
				{
					_owner.addEventListener(FocusEvent.FOCUS_IN, handelOwnerFocusIn, false, 0, true);
					_owner.addEventListener(FocusEvent.FOCUS_OUT, handelOwnerFocusOut, false, 0, true);
					_ownerFocused = _owner.focused > 0;
				}
			}
		}

		public function get data():* { return _data }
		public function set data(value:*):void
		{
			if (value)
			{
				_data = value;
				_isEmpty = false;
				
				awaitingCompleteValidation = true;
				
				gridSize = _data.gridSize;
				
				//if (!OPT_MODE)
				//{
					data_set_init();
				//}
			}
		}
		
		protected function data_set_init():void
		{
			if (selected && selectingTooltipShowCheck() )
			{
				fireTooltipShowEvent();
			}
			
			invalidateData();
			SlotsTransferManager.getInstance().addDragTarget(this);
		}

		protected var _activeSelectionEnabled:Boolean = true;
		public function get activeSelectionEnabled():Boolean
		{
			if (_activeSelectionEnabled)
			{
				var parentList:SlotsListBase = parent as SlotsListBase;
				if (!parentList || parentList.activeSelectionVisible)
				{
					return true;
				}
			}
			return false;
		}
		public function set activeSelectionEnabled(value:Boolean):void
		{
			_activeSelectionEnabled = value;
			invalidateState();
			
			///trace("GFX [SlotBase][", this, "] activeSelectionEnabled ", value, "; selected ", selected, "; ", isParentEnabled());
			
			if ( selectingTooltipShowCheck() )
			{
				if (value && selected && isParentEnabled())
				{
					fireTooltipShowEvent(false);
				}
				else
				{
					fireTooltipHideEvent(false)
				}
			}
			
			if (activeSelectionEnabled && selected)
			{
				clearNewFlag();
			}
		}

		protected function setBackgroundColor():void
		{
			mcColorBackground.setByItemQuality(_data.quality);
		}
		
		public function GetNavigationIndex( navDir : String ) : int
		{
			//trace("GFX GetNavigationIndex [", this, "]", navDir);
			//trace("GFX ", _navigationUp, _navigationRight, _navigationDown, _navigationLeft);
			
			switch( navDir )
			{
				case NavigationCode.UP:
					return _navigationUp;
				case NavigationCode.RIGHT:
					return _navigationRight;
				case NavigationCode.DOWN:
					return _navigationDown;
				case NavigationCode.LEFT:
					return _navigationLeft;
				default :
					return -1;
			}
		}

		public function cleanup():void
		{
			unloadIcon();

			var dragManager:SlotsTransferManager = SlotsTransferManager.getInstance();
			dragManager.removeDragTarget(this);

			_data = null;
			_isEmpty = true;
			
			if (selected)
			{
				if ( selectingTooltipShowCheck() )
				{
					hideTooltip();
				}
				else if (_tooltipRequested)
				{
					fireTooltipHideEvent();
				}
			}
			
			if (mcSlotOverlays)
			{
				mcSlotOverlays.visible = false;
				//mcSlotOverlays.SetQuantity("0");
				//mcSlotOverlays.updateSlots(0, 0);
			}
			if (mcColorBackground)
			{
				mcColorBackground.visible = false;
			}
			if (mcCantEquipIcon)
			{
				mcCantEquipIcon.visible = false
			}
			
			if (isOver() && !_isGamepad)
			{
				SlotsTransferManager.getInstance().hideDropTargets();
			}
			_over = false;
		}

		public function isEmpty():Boolean
		{
			return _isEmpty;
		}

		public function getHitArea():DisplayObject
		{
			return mcHitArea ? mcHitArea : this;
		}

		public function getAvatar():UILoader
		{
			if (_imageLoader)
			{
				return _imageLoader
			}
			return null;
		}

		public function canDrag():Boolean
		{
			return _draggingEnabled;
		}

		public function getDragData():*
		{
			return data;
		}

		public function executeAction(keyCode:Number, event:InputEvent):Boolean
		{
			//trace("GFX executeAction keyCode ", keyCode, canExecuteAction());
			if (canExecuteAction())
			{
				executeDefaultAction(keyCode, event);
				return true;
			}
			return false;
		}

		// Get slot rect in stage coordinate system
		public function getGlobalSlotRect():Rectangle
		{
			var targetRect:Rectangle = getSlotRect();
			var globalPoint:Point =	localToGlobal(new Point(targetRect.x, targetRect.y));
			targetRect.x = globalPoint.x + RECT_MARGIN;
			targetRect.y = globalPoint.y + RECT_MARGIN;
			return targetRect;
		}

		// Get visible slot's rect
		public function getSlotRect():Rectangle
		{
			var resultRect:Rectangle;
			if (mcSizeAnchor)
			{
				resultRect = new Rectangle(mcSizeAnchor.x, mcSizeAnchor.y, mcSizeAnchor.width, mcSizeAnchor.height);
			}
			else
			{
				var sideSize:Number = CommonConstants.INVENTORY_GRID_SIZE;
				resultRect = new Rectangle(0, 0, sideSize, sideSize * _gridSize);
			}
			return resultRect;
		}
		
		public function isOver():Boolean
		{
			return _over;
		}

		/*
		 * 			- CORE -
		 */

		public function SlotBase()
		{
			_isEmpty = true;
			
			if (!OPT_MODE)
			{
				constructor_init();
			}
		}
		
		protected function constructor_init_call():void{}
		protected function constructor_init():void
		{
			_indicators = new Vector.<MovieClip>;
			
			// not for sale, etc
			_warningFilter = CommonUtils.getRedWarningFilter();
			// selected
			_glowFilter = new GlowFilter(OVER_GLOW_COLOR, 1, OVER_GLOW_BLUR, OVER_GLOW_BLUR, OVER_GLOW_STRENGHT, BitmapFilterQuality.HIGH);
			// dragging
			_desaturateFilter = CommonUtils.getDesaturateFilter();
			
			if (OPT_MODE)
			{
				
			}
			
			if (mcCantEquipIcon) mcCantEquipIcon.visible = false;
			if (mcColorBackground) mcColorBackground.visible = false;
			if (mcSlotOverlays) mcSlotOverlays.visible = false;
		
			if (mcStateSelectedActive) _indicators.push(mcStateSelectedActive);
			if (mcStateSelectedPassive) _indicators.push(mcStateSelectedPassive);
			if (mcStateDropTarget) _indicators.push(mcStateDropTarget);
			if (mcStateDropReady) _indicators.push(mcStateDropReady);
			
			var len:int = _indicators.length;
			for (var i:int; i < len; i++)
			{
				var curItem:MovieClip = _indicators[i];
				curItem.mouseEnabled = false;
				curItem.mouseChildren = false;
				curItem.alpha = 0;
			}
			//if (mcHitArea) _indicators.push(mcHitArea);
			
			if (mcSlotOverlays)
			{
				_mcCollapsedTooltipIcon = mcSlotOverlays.mcCollapsedTooltipIcon;
			}
			
			initCollapsedIconBehavior();
		}
		
		protected function initCollapsedIconBehavior():void
		{
			if (AUTO_SHOW_COLLAPSED_ICON && _mcCollapsedTooltipIcon)
			{
				showCollapsedTooltipIcon = true;
			}
		}
		
		protected function resetIndicators():void
		{
			var len:int = _indicators.length;
			for (var i:int; i < len; i++)
			{
				var curItem:MovieClip = _indicators[i];
				GTweener.removeTweens(curItem);
				curItem.alpha = 0;
			}
		}

		override protected function configUI():void
		{
			super.configUI();
			
			if (!OPT_MODE)
			{
				config_init_call();
			}
		}
		
		protected function config_init_call()
		{
			doubleClickEnabled = true;
			var hitArea:MovieClip = getHitArea() as MovieClip;
			
			hitArea.doubleClickEnabled = true;
			hitArea.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true);
			hitArea.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
			hitArea.addEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick, false, 0, true);
			hitArea.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true);
			
			_isGamepad = InputManager.getInstance().isGamepad();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}
		
		// SHOULD BE USED IN STAGE SPACE
		protected var _validationBounds:Rectangle = null;
		public function set validationBounds(value:Rectangle):void
		{
			_validationBounds = value;
		}
		
		public function canBeValidated():Boolean
		{
			return _validationBounds == null || getBounds(stage).intersects(_validationBounds);
			//return _validationBounds == null || getGlobalSlotRect().intersects(_validationBounds);
		}
		
		protected var initValidation:Boolean = false;
		
		override public function validateNow(event:Event = null):void
		{
			if ((!initialized || _invalid) && canBeValidated())
			{
				if (!initValidation)
				{
					initValidation = true;
					
					if (OPT_MODE)
					{
						constructor_init();
						config_init_call();
						data_set_init();
					}
				}
				
				super.validateNow();
			}
		}
		
		protected var _forceNextValidation:Boolean = false;
		public function forceValidateNow():void
		{
			_forceNextValidation = true;
			super.validateNow();
		}
		
		override protected function draw():void
		{
			var canValidate:Boolean = _validationBounds == null || getBounds(stage).intersects(_validationBounds);
			
			if (_forceNextValidation)
			{
				_forceNextValidation = false;
				canValidate = true;
			}
			
			if (canValidate)
			{
				awaitingCompleteValidation = false;
				super.draw();
				
				if (isInvalid(InvalidationType.DATA) && _data)
				{
					updateData();
				}
				if (isInvalid(InvalidationType.STATE))
				{
					updateState();
				}
				if (isInvalid(InvalidationType.SIZE))
				{
					updateSize();
				}
			}
		}

		override public function set enabled(value:Boolean):void
		{
			if (!value && _tooltipRequested)
			{
				hideTooltip();
			}
			super.enabled = value;
			invalidateState();
		}

		/*
		 * 			- Handlers -
		 */
		
		
		protected function handleMouseOver(event:MouseEvent):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			//trace("GFX [SLOT handleMouseOver][", this, "]; _over: ", _over, "; _isEmpty: ", _isEmpty, "; isGamepad: ", isGamepad);
			
			if (useContextMgr && !isGamepad)
			{
				updateMouseContext();
			}
			
			if (!_over && !isGamepad && selectable && !SlotsTransferManager.getInstance().isDragging())
			{
				_over = true;
				fireTooltipShowEvent(true);
			}
			
			invalidateState();
		}

		protected function handleMouseOut(event:MouseEvent):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			//trace("GFX [SLOT handleMouseOut][", this, "]; _over: ", _over, "; _isEmpty: ", _isEmpty, "; isGamepad: ", isGamepad);
			if (_over && !isGamepad && selectable && !SlotsTransferManager.getInstance().isDragging())
			{
				_over = false;
				fireTooltipHideEvent(true);
			}
			invalidateState();
		}
		
		protected function handleMouseDown(event:MouseEvent):void
		{
			// virtual
		}
		
		protected function updateMouseContext():void
		{
			// virtual
		}
		
		protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				if (canExecuteAction())
				{
					executeDefaultAction(KeyCode.PAD_A_CROSS, null);
				}
			}
		}
		
		protected function handleMouseClick(event:MouseEvent):void
		{
			
		}
		
		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			_isGamepad = event.isGamepad;
			invalidateState();
		}

		protected function handelOwnerFocusIn(event:FocusEvent):void
		{
			_ownerFocused = true;
			invalidateState();
		}

		protected function handelOwnerFocusOut(event:FocusEvent):void
		{
			_ownerFocused = false;
			invalidateState();
		}

		// We use pending because of problem with data transfering during one tick
		public function showTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] TP [", this.index, "] <", owner, "> showTooltip; parent enabled: ", isParentEnabled());
			if (selectingTooltipShowCheck() && isParentEnabled())
			{
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipShow, false, 0, true);
			}
		}
		
		public function hideTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] TP [", this.index, "] <", owner, "> hideTooltip; parent enabled: ", isParentEnabled());
			if (selectingTooltipShowCheck() && isParentEnabled())
			{
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipHide, false, 0, true);
			}
		}

		protected function pendedTooltipShow(event:Event):void
		{
			//trace("GFX [SlotBase][", this, "] TP pendedTooltipShow ", selectable, "]--");
			removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
			if (selectable)
			{
				fireTooltipShowEvent(false);
			}
		}
		protected function pendedTooltipHide(event:Event):void
		{
			//trace("GFX [SlotBase][", this, "] TP pendedTooltipHide ", selectable, "]--");
			removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
			if (selectable)
			{
				fireTooltipHideEvent(false);
			}
		}

		protected var _tooltipRequested:Boolean;
		protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			if ((activeSelectionEnabled || !_isGamepad) && _data && isParentEnabled())
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				displayEvent.defaultAnchor = _defaultTooltipAnchor;
				displayEvent.tooltipAlignment = CommonConstants.ALIGNMENT_RIGHT;
				
				if (!_data.showExtendedTooltip)
				{
					displayEvent.tooltipContentRef = "ItemDescriptionTooltipRef";
				}
				
				displayEvent.tooltipMouseContentRef = "ItemTooltipRef_mouse";
				
				dispatchEvent(displayEvent);
				_tooltipRequested = true;
				
				clearNewFlag();
			}
		}
		protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase][", this, "] fireTooltipHideEvent ", isMouseTooltip, _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}

		/*
		 *  		- Data and size updating -
		 */

		protected function updateState():void
		{
			if (!enabled)
			{
				if (_currentIdicator)
				{
					_currentIdicator.visible = false;
					_currentIdicator = null;
				}
				if (mcFrame)
				{
					mcFrame.alpha = DISABLE_ALPHA;
				}
				updateImageLoaderStates();
				updateToggledToolipIcon();
				return;
			}
			if (mcFrame)
			{
				mcFrame.alpha = 1;
			}
			
			// Indicators
			
			var newIndicator:MovieClip = getTargetIndicator();
			var tweenPropsShow:Object = { alpha:1 };
			
			if (newIndicator != _currentIdicator)
			{
				if (_currentIdicator)
				{
					var tweenPropsHide:Object = { alpha:0 };
					GTweener.removeTweens(_currentIdicator);
					GTweener.to(_currentIdicator, INDICATE_ANIM_DURATION, tweenPropsHide, { ease:Strong.easeOut } );
				}
				_currentIdicator = newIndicator;
				if (_currentIdicator)
				{
					_currentIdicator.visible = true;
					_currentIdicator.alpha = 0;
					GTweener.removeTweens(_currentIdicator);
					GTweener.to(_currentIdicator, INDICATE_ANIM_DURATION, tweenPropsShow, { ease:Strong.easeOut } );
				}
			}
			else if (_currentIdicator && (_currentIdicator.visible == false || _currentIdicator.alpha == 0))
			{
				_currentIdicator.visible = true;
				_currentIdicator.alpha = 0;
				GTweener.removeTweens(_currentIdicator);
				GTweener.to(_currentIdicator, INDICATE_ANIM_DURATION, tweenPropsShow, { ease:Strong.easeOut } );
			}
			
			updateImageLoaderStates();
			updateToggledToolipIcon();
		}
		
		protected function updateImageLoaderStates():void
		{
			if (_imageLoader && _imageLoaded)
			{
				var filterArray:Array = [];
				var overState:Boolean = _over && !_isGamepad && !_isEmpty;
				if (!_dragSelection &&!_currentIdicator && overState)
				{
					filterArray.push(_glowFilter);
				}
				if (_data && _data.disableAction)
				{
					filterArray.push(_warningFilter);
					_imageLoader.alpha = DISABLED_ACTION_ALPHA;
				}
				else if (_dragSelection)
				{
					filterArray.push(_desaturateFilter);
					_imageLoader.alpha = DRAG_ALPHA;
				}
				else if (_data && _data.isReaded)
				{
					//filterArray.push(_desaturateFilter);
					_imageLoader.alpha = BOOK_READED_ALPHA;
				}
				else
				{
					_imageLoader.alpha = 1;
				}
				_imageLoader.filters = filterArray;
			}
		}

		protected function updateData()
		{
			if (_data)
			{
				if (mcCantEquipIcon)
				{
					mcCantEquipIcon.visible = _data.cantEquip;
				}
				if (mcSlotOverlays)
				{
					mcSlotOverlays.visible = true;
					mcSlotOverlays.updateSlots(_data.socketsCount, _data.socketsUsedCount);
					
					// data.highlighted.setIsPinned(data.highlighted);
					
					if (_data.charges)
					{
						mcSlotOverlays.SetQuantity(_data.charges);
					}
					else
					{
						mcSlotOverlays.SetQuantity(_data.quantity);
					}
					
					mcSlotOverlays.setPreviewIcon(_data.isPreviewItem);
					mcSlotOverlays.setOilApplied(_data.isOilApplied);
					mcSlotOverlays.SetNeedRepair(_data.needRepair);
					mcSlotOverlays.SetIsNew(_data.isNew);
					mcSlotOverlays.SetIsQuestItem(_data.isQuest , _data.questTag);
					
					
					mcSlotOverlays.SetEnchantment(_data.enchanted, _data.socketsCount);
					mcSlotOverlays.SetAppliedDyeColor(_data.itemColor);
					mcSlotOverlays.SetDyePreview(_data.isDyePreview);
					
					mcSlotOverlays.updateIcons();
				}
				if (mcColorBackground)
				{
					if (_data.quality)
					{
						mcColorBackground.visible = true;
						setBackgroundColor();
						mcColorBackground.colorBlind = CoreComponent.isColorBlindMode;
					}
				}
				
				if (_data.iconPath != "")
				{
					if (_loadedImagePath != _data.iconPath || _imageLoader == null)
					{
						_loadedImagePath = _data.iconPath;
						loadIcon(_loadedImagePath);
					}
				}
				else
				{
					unloadIcon();
				}
			}
		}

		// Virtual. Depends on control's type
		protected function updateSize()	{}

		protected function getTargetIndicator():MovieClip
		{
			/*
			trace("GFX * _dropSelection ", _dropSelection);
			trace("GFX * _highlight ", _highlight);
			trace("GFX * _selected ", _selected);
			trace("GFX * _owner.focused ", _owner.focused);
			trace("GFX * _owner.focusable ", _owner.focusable);
			*/
			
			if (_selected)
			{
				if (_owner && (_owner.focused || !_owner.focusable) && _activeSelectionEnabled)
				{
					return mcStateSelectedActive;
				}
			}
			
			if (_highlight && mcStateDropReady)
			{
				return mcStateDropReady;
			}
			
			if (_dropSelection)
			{
				return mcStateDropTarget;
			}
			
			if (_selected && _isGamepad)
			{
				return mcStateSelectedPassive;
			}
			
			return null;
		}

		protected function loadIcon(iconPath:String):void
		{
			unloadIcon();
			_imageLoader = new W3UILoaderSlot();
			if (_data) { _imageLoader.slotType = _data.slotType; }
			_imageLoader.maintainAspectRatio = false;
			_imageLoader.autoSize = false;
			_imageLoader.addEventListener(Event.COMPLETE, handleIconLoaded, false, 0, true);
			_imageLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadIOError, false, 0, true );
			_imageLoader.source = iconPath;
			_imageLoader.mouseChildren = false;
			_imageLoader.mouseEnabled = false;
			addChild(_imageLoader);
			
			if (mcCantEquipIcon)
			{
				addChild(mcCantEquipIcon);
			}
			
			if (mcStateSelectedActive)
			{
				addChild(mcStateSelectedActive);
			}
			
			if (mcSlotOverlays)
			{
				addChild(mcSlotOverlays);
			}
			
			if (mcHitArea)
			{
				addChild(mcHitArea);
			}
		}

		protected function unloadIcon():void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				_imageLoader.removeEventListener(Event.COMPLETE, handleIconLoaded);
				removeChild(_imageLoader);
				_imageLoader = null;
				_loadedImagePath = "";
			}
			if (_imageStub)
			{
				removeChild(_imageStub);
				_imageStub = null;
			}
			if (_imageLoaded)
			{
				GTweener.removeTweens(_imageLoader);
			}
			_imageLoaded = false;
		}

		public function desaturateIcon(amount:Number):void
		{
			this.filters = [CommonUtils.generateDesaturationFilter(amount)];
		}

		public function darkenIcon(amount:Number):void
		{
			this.filters = [CommonUtils.generateDarkenFilter(amount)];
		}

		protected function handleLoadIOError(event:Event):void
		{
			try
			{
				var StubIconRef:Class = getDefinitionByName(NO_IMAGE_SPRITE_REF) as Class;
				_imageStub = new StubIconRef() as UIComponent;
				addChild(_imageStub);
				fitImage(_imageStub);
			}
			catch (er:Error)
			{
			}
		}
		
		protected function handleIconLoaded(event:Event):void
		{
			var image:Bitmap = Bitmap(event.target.content);
			if (image)
			{
				image.smoothing = true;
				image.pixelSnapping = PixelSnapping.NEVER;
			}
			if (_imageLoader)
			{
				fitImage(_imageLoader);
			}
			if (_iconFilterTimer)
			{
				_iconFilterTimer.stop();
				_iconFilterTimer.removeEventListener(TimerEvent.TIMER, handleIconFilter, false);
			}
			
			_iconFilterTimer = new Timer(ICON_FILTER_TIMER, 1);
			_iconFilterTimer.addEventListener(TimerEvent.TIMER, handleIconFilter, false, 0, true);
			_iconFilterTimer.start();
		}
		
		protected function handleIconFilter(event:TimerEvent):void
		{
			_imageLoaded = true;
			if (_iconFilterTimer)
			{
				_iconFilterTimer.stop();
				_iconFilterTimer.removeEventListener(TimerEvent.TIMER, handleIconFilter, false);
				_iconFilterTimer = null;
			}
			updateImageLoaderStates();
		}

		protected function fitImage(targetImage:UIComponent):void
		{
			var targetRect:Rectangle = getSlotRect();
			var scaleFactor:Number;
			var sizingX:Number =  targetRect.width / targetImage.actualWidth;
			var sizingY:Number =  targetRect.height / targetImage.actualHeight;
			var sizing:Number = Math.min(sizingX, sizingY);

			targetImage.scaleX = targetImage.scaleY = sizing;
			targetImage.x = targetRect.x + (targetRect.width - targetImage.actualWidth) / 2;
			targetImage.y = targetRect.y + (targetRect.height - targetImage.actualHeight) / 2;
			
			/*
			 * TODO: Implement scaling
			if (_imageLoader && _imageLoader.content)
			{
				_imageLoader.content.scaleX = _imageLoader.content.scaleY = _selected ? 1 : .9;
			}
			*/
		}

		protected function canExecuteAction():Boolean
		{
			return _data && !_isEmpty;
		}

		protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			if (!canExecuteAction()) return;

			//var er:Error = new Error();
			//trace("GFX Slot [", index, "] executeDefaultAction ", _data.actionType, "; keyCode ", keyCode/*, er.getStackTrace()*/);
			//trace("GFX Slot [", index, "] executeDefaultAction ", _data);

			if (keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.E || keyCode == KeyCode.SPACE)
			{
				if (!_data)
				{
					return;
				}
				
				if (event)
					event.handled = true;

				fireActionEvent(_data.actionType);
				//trace("GFX - Executing action type: ", _data.actionType);
				switch (_data.actionType)
				{
					case InventoryActionType.EQUIP:
						defaultSlotEquipAction(_data);
						break;
					case InventoryActionType.CONSUME:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConsumeItem', [_data.id ] ));
						break;
					case InventoryActionType.READ:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnReadBook', [_data.id ] ));
					case InventoryActionType.DROP:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDropItem', [_data.id, _data.quantity ] ));
						break;
					case InventoryActionType.TRANSFER:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTransferItem', [_data.id, _data.quantity, -1 ] ));
						break;
					case InventoryActionType.SELL:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSellItem', [_data.id, _data.quantity ] ));
						break;
					case InventoryActionType.BUY:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBuyItem', [_data.id, _data.quantity, -1 ] ));
						break;
					case InventoryActionType.REPAIR:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRepairItem', [_data.id ] ));
						break;
					case InventoryActionType.SOCKET:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPutInSocket', [_data.id] ));
						break;
				}
			}
			else
			if (keyCode == KeyCode.PAD_Y_TRIANGLE)
			{
				// TODO: Check it in the WS
				if (
					_data.slotType != InventorySlotType.Potion1 &&
					_data.slotType != InventorySlotType.Potion2 &&
					_data.slotType != InventorySlotType.Petard1 &&
					_data.slotType != InventorySlotType.Petard2 &&
					_data.slotType != InventorySlotType.Quickslot1 &&
					_data.slotType != InventorySlotType.Quickslot2
				)
				{
					defaultSlotDropAction(_data);
				}
				fireActionEvent(InventoryActionType.DROP);
			}
			else
			if (keyCode == KeyCode.PAD_X_SQUARE)
			{
				fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
			}
		}

		// overrided for other slots
		protected function defaultSlotEquipAction(itemData:Object):void
		{
			//trace("GFX defaultSlotEquipAction itemData.slotType ", itemData.slotType, itemData.id);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItem', [itemData.id, itemData.slotType, itemData.quantity ] ));
		}

		// overrided for other slots
		protected function defaultSlotDropAction(itemData:Object):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDropItem', [itemData.id, itemData.quantity ] ));
		}

		protected function fireActionEvent(actionType:int, eventName:String = "event_activate", isMouseEvent:Boolean = false):void
		{
			//trace("GFX fireActionEvent from slot [ ", this, "] eventName: ", eventName);
			
			var activateEvent:SlotActionEvent = new SlotActionEvent(eventName, true);
			
			activateEvent.actionType = actionType;
			activateEvent.targetSlot = this;
			activateEvent.isMouseEvent = isMouseEvent;
			dispatchEvent(activateEvent);
		}

		override public function toString():String
		{
			return 	"Slot [ " + this.name + ", activeSel: " + activeSelectionEnabled + " ]";
		}
		
		override public function get scaleX():Number
		{
			return super.actualScaleX;
		}
		
		override public function get scaleY():Number
		{
			return super.actualScaleY;
		}
		
		protected function isParentEnabled():Boolean
		{
			var ownerList:UIComponent = owner as UIComponent;
			return ownerList ? ownerList.enabled : true;
		}
		
		// For copatibility with ListItemRenderer
		public function setListData(listData:ListData):void { }
        public function setData(value:Object):void { data = value;  }
	}
}
