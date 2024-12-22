package red.game.witcher3.menus.meditation_menu
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.core.utils.InputUtils;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.gfx.MouseEventEx;
	import flash.events.Event;
	
	/**
	 * Brew With A View panel to confirm intent when switching tabs in common menu
	 * @author Modcrab
	 */
	public class ModConfirmIntentPanel extends UIComponent
	{
		private const PANEL_CENTER:Number = 326;

		// references to elements in stage, the names must match the instance name
		public var mcActivateButton:InputFeedbackButton;
		public var mcActivateButtonPc:InputFeedbackButton;
		public var lbPanelTextField:TextField;

		private var _confirmIntentMode:Boolean = false;
		private var _confirmedIntent:Boolean = false;
		private var _panelText:String = "";
		private var _buttonPromptLabel:String = "";

		public function ModConfirmIntentPanel()
		{
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
		}

		public function ModcrabSetIsInConfirmIntentMode(value:Boolean, panelText:String, buttonPromptLabel:String):void
		{
			_confirmIntentMode = value;
			_panelText = panelText;
			_buttonPromptLabel = buttonPromptLabel;
			visible = value;

			if (!value)
				return;

			mcActivateButtonPc.addEventListener(ButtonEvent.PRESS, handleActionButtonPress, false, 0, true);
			UpdateTextAndButtonPrompts();
		}

		public function ModcrabCleanup():void
		{
			
		}

		private function UpdateTextAndButtonPrompts():void
		{
			lbPanelTextField.text = _panelText;

			mcActivateButton.setDataFromStage(NavigationCode.GAMEPAD_A, -1);
			mcActivateButtonPc.setDataFromStage("", KeyCode.E);

			mcActivateButton.clickable = false;
			mcActivateButtonPc.clickable = true;

			mcActivateButton.label = _buttonPromptLabel;
			mcActivateButtonPc.label = _buttonPromptLabel;

			mcActivateButton.displayGamepadIcon();

			mcActivateButton.validateNow();
			mcActivateButtonPc.validateNow();
			
			// centre buttons under panel
			mcActivateButton.x = PANEL_CENTER - (mcActivateButton.getViewWidth() * mcActivateButton.scaleX) / 2;
			mcActivateButtonPc.x = PANEL_CENTER - mcActivateButtonPc.getViewWidth() / 2;

			mcActivateButton.updateDataFromStage();
			mcActivateButtonPc.updateDataFromStage();
		}

		public function ConfirmedIntent()
		{
			if (_confirmIntentMode == false)
			{
				return;
			}

			if (!_confirmedIntent)
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnModcrabConfirmedIntent' ));
				_confirmedIntent = true;
			}
		}

		// ----- events -----

		override public function handleInput(event:InputEvent):void
		{
			if (_confirmIntentMode == false)
			{
				return;
			}

			super.handleInput(event);
			if (event.handled)
			{
				return;
			}
			
			var details : InputDetails = event.details;

			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			if (details.code == KeyCode.E)
			{
				details.navEquivalent = NavigationCode.ENTER;
			}
			
			if (details.value == InputValue.KEY_UP && details.fromJoystick == false)
			{
				switch(details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_A:
				case NavigationCode.ENTER:
					ConfirmedIntent();
					break;
				}
			}
		}
		
		protected function handleActionButtonPress( event : ButtonEvent ) : void
		{
			if (_confirmIntentMode == false)
			{
				return;
			}

			ConfirmedIntent();
		}

		protected function handleControllerChange( event:ControllerChangeEvent ):void
		{
			if (_confirmIntentMode == false)
			{
				return;
			}

			UpdateTextAndButtonPrompts();
		}

		// -----
	}
}
