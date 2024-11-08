/***********************************************************************
/** PANEL Character button container module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.menus.common.SkillDataStub;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.events.GridEvent;
	//import scaleform.clik.constants.NavigationCode;
	
	public class CharacterButtonContainerModule extends UIComponent
	{
		public var btnPreview : W3GamepadButton;
		public var btnContext : W3GamepadButton;
		
		protected var _activeSkillDataStub:SkillDataStub;
		protected var _inputHandlers:Vector.<UIComponent>;
		
		public function CharacterButtonContainerModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function configUI():void
		{
			super.configUI();
			setupButtons();
		}
		
		protected function setupButtons() : void
		{
			btnContext.addEventListener( ButtonEvent.CLICK, handleButtonContextActivateItem, false, 10, true );
			btnContext.navigationCode = NavigationCode.GAMEPAD_A;
			_inputHandlers.push( btnContext );
			
			btnPreview.label = "[[panel_button_inventory_preview_char]]";
			btnPreview.addEventListener( ButtonEvent.CLICK, handleButtonPreview, false, 0, true );
			btnPreview.navigationCode = NavigationCode.GAMEPAD_L1;
			_inputHandlers.push( btnPreview );
		}
		
		public function SetActiveSkillDataStub( inActiveSkillDataStub : SkillDataStub ) : void
		{
			_activeSkillDataStub = inActiveSkillDataStub;
			UpdateButtons();
		}
		
		override public function toString():String
		{
			return "[W3 ButtonContainerModule: ]";
		}
		
		private function UpdateButtons() : void
		{
			if( _activeSkillDataStub )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateCharacterButtons", [ _activeSkillDataStub.abilityName ] ));
				btnContext.label = "[[panel_button_character_buy_skill]]";
				btnContext.enabled = true;
				btnContext.visible = true;
			}
			else
			{
				btnContext.label = "";
				btnContext.enabled = false;
				btnContext.visible = false;
			}
		}
		
		private function handleButtonContextActivateItem( event : ButtonEvent ):void
		{
			if ( _activeSkillDataStub )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnBuySkill", [ _activeSkillDataStub.abilityName ] ));
			}
		}
		
		private function handleButtonMoreInfo( event : ButtonEvent ):void
		{
			trace("CHARACTER: handleButtonMoreInfo");
		}
		
		private function handleButtonPreview( event : ButtonEvent ):void
		{
			trace("CHARACTER: handleButtonPreview");
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
	
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
		}
	}
}