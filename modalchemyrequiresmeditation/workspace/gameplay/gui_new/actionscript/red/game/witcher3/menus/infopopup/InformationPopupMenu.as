/***********************************************************************
/** Generic information popup window with optional buttons
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Shadi Dadenji
/***********************************************************************/

package red.game.witcher3.menus.infopopup
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3TextArea;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	
	import red.core.CoreMenu;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;

	
	
	public class InformationPopupMenu extends CoreMenu
	{
	
		public var mcInfoPopupModule:InformationPopup;
		
		
		public function InformationPopupMenu()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function configUI():void
		{
			super.configUI();

			_inputHandlers.push(mcInfoPopupModule);
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			dispatchEvent( new GameEvent(GameEvent.CALL, "OnConfigUI"));			
		}
		
		
		override protected function get menuName():String
		{
			return "InformationPopupMenu";
		}
		

		override public function toString():String
		{
			return "[W3 InfoPopupMenu: ]";
		}

		
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if ( keyPress )
			{
				switch(details.navEquivalent)
				{
					case mcInfoPopupModule.btnFirst.navigationCode:
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnFirstButtonPress'));
						break;
					case mcInfoPopupModule.btnSecond.navigationCode:
						if(mcInfoPopupModule.bTwoButtons) dispatchEvent(new GameEvent(GameEvent.CALL, 'OnSecondButtonPress'));
						break;
				}
			}
		}
	}
}