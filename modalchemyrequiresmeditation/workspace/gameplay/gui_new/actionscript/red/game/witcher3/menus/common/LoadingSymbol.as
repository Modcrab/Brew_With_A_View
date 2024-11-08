/***********************************************************************
/** Loading Symbol and key feedback
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.managers.InputDelegate;
	
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	
	public class LoadingSymbol extends UIComponent
	{
		public var textField : TextField;
		public var mcLoading : MovieClip;
		public var mcSkipButton : InputFeedbackButton;
		
		protected var _isGamepad:Boolean;
		
		public function LoadingSymbol()
		{
			super();
			textField.htmlText = "[[panel_loading_screen_loading]]";
		}

		override protected function configUI():void
		{
			super.configUI();
			//InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			SetupButton();
		}
		
		override public function toString():String
		{
			return "[W3 LoadingSymbol: ]";
		}
		
		protected function SetupButton():void
		{
			_isGamepad = InputManager.getInstance().isGamepad();
			var curData:KeyBindingData = new KeyBindingData;
			curData.gamepad_navEquivalent = "enter-gamepad_A";
			curData.label = "[[panel_button_dialogue_skip]]";
			curData.keyboard_keyCode = 113;
				
			mcSkipButton.enabled = false;
			mcSkipButton.setData(curData, true);
			mcSkipButton.addEventListener( ButtonEvent.CLICK, handleButtonPress, false, 10, true);
		}
		
		/*
		 * #Y disabled for now, button fix required
		 
		protected function handleControllerChange( event:ControllerChangeEvent ):void
		{
			if ( _isGamepad != event.isGamepad )
			{
				SetupButton();
			}
		}
		*/
		
		protected function handleButtonPress(event:ButtonEvent):void
		{
			var mcButton:InputFeedbackButton = event.target as InputFeedbackButton;
		}
		
		override public function handleInput(event:InputEvent):void
		{
			if (event.handled) return;
			
			if( mcSkipButton.enabled )
			{
				dispatchEvent( new GameEvent(GameEvent.CALL,"OnSkipPressed"));
			}
		}
		
		public function enableSkip( value : Boolean ):void
		{
			trace("HUD LS enableSkip value " + value);
			
			if( mcSkipButton )
			{
				mcSkipButton.enabled = value;
				mcSkipButton.visible = value;
				mcLoading.visible = !value;
				if ( value )
				{
					textField.htmlText = "";
				}
				else
				{
					textField.htmlText = "[[panel_loading_screen_loading]]";
				}
			}
		}
	}
}
