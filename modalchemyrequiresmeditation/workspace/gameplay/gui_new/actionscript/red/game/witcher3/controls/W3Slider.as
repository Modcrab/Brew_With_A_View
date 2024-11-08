package red.game.witcher3.controls
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import scaleform.clik.controls.Slider;
	import red.core.events.GameEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import scaleform.clik.events.SliderEvent;
	/**
	 * Slider component
	 * @author Yaroslav Getsevich
	 * 		   Bartosz Bigaj
	 */
	public class W3Slider extends Slider
	{
		public var txtValue:TextField;
		public var previousValue:Number = -1;
		private var errorTimer : Timer;
		protected var _lockedValue : Number = -1;
		protected var _gEvent : GameEvent = null;
		protected var _skipValue : Number = -1;
		
		public var isVertical:Boolean = false;
		
		private var _enableSounds:Boolean;
		[Inspectable(defaultValue="false")]
		public function get enableSounds():Boolean { return _enableSounds };
		public function set enableSounds(value:Boolean):void
		{
			_enableSounds = value;
		}

		override protected function configUI():void
		{
			super.configUI();
			errorTimer = new Timer(500,1);
			errorTimer.addEventListener( TimerEvent.TIMER, OnErrorTimer, false, 0, true );
		}
		
        public function get gEvent():GameEvent { return _gEvent; }
        public function set gEvent(value:GameEvent):void {
            _gEvent = value;
        }
		
        public function get lockedValue():Number { return _lockedValue; }
        public function set lockedValue(value:Number):void {
            _lockedValue = value;
        }
		
		public function get skipValue():Number { return _skipValue; }
        public function set skipValue(value:Number):void {
            _skipValue = value;
        }
		
		//Checks if trying to set value that should be skipped. Retunrs the same value if it should't be skipped or a next if it should.
		private function checkSkipValue(newValue : Number) : Number
		{
			if (newValue == skipValue && skipValue >= 0)
			{
				if (newValue > _value)
				{
					newValue = newValue + 1;
					if (_gEvent != null)
					{
						dispatchEvent(_gEvent);
					}
				}
				else if (newValue < _value)
				{
					newValue = newValue - 1;
					if (_gEvent != null)
					{
						dispatchEvent(_gEvent);
					}
				}	
			}
			return newValue;
		}
		
		override public function set value(value:Number):void
		{
			var newValue:Number = value;
			if (newValue >= _lockedValue && _lockedValue >= 0)
			{
				if (_gEvent != null)
				{
					dispatchEvent(_gEvent);
				}
				return;
			}
			
			newValue = checkSkipValue(newValue);
			
			if( newValue > maximum || newValue < minimum  )
			{
				if ( previousValue != newValue && _enableSounds)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlaySoundEvent', ["gui_global_slider_move_failed"] ));
				}
				previousValue = newValue;
				if ( errorTimer == null )
				{
					errorTimer = new Timer(500,1);
					errorTimer.addEventListener( TimerEvent.TIMER, OnErrorTimer, false, 0, true );
				}
				errorTimer.reset();
				errorTimer.start();
				return;
			}
			if (_enableSounds)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlaySoundEvent', ["gui_global_slider_move"] ));
			}
			super.value = newValue;
			if ( txtValue )
			{
				txtValue.text = _value.toString();
			}
		}
		
		override protected function doDrag(e:MouseEvent):void {
            var lp:Point = globalToLocal( new Point(e.stageX, e.stageY) );
            var thumbPosition:Number = lp.x - _dragOffset.x;
            var trackWidth:Number = (_width - offsetLeft - offsetRight);
            var newValue:Number = lockValue( (thumbPosition - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum );
			
			if (newValue >= _lockedValue && _lockedValue >= 0)
			{
				if (_gEvent != null)
				{
					dispatchEvent(_gEvent);
				}
				return;
			}
            
			if (newValue != checkSkipValue(newValue))
			{
				newValue = checkSkipValue(newValue);
			}
            else if (value == newValue) 
			{
				return; 
			}
			
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
            
            var trackWidth:Number = (_width - offsetLeft - offsetRight);
            var newValue:Number = lockValue( (e.localX * scaleX - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum);
            
			if (newValue >= _lockedValue && _lockedValue >= 0)
			{
				if (_gEvent != null)
				{
					dispatchEvent(_gEvent);	
				}
				return;
			}
			
            if (newValue != checkSkipValue(newValue))
			{
				newValue = checkSkipValue(newValue);
			}
            else if (value == newValue) 
			{
				return; 
			}
            value = newValue;
            
            if (!liveDragging) { 
                dispatchEvent( new SliderEvent(SliderEvent.VALUE_CHANGE, false, true, _value) );
            }
            
            // Pressing on the track moves the grip to the cursor and the thumb becomes draggable.
            _trackDragMouseIndex = 0 // e.mouseIdx; // @todo, NFM: This needs to use the multi-controller system.
            
            // thumb.onPress(trackDragMouseIndex);
            _dragOffset = {x:0};
        }
		

		public function OnErrorTimer( event : TimerEvent )
		{
			errorTimer.stop();
			previousValue = -1;
		}
	}

}
