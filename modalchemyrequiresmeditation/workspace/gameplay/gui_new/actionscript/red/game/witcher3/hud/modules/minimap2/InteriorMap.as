package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.geom.Point;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;

	public class InteriorMap extends BaseMap
	{
		public var mcInteriorMapContainer : InteriorMapContainer;
		public var mcInteriorBackground : MovieClip;

		public function InteriorMap()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}

		override public function SetScale( value : Number )
		{
			var coef : Number = HudModuleMinimap2.GetCoef( true );
			var finalScale = ZOOM_COEF * coef * value;

			scaleX = finalScale;
			scaleY = finalScale;
			
			mcInteriorBackground.scaleX = 1 / actualScaleX;
			mcInteriorBackground.scaleY = 1 / actualScaleY;
		}

	}
	
}
