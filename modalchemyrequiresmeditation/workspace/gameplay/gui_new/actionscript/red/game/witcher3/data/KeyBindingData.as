package red.game.witcher3.data
{
	import red.game.witcher3.constants.KeyboardKeys;
	
	/**
	 * Data for input feedback control
	 * @author Yaroslav Getsevich
	 */
	public class KeyBindingData
	{
		public var actionId:uint;
		public var gamepad_navEquivalent:String = "";
		public var keyboard_keyCode:int;
		public var label:String;
		public var level:int; // binding priority, if we have several equal bindings, one with highest level will be shown
		public var isContextBinding:Boolean; // @deprecated
		public var gamepad_keyCode:int = -1;
		public var disabled:Boolean;
		public var contextId:int; // optional param, ref to menuName
		public var holdDuration:Number;
		public var hasHoldPrefix:Boolean;
		public var altKeyCode:int;

		public function toString():String
		{
			return "[KeyBindingData: " + label + " " + keyboard_keyCode + " " + gamepad_navEquivalent + " ]";
		}
	}
}
