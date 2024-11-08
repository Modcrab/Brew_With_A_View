/***********************************************************************
/** Main Menu Gamma class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

	import scaleform.clik.events.InputEvent;
	import red.core.constants.KeyCode;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.data.InputAxisData;

	import scaleform.clik.controls.Slider;
	import scaleform.clik.events.SliderEvent;

	public class MainMenuGamma extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		//public var dataBindingKey : String = "mainmenu.main.entries";
		
		public var mcGammaModule:GammaSettingModule;
		public var mcInputFeedbackModule:ModuleInputFeedback;
		
		public var txtUserName:TextField;

		public function MainMenuGamma()
		{
			super();
		}
		
		public function setCurrentUsername(name:String):void
		{
			if (txtUserName)
			{
				txtUserName.text = name;
			}
		}

		override protected function get menuName():String
		{
			return "MainGammaMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			
			setCurrentUsername("");
			
			if (mcGammaModule)
			{
				mcGammaModule.addEventListener( IngameMenu.OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "gammamenu.setvalues", [handleRecieveGamma] ) );
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			mcInputFeedbackModule.appendButton(0, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", false);
			mcInputFeedbackModule.appendButton(1, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_continue]]", true);
		}

		public function SetInitialGamma( value : Number )
		{
		}

		private function handleSliderValueChange( event : SliderEvent )
		{
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
			mcGammaModule.handleInputNavigate(event);
			
			var details:InputDetails = event.details;
			var keyUp:Boolean = (details.value == InputValue.KEY_UP);
			
			if ( keyUp && !event.handled )
			{
				switch(details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_A:
					{
						closeMenu();
						event.handled = true;
					}
					break;
				}
			}
			
			if ( keyUp && !event.handled && 
				(details.code == KeyCode.SPACE || details.code == KeyCode.ENTER || details.code == KeyCode.E))
			{
				closeMenu();
				event.handled = true;
			}
		}
		
		protected function handlePanelClosed(event:Event):void
		{
			closeMenu();
		}
		
		protected function handleRecieveGamma(gammaData:Object):void
		{
			if (mcGammaModule)
			{
				mcGammaModule.showWithData(gammaData);
			}
		}
	}
}
