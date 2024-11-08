package red.game.witcher3.controls 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Keyboard button icon
	 * @author Yaroslav Getsevich
	 */
	public class KeyboardButtonIcon extends MovieClip
	{
		protected static const TEXT_OFFSET:Number = 5; // Hack to prevent text's cutting 
		protected static const MIN_SIZE:Number = 42;
		
		protected static const POS_LEFT_X:Number = 5;
		protected static const POS_LEFT_X_BIG:Number = 10;
		
		public var mcBackground:Sprite;
		public var textField:TextField;
		
		protected var _label:String;
		public function get label():String { return _label }
		public function set label(value:String):void
		{
			_label = value;
			textField.text = _label;
			var curWidth:Number = textField.textWidth + TEXT_OFFSET;
			textField.width = curWidth;
			if ((POS_LEFT_X_BIG + curWidth) > MIN_SIZE)
			{
				mcBackground.width = curWidth + POS_LEFT_X_BIG;
				textField.x = POS_LEFT_X;
			}
			else
			{
				mcBackground.width = MIN_SIZE;
				textField.x = (mcBackground.width - curWidth) / 2;
			}
		}
		
		protected var _backgroundVisibility:Boolean;
		public function get backgroundVisibility():Boolean { return _backgroundVisibility }
		public function set backgroundVisibility(value:Boolean):void
		{
			_backgroundVisibility = value;
			mcBackground.visible = _backgroundVisibility;
		}
	}

}
