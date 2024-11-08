/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.core.utils.InputUtils;
	import red.game.witcher3.controls.W3Slider;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.scrollbar.ScrollBarEvent;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class UIRescaleModule extends CoreMenuModule
	{
		private static const MAX_H_SCALE : Number = 1.0;
		private static const MIN_H_SCALE : Number = 0.9;
		
		private static const MAX_V_SCALE : Number = 1.0;
		private static const MIN_V_SCALE : Number = 0.9;
		private static const MIN_OPACITY : Number = 0.2;
		private static const MAX_OPACITY : Number = 1.0;
		
		private static const RESIZE_SCALE_BASE_FACTOR : Number = 0.0075;
		private static const RESIZE_SCALE_STICK_SPEED_CAP : Number = 0.05;
		
		protected var _updatingScale:Boolean = false;
		
		// PC specific controllers
		public var hSlider : W3Slider;
		public var vSlider : ScrollBar;
		public var mcSampleFrame : MovieClip;
		public var mcSampleScaleFrame : MovieClip;
		public var mcPCBackground : MovieClip;
		
		private var baseSampleScaleX : Number;
		private var baseSampleScaleY : Number;
		
		public var mcScaleFrame : MovieClip;
		public var txtExplanation : TextField;
		
		private var initialHScale : Number;
		private var initialVScale : Number;
		
		private var gapH:Number;
		private var gapV:Number;
		private var numValuesV:int;
		
		public var _lastSentHValue : Number;
		public var _lastSentVValue : Number;
		
		override protected function configUI():void
		{
			super.configUI();
			
			setupSliders();
			
			showPCControllers(!InputManager.getInstance().isGamepad());
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			if (mcSampleScaleFrame)
			{
				baseSampleScaleX = mcSampleScaleFrame.scaleX;
				baseSampleScaleY = mcSampleScaleFrame.scaleY;
			}
			
			enabled = false;
			visible = false;
			alpha = 0;
		}
		
		public function SetInitialScaleHorizontal( value : Number )
		{
			initialHScale = mcScaleFrame.scaleX;
		}
		
		public function SetInitialScaleVertical( value : Number )
		{
			initialVScale = mcScaleFrame.scaleY;
		}
		
		public function show(data:Object):void
		{
			showWithScale(data.initialHScale, data.initialVScale);
		}
		
		public function showWithScale(hScale:Number, vScale:Number):void
		{
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
			
			SetInitialScaleHorizontal(hScale);
			SetInitialScaleVertical(vScale);
			updateScale(Math.min( Math.max( hScale, MIN_H_SCALE ), MAX_H_SCALE), Math.min( Math.max( vScale, MIN_V_SCALE ), MAX_V_SCALE));
		}
		
		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
			}
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			visible = false;
		}
		
		protected function setupSliders():void
		{
			if (hSlider && vSlider)
			{
				//hSlider.snapInterval = RESIZE_SCALE_BASE_FACTOR;
				gapH = MAX_H_SCALE - MIN_H_SCALE;
				hSlider.snapping = false;
				hSlider.offsetLeft = 35;
				hSlider.offsetRight = 35;
				hSlider.maximum = MAX_H_SCALE;
				hSlider.minimum = MIN_H_SCALE;
				hSlider.value = MAX_H_SCALE;
				hSlider.addEventListener(SliderEvent.VALUE_CHANGE, onSliderValueChanged, false, 0, false);
				hSlider.addEventListener(MouseEvent.MOUSE_OUT, onHSliderMouseOut, false, 0, true);
				hSlider.validateNow();
				
				gapV = MAX_V_SCALE - MIN_V_SCALE;
				numValuesV = gapV / RESIZE_SCALE_BASE_FACTOR;
				vSlider.setScrollProperties(5, 0, numValuesV, 1);
				/*vSlider.snapInterval = RESIZE_SCALE_BASE_FACTOR;
				vSlider.snapping = true;
				vSlider.offsetLeft = 35;
				vSlider.offsetRight = 35;
				vSlider.isVertical = true;
				vSlider.maximum = MAX_V_SCALE;
				vSlider.minimum = MIN_V_SCALE;
				vSlider.value = MAX_V_SCALE;*/
				vSlider.addEventListener(Event.SCROLL, onScrollbarValue, false, 0, true);
				vSlider.addEventListener(Event.CHANGE, onScrollbarValue, false, 0, true);
				vSlider.addEventListener(MouseEvent.MOUSE_OUT, onVSliderMouseOut, false, 0, true);
				vSlider.validateNow();
			}
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( !event.handled )
				{
					if (details.code == KeyCode.PAD_LEFT_STICK_AXIS)
					{
						var axisData:InputAxisData;
						var magnitude:Number;
						var magnitudeCubed:Number;
						var rescaleValue : Number;
						
						axisData = InputAxisData(details.value);
						magnitude = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
						magnitudeCubed = magnitude * magnitude * magnitude;
						
						rescaleValue = RESIZE_SCALE_BASE_FACTOR;
						
						updateScale(Math.min( Math.max( mcScaleFrame.scaleX - rescaleValue * axisData.xvalue, MIN_H_SCALE ), MAX_H_SCALE), Math.min( Math.max( mcScaleFrame.scaleY + rescaleValue * axisData.yvalue, MIN_V_SCALE ), MAX_V_SCALE));
						event.handled = true;
							//event.preventDefault();
					}
					else
					{
						CommonUtils.convertWASDCodeToNavEquivalent(details);
						
						var xChange:Number = 0;
						var yChange:Number = 0;
						
						switch(details.navEquivalent)
						{
						case NavigationCode.GAMEPAD_B:
							if (keyUp)
							{
								handleNavigateBack();
							}
							break;
						case NavigationCode.UP:
							if (!details.fromJoystick)
							{
								yChange = RESIZE_SCALE_BASE_FACTOR;
							}
							break;
						case NavigationCode.DOWN:
							if (!details.fromJoystick)
							{
								yChange = -RESIZE_SCALE_BASE_FACTOR;
							}
							break;
						case NavigationCode.LEFT:
							if (!details.fromJoystick)
							{
								xChange = RESIZE_SCALE_BASE_FACTOR;
							}
							break;
						case NavigationCode.RIGHT:
							if (!details.fromJoystick)
							{
								xChange = -RESIZE_SCALE_BASE_FACTOR;
							}
							break;
						}
						
						if (xChange != 0 || yChange != 0)
						{
							updateScale(Math.min( Math.max( mcScaleFrame.scaleX + xChange, MIN_H_SCALE ), MAX_H_SCALE), Math.min( Math.max( mcScaleFrame.scaleY + yChange, MIN_V_SCALE ), MAX_V_SCALE));
						}
					}
				}
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			showPCControllers(!event.isGamepad);
		}
		
		public function showPCControllers(value:Boolean):void
		{
			if (hSlider)
			{
				hSlider.visible = value;
			}
			
			if (vSlider)
			{
				vSlider.visible = value;
			}
			
			if (mcSampleFrame)
			{
				mcSampleFrame.visible = value;
			}
			
			if (mcSampleScaleFrame)
			{
				mcSampleScaleFrame.visible = value;
			}
			
			if (mcPCBackground)
			{
				mcPCBackground.visible = value;
			}
		}
		
		protected function onHSliderMouseOut(e:MouseEvent):void
		{
			hSlider.focused = 0;
		}
		
		protected function onVSliderMouseOut(e:MouseEvent):void
		{
			vSlider.focused = 0;
		}
		
		protected function onSliderValueChanged( event : SliderEvent ) : void
		{
			if (!_updatingScale)
			{
				updateScale(getConvertedHSliderValue(), getScrollBarVValue());
			}
		}
		
		protected function onScrollbarValue( event : Event ) : void
		{
			if (!_updatingScale)
			{
				updateScale(getConvertedHSliderValue(), getScrollBarVValue());
			}
		}
		
		protected function getConvertedHSliderValue():Number
		{
			return MAX_H_SCALE - (hSlider.value - MIN_H_SCALE);
		}
		
		protected function updateScale(scaleH : Number, scaleV : Number) : void
		{
			mcScaleFrame.scaleX = Math.min( Math.max( scaleH, MIN_H_SCALE ), MAX_H_SCALE);
			mcScaleFrame.scaleY = Math.min( Math.max( scaleV, MIN_V_SCALE ), MAX_V_SCALE);
			
			if (scaleH != _lastSentHValue || scaleV != _lastSentVValue)
			{
				_lastSentHValue = scaleH;
				_lastSentVValue = scaleV;
				
				if (hSlider && vSlider)
				{
					_updatingScale = true;
					hSlider.value = MAX_H_SCALE - (scaleH - MIN_H_SCALE);
					setScrollbarVValue(scaleV);
					_updatingScale = false;
				}
				
				if (mcSampleScaleFrame)
				{
					mcSampleScaleFrame.scaleX = baseSampleScaleX * scaleH;
					mcSampleScaleFrame.scaleY = baseSampleScaleY * scaleV;
				}
				
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUpdateRescale' , [mcScaleFrame.scaleX, mcScaleFrame.scaleY]) );
			}
		}
		
		protected function getScrollBarVValue():Number
		{
			var value:Number = MIN_V_SCALE + RESIZE_SCALE_BASE_FACTOR * (numValuesV - vSlider.position);
			return value;
		}
		
		protected function setScrollbarVValue(number:Number):void
		{
			var targetPosition:int = numValuesV - (number - MIN_V_SCALE ) / RESIZE_SCALE_BASE_FACTOR;
			vSlider.position = targetPosition;
			vSlider.validateNow();
		}
		
		public function onRightClick(event:MouseEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}
		
		protected function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
		}
	}
}