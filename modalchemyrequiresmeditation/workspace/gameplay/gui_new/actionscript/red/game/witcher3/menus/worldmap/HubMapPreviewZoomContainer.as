package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Bitmap;
		
	public class HubMapPreviewZoomContainer extends UIComponent
	{
		private var _loader : HubMapTileLoader;
		
		public function HubMapPreviewZoomContainer()
		{
			// constructor code
		}
		
		public function SetMapSettings( mapPath : String )
		{
			var texturePath : String = "img://maps/" + mapPath + "/level0/tile0x0.jpg";
			
			_loader = new HubMapTileLoader();
			_loader.addEventListener( Event.COMPLETE, handleImageLoaded, false, 0, true);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, handleImageFailed, false, 0, true );
			addChild( _loader );
			_loader.source = texturePath;
		}
		
		protected function handleImageLoaded(event:Event):void
		{
			var image : Bitmap = Bitmap( event.target.content );
			if ( image )
			{
				image.smoothing = true;
				
				_loader.x = -image.width / 2;
				_loader.y = -image.height / 2;
			}
		}
		
		protected function handleImageFailed(event:Event):void
		{
		}
	}
	
}
