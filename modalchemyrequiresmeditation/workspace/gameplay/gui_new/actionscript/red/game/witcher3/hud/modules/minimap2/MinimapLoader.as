package red.game.witcher3.hud.modules.minimap2 
{
	import scaleform.clik.controls.UILoader;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MinimapLoader extends UILoader 
	{
		private var _loading : Boolean = false;

		public function IsLoading() : Boolean
		{
			return _loading;
		}
		
        override public function set source(value:String):void
		{ 
            if (_source == value)
			{
				return;
			}
            if ( value == "" || value == null )
			{
				_loading = false;
				if ( loader && loader.content )
				{
					unload();
				}
            }
            else
			{
				_loading = true;
                load(value);
            }
        }
		
		public function OnLoadingComplete()
		{
			_loading = false;
		}

		public function OnLoadingError()
		{
			_loading = false;
		}

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