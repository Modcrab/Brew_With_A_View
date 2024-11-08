package red.game.witcher3.utils 
{
	import scaleform.clik.core.UIComponent;
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class CurrentActiveObject 
	{
		
		private var _focus:UIComponent;
		private var _lastFocus:UIComponent;
		private var _nextFocus:UIComponent;
		public function CurrentActiveObject() 
		{
			
		}
		
		public function get focus():UIComponent 
		{
			return _focus;
		}
		
		public function set focus(value:UIComponent):void 
		{
			if (_lastFocus!= _focus) 
			{
				_lastFocus = _focus;
			}
			
			_focus = value;
		}
		
		public function get lastFocus():UIComponent 
		{
			return _lastFocus;
		}
		
		public function get nextFocus():UIComponent 
		{
			return _nextFocus;
		}
		
		public function set nextFocus(value:UIComponent):void 
		{
			_nextFocus = value;
		}
		
	}

}