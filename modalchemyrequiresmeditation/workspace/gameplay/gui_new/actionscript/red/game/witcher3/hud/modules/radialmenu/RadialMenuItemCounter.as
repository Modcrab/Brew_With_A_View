package red.game.witcher3.hud.modules.radialmenu
{
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * [HUD] Simple stepper for radial menu
	 * red.game.witcher3.hud.modules.radialmenu.RadialMenuItemCounter
	 * @author Getsevich Yaroslav
	 */
	public class RadialMenuItemCounter extends UIComponent
	{
		public var tfValue : TextField;
		private var _maximum : int;
		private var _value   : int;
		
		public function RadialMenuItemCounter()
		{
			visible = false;
		}
		
		public function get maximum():int { return _maximum; }
		public function set maximum(value:int):void
		{
			_maximum = value;
			updateVisuals();
		}
		
		public function get value():int { return _value; }
		public function set value(value:int):void
		{
			_value = value;
			updateVisuals();
		}
		
		protected function updateVisuals():void
		{
			if (_maximum < 2)
			{
				visible = false;
			}
			else
			{
				visible = true;
				_value = Math.min( Math.max( 1, _value ), _maximum );
				tfValue.text =  "< " + _value + "/" + _maximum + " >";
			}
		}
		
	}

}
