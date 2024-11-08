package red.game.witcher3.menus.worldmap 
{
	import scaleform.clik.controls.UILoader;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HubMapTileLoader extends UILoader 
	{
		// taken from UILoader
        override public function unload():void {
            if (loader != null) { 
                visible = _visiblilityBeforeLoad;
                loader.unloadAndStop(false);
            }
            _source = null;
            _loadOK = false;
            _sizeRetries = 0;
        }		
	}

}
