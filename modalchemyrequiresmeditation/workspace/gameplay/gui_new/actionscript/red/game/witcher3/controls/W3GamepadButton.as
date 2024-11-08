package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.GamepadButton;
	import red.game.witcher3.utils.motion.TweenEx;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import flash.text.TextFieldAutoSize;
	
	import fl.transitions.easing.Strong;
	
	public class W3GamepadButton extends GamepadButton
	{

	//{region Art clips
	// ------------------------------------------------
		
		public var mcIcon : MovieClip;
	
	//{region Internal properties
	// ------------------------------------------------
		
		public var index : int = -1;
	
	//{region Private constants
	// ------------------------------------------------
	
		private static const ICON_GROW_DURATION = 200;
		
	//{region Component setters/getters
	// ------------------------------------------------
	
		override public function set navigationCode( value:String ):void
		{
			super.navigationCode = value;
			
			if ( mcIcon )
			{
				mcIcon.gotoAndStop(value);
				if( mcIcon.getChildByName("mcIconText") != null )
				{
					var mcIconText : MovieClip = MovieClip(mcIcon.getChildByName("mcIconText"));
					mcIconText.gotoAndStop(value);
				}
				invalidateData();
			}
		}

		override public function set label(value:String):void {
            if (_label == value) { return; }
            _label = value;
            updateText();
        }
		
		/** @private */
        override protected function updateText():void {
            if (_label != null && textField != null) {
				//textField.autoSize = TextFieldAutoSize.LEFT;
                textField.text = _label;
            }
        }
		
	//{region Overrides
	// ------------------------------------------------
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( enabled )
			{
				var details:InputDetails = event.details;
				
				if ( details.navEquivalent == navigationCode )
				{
					if (details.value == InputValue.KEY_DOWN)
					{
						TweenEx.pauseTweenOn(mcIcon);
						TweenEx.to(ICON_GROW_DURATION, mcIcon, { scaleX:0.8, scaleY:0.8 }, { paused:false, ease:Strong.easeOut } );
					}
					else if (details.value == InputValue.KEY_UP)
					{
						TweenEx.pauseTweenOn(mcIcon);
						TweenEx.to(ICON_GROW_DURATION, mcIcon, { scaleX:1, scaleY:1 }, { paused:false, ease:Strong.easeOut } );
					}
					super.handleInput(event);
				}
			}
		}
		
		override protected function updateAfterStateChange():void 
		{
			//trace("Bidon: W3 gamepad "+state+" this.name "+this.name);
			super.updateAfterStateChange();
			/*if (state == 'down')
			{
				TweenEx.pauseTweenOn(mcIcon);
				TweenEx.to(ICON_GROW_DURATION, mcIcon, { scaleX : 0.8 ,scaleY : 0.8 }, { paused:false, ease:Strong.easeOut } );
			}
			else if (state == "release")
			{
					TweenEx.pauseTweenOn(mcIcon);
					TweenEx.to(ICON_GROW_DURATION, mcIcon, {  scaleX : 1 , scaleY : 1 }, { paused:false, ease:Strong.easeOut } );
			}*/
		}
		
		public function setStateExternal(state : String):void
		{
			setState(state);
		}
	}

}