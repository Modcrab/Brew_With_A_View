package red.game.witcher3.controls 
{
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	
	/**
	 * For InputFeedbackButton
	 * @author Getsevich Yaroslav
	 */
	public class KeyboardButtonMouseIcon extends MovieClip
	{
		private const LABEL_BTN_LEFT:String = "left";
		private const LABEL_BTN_RIGHT:String = "right";
		private const LABEL_BTN_MIDDLE:String = "middle";
		private const LABEL_SCROLL_UP:String = "scroll_up";
		private const LABEL_SCROLL_DOWN:String = "scroll_down";
		private const LABEL_PAN:String = "pan";
		private const LABEL_SCROLL:String = "scroll";
		private const LABEL_MOVE:String = "move";
		
		protected var _keyCode:uint;
		
		public function isMouseKey(keyCode:uint):Boolean
		{
			return keyCode >= KeyCode.LEFT_MOUSE && keyCode <= KeyCode.MIDDLE_MOUSE 
			|| keyCode == KeyCode.MOUSE_WHEEL_UP 
			|| keyCode == KeyCode.MOUSE_WHEEL_DOWN 
			|| keyCode == KeyCode.MOUSE_PAN 
			|| keyCode == KeyCode.MOUSE_SCROLL
			|| keyCode == KeyCode.MOUSE_MOVE;
		}
		
		public function get keyCode():uint { return _keyCode }
		public function set keyCode(value:uint):void
		{
			_keyCode = value;
			updateIcon();
		}
		
		protected function updateIcon():void
		{
			switch (_keyCode)
			{
				case KeyCode.LEFT_MOUSE:
					gotoAndStop(LABEL_BTN_LEFT);
					break;
				case KeyCode.RIGHT_MOUSE:
					gotoAndStop(LABEL_BTN_RIGHT);
					break;
				case KeyCode.MIDDLE_MOUSE:
					gotoAndStop(LABEL_BTN_MIDDLE);
					break;
				case KeyCode.MOUSE_WHEEL_UP:
					gotoAndStop(LABEL_SCROLL_UP);
					break;
				case KeyCode.MOUSE_WHEEL_DOWN:
					gotoAndStop(LABEL_SCROLL_DOWN);
					break;
				case KeyCode.MOUSE_SCROLL:
					gotoAndStop(LABEL_SCROLL);
					break;
				case KeyCode.MOUSE_PAN:
					gotoAndStop(LABEL_PAN);
				case KeyCode.MOUSE_MOVE:
					gotoAndStop(LABEL_MOVE);
					break;
			}
		}
		
	}

}
