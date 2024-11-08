package red.game.witcher3.controls
{    
	import scaleform.clik.controls.Label;

	[Event(name = "change", type = "flash.events.Event")]

	public class Label extends scaleform.clik.controls.Label
	{
		public function Label()
		{
			super();
		} 
		
		/*override public function get defaultState():String {
			var str : String;
			str = !enabled ? "disabled" : (focused ? "focused" : "default");
			trace(toString()+" defaultState " + str +" enabled "+enabled + " focused "+focused+" focusable "+focusable);
            return (str);
        }*/
		
		// Public getter / setters:
        [Inspectable(defaultValue="0")]
        override public function get focused():Number { return super.focused; }
        override public function set focused(value:Number):void {
            if (value == super.focused || !super.focusable) { return; }
            super.focused = value;
            setState(defaultState);
        }
		
		override public function set text(value:String):void {
			if (value == null) { 
                value == ""; 
            }
            isHtml = false;
            _text = value;
            invalidateData();
        }
	}
}