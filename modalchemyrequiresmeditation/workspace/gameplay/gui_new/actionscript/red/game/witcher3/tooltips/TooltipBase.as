package red.game.witcher3.tooltips
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.utils.Padding;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.utils.CommonUtils;
	import red.core.CoreComponent;
	import red.game.witcher3.managers.ContextInfoManager;

	/**
	 * Base tooltip class
	 * @author Yaroslav Getsevich
	 */
	public class TooltipBase extends UIComponent
	{
		protected var INVALIDATE_PADDING:String = "padding";
		protected var INVALIDATE_POSITION:String = "position";

		protected var _internalVisibility:Boolean = true;
		protected var _shown:Boolean;
		protected var _populated:Boolean;
		protected var _expanded:Boolean;
		protected var isArabicAligmentMode:Boolean;
		
		protected var _backgroundVisibility:Boolean;
		protected var _actualPosition:Point;
		protected var _anchorRect:Rectangle;
		protected var _defaultHeight:Number;
		protected var _cachedExtraWidth:Number = 0;
		protected var _isMouseTooltip:Boolean;
		protected var _lockFixedPosition:Boolean;
		protected var _visibility:Boolean = true;
		protected var _data:*;

		protected var _tweenerShow:GTween;
		protected var _tweenerScale:GTween;

		protected var _contextMgr:ContextInfoManager;
		protected var _tooltipAlignment:String = "Right";

		public function TooltipBase()
		{
			super();
			_actualPosition = new Point();
			_defaultHeight = height;
			_contextMgr = ContextInfoManager.getInstanse();
			//visible = true;
		}
		
		public function get backgroundVisibility():Boolean { return _backgroundVisibility };
		public function set backgroundVisibility(value:Boolean):void
		{
			_backgroundVisibility = value;
		}

		public function get data():* { return _data }
		public function set data(value:*):void
		{
			_data = value;
			invalidateData();
		}

		public function get anchorRect():Rectangle { return _anchorRect; }
		public function set anchorRect(value:Rectangle):void
		{
			_anchorRect = value;
		}

		public function get expanded():Boolean { return _expanded }
		public function set expanded(value:Boolean):void
		{
			if (_expanded != value)
			{
				_expanded = value;
				if (this.actualHeight > _defaultHeight)
				{
					expandTooltip();
				}
			}
		}
		
		public function setVisibility(value:Boolean):void
		{
			_visibility = value;
			updateVisibility();
		}
		
		public function toggleVisibility():void
		{
			_visibility = !_visibility;
			updateVisibility();
		}
		
		public function get tooltipAlignment():String { return _tooltipAlignment }
		public function set tooltipAlignment(value:String):void
		{
			_tooltipAlignment = value;
		}

		public function get isMouseTooltip():Boolean { return _isMouseTooltip }
		public function set isMouseTooltip(value:Boolean):void
		{
			_isMouseTooltip = value;
		}

		[Inspectable(name = "Lock Fix position", defaultValue = "false")] // #B
		public function get lockFixedPosition():Boolean { return _lockFixedPosition }
		public function set lockFixedPosition(value:Boolean):void
		{
			_lockFixedPosition = value;
			if (!stage)
			{
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}
			else
			{
				//updatePosition();
				invalidate(INVALIDATE_POSITION);
			}
		}
		
		public function stopSafeRectCheck(value:Boolean = false):void
		{
			// virtual
		}
		
		public function updateSafeRectCheck():void
		{
			// virtual
		}
		
		public function getPositionAfterScale(emulateScale:Number = -1):Point
		{
			return new Point(x, y);
		}
		
		/*
		 * Underhood
		 */
		
		override public function set visible(value:Boolean):void
		{
			_internalVisibility	= value;
			
			updateVisibility();
		}
		
		protected function updateVisibility():void
		{
			//trace("GFX  updateVisibility ", _internalVisibility, _visibility);
			
			super.visible = _internalVisibility && _visibility;
		}
		
		override protected function draw():void
		{
			super.draw();
			if (isInvalid(InvalidationType.DATA))
			{
				populateData();
			}
			if (isInvalid(InvalidationType.SIZE)) updateSize();
			if (isInvalid(INVALIDATE_POSITION)) updatePosition();
		}

		override protected function configUI():void
		{
			super.configUI();
			mouseEnabled = mouseChildren = false;
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
		}

		protected function showAnimation():void
		{
			alpha = 0;
			_tweenerShow = GTweener.to(this, .2, { alpha:1 }, { ease:Exponential.easeOut } );
		}
		
		protected function handleAddedToStage(event:Event):void
		{
			invalidatePosition();
		}
		
		protected function invalidatePosition():void
		{
			updatePosition();
			invalidate(INVALIDATE_POSITION);
			invalidateSize();
		}
		
		protected function updatePosition():void
		{
			applyPositioning(); // set _actualPosition value
			
			x = _actualPosition.x;
			y = _actualPosition.y;
		}
	
		protected function applyPositioning():void
		{
			var localPoint:Point;

			//trace("GFX [TOOLIP][", this, "] applyPositioningType");
			//trace("GFX _anchorRect: ", _anchorRect, _lockFixedPosition);

			if (_anchorRect)
			{
				localPoint = new Point(_anchorRect.x , _anchorRect.y);
				
				_actualPosition.x = localPoint.x + _anchorRect.width;
				_actualPosition.y = localPoint.y + _anchorRect.height;
			}
			else
			{
				if (_lockFixedPosition)
				{
					_actualPosition.x = this.x;
					_actualPosition.y = this.y;
				}
				else
				{
					localPoint = new Point(0, 0);
					throw( new Error(" Missing anchor for tooltip"));
				}
			}
		}
		
		// virtual fucntions
		protected function populateData():void
		{
			//_visibility = true;
			_populated = true;
			invalidateSize();
			invalidate(INVALIDATE_POSITION);
		}

		protected function updateSize():void
		{
			invalidate(INVALIDATE_POSITION);
			if (!_shown)
			{
				_shown = true;
				//visible = true;
				showAnimation();
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			// ?
		}
		
		// virtual
		protected function expandTooltip(smoothExpand:Boolean = true):void { }
		protected function getExtraHeight():Number { return 0 };
		
		// utils
		private var tempStr:String;
		protected function applyTextValue(targetTextField:TextField, value:String, capitalize:Boolean, useArabicAlignment : Boolean = false):void
		{
			
			tempStr = value;
			if (!targetTextField || !value)
			{
				if (targetTextField)
				{
					targetTextField.htmlText = "";
					targetTextField.visible = false;
				}
				return;
			}
			
			targetTextField.visible = true;
			targetTextField.htmlText = tempStr;
			if (useArabicAlignment && _contextMgr.isArabicAligmentMode )
			{
				targetTextField.htmlText = "<p align=\"right\">" + tempStr +"</p>";
			}
			else if (capitalize)
			{
				targetTextField.htmlText = CommonUtils.toUpperCaseSafe(targetTextField.htmlText);
				
				//CommonUtils.toSmallCaps(targetTextField);
			}
			targetTextField.height = targetTextField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
		}
	}
}
