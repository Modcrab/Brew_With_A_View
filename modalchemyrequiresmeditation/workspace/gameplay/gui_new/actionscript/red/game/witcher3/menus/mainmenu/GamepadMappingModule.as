/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.constants.EInputDeviceType;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.constants.PlatformType;
	
	public class GamepadMappingModule extends CoreMenuModule
	{
		public var txtRightJoy : W3TextArea;
		public var txtLeftJoyRightJoy : W3TextArea;
		public var txtXButton : W3TextArea;
		public var txtAButton : W3TextArea;
		public var txtBButton : W3TextArea;
		public var txtYButton : W3TextArea;
		public var txtYButtonPs : W3TextArea;
		public var txtYButtonXbox : W3TextArea;
		public var txtRightBumper : W3TextArea;
		public var txtRightTrigger : W3TextArea;
		public var txtStartButton : W3TextArea;
		public var txtSelectButton : W3TextArea;
		public var txtLeftTrigger : W3TextArea;
		public var txtLeftBumper : W3TextArea;
		public var txtLeftJoy : W3TextArea;
		public var txtDPad : W3TextArea;
		public var mcLeftPCButton : ConditionalButton;
		public var mcRightPCButton : ConditionalButton;
		
		public var txtLayoutName : TextField;
		
		protected var dataArray : Array;
		protected var selectedIndex : int = 0;
		protected var platformType : int = PlatformType.PLATFORM_UNKNOWN;
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (mcLeftPCButton)
			{
				mcLeftPCButton.addEventListener(ButtonEvent.PRESS, handlePrevButtonPress, false, 0, true);
			}
			
			if (mcRightPCButton)
			{
				mcRightPCButton.addEventListener(ButtonEvent.PRESS, handleNextButtonPress, false, 0, true);
			}
			
			enabled = false;
			visible = false;
			alpha = 0;
		}
		
		public function showWithData(data:Array, platform:int):void
		{
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
	
			platformType = platform ;
			
			switch (platform)
			{
			case PlatformType.PLATFORM_PC:
				showControllerPC();
				break;
			case PlatformType.PLATFORM_XBOX1:
				gotoAndStop("xboxone");
				break;
			case PlatformType.PLATFORM_XB_SCARLETT_LOCKHART:
			case PlatformType.PLATFORM_XB_SCARLETT_ANACONDA:
				gotoAndStop("xboxseries");
				break;
			case PlatformType.PLATFORM_PS4:
				gotoAndStop("ps4");
				break;
			case PlatformType.PLATFORM_PS5:
				gotoAndStop("ps5");
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
				break;
			}
			
			dataArray = data;
			selectedIndex = 0;
			updateButtonMapping();
		}

		private function showControllerPC(): void
		{
			var gamepadType:uint = InputManager.getInstance().gamepadType;

			switch (gamepadType)
			{
			case EInputDeviceType.IDT_PS4:
				gotoAndStop("ps4");
				return;
			case EInputDeviceType.IDT_PS5:
				gotoAndStop("ps5");
				return;
			case EInputDeviceType.IDT_Xbox1: // There isn't one for XSS
				gotoAndStop("xboxseries"); // Should it be XB1
				return;
			default:
				gotoAndStop("xboxseries");
				return;
			}
		}
		
		private function handleEnterFrame(event:Event):void
		{
			if (txtLeftBumper)
			{
				txtLeftBumper.x = 125.7;
				txtLeftBumper.y = 376.9;
			}
			
			if (txtRightBumper)
			{
				txtRightBumper.x = 1098.05;
				txtRightBumper.y = 312.15;
			}
			
			if (txtYButton)
			{
				txtYButton.x = 1108.95;
				txtYButton.y = 438.3;
			}
			
			removeEventListener( Event.ENTER_FRAME, handleEnterFrame );
		}
		
		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
			}
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			visible = false;
		}
		
		protected function handlePrevButtonPress( event : ButtonEvent ) : void
		{
			navigateLeft();
		}
		
		protected function handleNextButtonPress( event : ButtonEvent ) : void
		{
			navigateRight();
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( keyUp && !event.handled )
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_B:
						{
							handleNavigateBack();
						}
						break;
					case NavigationCode.LEFT:
						{
							navigateLeft();
						}
						break;
					case NavigationCode.RIGHT:
						{
							navigateRight();
						}
						break;
					}
				}
			}
		}
		
		protected function navigateLeft():void
		{
			if (selectedIndex > 0)
			{
				selectedIndex -= 1;
			}
			else
			{
				selectedIndex = dataArray.length - 1;
			}
			
			updateButtonMapping();
		}
		
		protected function navigateRight():void
		{
			if (selectedIndex < (dataArray.length - 1))
			{
				selectedIndex += 1;
			}
			else
			{
				selectedIndex = 0;
			}
			
			updateButtonMapping();
		}
		
		protected function updateButtonMapping():void
		{
			var currentData:Object = dataArray[selectedIndex];
			
			if (txtLayoutName)
			{
				txtLayoutName.htmlText = currentData.layoutName;
			}
			
			if (txtLeftJoyRightJoy)
			{
				if (currentData.txtLeftJoyRightJoy== ""  || platformType== PlatformType.PLATFORM_PS4 || platformType==PlatformType.PLATFORM_XBOX1)
				{
					txtLeftJoyRightJoy.visible = false;
				}
				else
				{
					txtLeftJoyRightJoy.visible = true;
					txtLeftJoyRightJoy.htmlText = currentData.txtLeftJoyRightJoy;
				}
			}
			
			if (txtRightJoy)
			{
				if (currentData.txtRightJoy == "")
				{
					txtRightJoy.visible = false;
				}
				else
				{
					txtRightJoy.visible = true;
					txtRightJoy.htmlText = currentData.txtRightJoy;
				}
			}
			
			if (txtXButton)
			{
				if (currentData.txtXButton == "")
				{
					txtXButton.visible = false;
				}
				else
				{
					txtXButton.visible = true;
					txtXButton.htmlText = currentData.txtXButton;
				}
			}
			
			if (txtAButton)
			{
				if (currentData.txtAButton == "")
				{
					txtAButton.visible = false;
				}
				else
				{
					txtAButton.visible = true;
					txtAButton.htmlText = currentData.txtAButton;
				}
			}
			
			if (txtBButton)
			{
				if (currentData.txtBButton == "")
				{
					txtBButton.visible = false;
				}
				else
				{
					txtBButton.visible = true;
					txtBButton.htmlText = currentData.txtBButton;
				}
			}
			
			if (txtYButton)
			{
				if (currentData.txtYButton == "")
				{
					txtYButton.visible = false;
				}
				else
				{
					txtYButton.visible = true;
					txtYButton.htmlText = currentData.txtYButton;;
				}
			}
			
			if (txtYButtonXbox)
			{
				if (currentData.txtYButton == "")
				{
					txtYButtonXbox.visible = false;
				}
				else
				{
					txtYButtonXbox.visible = true;
					txtYButtonXbox.htmlText = currentData.txtYButton;
				}
			}
			
			if (txtYButtonPs)
			{
				if (currentData.txtYButton == "")
				{
					txtYButtonPs.visible = false;
				}
				else
				{
					txtYButtonPs.visible = true;
					txtYButtonPs.htmlText = currentData.txtYButton;
				}
			}
			
			if (txtRightBumper)
			{
				if (currentData.txtRightBumper == "")
				{
					txtRightBumper.visible = false;
				}
				else
				{
					txtRightBumper.visible = true;
					txtRightBumper.htmlText = currentData.txtRightBumper;
				}
			}
			
			if (txtRightTrigger)
			{
				if (currentData.txtRightTrigger == "")
				{
					txtRightTrigger.visible = false;
				}
				else
				{
					txtRightTrigger.visible = true;
					txtRightTrigger.htmlText = currentData.txtRightTrigger;
				}
			}
			
			if (txtStartButton)
			{
				if (currentData.txtStartButton == "")
				{
					txtStartButton.visible = false;
				}
				else
				{
					txtStartButton.visible = true;
					txtStartButton.htmlText = currentData.txtStartButton;
				}
			}
			
			if (txtSelectButton)
			{
				if (currentData.txtSelectButton == "")
				{
					txtSelectButton.visible = false;
				}
				else
				{
					txtSelectButton.visible = true;
					txtSelectButton.htmlText = currentData.txtSelectButton;
				}
			}
			
			if (txtLeftTrigger)
			{
				if (currentData.txtLeftTrigger == "")
				{
					txtLeftTrigger.visible = false;
				}
				else
				{
					txtLeftTrigger.visible = true;
					txtLeftTrigger.htmlText = currentData.txtLeftTrigger;
				}
			}
			
			if (txtLeftBumper)
			{
				if (currentData.txtLeftBumper == "")
				{
					txtLeftBumper.visible = false;
				}
				else
				{
					txtLeftBumper.visible = true;
					txtLeftBumper.htmlText = currentData.txtLeftBumper;
				}
			}
			
			if (txtLeftJoy)
			{
				if (currentData.txtLeftJoy == "")
				{
					txtLeftJoy.visible = false;
				}
				else
				{
					txtLeftJoy.visible = true;
					txtLeftJoy.htmlText = currentData.txtLeftJoy;
				}
			}
			
			if (txtDPad)
			{
				if (currentData.txtDPad == "")
				{
					txtDPad.visible = false;
				}
				else
				{
					txtDPad.visible = true;
					txtDPad.htmlText = currentData.txtDPad;
				}
			}
		}
		
		public function onRightClick(event:MouseEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}
		
		protected function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
		}
	}
}