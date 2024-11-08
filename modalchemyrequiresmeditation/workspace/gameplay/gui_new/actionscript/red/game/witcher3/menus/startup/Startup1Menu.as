package red.game.witcher3.menus.startup
{
	import flash.events.Event;
	import flash.display.MovieClip;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import flash.events.FocusEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import flash.events.MouseEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	
	public class Startup1Menu extends CoreMenu
	{
		public function Startup1Menu()
		{
			super();
		}

		override protected function get menuName():String
		{
			return "Startup1Menu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
					case NavigationCode.GAMEPAD_B:
					case NavigationCode.GAMEPAD_X:
					case NavigationCode.GAMEPAD_Y:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
						return;
				}
			}
		}

	}
}
