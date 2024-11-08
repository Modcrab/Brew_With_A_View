/***********************************************************************
/** ABSTRACT LIST ITEM RENDERER
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.core.UIComponent;
	import red.core.CoreComponent;

	public class BaseListItem extends ListItemRenderer
	{
		public function BaseListItem()
		{
			super();
			doubleClickEnabled = true;
			preventAutosizing = true;
			constraintsDisabled = true;
		}

		protected override function configUI():void
		{
			super.configUI();
		}

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}

		//overriding this coz the base function doesn't use htmlText which doesn't allow us to employ colors
        override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					textField.htmlText = "<p align=\"right\">" + _label + "</p>";
					return;
				}
                textField.htmlText = _label;
            }
        }
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if (! data )
			{
				return;
			}
			if(data.selected)
			{
				selected = true;
			}
			update();
		}

		public function hasData():Boolean
		{
			return data != null;
		}

		override protected function updateAfterStateChange():void {}

		protected function update(){}

		public var canBePressed:Boolean = true;
		override public function handleInput(event:InputEvent):void
		{
            if (event.isDefaultPrevented() || !canBePressed)
			{
				return;
			}
            var details:InputDetails = event.details;
            var index = details.controllerIndex;

            switch (details.navEquivalent)
			{
                case NavigationCode.ENTER:
                case NavigationCode.GAMEPAD_A:
                    if (details.value == InputValue.KEY_DOWN)
					{
                        handlePress(index);
                        event.handled = true;
                    }
                    else if (details.value == InputValue.KEY_UP)
					{
                        if (_pressedByKeyboard) {
                            handleRelease(index);
                            event.handled = true;
                        }
                    }
                    break;
				default:
					break;
            }
        }
		
		public function getRendererWidth():Number { return actualWidth; }
		public function getRendererHeight():Number { return actualHeight; }
	}
}
