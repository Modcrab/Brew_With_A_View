/***********************************************************************
/** Main Options Menu class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	public class AutosaveWarningMenu extends CoreMenu
	{
		public var mcIndicatorSave:MovieClip;
		public var txtAutosaveWarning:TextField;
		public var mcSkipButton:InputFeedbackButton;

		private var showTimer:Timer;
		private var closing:Boolean = false;

		private var menuShown:Boolean = false;

		override protected function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}

		override protected function get menuName():String
		{
			return "AutosaveWarningMenu";
		}

		public function showSaveIdicator():void
		{
			mcIndicatorSave.gotoAndPlay("activate");
		}

		override public function setPlatform(platformType:uint):void
		{
			super.setPlatform(platformType);

			mcSkipButton.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.ESCAPE);
			mcSkipButton.label = "[[panel_button_dialogue_skip]]";
			mcSkipButton.clickable = false;
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
			// Override to remove all default menu navigation behavior
			if (menuShown && !closing)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);

				if (keyUp && details.navEquivalent == NavigationCode.GAMEPAD_X)
				{
					closing = true;
					showTimer.stop();
					hideAnimation();
				}
			}
		}

		public function setAutosaveMessage(message:String):void
		{
			txtAutosaveWarning.htmlText = message;
		}

		public function setShowTimerDuration(duration:int):void
		{
			showTimer = new Timer(duration, 1);
		}

		override protected function handleShowAnimComplete(instTween:GTween):void
		{
			menuShown = true;
			super.handleShowAnimComplete(instTween);
			showSaveIdicator();

			if (!showTimer)
			{
				showTimer = new Timer(3000, 1);
			}

			showTimer.addEventListener(TimerEvent.TIMER, showTimerEnded);
			showTimer.start();
		}

		function showTimerEnded(event:TimerEvent):void
		{
			hideAnimation();
		}
	}
}