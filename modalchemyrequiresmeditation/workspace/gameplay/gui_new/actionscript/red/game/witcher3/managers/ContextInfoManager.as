package red.game.witcher3.managers
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.plugins.ColorTransformPlugin;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.TooltipData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.interfaces.IAnchorable;
	import red.game.witcher3.interfaces.ITooltipHolder;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common.W3VideoObject;
	import red.game.witcher3.tooltips.TooltipBase;
	import red.game.witcher3.tooltips.TooltipInventory;
	import red.game.witcher3.tooltips.TooltipStatistic;
	import red.game.witcher3.tooltips.TooltipText;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.motion.Tween;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;

	/**
	 * Manager for tooltips and context menus
	 * @author Yaroslav Getsevich
	 */
	public class ContextInfoManager extends EventDispatcher
	{
		// scale / visibility states
		protected var _holdTriggered:Boolean = false;
		protected var _upscaleMePlease:Boolean = false;
		public const MAX_ZOOM:Number = 1.3;
		public const NORMAL_SCALE:Number = 1;
		
		public static const EVENT_TOOLTIP_HIDDEN:String = "EVENT_TOOLTIP_HIDDEN";
		public static const EVENT_TOOLTIP_SHOWN:String = "EVENT_TOOLTIP_SHOWN";
		
		private static const COLLAPSED_TOOLTIP_ICON_REF:String = "IcoTooltipCollapsedRef";
		
		public static var TOOLTIPS_DELAY:Number = 450; //300;
		public static var TOOLTIPS_DELAY_MOUSE:Number = 450; //100;
		
		public var saveScaleValue 			: Boolean = true;
		public var blockModeSwitching 		: Boolean = false;
		public var isArabicAligmentMode 	: Boolean;
		public var _DBG_LOCK_MOUSE_TOOLTIP  : Boolean = true;
		
		public static const TOOLTIP_SHOW_ERROR:String = "FailedToSetTooltip";
		
		public var dataSetterCallback:Function;
		public var handleTooltipVisibilityToggled:Function;
		
		protected static const SHOW_ANIM_DURATION:Number = .8;
		protected static const HIDE_ANIM_DURATION:Number = .8;
		protected static var _instanse:ContextInfoManager;
		
		private var _rootCanvas:Sprite;
		private var _tooltipTimer:Timer;
		
		// For current tooltip
		protected var _tooltip:TooltipBase;
		protected var _data:TooltipData;
		
		protected var _pospondedData:TooltipData;
		protected var _pospondedKeyValue:Array;
		
		protected var _initialized:Boolean;
		protected var _inputMgr:InputManager;
		protected var _defaultAnchor:DisplayObject;
		protected var _comparisonMode:Boolean;
		protected var _overridedMouseDataSource:String;
		
		private var _blocked:Boolean;
		private var _isHiddenState:Boolean;
		private var _enableInputFeedback:Boolean;
		
		private var _btn_zoom_tooltip_kb	: int = -1;
		private var _btn_zoom_tooltip_gp	: int = -1;
		private var _btn_show_tooltip  		: int = -1;
		private var _btn_hide_tooltip  		: int = -1;
		
		public static function getInstanse():ContextInfoManager
		{
			if (!_instanse) _instanse = new ContextInfoManager();
			return _instanse;
		}
		
		public function blockTooltips(value:Boolean, resetEntity:Boolean = false):void
		{
			if (_blocked != value)
			{
				_blocked = value;
				
				if (_tooltip)
				{
					if (resetEntity)
					{
						removeCurrentTooltip();
					}
					else
					{
						_tooltip.visible = !value;
					}
				}
			}
		}
		
		public function enableInputFeedbackShowing( value : Boolean, noUpdate:Boolean = false ):void
		{
			_enableInputFeedback = value;
			
			handleTooltipToggled(noUpdate);
		}
		
		public function isHidden():Boolean
		{
			return _isHiddenState;
		}
		
		public function setHiddenState(value:Boolean):void
		{
			if (_isHiddenState != value)
			{
				_isHiddenState = value;
				
				handleTooltipToggled();
				
				if (_tooltip)
				{
					_tooltip.setVisibility(!value);
				}
				
				if (handleTooltipVisibilityToggled != null)
				{
					handleTooltipVisibilityToggled(!_isHiddenState);
				}
				
				if (_isHiddenState)
				{
					//trace("GFX ------------------------------------------------ ContextInfoManager.EVENT_TOOLTIP_HIDDEN");
					dispatchEvent( new Event( ContextInfoManager.EVENT_TOOLTIP_HIDDEN ) );
				}
				else
				{
					//trace("GFX ------------------------------------------------ ContextInfoManager.EVENT_TOOLTIP_SHOWN");
					dispatchEvent( new Event( ContextInfoManager.EVENT_TOOLTIP_SHOWN ) );
				}
			}
		}
		
		public function init(canvas:Sprite, inputManager:InputManager ):void
		{
			_inputMgr = inputManager;
			_inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			_rootCanvas = canvas;
			_rootCanvas.dispatchEvent( new GameEvent( GameEvent.REGISTER, "context.tooltip.data", [dataReceiver] ) );
			_rootCanvas.dispatchEvent( new GameEvent( GameEvent.REGISTER, "statistic.tooltip.data", [dataReceiverStat] ) );
			_rootCanvas.addEventListener(Event.ENTER_FRAME, handleCanvasTick, false, 0, true);
			_rootCanvas.stage.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true)
			
			handleTooltipToggled();
		}
		
		public function get defaultAnchor():DisplayObject { return _defaultAnchor }
		public function set defaultAnchor(value:DisplayObject):void
		{
			_defaultAnchor = value;
		}
		
		public function get comparisonMode():Boolean { return _comparisonMode }
		public function set comparisonMode(value:Boolean):void
		{
			if (_comparisonMode != value)
			{
				_comparisonMode = value;
				updateComparisonMode();
			}
		}
		
		public function get overridedMouseDataSource():String { return _overridedMouseDataSource }
		public function set overridedMouseDataSource(value:String):void
		{
			_overridedMouseDataSource = value;
		}
		
		
		protected function updateComparisonMode():void
		{
			var currentInventoryTooltip:TooltipInventory = _tooltip as TooltipInventory;
			if (currentInventoryTooltip)
			{
				currentInventoryTooltip.showEquippedTooltip(comparisonMode);
			}
		}
		
		protected function handleCanvasTick(event:Event):void
		{
			_initialized = true;
			_rootCanvas.removeEventListener(Event.ENTER_FRAME, handleCanvasTick);
			if (_pospondedData && _pospondedKeyValue)
			{
				showTooltip(_pospondedKeyValue, _pospondedData);
				_pospondedData = null;
				_pospondedKeyValue = null;
			}
		}
		
		public function handleTooltipToggled(noUpdate:Boolean = false ):void
		{
			trace("GFX handleTooltipToggled; noUpdate ", noUpdate);
			
			if (!_rootCanvas)
			{
				return;
			}
			
			trace("GFX _enableInputFeedback ", _enableInputFeedback, "; noUpdate", noUpdate);
			
			if (_enableInputFeedback)
			{
				if (!_isHiddenState)
				{
					if (_btn_show_tooltip == -1)
					{
						_btn_show_tooltip = InputFeedbackManager.appendButton(_rootCanvas, NavigationCode.GAMEPAD_LSTICK_HOLD, -1, "input_tooltip_hide");
					}
					
					if (_btn_hide_tooltip != -1)
					{
						InputFeedbackManager.removeButton(_rootCanvas, _btn_hide_tooltip);
						_btn_hide_tooltip = -1;
					}
				}
				else
				{
					if (_btn_hide_tooltip == -1)
					{
						_btn_hide_tooltip = InputFeedbackManager.appendButton(_rootCanvas, NavigationCode.GAMEPAD_LSTICK_HOLD, -1, "input_tooltip_show");
					}
					
					if (_btn_show_tooltip != -1)
					{
						InputFeedbackManager.removeButton(_rootCanvas, _btn_show_tooltip);
						_btn_show_tooltip = -1;
					}
				}
				
				if (_btn_zoom_tooltip_gp == -1)
				{
					_btn_zoom_tooltip_gp = InputFeedbackManager.appendButton(_rootCanvas, NavigationCode.GAMEPAD_LSTICK_HOLD, -1, "input_tooltip_zoom", true);
				}
				
				if (_btn_zoom_tooltip_kb == -1)
				{
					_btn_zoom_tooltip_kb = InputFeedbackManager.appendButton(_rootCanvas, "", KeyCode.MIDDLE_MOUSE, "input_tooltip_zoom");
				}
			}
			else
			{
				if (_btn_zoom_tooltip_kb != -1)
				{
					InputFeedbackManager.removeButton(_rootCanvas, _btn_zoom_tooltip_kb);
					_btn_zoom_tooltip_kb = -1;
				}
				
				if (_btn_zoom_tooltip_gp != -1)
				{
					InputFeedbackManager.removeButton(_rootCanvas, _btn_zoom_tooltip_gp);
					_btn_zoom_tooltip_gp = -1;
				}
				
				if (_btn_show_tooltip != -1)
				{
					InputFeedbackManager.removeButton(_rootCanvas, _btn_show_tooltip);
					_btn_show_tooltip = -1;
				}
				
				if (_btn_hide_tooltip != -1)
				{
					InputFeedbackManager.removeButton(_rootCanvas, _btn_hide_tooltip);
					_btn_hide_tooltip = -1;
				}
			}
			
			if (!noUpdate)
			{
				InputFeedbackManager.updateButtons(_rootCanvas);
			}
		}
		
		
		//#Y HAX; Stats only, REFACT
		public function dataReceiverStat(value:Object):void
		{
			if (_tooltip as TooltipStatistic)
			{
				_tooltip.data = value;
			}
		}
		
		public function dataReceiver(value:Object):void
		{
			if (_tooltip)
			{
				_tooltip.data = value;
				_tooltip.validateNow();
				updateComparisonMode();
			}
			else
			{
				dispatchEvent(new Event(ContextInfoManager.TOOLTIP_SHOW_ERROR, true, false));
			}
			
			if (dataSetterCallback != null)
			{
				dataSetterCallback(value);
			}
		}
		
		/**
		 * 	For old tooltips system, use GridEvent like data source, but
		 * 	We also use this system now with some changes, probably
		 * 	we need to refact other parts of this manager
		 */
		protected var _gridEventsMouseOnly:Boolean;
		public function addGridEventsTooltipHolder(target:EventDispatcher, mouseOnly:Boolean = false):void
		{
			_gridEventsMouseOnly = mouseOnly;
			target.addEventListener(GridEvent.DISPLAY_TOOLTIP, pospondedTooltipShow, false, 0, true);
			target.addEventListener(GridEvent.HIDE_TOOLTIP, handleTooltipHideEvent, false, 0, true);
		}
		
		public function removeGridEventsTooltipHolder(target:EventDispatcher):void
		{
			target.removeEventListener(GridEvent.DISPLAY_TOOLTIP, pospondedTooltipShow);
			target.removeEventListener(GridEvent.HIDE_TOOLTIP, handleTooltipHideEvent);
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if (!event.isGamepad)
			{
				setHiddenState(false);
			}
			removeCurrentTooltip();
		}
		
		// Hack to avoid prolem with data passing from WS
		// TODO: Investigate it
		protected var bufGridEvent:GridEvent;
		protected function pospondedTooltipShow(event:GridEvent):void
		{
			var isGamepad:Boolean = _inputMgr.isGamepad();
			
			if (!_gridEventsMouseOnly || !isGamepad)
			{
				bufGridEvent = event;
				handleTooltipHideEvent();
				
				_tooltipTimer = new Timer(isGamepad ? TOOLTIPS_DELAY : TOOLTIPS_DELAY_MOUSE , 1);
				_tooltipTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showTooltipTimerEnded);
				_tooltipTimer.start();
			}
		}
		
		protected function showTooltipTimerEnded( event : TimerEvent ) : void
		{
			handleTooltipShowEvent(bufGridEvent);
		}
		
		protected function handleTooltipShowEvent(event:GridEvent):void
		{
			var tooltipData 	: Object = event.itemData as Object;
			var compareItem 	: int;
			var dataObject  	: TooltipData = new TooltipData();
			var keyArgs			: Array;
			var targetConentRef : String;
			
			if (_gridEventsMouseOnly && _inputMgr.isGamepad())
			{
				return;
			}
			
			if( tooltipData != null )
			{
				if( event.directData == false )
				{
					if ( tooltipData.equipped == 0 )
					{
						compareItem = tooltipData.slotType;
					}
					else
					{
						compareItem = -1;
					}
				}
			}
			else if (!event.tooltipCustomArgs)
			{
				handleHideTooltip();
				return;
			}
			
			dataObject.alignment = event.tooltipAlignment;
			dataObject.isMouseTooltip = event.isMouseTooltip;
			dataObject.anchorRect = event.anchorRect;
			dataObject.directData = event.directData;
			dataObject.defaultAnchorName = event.defaultAnchor;
			
			if ( event.directData == true )
			{
				dataObject.description = tooltipData.description;
				dataObject.label = tooltipData.label;
			}
			
			dataObject.dataSource = event.tooltipDataSource ? event.tooltipDataSource : "OnGetItemData";
			dataObject.anchor = _defaultAnchor;
			
			if (event.isMouseTooltip)
			{
				targetConentRef = event.tooltipMouseContentRef ? event.tooltipMouseContentRef : event.tooltipContentRef;
				
				if (overridedMouseDataSource && !event.tooltipForceSetDataSource)
				{
					dataObject.dataSource = overridedMouseDataSource;
				}
			}
			else
			{
				targetConentRef = event.tooltipContentRef;
			}
			
			// #Y TMP PROTO; ALWAYS DISPLAY MOUSE TOOLTIP
			//if (_DBG_LOCK_MOUSE_TOOLTIP)
			//{
				targetConentRef = event.tooltipMouseContentRef ? event.tooltipMouseContentRef : event.tooltipContentRef;
			//}
			//
			
			dataObject.viewerClass = targetConentRef ? targetConentRef : "ItemTooltipRef";
			
			if (event.tooltipCustomArgs)
			{
				keyArgs = event.tooltipCustomArgs;
			}
			else
			{
				if ( event.directData == false )
				{
					keyArgs = [uint(tooltipData.id), compareItem];
				}
			}
			showTooltip(keyArgs, dataObject);
			event.stopImmediatePropagation();
		}

		protected function handleTooltipHideEvent(event:GridEvent = null):void
		{
			if (_tooltipTimer)
			{
				_tooltipTimer.stop();
			}
			removeCurrentTooltip();
		}

		/*
		 * Underhood
		 */

		protected function showTooltip(keyValues:Array, dataObject:TooltipData):void
		{
			removeCurrentTooltip();
			
			if (_blocked)
			{
				return;
			}
			
			if (_initialized && dataObject.directData  == false )
			{
				_rootCanvas.dispatchEvent( new GameEvent(GameEvent.CALL, dataObject.dataSource, keyValues));
			}
			else
			{
				_pospondedData = dataObject;
				_pospondedKeyValue = keyValues;
			}
			
			var instance:TooltipBase = getDefinition(dataObject.viewerClass) as TooltipBase;
			
			// #Y TMP PROTO; ALWAYS DISPLAY MOUSE TOOLTIP
			// For now inventory only
			if (_DBG_LOCK_MOUSE_TOOLTIP || dataObject.viewerClass == "ItemTooltipRef_mouse" || dataObject.viewerClass == "ItemTooltipRef")
			{
				instance.isMouseTooltip = true;
				instance.backgroundVisibility = true;
				instance.tooltipAlignment = dataObject.alignment;
			}
			//instance.scaleX = instance.scaleY = 1.3;
			// -------
			
			if (dataObject.isMouseTooltip)
			{
				// #Y TMP PROTO; ALWAYS DISPLAY MOUSE TOOLTIP
				/*
				var tmpRect:Rectangle = dataObject.anchorRect;
				tmpRect.x = _defaultAnchor.x;
				dataObject.anchorRect = tmpRect;
				*/
				//--
				
				instance.anchorRect = dataObject.anchorRect;
				instance.isMouseTooltip = true;
				instance.backgroundVisibility = true;
			}
			else
			{
				// ---- PROTO
				// try get default anchor from slot info
				// var defAnchorRect:Rectangle = new Rectangle(_defaultAnchor.x, dataObject.anchorRect.y, 0, 0);
				// var defAnchorRect:Rectangle = new Rectangle(dataObject.anchorRect.x + dataObject.anchorRect.width + 20, dataObject.anchorRect.y, 0, 0);
				
				//  -- POSITION:
				//  -- POSITION:
				var defAnchorRect:Rectangle = dataObject.anchorRect;
				if (dataObject.defaultAnchorName)
				{
					var stageAnchor:MovieClip = _rootCanvas.parent.getChildByName(dataObject.defaultAnchorName) as MovieClip;
					if (stageAnchor)
					{
						// defAnchorRect.x = stageAnchor.x;
					}
				}
				
				// instance.isMouseTooltip = false;
				//
				
				// TMP PROTO
				if (!_DBG_LOCK_MOUSE_TOOLTIP && dataObject.viewerClass != "ItemTooltipRef_mouse" && dataObject.viewerClass != "ItemTooltipRef")
				{
					instance.anchorRect = new Rectangle(_defaultAnchor.x, _defaultAnchor.y, 0, 0);
				}
				else
				{
					instance.anchorRect = defAnchorRect;
				}
				
				// TMP:
				//instance.anchorRect = dataObject.anchorRect;
				//--
			}
			
			if ( dataObject.directData == true )
			{
				instance.data = dataObject;
				updateComparisonMode();
			}
			
			instance.addEventListener(Event.ADDED_TO_STAGE, handleTooltipOnStage, false, 0, true);
			
			if (instance as TooltipInventory)
			{
				instance.addEventListener( Event.ACTIVATE, handleTooltipResized, false, 0, true );
			}
			else
			{
				handleTooltipResized();
			}
			
			_rootCanvas.addChild(instance);
			_tooltip = instance;
			_tooltip.setVisibility(!_isHiddenState);
			_data = dataObject;
		}
		
		protected function handleTooltipOnStage(event:Event):void { };
		
		protected function handleTooltipResized(event:Event = null):void
		{
			_rootCanvas.removeEventListener(Event.ENTER_FRAME, handleScaleEnterFrame, false);
			_rootCanvas.addEventListener(Event.ENTER_FRAME, handleScaleEnterFrame, false, 0, true);
		}
		
		protected function handleScaleEnterFrame(event:Event):void
		{
			_rootCanvas.removeEventListener(Event.ENTER_FRAME, handleScaleEnterFrame, false);
			
			if (_upscaleMePlease && _tooltip)
			{
				_tooltip.scaleX = _tooltip.scaleY = getMaxScale( _tooltip );
			}
		}

		protected function handleHideTooltip(event:Event = null):void
		{
			if (!_tooltip)
			{
				return;
			}
			else if (InputManager.getInstance().isGamepad())
			{
				_rootCanvas.removeChild(_tooltip);
			}
			else
			{
				removeCurrentTooltip();
			}
		}

		protected function subscribeOn(target:EventDispatcher, eventsList:Array, handler:Function):void
		{
			if (target && eventsList && handler != null)
			{
				for each (var currentEvent:String in eventsList)
				{
					target.addEventListener(currentEvent, handler, false, 0, true);
				}
			}
		}

		protected function getDefinition(assetName:String):DisplayObject
		{
			var assetsMgr:RuntimeAssetsManager = RuntimeAssetsManager.getInstanse();
			return assetsMgr.getAsset(assetName);
		}
		
		protected function removeCurrentTooltip():void
		{
			if (_tooltip)
			{
				GTweener.removeTweens(_tooltip);
				GTweener.to(_tooltip, HIDE_ANIM_DURATION, { alpha:0 }, { ease:Exponential.easeOut, onComplete:handleTooltipHidden } );
				_tooltip = null;
				_data = null;
			}
		}
		
		protected function handleTooltipHidden(tween:GTween):void
		{
			_rootCanvas.removeChild(tween.target as DisplayObject);
		}
		
		public function setInitialState( initScaling : Boolean, initVisibility:Boolean ):void
		{
			_upscaleMePlease = initScaling;
		}
		
		protected function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
					
			
			if (!event.handled)
			{
				if (details.navEquivalent == NavigationCode.GAMEPAD_L2 || details.code == KeyCode.SHIFT_LEFT || details.code == KeyCode.SHIFT_RIGHT )
				{
					if (details.value == InputValue.KEY_UP)
					{
						comparisonMode = false;
					}
					else
					{
						comparisonMode = true;
					}
				}
				else
				if ( details.navEquivalent == NavigationCode.GAMEPAD_L3 && details.value == InputValue.KEY_UP && _enableInputFeedback)
				{
					if (blockModeSwitching)
					{
						return;
					}
					
					if (_holdTriggered)
					{
						_holdTriggered = false;
						return;
					}
					
					setHiddenState(!_isHiddenState);
				}
				if ( details.navEquivalent == NavigationCode.GAMEPAD_L3 && details.value == InputValue.KEY_HOLD && !_holdTriggered && _enableInputFeedback)
				{
					var tweenValues:Object;
					var scaledPosition:Point;
					
					if (blockModeSwitching)
					{
						return;
					}
					
					_holdTriggered = true;
					
					if (_tooltip && _upscaleMePlease)
					{
						tweenValues = { scaleX: NORMAL_SCALE, scaleY: NORMAL_SCALE };
						scaledPosition = _tooltip.getPositionAfterScale( NORMAL_SCALE );
						
						/*
						trace("GFX ------------------------------------------ ");
						trace("GFX origin Position ", _tooltip.x, _tooltip.y);
						trace("GFX scaled Position ", scaledPosition);
						trace("GFX ------------------------------------------ ");
						*/
						
						if (scaledPosition)
						{
							tweenValues.x = scaledPosition.x;
							tweenValues.y = scaledPosition.y;
						}
						
						_tooltip.stopSafeRectCheck(true);
						
						GTweener.removeTweens(_tooltip);
						GTweener.to(_tooltip, .5, tweenValues, { ease:Exponential.easeOut, onComplete:handleTooltipUnzoomed  } );
						_upscaleMePlease = false;
					}
					else
					if (_tooltip && !_upscaleMePlease && _enableInputFeedback)
					{
						var curMaxZoom:Number = getMaxScale( _tooltip );
						
						tweenValues = { scaleX: curMaxZoom, scaleY: curMaxZoom };
						scaledPosition = _tooltip.getPositionAfterScale( curMaxZoom );
						
						/*
						trace("GFX ------------------------------------------ ");
						trace("GFX origin Position ", _tooltip.x, _tooltip.y);
						trace("GFX scaled Position ", scaledPosition);
						trace("GFX ------------------------------------------ ");
						*/
						
						if (scaledPosition)
						{
							tweenValues.x = scaledPosition.x;
							tweenValues.y = scaledPosition.y;
						}
						
						//trace("GFX tweenValues", tweenValues);
						
						_tooltip.stopSafeRectCheck(true);
						
						GTweener.removeTweens(_tooltip);
						GTweener.to(_tooltip, .5, tweenValues, { ease:Exponential.easeOut, onComplete:handleTooltipZoomed } );
						_upscaleMePlease = true;
					}
				}
			}
		}
		
		private function handleTooltipZoomed(gt:GTween):void
		{
			//trace("GFX handleTooltipZoomed ", saveScaleValue);
			
			if (_tooltip)
			{
				_tooltip.stopSafeRectCheck(false);
			}
			
			if (saveScaleValue)
			{
				_rootCanvas.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTooltipScaleStateSave', [true] ) );
			}
		}
		
		private function handleTooltipUnzoomed(gt:GTween):void
		{
			//trace("GFX handleTooltipUnzoomed ", saveScaleValue);
			
			if (_tooltip)
			{
				_tooltip.stopSafeRectCheck(false);
			}
			
			if (saveScaleValue)
			{
				_rootCanvas.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTooltipScaleStateSave', [false] ) );
			}
		}
		
		private function handleMouseClick(event:MouseEvent):void
		{
			var extEvent:MouseEventEx = event as MouseEventEx;
			
			//trace("GFX handleMouseClick; saveScaleValue ", saveScaleValue);
			
			if (extEvent && extEvent.buttonIdx == MouseEventEx.MIDDLE_BUTTON)
			{
				_upscaleMePlease = !_upscaleMePlease;
				

				if (_upscaleMePlease)
				{
					_tooltip.scaleX = _tooltip.scaleY = getMaxScale( _tooltip );
				}
				else
				{
					_tooltip.scaleX = _tooltip.scaleY = 1;
				}
				
				if (saveScaleValue)
				{
					_rootCanvas.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTooltipScaleStateSave', [_upscaleMePlease] ) );
				}
				
				_tooltip.updateSafeRectCheck();
			}
		}
		
		private function getMaxScale( _tooltip : UIComponent ) : Number
		{
			var screenHeight : Number = 1070; // #Y Hardcode, flash document's height
			
			if (_tooltip)
			{
				_tooltip.validateNow();
				
				var mcBackground:MovieClip = _tooltip["mcBackground"] as MovieClip;
				var actualTooltipHeight:Number;
				
				if (mcBackground)
				{
					var boundsRect:Rectangle = mcBackground.getBounds( _rootCanvas );
					
					actualTooltipHeight = boundsRect.height;
				}
				else
				{
					actualTooltipHeight = _tooltip.actualHeight;
				}
				
				/*
				_rootCanvas.graphics.clear();
				_rootCanvas.graphics.lineStyle( 1, 0xFF0000, 1 );
				_rootCanvas.graphics.drawRect( boundsRect.x, boundsRect.y, boundsRect.width, boundsRect.height );
				*/
				
				if ( actualTooltipHeight * MAX_ZOOM > screenHeight )
				{
					return screenHeight / actualTooltipHeight;
				}
				else
				{
					return MAX_ZOOM;
				}
			}
			else
			{
				return MAX_ZOOM;
			}
		}
		

	}
}
