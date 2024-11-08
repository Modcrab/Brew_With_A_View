package red.game.witcher3.controls 
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class KeyboardButtonClickArea extends UIComponent
	{
		protected var _state:String;
		public function get state():String { return _state }
		public function set state(value:String):void
		{
			var newState:String = value;
			
			if (!_labelHash[newState])
			{
				newState = "up";
			}
			
			if (_state != newState)
			{
				_state = newState;
				gotoAndPlay(_state);
			}
		}
		
	}
}
