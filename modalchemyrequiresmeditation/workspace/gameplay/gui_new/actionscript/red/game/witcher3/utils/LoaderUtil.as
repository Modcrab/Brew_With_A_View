package red.game.witcher3.utils 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class LoaderUtil 
	{
		
		public function LoaderUtil() 
		{
			
		}
		
		public static function loadAndCenterImage(loader:Loader,path:String):void 
		{
			loader.visible = false;
			
				try
				{
					
					loader.close();
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, hCompleteLoad);
				}
				catch (err:Error)
				{
					
				}
				
				loader.unload();
				
			
				
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, hCompleteLoad);
			loader.load(new URLRequest(path));
			
		}
		
		static private function hCompleteLoad(e:Event):void 
		{
			var li:LoaderInfo = e.target as LoaderInfo;
			li.content.x = -li.content.width / 2;
			li.content.y = -li.content.height / 2;
			
			li.removeEventListener(Event.COMPLETE, hCompleteLoad);
			li.loader.visible = true;
		}
		
	}

}