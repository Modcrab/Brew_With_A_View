package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Simple color'ed sprite with color bline mode
	 * @author Yaroslav Getsevich
	 */
	public class ColorSprite extends UIComponent
	{
		public static const COLOR_NONE:String = "none";
		public static const COLOR_YELLOW:String = "red"; //"yellow"; // #Y old label, TODO: Change label name in the gfxassetslib
		public static const COLOR_GREEN:String = "green";
		public static const COLOR_BLUE:String = "blue";
		public static const COLOR_ORANGE:String = "orange";
		
		public var mcColorBlind:MovieClip;
		public var mcColor:MovieClip;
		
		public function ColorSprite()
		{
			mcColorBlind.visible = false;
		}
		
		protected var _colorBlind:Boolean;
		public function get colorBlind():Boolean { return _colorBlind }
		public function set colorBlind(value:Boolean):void
		{
			_colorBlind = value;
			mcColorBlind.visible = _colorBlind;
		}
		
		protected var _color:String;
		public function get color():String { return _color };
		public function set color(value:String):void
		{
			_color = value;
			updateColor();
		}
		
		protected function updateColor():void
		{
			if (_color)
			{
				mcColorBlind.gotoAndStop(_color);
				mcColor.gotoAndStop(_color);
			}
		}
		
		public function setByItemQuality(itemQuality:int):void
		{
			switch (itemQuality)
			{
				case 0:
				case 1:  // common // 0x7b7877 // white
					color = COLOR_NONE;
					break;
				case 2: // masterwork // 0x3661dc // blue
					color = COLOR_BLUE;
					break;
				case 3: // magic // 0x959500 // yellow
					color = COLOR_YELLOW;
					break;
				case 4: // relic // 0x934913 // orange
					color = COLOR_ORANGE;
					break;
				case 5: // set // 0x197319 // green
					color = COLOR_GREEN;
					break;
			}
		}
		
		public function setBySkillType(skillType:String):void
		{
			switch (skillType)
			{
				case "SC_None":
					color = COLOR_NONE;
					break;
				case "SC_Blue":
					color = COLOR_BLUE;
					break;
				case "SC_Green":
					color = COLOR_GREEN;
					break;
				case "SC_Yellow":
					color = COLOR_YELLOW;
					break;
				case "SC_Red":
					color = COLOR_ORANGE;
					break;
			}
		}
		
		override public function toString():String 
		{
			return "ColorSprite [" + this.name + "]";
		}
	}
}
