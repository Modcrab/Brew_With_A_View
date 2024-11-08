package red.game.witcher3.hud 
{
	import scaleform.clik.controls.UILoader;
	
	public class LightweightUILoader extends UILoader 
	{
		// taken from UILoader
        override public function unload():void {
            if (loader != null) { 
                visible = _visiblilityBeforeLoad;
                loader.unloadAndStop( false );      // do not force GC to kick in
            }
            _source = null;
            _loadOK = false;
            _sizeRetries = 0;
        }		
	}

}