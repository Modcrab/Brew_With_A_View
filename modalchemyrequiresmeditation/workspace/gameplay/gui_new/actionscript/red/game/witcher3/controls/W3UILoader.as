/***********************************************************************
/** UILoader with loading default icon on load fail
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.events.Event;
    import flash.net.URLRequest;
	import flash.display.DisplayObject;
	
	import flash.utils.getDefinitionByName;
	
	import scaleform.clik.controls.Label;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.constants.InvalidationType;
	
    public class W3UILoader extends UILoader
    {
		public var fallbackIconPath : String = "icons/inventory/raspberryjuice_64x64.dds"; //#B temp default icon
		private var tmpHackTextField : Label
		private var fallbackLoad : Boolean = true;
		private var _gridSize : int = 0;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
        public function W3UILoader()
		{
            super();
        }
		
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
        override protected function handleLoadIOError( ioe : Event ) : void
		{
			if( fallbackLoad )
			{
				unload();
				loader.load( new URLRequest(fallbackIconPath) );
				visible = true;
				
				/*if ( !tmpHackTextField )
				{
					var ref : Class = getDefinitionByName( 'W3DebugLabel' ) as Class;
					tmpHackTextField  =	new ref();
				}
				
				var tmpStr : String = source;
				tmpStr = tmpStr.replace("img://", "");
				tmpStr = tmpStr.replace("icons/items/", "");
				tmpStr = tmpStr.replace("_64x64", "");
				tmpStr = tmpStr.replace(".dds", "");
							
				tmpHackTextField.text = tmpStr;
				tmpHackTextField.visible = true;
				
				addChild( tmpHackTextField );	*/

				fallbackLoad = false;
			}
			else
			{
				trace("Bidon: Couldn't load fallback icon: "+fallbackIconPath);
				return;
			}
		}
		
		override public function set source(value:String):void
		{
			fallbackLoad = true;
/*			if ( value != "" )
			{
				_visiblilityBeforeLoad = true;
			}*/
			
/*			if ( value && value != "" )
			{
				visible = true;
			}
			else
			{
				visible = false;
			}*/

			if ( super.source != value )
			{
				super.source = value;
			}
			
			if ( value && value != "" )
			{
				visible = true;
			}
			else
			{
				visible = false;
			}
		}

        override public function unload():void {
			super.unload();
			if (tmpHackTextField)
			{
				tmpHackTextField.visible = false;
				removeChild( tmpHackTextField );
			}
        }
		
		override public function get content() : DisplayObject
		{
			if (loader.content == null )
			{
				return null;
			}
            return loader.content;
        }
		
        override public function toString():String
		{
            return "[W3 W3UILoader " + name + "]";
        }
		
		public function set GridSize( value : int ) : void
		{
			_gridSize = value;
		}
		
		public function get GridSize( ) : int
		{
			return _gridSize;
		}
		
		override protected function draw():void
		{
            if (!_loadOK) { return; }
			if ( GridSize > 0  && isInvalid(InvalidationType.SIZE) )
			{
				loader.scaleX = loader.scaleY = 1;
				visible = _visiblilityBeforeLoad;
				if ( GridSize > 3 )
				{
					loader.height = GridSize / 2 * 64;
					loader.width = GridSize / 2 * 64;
				}
				else
				{
					loader.height = GridSize * 64;
					loader.width = 64;
				}
			}
			else
			{
				super.draw();
			}
        }
		
		/*
		// avoid click invalidation system for tweens
		override public function get scaleX():Number { return super.actualScaleX; }
		override public function get scaleY():Number { return super.actualScaleY; }	
		*/
    }
}
