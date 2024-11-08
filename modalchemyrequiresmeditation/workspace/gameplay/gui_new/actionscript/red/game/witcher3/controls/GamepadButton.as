package red.game.witcher3.controls
{
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.ButtonEvent
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	[Event(name="select", type="flash.events.Event")]
    [Event(name="stateChange", type="scaleform.clik.events.ComponentEvent")]
    [Event(name="dragOver", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="dragOut", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="releaseOutside", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="buttonRepeat", type="scaleform.clik.event.ButtonEvent")]
	
	public class GamepadButton extends Button
	{

	//{region Component properties
	// ------------------------------------------------
	
		// TBD: Not really that great being a string
		// Same as scaleform.clik.constants.NavigationCode
		protected var _navigationCode:String;
		
	//{region Component setters/getters
	// ------------------------------------------------
	
		public function get navigationCode():String
		{
			return _navigationCode;
		}
	
		public function set navigationCode( value:String ):void
		{
			_navigationCode = value;
		}
		
	//{region Overrides
	// ------------------------------------------------		
		
		override protected function configUI():void
		{
			super.configUI();
			focusable = false;
		}
	
		override public function setActualSize( newWidth:Number, newHeight:Number ):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}
	
		override public function handleInput( event:InputEvent ):void
		{
            if ( event.isDefaultPrevented() )
			{
				return;
			}
            
			var details:InputDetails = event.details;
            var index = details.controllerIndex;
            
			if  ( details.navEquivalent != _navigationCode )
			{
				return;
			}
			
			if ( details.value == InputValue.KEY_DOWN )
			{
				handlePress( index );
				event.handled = true;
			}
			else if ( details.value == InputValue.KEY_UP )
			{
				if ( _pressedByKeyboard )
				{ 
					handleRelease( index );
					event.handled = true;
				}
			}
		}
		
		override protected function handlePress(controllerIndex:uint = 0):void
		{
            if ( ! enabled )
			{
				return;
			}
            
			_pressedByKeyboard = true;
            
			setState( _focusIndicator == null ? "down" : "kb_down" );
            
			// Sending a click instead
            var sfEvent:ButtonEvent = new ButtonEvent(ButtonEvent.CLICK, true, false, controllerIndex, 0, true, false);
			
            dispatchEvent(sfEvent);
        }
		
        override protected function handleRelease(controllerIndex:uint = 0):void
		{
            if ( ! enabled )
			{ 
				return;
			}
            
			setState(focusIndicator == null ? "release" : "kb_release");
			
			_pressedByKeyboard = false;
        }
	
		override public function toString():String
		{
            return "[W3 GamepadButton" + name + ", navigation code " + _navigationCode; 
        }
	}

}