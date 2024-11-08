package red.game.witcher3.controls 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.SliderEvent;
	
	/**
	 * Slider for sell / buy / drop / bet dialog
	 * @author Getsevich Yaroslav
	 */
	public class W3QuantitySlider extends W3Slider
	{
		private const BUTTON_WIDTH:Number = 24;
		private const BLOCK_PADDING:Number = 5;
		private const SLIDER_WIDTH:Number = 331;
		
		public var txtMinValue:TextField;
		public var txtMaxValue:TextField;
		public var btnLeft:Button;
		public var btnRight:Button;
		
		public function W3QuantitySlider()
		{
			btnLeft.addEventListener(ButtonEvent.CLICK, handleLeftPress, false, 0, true);
			btnRight.addEventListener(ButtonEvent.CLICK, handleRightPress, false, 0, true);
		}
		
		override public function set maximum(value:Number):void 
		{
			super.maximum = value;
			
			txtMaxValue.text = _maximum.toString();
			txtMaxValue.width = txtMaxValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			updateControls();
        }
		
		override public function set minimum(value:Number):void 
		{
			super.minimum = value;
			
			txtMinValue.text = _minimum.toString();
			//txtMinValue.width = txtMinValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			updateControls();
        }
		
		override protected function configUI():void 
		{
			super.configUI();
			
			var inputMgr:InputManager = InputManager.getInstance();
			inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			updateControls();
			
			if (stage)
			{
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, handleAddedOnStage, false, 0, true);
			}
		}
		
		private function handleAddedOnStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedOnStage);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
		}
		
		private function handleControllerChanged(event:ControllerChangeEvent):void
		{
			updateControls();
		}
		
		private function updateControls():void
		{
			var inputMgr:InputManager = InputManager.getInstance();
			var isGamepad:Boolean = inputMgr.isGamepad();
			
			if (isGamepad)
			{
				btnLeft.visible = false;
				btnRight.visible = false;
				
				//txtMinValue.x = track.x - txtMinValue.width - BLOCK_PADDING;
				//txtMaxValue.x = SLIDER_WIDTH + BLOCK_PADDING;
			}
			else
			{
				btnLeft.visible = true;
				btnRight.visible = true;
				btnLeft.x = track.x - BLOCK_PADDING;
				btnRight.x = SLIDER_WIDTH + BLOCK_PADDING;
				
				//txtMinValue.x = track.x - (btnLeft.width + txtMinValue.width + BLOCK_PADDING);
				//txtMaxValue.x = SLIDER_WIDTH + btnRight.width + BLOCK_PADDING;
			}
			
			invalidateData();
		}
		
		private function handleMouseWheel(event:MouseEvent):void
		{
			if (event.delta > 0)
			{
				value += snapInterval;
			}
			else
			{
				value -= snapInterval;
			}
		}
		
		private function handleLeftPress(event:ButtonEvent):void
		{
			value -= snapInterval;
		}
		
		private function handleRightPress(event:ButtonEvent):void
		{
			value += snapInterval;
		}
		
		// -----------------------------------------------
		// -- override to replace _width with track.width
		
		override protected function updateThumb():void 
		{
            if (!enabled) { return; }
            var trackWidth:Number = (track.width - offsetLeft - offsetRight);
            thumb.x = ((_value - _minimum) / (_maximum - _minimum) * trackWidth) - thumb.width / 2 + offsetLeft;
			
			if ( txtValue )
			{
				txtValue.text = _value.toString();
			}
        }
		
		override protected function doDrag(e:MouseEvent):void 
		{
            var lp:Point = globalToLocal( new Point(e.stageX, e.stageY) );
            var thumbPosition:Number = lp.x - _dragOffset.x;
            var trackWidth:Number = (track.width - offsetLeft - offsetRight);
            var newValue:Number = lockValue( (thumbPosition - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum );
            
            if (value == newValue) { return; }
            _value = newValue;
            
            updateThumb();
            
            if (liveDragging) {
                dispatchEvent( new SliderEvent(SliderEvent.VALUE_CHANGE, false, true, _value) );
            }
        }
		
        override protected function trackPress(e:MouseEvent):void 
		{
            _trackPressed = true;
            
            track.focused = _focused;
            
            var trackWidth:Number = (track.width - offsetLeft - offsetRight);
            var newValue:Number = lockValue( (e.localX * scaleX - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum);
            
            if (value == newValue) { return; }
            value = newValue;
            
            if (!liveDragging) { 
                dispatchEvent( new SliderEvent(SliderEvent.VALUE_CHANGE, false, true, _value) );
            }
            
            // Pressing on the track moves the grip to the cursor and the thumb becomes draggable.
            _trackDragMouseIndex = 0 // e.mouseIdx; // @todo, NFM: This needs to use the multi-controller system.
            
            // thumb.onPress(trackDragMouseIndex);
            _dragOffset = {x:0};
        }
		
	}

}
