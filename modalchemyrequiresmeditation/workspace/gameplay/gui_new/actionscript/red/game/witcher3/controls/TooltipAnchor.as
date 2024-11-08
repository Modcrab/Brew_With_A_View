package red.game.witcher3.controls
{
	import flash.text.TextFormatAlign;
	import red.game.witcher3.constants.TooltipAlignment;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;
	
	// used in the mutations panel
	// red.game.witcher3.controls.TooltipAnchor
	//
	
	public class TooltipAnchor extends UIComponent
	{
		override protected function configUI():void
		{
			super.configUI();
			mouseEnabled = mouseChildren = false;
			//visible = true;
			visible = false;
		}
		
		private var _alignment:String = "BottomRight";
		[Inspectable(name = "alignment", type = "list", enumeration = "TopRight, TopLeft, BottomRight, BottomLeft", defaultValue="BottomRight")]
        public function get alignment():String { return _alignment; }
        public function set alignment(value:String):void
		{
			_alignment = value;
		}
		
	}
}
