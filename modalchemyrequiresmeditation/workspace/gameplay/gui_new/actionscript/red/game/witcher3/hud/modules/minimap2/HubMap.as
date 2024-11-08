package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.utils.Dictionary;
	import red.game.witcher3.hud.modules.minimap2.MapPin;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import flash.utils.getDefinitionByName;

	public class HubMap extends BaseMap
	{
		public var mcHubMapContainer : HubMapContainer;

		public function HubMap()
		{
			super();
		}

		override public function SetScale( value : Number )
		{
			var coef : Number = HudModuleMinimap2.GetCoef( false );
			var finalScale = ZOOM_COEF * coef * value;

			scaleX = finalScale;
			scaleY = finalScale;
		}


	}

}
