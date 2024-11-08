/***********************************************************************/
/** Action Script file - Meditation Menu Base Class
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation {
	
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.gfx.Extensions;
	
	// INPUT
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.game.witcher3.controls.W3GamepadButton;
	import red.core.CoreMenu;
	import scaleform.clik.core.UIComponent;
	
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class MeditationMenu extends CoreMenu
	{
		public var mcExitBtn:W3GamepadButton;
		public var mcMeditationModule:MeditationMainModule;

		protected var _inputHandlers:Vector.<UIComponent>;
		private	var	bHandleInputHax	: Boolean = true;

		public function MeditationMenu()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			SetupButtons();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			focused = 1;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "restore.input",[restoreInput] ) );
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, "meditation.input",[restoreInput] ) );
			//@TODO Add meditation main title set and localization
		}
				
		override protected function get menuName():String
		{
			return "MeditationMenu";
		}
		
		function restoreInput( value : Boolean ) : void //#B HAX
		{
			bHandleInputHax = value;
			mcExitBtn.visible = value;
		}
		
		private function SetupButtons():void
		{
			mcExitBtn.addEventListener(ButtonEvent.CLICK, onClosePanel, false, 0, false);
			mcExitBtn.navigationCode = NavigationCode.GAMEPAD_B;
			
			_inputHandlers.push( mcMeditationModule );
			_inputHandlers.push( mcExitBtn );
			
			mcExitBtn.label = "[[panel_button_common_exit]]";
		}

		private function onClosePanel ( ) : void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, 'OnCloseMenu'));
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled 	|| !bHandleInputHax )
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			for each ( var handler:UIComponent in _inputHandlers )
			{
				handler.handleInput( event );
				if ( event.handled )
				{
					return;
				}
			}
			return;
		}
	}
}
