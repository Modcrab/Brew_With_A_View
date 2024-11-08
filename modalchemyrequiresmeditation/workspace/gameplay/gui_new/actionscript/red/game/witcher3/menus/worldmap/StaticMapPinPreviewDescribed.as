package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import red.game.witcher3.data.StaticMapPinData;
	import flash.geom.Point;
	import scaleform.clik.core.UIComponent;
	
	public class StaticMapPinPreviewDescribed extends UIComponent
	{
		public var id : uint;
		public var worldX : Number;
		public var worldY : Number;
		public var isPlayer : Boolean;
		
		public var data : StaticMapPinData;
		
		public var mcHighlight : MovieClip;
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
	}
}
