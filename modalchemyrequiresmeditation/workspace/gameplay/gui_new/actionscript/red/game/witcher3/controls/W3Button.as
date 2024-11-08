package red.game.witcher3.controls
{    
    import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.controls.Button;
    import red.game.witcher3.managers.InputManager;
    
    [Event(name="select", type="flash.events.Event")]
    [Event(name="stateChange", type="scaleform.clik.events.ComponentEvent")]
    [Event(name="dragOver", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="dragOut", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="releaseOutside", type="scaleform.clik.events.ButtonEvent")]
    [Event(name="buttonRepeat", type="scaleform.clik.event.ButtonEvent")]
    
    public class W3Button extends scaleform.clik.controls.Button
	{
        private var _desiredNavCode:String;
        public var keyboardButtonIcon:MovieClip;
        public var gamepadButtonIcon:MovieClip;
		public var textField_disabled:TextField;
        
        [Inspectable(type = "string", defaultValue = "enter-gamepad_A")]
        public function get desiredNavCode():Object { return _desiredNavCode; }
        public function set desiredNavCode(value:Object):void {
            _desiredNavCode = String(value);
            UpdateButtonIcon();
        }
        
		public function W3Button()
		{
			super();
            UpdateButtonIcon();
		}
		
		override protected function updateText():void {
			super.updateText();
			
			if (_label != null && textField_disabled != null) {
                textField_disabled.text = _label;
            }
        }
        
        protected function UpdateButtonIcon():void
        {
			// # TODO, hacked away this feature for now. Remove hack when proper button system done
			// {
			keyboardButtonIcon.visible = false;
			gamepadButtonIcon.visible = false;
			// }
			
            /*if (InputManager.getInstance().isGamepad())
            {
                keyboardButtonIcon.visible = false;
                gamepadButtonIcon.visible = true;
                
                gamepadButtonIcon.gotoAndStop(_desiredNavCode);
            }
            else
            {
                keyboardButtonIcon.visible = true;
                gamepadButtonIcon.visible = false;
            }*/
        }
	}
}