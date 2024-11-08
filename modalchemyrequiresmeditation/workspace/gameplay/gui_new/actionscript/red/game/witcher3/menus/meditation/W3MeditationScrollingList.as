/***********************************************************************
/** Meditation scrolling list
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation
{
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.controls.ScrollingList;
		
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	
	import scaleform.clik.constants.WrappingMode;
    import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.controls.ScrollIndicator;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3ScrollingList;

	public class W3MeditationScrollingList extends W3ScrollingList
	{
		public function W3MeditationScrollingList()
		{
			super();
		}
		
		// Protected Methods:
        override protected function configUI():void
		{
            super.configUI();
        }

        override public function handleInput(event:InputEvent):void
		{
			if( event.handled /*|| !focused*/ )
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			if ( details.code > 500 )
			{
				return;
			}

			var renderer : BaseListItem;
			switch( details.navEquivalent ) // #B quick hax
			{
                case NavigationCode.DOWN:
					selectedIndex = 2;
                    break;
                case NavigationCode.UP:
					selectedIndex = 0;
                    break;
                case NavigationCode.LEFT:
					selectedIndex = 3;
                    break;
                case NavigationCode.RIGHT:
					selectedIndex = 1;
                    break;
				case NavigationCode.GAMEPAD_A:
				case NavigationCode.ENTER:
					renderer = getRendererAt(selectedIndex) as BaseListItem;
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestSubMenu",[renderer.data.subPanelName] ) );
                    break;
                default:
                    return;
            }
        }
			
		override public function toString():String
		{
			return "[W3 W3MeditationScrollingList "+ this.name+" ]";
		}
	}
}
