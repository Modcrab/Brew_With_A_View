/***********************************************************************
/** Generic information popup window with optional buttons
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Shadi Dadenji
/***********************************************************************/

package red.game.witcher3.menus.infopopup
{
	import flash.display.MovieClip;
	import flash.text.TextField;	
	import flash.text.TextFieldAutoSize;
	
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;

	import red.core.events.GameEvent;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3GamepadButton;

	
	public class InformationPopup extends CoreComponent
	{
		public var mcTextArea : W3TextArea;
		public var btnFirst : W3GamepadButton;
		public var btnSecond : W3GamepadButton;
		public var mcTextAreaBck : MovieClip;
		public var bTwoButtons : Boolean;
		
		public function InformationPopup()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		
		override protected function configUI():void
		{
			super.configUI();
			
			//by default, we always have one OK button to confirm/dismiss the window
			btnFirst.label = "[[panel_button_common_close]]";			
			btnFirst.navigationCode = NavigationCode.GAMEPAD_A;

			btnFirst.addEventListener( ButtonEvent.CLICK, handleButtonOne, false, 150 , true );
			_inputHandlers.push( btnFirst );

			btnSecond.visible = false;
			arrangeButtons(false);							
			bTwoButtons = false;
			
			visible = false;
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "popup.info.text", 		[handleSetPopupText]));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "popup.info.button1", 	[SetFirstButton]));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "popup.info.button2", 	[SetSecondButton]));			
		}
		
		private function handleSetPopupText(value:String) : void
		{
			mcTextArea.textField.htmlText = value;
			visible = true;
			
			//this stuff doesn't work well because of the way the background resizes (surrounding shadow). the text ends up outside the box. @SD
			//mcTextArea.textField.autoSize = TextFieldAutoSize.CENTER;			
			//mcTextAreaBck.height = mcTextArea.textField.textHeight * 2;
			//mcTextAreaBck.y = mcTextArea.y;
		}
		
		private function SetFirstButton(gameData:Object, index:int) : void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array;
			
				btnFirst.label = dataArray[0].label;			
				btnFirst.navigationCode = dataArray[0].icon

				btnFirst.addEventListener(ButtonEvent.CLICK, handleButtonOne, false, 150 , true);				
				_inputHandlers.push(btnFirst);				
			}
		}
		
		private function SetSecondButton(gameData:Object, index:int) : void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array;

				btnSecond.label = dataArray[0].label;			
				btnSecond.navigationCode = dataArray[0].icon

				arrangeButtons(true);
				btnSecond.visible = true;
				bTwoButtons = true;
				
				btnSecond.addEventListener(ButtonEvent.CLICK, handleButtonTwo, false, 150 , true);
				_inputHandlers.push(btnSecond);
			}
		}		
		

		private function handleButtonOne(event:ButtonEvent) : void
		{
			event.stopImmediatePropagation();
		}

		private function handleButtonTwo(event:ButtonEvent) : void
		{
			event.stopImmediatePropagation();
		}

		private function arrangeButtons(bTwoButtons:Boolean) : void
		{
			if (bTwoButtons)
			{
				btnFirst.x = mcTextArea.x + (mcTextArea.width / 3);
				btnSecond.x = mcTextArea.x + 2*(mcTextArea.width / 3);
			}
			else
				btnFirst.x = mcTextArea.x + (mcTextArea.width / 2);				
		}
		
		override public function toString():String
		{
			return "[W3 InformationPopup: ]";
		}
	}
}