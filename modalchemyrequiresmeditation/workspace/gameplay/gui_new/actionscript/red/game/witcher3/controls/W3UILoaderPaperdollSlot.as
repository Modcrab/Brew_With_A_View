/***********************************************************************
/** UILoader with loading default icon on load fail ( texture is centered)
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
	
    public class W3UILoaderPaperdollSlot extends W3UILoader //@FIXME BIDON - do it better.
    {
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
        public function W3UILoaderPaperdollSlot() 
		{
            super();
        }
		
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
        override public function toString():String 
		{
            return "[W3 W3UILoaderPaperdollSlot " + name + "]";
        }
		
		override protected function draw():void {
            if (!_loadOK) { return; }
            if (isInvalid(InvalidationType.SIZE)) {
                loader.scaleX = loader.scaleY = 1;
                if (!_autoSize) { 
                    visible = _visiblilityBeforeLoad;
                } 
                else {
                    if (loader.width <= 0) { 
                        if (_sizeRetries < 10) { 
                            _sizeRetries++;
                            invalidateData(); 
                        }
                        else { 
                            trace("Error: " + this + " cannot be autoSized because content width is <= 0!"); 
                        }
                        return; 
                    }
                    if (_maintainAspectRatio) { 
                        loader.scaleX = loader.scaleY = Math.min( height/loader.height, width/loader.width );
                        loader.x = (_width - loader.width >> 1);
                        loader.y = (_height - loader.height >> 1);
                    } else {
						//#B here are changes
						loader.x = - loader.width / 2;
						loader.y = - loader.height / 2;
                    }
                    visible = _visiblilityBeforeLoad;
                }
            }
        }
    }
}
