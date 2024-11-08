package red.game.witcher3.menus.common 
{
	import scaleform.clik.controls.Button;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.events.InputEvent;
		
	public class DownloadButton extends Button
	{
		public var gamepadButton : String;
		public var keyboardButton : uint;
		
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			
			if ( details.value == InputValue.KEY_DOWN && IsButtonPressed(details) )
			{
				this.handlePress();
				event.handled = true;
			}
			else if ( details.value == InputValue.KEY_UP && IsButtonPressed(details) )
			{
				this.handleRelease();
				event.handled = true;
			}
		}
		
		private function IsButtonPressed( inputDetails : InputDetails ):Boolean 
		{
			return inputDetails.navEquivalent == gamepadButton || inputDetails.code == keyboardButton;
		}
	}
}