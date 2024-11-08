package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	public class BaseMap extends UIComponent
	{
		protected static const ZOOM_COEF : Number = 3;

		public function SetRotation( angle : Number ) {}
		public function SetScale( value : Number ) {}
		public function UpdatePosition() : Boolean { return false; }
		
		public function ResetZoom()
		{
			SetScale( 1 );
		}


	}
	
}
