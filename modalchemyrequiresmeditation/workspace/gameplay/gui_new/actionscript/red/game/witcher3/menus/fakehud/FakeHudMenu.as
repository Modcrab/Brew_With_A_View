 package red.game.witcher3.menus.fakehud
{
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.core.constants.KeyCode;
	
	public class FakeHudMenu extends CoreMenu
	{
		
		public function FakeHudMenu():void
		{
			super();
		}
		
		override protected function get menuName():String
		{
			return "FakeHudMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
		}
		
		override public function handleInput(event:InputEvent):void
		{
            var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if ( keyPress )
			{
				switch( details.code )
				{
					case KeyCode.O :
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
						return;
				}
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B :
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
						return;
				}
			}
		}
	}
}