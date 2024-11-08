package red.game.witcher3.hud.modules
{
	import com.gskinner.motion.easing.Quadratic;
	import flash.accessibility.AccessibilityImplementation;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.controls.Label;
	import red.core.constants.KeyCode;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.hud.modules.radialmenu.RadialMenuItemEquipped;
	import red.game.witcher3.hud.modules.radialmenu.RadialMenuSelectedInfo;
	import red.game.witcher3.hud.modules.radialmenu.RadialMenuSubItemView;
	import red.game.witcher3.hud.states.OnDemandState;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.InputUtils;
	import red.core.data.InputAxisData;
	import red.game.witcher3.hud.modules.radialmenu.RadialMenuItem;
	import red.game.witcher3.hud.modules.radialmenu.RadialMenuFieldsContainer;
	import flash.filters.ColorMatrixFilter;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.gfx.MouseEventEx;

	import scaleform.clik.controls.UILoader;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.controls.Label;

	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.constants.NavigationCode;

	import red.game.witcher3.hud.modules.radialmenu.RadialMenuFieldsContainer;

	import scaleform.clik.managers.InputDelegate;
	import red.game.witcher3.controls.MouseCursor;

	public class HudModuleRadialMenu extends HudModuleBase
	{
		private const ITEM_SECTOR : Number = 0.785; // RADS (~= 45);
		private const ITEM_COUNT  : uint = 8;
		
		public var mcRadialMenuFields   : RadialMenuFieldsContainer;
		public var mcLabel				: TextField;
		public var textField			: TextField;

		private const BTN_ID_SWITCH 	: int = 0;
		private const BTN_ID_ACCEPT 	: int = 1;
		private const BTN_ID_EXIT  		: int = 2;
		private const BTN_ID_MEDITATION : int = 3;
		
		/*
		public var btnSwitchItem   : InputFeedbackButton;
		public var btnAccept 	   : InputFeedbackButton;
		public var btnExit 		   : InputFeedbackButton;
		public var btnMeditation   : InputFeedbackButton;
		*/
		
		public var mcInputFeedback : ModuleInputFeedback;

		public var mcSelection			: MovieClip;
		public var mcBck				: MovieClip;
		public var mcMeditationBtnBck	: MovieClip;
		public var mcRadialPointer		: MovieClip;

		public var mcBlinkIcon			: MovieClip;
		public var mcChargeIcon			: MovieClip;
		public var mcIconLoaderMedalion	: W3UILoader;
		public var bIsCiri				: Boolean = false;
		public var textFieldRight 		: TextField;
		public var textFieldRightUp		: TextField;
		public var textFieldMedalion	: TextField;
		public var textFieldMedalionUp	: TextField;
		
		public var mcDBGMouseCenter		: MovieClip;
		
		public var mcSubItemView 		: RadialMenuSubItemView;
		
		//public var mcItemDescription	: RadialMenuSelectedInfo;
		//public var mcSignDescription	: RadialMenuSelectedInfo;
		private var bSignsBlocked : Boolean = false;
		
		protected var _mouseCursor : MouseCursor;
		
		private static const CENTER_X				= 960;
		private static const CENTER_Y				= 540;
		private static const CENTER_Y_DEADZONE_TOP 	= 492;
		private static const CENTER_Y_DEADZONE_BOT 	= 592;
		private static const CENTER_DEADZONE_RADIUS_MIN = 146;
		private static const CENTER_DEADZONE_RADIUS_MAX	= 260;
		
		private static const MAX_DISTANCE_FROM_CENTER = 150;
		private static const MOUSE_DEAD_ZONE = 30;
		private static const DESCR_PADDING = 20;

		private static const FADE_IN_DURATION:Number = 250;

		private var subCategory 	: String = "none";
		private var subCategoryID 	: int	= -1;
		private var bCheckStick: Boolean	= false;

		private var realeseTimer : Timer;

		private var bBlockRadialMenu : Boolean = false;
		private var bOpenTimerRunning : Boolean = false;

		public var DebugOpeningKey : String = "escape-gamepad_B";
		public var previousMagnitude : Number = 0;
		
		private var _dynamicMouseCenterX : Number = CENTER_X;
		private var _dynamicMouseCenterY : Number = CENTER_Y;

		//public var mcIconLoader : W3UILoader;

		private var m_isUsingRightStickNow : Boolean = false;
		private var SlotsNames : Array = new Array();
		public var mcItemDescrBackground:MovieClip;
		
		// test feature
		const HOLD_CLOSE_DELAY = 400;
		private var holdCloseTimer:Timer;
		
		private var _isAlternativeInputMode:Boolean;
		
		private var disableRadialInput:Boolean; // NGE
		
		public function HudModuleRadialMenu()
		{
			super();
			RadialGeraltMode();
			
			mcInputFeedback.buttonAlign = "center";
			mcInputFeedback.clickable = false;
		}
		
		public function setAlternativeInputMode( value : Boolean ) : void
		{
			_isAlternativeInputMode = value;
			
			var curSelection : RadialMenuItemEquipped =  mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
			
			if (curSelection)
			{
				updateSelectedSlotItemFeedback( curSelection );
			}
		}
		
		override public function get moduleName():String
		{
			return "RadialMenuModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			visible = false;
			
			mcRadialMenuFields.setExternalViewer( mcSubItemView );
			
			if (mcDBGMouseCenter)
			{
				mcDBGMouseCenter.visible = false;
			}

			mcRadialMenuFields.SetRadialMenuFieldsNames(SlotsNames);
			mcRadialMenuFields.Init();

			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			focused = 1;
			this.alpha = 0;
			configLabels();
			//mcIconLoader.fallbackIconPath =  "icons/inventory/bomb-01.png";
			realeseTimer = new Timer(500, 1);
			mcBck.mcSign.gotoAndStop("none");
			
			/*
			buttonsList = new Vector.<InputFeedbackButton>;
			btnSwitchItem.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			btnSwitchItem.label = "[[panel_button_common_back_to_game]]";
			btnSwitchItem.clickable = false;
			buttonsList.push( btnSwitchItem );
			
			btnExit.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			btnExit.label = "[[panel_button_common_back_to_game]]";
			btnExit.clickable = false;
			buttonsList.push( btnExit );

			btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
			btnAccept.label = "[[panel_button_common_select_radial_item]]";
			btnAccept.clickable = false;
			buttonsList.push( btnAccept );

			btnMeditation.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.SPACE); // #B change it to proper one
			btnMeditation.label = "[[panel_title_meditation]]";
			btnMeditation.clickable = false;
			buttonsList.push( btnMeditation );
			*/
			
			/*
			private const BTN_ID_SWITCH 	: int = 0;
			private const BTN_ID_ACCEPT 	: int = 1;
			private const BTN_ID_EXIT  		: int = 2;
			private const BTN_ID_MEDITATION : int = 3;
			*/
			
			mcInputFeedback.appendButton( BTN_ID_MEDITATION, NavigationCode.GAMEPAD_X, KeyCode.SPACE, "[[panel_title_meditation]]" );
			mcInputFeedback.appendButton( BTN_ID_EXIT, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_button_common_back_to_game]]", true );
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			//mcItemDescription.visible = false;
			_mouseCursor = new MouseCursor(this);
			
			textFieldRight.visible = false;
			textFieldRightUp.visible = false;
			textFieldMedalion.visible = false;
			textFieldMedalionUp.visible = false;
			
			mcRadialMenuFields.addEventListener( Event.CHANGE, handleItemChanged, false, 0, true );
			
			registerDataBinding( 'hud.radial.items', handleSetItemsList );
		}
		
		private function handleItemChanged( event : Event ) : void
		{
			var targetRdr : RadialMenuItemEquipped = event.target as RadialMenuItemEquipped;
			
			trace("GFX [handleItemChanged] ---------------- ", targetRdr);
			
			if ( targetRdr && targetRdr.data )
			{
				var curSlotName:String = targetRdr.getCurrentGroupSlotName();
				
				trace("GFX [handleItemChanged] subCategory ", subCategory, "; curSlotName ", curSlotName);
				
				if (curSlotName)
				{
					// #Y quick hack; force remove indicator
					if (mcRadialMenuFields.mcRadialMenuItem6 != targetRdr) mcRadialMenuFields.mcRadialMenuItem6["mcEquipped"].visible = false;
					if (mcRadialMenuFields.mcRadialMenuItem7 != targetRdr) mcRadialMenuFields.mcRadialMenuItem7["mcEquipped"].visible = false;
					if (mcRadialMenuFields.mcRadialMenuItem8 != targetRdr) mcRadialMenuFields.mcRadialMenuItem8["mcEquipped"].visible = false;
					
					setSelectedItem( curSlotName, true );
				}
				
			}
		}
		
		public function ResetPetardData() : void
		{
			if(mcSubItemView)
			{
				mcSubItemView.cleanup();
			}
			if(mcRadialMenuFields.mcRadialMenuItem6)
			{
				(mcRadialMenuFields.mcRadialMenuItem6 as RadialMenuItemEquipped).ResetPetardData();
			}
		}
		
		private function handleSetItemsList( dataList : Array ) : void
		{
			//trace("GFX handleSetItemsList ", dataList);
			
			RadialMenuItemEquipped.enableAnimationFx = true;
			
			var len:int = dataList.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var curData:Object = dataList[i];
				
				if ( curData )
				{
					var itemRenderer : RadialMenuItemEquipped = mcRadialMenuFields.GetRadialMenuFieldByID( curData.slotId ) as RadialMenuItemEquipped;
					
					if ( itemRenderer )
					{
						itemRenderer.data = curData;
					}
				}
			}
		}
		
		public function setCiriRadial( value : Boolean, blinkEnabled : Boolean, chargeEnabled : Boolean ) : void
		{
			bIsCiri = value;
			
			if (mcLabel)
			{
				mcLabel.text = "";
			}
			
			if (mcSubItemView)
			{
				mcSubItemView.cleanup();
			}
			
			
			if (textField)
			{
				textField.text = "";
				mcItemDescrBackground.visible = false;
				updateItemDescrBackground();
			}
			if (mcRadialMenuFields)
			{
				mcRadialMenuFields.visible = false;
			}
			if (mcItemDescrBackground)
			{
				mcItemDescrBackground.visible = false;
			}
			
			if ( value )
			{
				RadialCiriMode( blinkEnabled, chargeEnabled );
			}
			else
			{
				RadialGeraltMode();
			}
			//mcRadialMenuFields.SetRadialMenuFieldsNames(SlotsNames);
			//mcRadialMenuFields.Init();
		}

		private function RadialGeraltMode()
		{
			subCategory = "none";

			gotoAndStop("Geralt");

			SlotsNames = new Array();
			SlotsNames.push("Yrden");
			SlotsNames.push("Quen");
			SlotsNames.push("Igni");
			SlotsNames.push("Axii");
			SlotsNames.push("Aard");
			SlotsNames.push("Slot1");
			SlotsNames.push("Crossbow");
			SlotsNames.push("Slot3");

			mcRadialMenuFields.visible = true;
			if (mcItemDescrBackground && !bIsCiri )
			{
				mcItemDescrBackground.visible = true;
			}
			/*
			btnAccept.visible = true;
			btnMeditation.visible = true;
			btnSwitchItem.visible = false;
			*/
			
			mcInputFeedback.alpha = 1;
			mcInputFeedback.visible = true;
			
			//mcItemDescription.visible = true;
			//mcSignDescription.visible = true;
			
			mcMeditationBtnBck.visible = true;
			shouldShouldRadialPointer = true;

			mcBlinkIcon.visible = false;
			mcChargeIcon.visible = false;
			mcIconLoaderMedalion.visible = false;
			textFieldRight.visible = false;
			textFieldRightUp.visible = false;
			textFieldMedalion.visible = false;
			textFieldMedalionUp.visible = false;
		}

		private function RadialCiriMode( blinkEnabled : Boolean, chargeEnabled : Boolean )
		{
			shouldShouldRadialPointer = false;
			gotoAndStop("Ciri");

			SlotsNames = new Array();
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			SlotsNames.push("disabled");
			
			/*
			btnSwitchItem.visible = false;
			mcRadialMenuFields.visible = false;
			btnAccept.visible = false;
			btnMeditation.visible = false;
			*/
			
			mcInputFeedback.alpha = 0;
			mcInputFeedback.visible = false;
			
			//mcItemDescription.visible = false;
			//mcSignDescription.visible = false;
			
			if ( chargeEnabled )
			{
				mcLabel.htmlText = "[[panel_hud_radial_ciri_charge]]";
				mcLabel.htmlText = CommonUtils.toUpperCaseSafe(mcLabel.htmlText);
				textField.htmlText = "[[panel_hud_radial_ciri_charge_description]]";
			}
			
			mcChargeIcon.visible = chargeEnabled;
			mcLabel.visible = chargeEnabled;
			textField.visible = chargeEnabled;
			mcBlinkIcon.visible = blinkEnabled;
			textFieldRight.visible = blinkEnabled;
			textFieldRightUp.visible = blinkEnabled;

			if( blinkEnabled )
			{
				textFieldRightUp.htmlText = "[[panel_hud_radial_ciri_blink]]";
				textFieldRightUp.htmlText = CommonUtils.toUpperCaseSafe(textFieldRightUp.htmlText);
				textFieldRight.htmlText = "[[panel_hud_radial_ciri_blink_description]]";
			}
			else
			{
				
			}
			
			mcIconLoaderMedalion.visible = false; // for now*/
			updateItemDescrBackground();
		}
		
		public function updateItemDescrBackground()
		{
			if ( mcItemDescrBackground && !bIsCiri)
			{
				mcItemDescrBackground.visible = textField.visible && textField.text;
				mcItemDescrBackground.height = textField.textHeight + DESCR_PADDING;
			}
		}
		
		private var _shouldShowRadialPointer:Boolean = true;
		public function set shouldShouldRadialPointer(value:Boolean):void
		{
			_shouldShowRadialPointer = value;
			mcRadialPointer.visible = value;
			
			//if (InputManager.getInstance().isGamepad())
			//{
			//	mcRadialPointer.visible = value;
			//}
			//else
			//{
			//	mcRadialPointer.visible = false;
			//}
		}
		
		public function get dynamicMouseCenterX():Number { return _dynamicMouseCenterX; }
		public function set dynamicMouseCenterX(value:Number):void
		{
			_dynamicMouseCenterX = value;
			
			if (mcDBGMouseCenter)
			{
				mcDBGMouseCenter.x = _dynamicMouseCenterX;
			}
		}
		
		public function get dynamicMouseCenterY():Number { return _dynamicMouseCenterY; }
		public function set dynamicMouseCenterY(value:Number):void
		{
			_dynamicMouseCenterY = value;
			
			if (mcDBGMouseCenter)
			{
				mcDBGMouseCenter.y = _dynamicMouseCenterY;
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			shouldShouldRadialPointer = _shouldShowRadialPointer;
		}
		
		private var mouseEventsRegistered:Boolean = false;
		protected function registerMouseEvents():void
		{
			if (!mouseEventsRegistered)
			{
				//trace("GFX ---------------- registering mouse events -------------");
				
				mouseEventsRegistered = true;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
				stage.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
				stage.addEventListener(MouseEvent.DOUBLE_CLICK, handleDoubleClick, false, 0, true);
				stage.doubleClickEnabled = true;
				stage.mouseChildren = false;
			}
		}
		
		protected function unregisterMouseEvents():void
		{
			if (mouseEventsRegistered)
			{
				//trace("GFX ------------------ unregistering mouse events ------------------");
				mouseEventsRegistered = false;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				stage.removeEventListener(MouseEvent.CLICK, handleClick);
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
				stage.removeEventListener(MouseEvent.DOUBLE_CLICK, handleDoubleClick);
				stage.doubleClickEnabled = false;
				stage.mouseChildren = true;
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			var distanceFromCenter:Number;
			var targetSubCategory:int = -1;
			var angleRadians:Number;
			
			// NGE
			if(disableRadialInput)
				return;
			// NGE
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// Old PC system for when cursor is visible
			// The radial menu detection works as follows:
			// distance must be less than outer radius of radial
			// distance must be greater than the inner radius (hole in middle)
			// Y value cannoy be in square (for middle section)
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//distanceFromCenter = Math.sqrt(Math.pow(event.stageX - CENTER_X, 2) + Math.pow(event.stageY - CENTER_Y, 2));
			//if (distanceFromCenter < CENTER_DEADZONE_RADIUS_MAX && distanceFromCenter > CENTER_DEADZONE_RADIUS_MIN &&
			//	(event.stageY < CENTER_Y_DEADZONE_TOP || event.stageY > CENTER_Y_DEADZONE_BOT))
			//{
			//	angleRadians = InputUtils.getAngleRadians( event.stageX - CENTER_X, CENTER_Y - event.stageY );
			//	targetSubCategory = getSubCategoryFromAngle(angleRadians, true);
			//}
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// PC system for when cursor is not visible
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//MAX_DISTANCE_FROM_CENTER
			var vectorX:Number = event.stageX - _dynamicMouseCenterX;
			var vectorY:Number = event.stageY - _dynamicMouseCenterY;
			distanceFromCenter = Math.sqrt(Math.pow(vectorX, 2) + Math.pow(vectorY, 2));
			
			if (distanceFromCenter > MOUSE_DEAD_ZONE)
			{
				if (distanceFromCenter > MAX_DISTANCE_FROM_CENTER)
				{
					dynamicMouseCenterX = event.stageX + (-vectorX) / distanceFromCenter * MAX_DISTANCE_FROM_CENTER;
					dynamicMouseCenterY = event.stageY + (-vectorY) / distanceFromCenter * MAX_DISTANCE_FROM_CENTER;
				}
				
				//angleRadians = InputUtils.getAngleRadians( event.stageX - _dynamicMouseCenterX, _dynamicMouseCenterY - event.stageY );
				
				var originAngleRadians = Math.atan2( _dynamicMouseCenterY - event.stageY, event.stageX - _dynamicMouseCenterX ); // proper angle
				
				targetSubCategory = getSubCategoryFromAngle(originAngleRadians, true);
			}
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			if (targetSubCategory != -1)
			{
				updateRadialPointer( originAngleRadians );
				SetSubCategory(targetSubCategory, false);
			}
		}
		
		protected function handleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			
			// NGE
			if(disableRadialInput)
				return;
			// NGE
			
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				if (_lastSetSelection != -1)
				{
					if (activateSelectedSlot(false)) // NGE
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [true] ) );
					}
				}
			}
			else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [false] ) );
			}
		}
		
		protected function handleDoubleClick(event:MouseEvent):void
		{
			// NGE
			if(disableRadialInput)
				return;
			// NGE
		
			activateSelectedSlot(false);  // NGE
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [true] ) );
		}
		
		protected function handleMouseWheel(event:MouseEvent):void
		{
			var itemRenderer:RadialMenuItemEquipped = mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
			
			// NGE
			if(disableRadialInput)
				return;
			// NGE
			
			if ( itemRenderer )
			{
				if ( event.delta > 0 )
				{
					itemRenderer.nextSubItem();
				}
				else
				{
					itemRenderer.priorSubItem();
				}
			}
		}
		
		protected function activateSelectedSlot(isTab:Boolean):Boolean  // NGE
		{
			if (pendingTimer)
			{
				handlePendedDataUpdate();
			}
			
			if (_lastSetSelection != -1)
			{
				var curSlot  : RadialMenuItemEquipped = mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
				var slotName : String;
				
				if (curSlot)
				{
					slotName = curSlot.getCurrentSlotName();
				}
				else
				{
					slotName = SlotsNames[_lastSetSelection];
				}
				
				if (slotName != "disabled" && !mcRadialMenuFields.IsDesatureted(slotName))
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnActivateSlot', [slotName, isTab, false]) );  // NGE
					return true;
				}
			}
			
			return false;
		}

		private function configLabels():void
		{
			mcLabel.visible = false;
		}

		override public function handleInput( event:InputEvent ):void
		{
			var axisData:InputAxisData;
			var xvalue:Number;
			var yvalue:Number;
			var magnitude:Number;
			var magnitudeCubed:Number;
			var angleRadians:Number;
			var targetSubCategory:int;
			
			var navCodeNextItem:String;
			var navCodePriorItem:String;
			var keyCodeNavigate:int;

			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			if (!bCheckStick)
			{
				trace("GFX RAD bCheckStick", bCheckStick);
				return;
			}
			
			// NGE
			if(disableRadialInput)
				return;
			// NGE
			
			//trace("GFX ------------ ", holdCloseTimer, details.value, details.navEquivalent );
			
			if (_isAlternativeInputMode)
			{
				navCodePriorItem = NavigationCode.LEFT;
				navCodeNextItem = NavigationCode.RIGHT;
				keyCodeNavigate = KeyCode.PAD_RIGHT_STICK_AXIS;
			}
			else
			{
				navCodePriorItem = NavigationCode.RIGHT_STICK_LEFT;
				navCodeNextItem = NavigationCode.RIGHT_STICK_RIGHT;
				keyCodeNavigate = KeyCode.PAD_LEFT_STICK_AXIS;
			}
			
			if ( details.value == InputValue.KEY_UP && ( details.navEquivalent ==  NavigationCode.GAMEPAD_L1 || details.code == KeyCode.TAB ) )
			{
				if (holdCloseTimer == null)
				{
					activateSelectedSlot( true ); // NGE
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [false] ) );
				}
				else
				{
					// #stop the game
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRadialPauseGame') );
				}
				
				return;
			}
			
			if (details.value == InputValue.KEY_UP && !bIsCiri)
			{
				/*
				if (details.navEquivalent == NavigationCode.GAMEPAD_L2) // misc
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnQuickslotSwapped' ) );
					trace("GFX RAD - R2");
					return;
				}
				else if (details.navEquivalent == NavigationCode.GAMEPAD_R2) // bomb
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBombSlotSwapped' ) );
					trace("GFX RAD - R3");
					return;
				}
				*/
				
				var itemRenderer : RadialMenuItemEquipped;
				
				if ( details.navEquivalent == navCodePriorItem ||
					 (!_isAlternativeInputMode && details.navEquivalent == NavigationCode.DPAD_LEFT ) ||
					 details.code == KeyCode.A )
				{
					itemRenderer = mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
					
					if ( itemRenderer )
					{
						itemRenderer.priorSubItem();
					}
				}
				else
				if ( details.navEquivalent == navCodeNextItem ||
					 (!_isAlternativeInputMode && details.navEquivalent == NavigationCode.DPAD_RIGHT ) ||
					 details.code == KeyCode.D )
				{
					itemRenderer = mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
					
					if ( itemRenderer )
					{
						itemRenderer.nextSubItem();
					}
				}
			}
			
			switch( details.code )
			{
				//case KeyCode.PAD_RIGHT_STICK_AXIS:
				case keyCodeNavigate:
					
					if (!bIsCiri)
					{
						axisData = InputAxisData(details.value);
						xvalue = axisData.xvalue;
						yvalue = axisData.yvalue;
						magnitude = InputUtils.getMagnitude( xvalue, yvalue );
						magnitudeCubed = magnitude * magnitude * magnitude;
						
						if ( magnitude < 0.5 )
						{
							break;
						}
						
						angleRadians = Math.atan2( yvalue, xvalue );
						targetSubCategory = getSubCategoryFromAngle(angleRadians, false);
						
						updateRadialPointer(angleRadians);
						SetSubCategory(targetSubCategory);
					}
					break;
				case KeyCode.ESCAPE:
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [false] ) );
					break;
				case KeyCode.E:
				case KeyCode.ENTER:
					activateSelectedSlot(false);  // NGE
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestCloseRadial', [true] ) );
					break;
				default:
					break;
			}
		}
		
		protected function getSubCategoryFromAngle(angleRadians:Number, isPC:Boolean):int
		{
			var category:int = Math.round( ( Math.abs( angleRadians - Math.PI ) ) / ITEM_SECTOR );
			
			if( category >= ITEM_COUNT )
			{
				category = 0;
			}
			
			// trace("GFX ----------------- getSubCategoryFromAngle ", ( angleRadians * 180 / Math.PI ), " :: ", Math.abs( angleRadians - Math.PI ) * 180 / Math.PI , " -> ", ( category ) );
			
			return category;
		}
		
		protected function updateRadialPointer( angleRadians : Number):void
		{
			//trace("GFX  --- updateRadialPointer ", angleRadians);
			
			mcRadialPointer.rotation = ( - angleRadians + Math.PI / 2) * 180 / Math.PI;
		}
		
		public function setSelectedItem( slotName : String, forced : Boolean = false ):void
		{
			var i:int;
			var targetRotation:Number;
			
			//trace("GFX setSelectedItem ", slotName);
			
			for (i = 0; i < SlotsNames.length; ++i)
			{
				if (SlotsNames[i] == slotName)
				{
					targetRotation =  - i * ITEM_SECTOR + Math.PI;
					
					//trace( "GFX * for [", i,"] ", SlotsNames[i], "-*-- targetRotation ", targetRotation );
					
					SetSubCategory( i, true, forced );
					
					updateRadialPointer( targetRotation );
					
					break;
				}
			}
		}
		
		private function SetSubCategory(dirID : int, allowNoSelection : Boolean = true, forced : Boolean = false):void
		{
			//trace( "GFX -!- SetSubCategory  [", dirID, "]  ", subCategory, " -> ", SlotsNames[dirID] );
			
			if ( !allowNoSelection && (dirID == -1) )
			{
				return;
			}
			
			if ( ( subCategory != SlotsNames[dirID] || forced ) && subCategory != "disabled" )
			{
				if ( subCategory != "none" )
				{
					deselectSubCategory( subCategoryID );
				}
				
				subCategory = dirID == -1 ? "none" : SlotsNames[dirID];
				subCategoryID = dirID;
				
				selectSubCategory( dirID );
			}
		}

		private function deselectSubCategory(dirID : int):void
		{
			//trace("GFX deselectSubCategory ", dirID);
			
			if (dirID != -1)
			{
				var mcCurrent : RadialMenuItem = mcRadialMenuFields.GetRadialMenuFieldByID(dirID);
				
				SetSelection(-1);
				mcRadialMenuFields.SetDeselected(dirID);
				//mcLabel.visible = false;
				//textField.visible = false;
				updateItemDescrBackground();
			}
		}
		
		private const PENDING_DELAY:Number = 100;
		private var pendingTimer:Timer;
		private var pendingLabel:String;
		private var pendingDescription:String;
		private var pendingCategory:String;
		private var pendingIsDesaturated;
		
		private function selectSubCategory(dirID : int):void
		{
			var str : String;
			
			//trace("GFX -!- selectSubCategory ", dirID);
			
			if( dirID != -1 )
			{
				str = SlotsNames[ dirID ] as String;
				
				if( str != "disabled" )
				{
					if( !mcRadialMenuFields.SetSelected( dirID ) && !bIsCiri )
					{
						mcLabel.visible = false;
						textField.visible = false;
						mcItemDescrBackground.visible = false;
						
						return;
					}
					
					SetSelection( dirID );
					
					//
					// #Y wait a little bit, then update data to avoid performance dropping and make navigation smoother
					//
					
					/*
					if( pendingTimer )
					{
						pendingTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, handlePendedDataUpdate );
						pendingTimer.stop();
					}
					
					pendingTimer = new Timer( PENDING_DELAY );
					pendingTimer.addEventListener( TimerEvent.TIMER_COMPLETE, handlePendedDataUpdate, false, 0, true );
					pendingTimer.start();
					*/
					
					if( GetCurrentItemIcon() != "" ) // #Y wierd check
					{
						pendingLabel = GetCurrentItemName();
					}
					else
					{
						pendingLabel = "[[" + str + "]]";
					}
					
					var curSelection : RadialMenuItemEquipped =  mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItemEquipped;
					
					if (curSelection)
					{
						pendingCategory = curSelection.getCurrentSlotName();
						pendingDescription = curSelection.GetItemDescription();
						
						updateSelectedSlotItemFeedback( curSelection );
					}
					else
					{
						pendingDescription = GetCurrentItemDescription();
						pendingCategory = subCategory;
						
						var curSelectionBase : RadialMenuItem =  mcRadialMenuFields.GetSelectedRadialMenuField() as RadialMenuItem;
						
						if ( curSelectionBase && !curSelectionBase.IsDesatureted() )
						{
							mcInputFeedback.appendButton( BTN_ID_ACCEPT, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select_radial_item]]" );
						}
						else
						{
							mcInputFeedback.removeButton( BTN_ID_ACCEPT );
						}
						
						mcInputFeedback.removeButton( BTN_ID_SWITCH, true );
					}
					
					pendingIsDesaturated = mcRadialMenuFields.IsDesatureted( str );
					
					// tmp, no delay
					handlePendedDataUpdate();
				}
			}
			else
			{
				SetSelection( dirID );
			}
			
			if (!bIsCiri)
			{
				//mcLabel.visible = false;
				//textField.visible = false;
			}
		}
		
		private function updateSelectedSlotItemFeedback( curSelection : RadialMenuItemEquipped ):void
		{
			if ( !curSelection.IsDesatureted() && curSelection.data )
			{
				mcInputFeedback.appendButton( BTN_ID_ACCEPT, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select_radial_item]]" );
			}
			else
			{
				mcInputFeedback.removeButton( BTN_ID_ACCEPT, true );
			}
			
			if ( curSelection.isSwitchable() )
			{
				var buttonLabel : String;
				
				// NGE
				if(curSelection.ShowChangeItemText())
					buttonLabel = "[[hud_radial_change_item]]";
				else if(curSelection.isCrossbow())
					buttonLabel = "[[hud_radial_change_bolt]]";
				else
					buttonLabel = "[[hud_radial_change_item]]";
				// NGE
				
				mcInputFeedback.removeButton( BTN_ID_SWITCH, false );
				
				if (_isAlternativeInputMode)
				{
					mcInputFeedback.appendButton( BTN_ID_SWITCH, "gamepad_L_Tab", KeyCode.MOUSE_SCROLL, buttonLabel, true );
				}
				else
				{
					mcInputFeedback.appendButton( BTN_ID_SWITCH, NavigationCode.GAMEPAD_RSTICK_TAB, KeyCode.MOUSE_SCROLL, buttonLabel, true );
				}
				
			}
			else
			{
				mcInputFeedback.removeButton( BTN_ID_SWITCH, true );
			}
		}
		
		private function handlePendedDataUpdate( event : TimerEvent = null ) : void
		{
			//trace("GFX handlePendedDataUpdate [" + pendingDescription + "] ");
			
			if( pendingTimer )
			{
				pendingTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, handlePendedDataUpdate );
				pendingTimer.stop();
				pendingTimer = null;
			}
			
			//mcLabel.visible = true;
			textField.visible = true;
			
			//mcLabel.htmlText = CommonUtils.toUpperCaseSafe( pendingLabel );
			textField.text = pendingDescription;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRadialMenuItemSelected' , [ pendingCategory, pendingIsDesaturated ] ) );
			
			updateItemDescrBackground();
		}
		
		public function SetChoosenDescription( value :String ):void
		{
			textField.htmlText = value;
			textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			updateItemDescrBackground();
		}

		private function SendChoosen():void
		{
			var str : String;
			str = subCategory;

			if (str != "" && str != "none" && str != "disabled")
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRadialMenuItemChoose', [ str ] ) );
			}
		}

		public function ShowRadialMenu(bShow : Boolean):void
		{
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', ["DEPRECTAED ShowRadialMenu "+bShow]));
		}

		override public function ShowElementFromState( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			if (!bBlockRadialMenu)
			{
				if ( !bShow && bCheckStick )
				{
					visible = false;
					this.alpha = 0;
					this.desiredAlpha = 0;
					unregisterMouseEvents();
					InputManager.getInstance().removeInputBlocker("HUD_RADIAL");
					
					dynamicMouseCenterX = CENTER_X;
					dynamicMouseCenterY = CENTER_Y; // Don't want to start near circle
					
					if (holdCloseTimer)
					{
						holdCloseTimer.removeEventListener(TimerEvent.TIMER, handleHoldTimer, false);
						holdCloseTimer.stop();
						holdCloseTimer = null;
					}
					
					if ( !bIsCiri )
					{
						/*
						if (InputManager.getInstance().isGamepad())
						{
							SetSelection(-1);
						}
						
						SendChoosen();

						deselectSubCategory(subCategoryID);
						subCategoryID = -1;
						subCategory = "none";
						*/
						
						mcRadialMenuFields.Init();
						//mcItemDescription.visible = false;
					}
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideRadialMenu' ) );
				}
				else if ( bShow && !bCheckStick )
				{
					visible = true;
					this.alpha = OPACITY_MAX;
					this.desiredAlpha = OPACITY_MAX;
					
					// start close timer
					if (holdCloseTimer)
					{
						holdCloseTimer.removeEventListener(TimerEvent.TIMER, handleHoldTimer, false);
						holdCloseTimer.stop();
					}
					
					holdCloseTimer = new Timer( HOLD_CLOSE_DELAY );
					holdCloseTimer.addEventListener( TimerEvent.TIMER, handleHoldTimer, false, 0, true);
					holdCloseTimer.start();
					
					focused = 1;
					registerMouseEvents();
					InputManager.getInstance().addInputBlocker(false, "HUD_RADIAL");
					
					if ( !bIsCiri )
					{
						//deselectSubCategory(subCategoryID);
						//subCategoryID = -1;
						//subCategory = "none";
						//SetSubCategory(subCategoryID);
						
						/*
						if (InputManager.getInstance().isGamepad())
						{
							SetSelection(subCategoryID); //@FIXME BIDON - id
						}
						else
						{
							SetSelection( -1);
						}
						*/
						
					}
					//mcRadialMenuFields.gotoAndPlay("OnStart");
					//GameInterface.playSound("gui_wheel_menu_open");
				}
				bCheckStick = bShow;
			}
		}
		
		private function handleHoldTimer(event:Event):void
		{
			if (holdCloseTimer)
			{
				holdCloseTimer.removeEventListener(TimerEvent.TIMER, handleHoldTimer, false);
				holdCloseTimer.stop();
				holdCloseTimer = null;
				
				// #slow1
			}
		}

		public function BlockRadialMenu(bBlock : Boolean)
		{
			bBlockRadialMenu = bBlock;
		}
		
		private var _lastSetSelection:int = -1;
		private function SetSelection(selectionID : int) : void
		{
			if (_lastSetSelection == selectionID)
			{
				return;
			}
			
			var mcCurrentSelection : MovieClip;
			
			if (_lastSetSelection != -1)
			{
				mcCurrentSelection = mcSelection.getChildByName("mcSelector" + (_lastSetSelection + 1)) as MovieClip;
				
				if (mcCurrentSelection && mcCurrentSelection.currentLabel != "start")
				{
					mcCurrentSelection.gotoAndPlay("FadeOut"); // which is hidden ><. Wierd name but whatever
				}
			}
			
			_lastSetSelection = selectionID;
			
			if ( _lastSetSelection != -1 )
			{
				mcCurrentSelection = mcSelection.getChildByName("mcSelector" + (_lastSetSelection + 1)) as MovieClip;
				
				if (mcCurrentSelection)
				{
					mcCurrentSelection.gotoAndPlay("FadeIn");
				}
			}
		}

		public function UpdateItemIcon(id : int, iconPath : String, itemName : String, itemCategory : String, itemDescription : String , itemQuality : int ): void
		{
			var mcCurrentField : RadialMenuItem;
			var selection : String;

			//selection = "Slot" + (id - 6);
			mcCurrentField = mcRadialMenuFields.GetRadialMenuFieldByID(id) as RadialMenuItem;
			if ( mcCurrentField )
			{
				mcCurrentField.SetIcon(iconPath, itemName, itemCategory, itemDescription , itemQuality);
			}
			else
			{
				trace("HUD_RADIAL mcCurrentField is wrong for id "+id);
			}
		}

		private function GetCurrentItemIcon(): String
		{
			var mcCurrentField : RadialMenuItem;
			var retString : String = "";
			
			mcCurrentField = mcRadialMenuFields.GetRadialMenuFieldByName(subCategory) as RadialMenuItem;
			if ( mcCurrentField )
			{
				retString = mcCurrentField.GetIconPath();
			}
			
			return retString;
		}

		private function GetCurrentItemName(): String
		{
			var mcCurrentField : RadialMenuItem;
			var retString : String = "";
			
			mcCurrentField = mcRadialMenuFields.GetRadialMenuFieldByName(subCategory) as RadialMenuItem;

			if ( mcCurrentField )
			{
				retString = mcCurrentField.GetItemName();
			}
			
			return retString;
		}

		private function GetCurrentItemDescription(): String
		{
			var mcCurrentField : RadialMenuItem;
			var retString : String = "";
			
			mcCurrentField = mcRadialMenuFields.GetRadialMenuFieldByName(subCategory) as RadialMenuItem;

			if ( mcCurrentField )
			{
				retString = mcCurrentField.GetItemDescription();
			}
			
			return retString;
		}

		public function UpdateFieldEquippedState( name : String, description : String, equipped : Boolean, keyCode : int ): void
		{
			var mcCurrentField : RadialMenuItem;
			var tempField : RadialMenuItem;
			var inputDelegate : InputDelegate;
			var keyName : String;

			mcCurrentField = mcRadialMenuFields.GetRadialMenuFieldByName(name) as RadialMenuItem;
			if ( mcCurrentField )
			{
				inputDelegate = InputDelegate.getInstance();
				
				if (name == "Aard" || name == "Yrden" || name == "Igni" || name == "Quen" || name == "Axii")
				{
					tempField = mcRadialMenuFields.GetRadialMenuFieldByName("Aard") as RadialMenuItem;
					if (tempField)
					{
						tempField["mcEquipped"].visible = false;
					}
					
					tempField = mcRadialMenuFields.GetRadialMenuFieldByName("Yrden") as RadialMenuItem;
					if (tempField)
					{
						tempField["mcEquipped"].visible = false;
					}
					
					tempField = mcRadialMenuFields.GetRadialMenuFieldByName("Igni") as RadialMenuItem;
					if (tempField)
					{
						tempField["mcEquipped"].visible = false;
					}
					
					tempField = mcRadialMenuFields.GetRadialMenuFieldByName("Quen") as RadialMenuItem;
					if (tempField)
					{
						tempField["mcEquipped"].visible = false;
					}
					
					tempField = mcRadialMenuFields.GetRadialMenuFieldByName("Axii") as RadialMenuItem;
					if (tempField)
					{
						tempField["mcEquipped"].visible = false;
					}
				}

				mcCurrentField["mcEquipped"].visible = equipped;
				if (equipped)
				{
					mcCurrentField["mcEquipped"].gotoAndPlay(2);
				}
				
				// #Y FIX mcEquipped should be a property
				/*
				//mcCurrentField["mcButton"].visible = equipped; // #Y FIX mcButton should be a property
				//keyName = inputDelegate.inputToNav( "key", keyCode );
				if ( keyName )
				{
					mcCurrentField.mcButton.setDataFromStage(keyName, -1);
				}
				*/
				if (equipped)
				{
					//UpdateFieldDescription(mcCurrentField);
				}
			}
			else
			{
				trace("HUD_RADIAL UpdateFieldEquippedState mcCurrentField is fucked for id "+name);
			}
		}

		public function UpdateFieldDescription( mcCurrentField : RadialMenuItem ): void
		{
			if ( mcCurrentField )
			{
				if (mcCurrentField.getRadialItemName() == "Meditation" ) // #B don't update when meditation selected
				{
					return;
				}

				if ( mcCurrentField.IsItemField() )
				{
					//mcItemDescription.SetAsItemField(mcCurrentField.IsItemField());
					//mcItemDescription.SetIcon(mcCurrentField.GetIconPath(), mcCurrentField.GetItemName(), mcCurrentField.GetItemCategory());
					//mcItemDescription.ItemName = mcCurrentField.GetItemName();
					//mcItemDescription.SetItemDescription(mcCurrentField.GetItemDescription());
					//mcItemDescription.visible = true;
				}
				else
				{
					//mcSignDescription.SetIcon(mcCurrentField.getRadialItemName(), mcCurrentField.GetItemName(), mcCurrentField.GetItemCategory());
					//mcSignDescription.ItemName = "[["+mcCurrentField.GetItemName()+"]]";
					//mcSignDescription.SetItemDescription(mcCurrentField.GetItemDescription());
				}
			}
		}

		public function SetDesaturated( value : Boolean, desName : String )
		{
			mcRadialMenuFields.SetDesatureted(desName, value);
			SetSelectionDesaturated(value, desName);
		}

		public function SetSelectionDesaturated( value : Boolean, desName : String )
		{
			var mcCurrentSelection : MovieClip;
			var i : int;
			var selectionID : int;

			for ( i = 0; i < SlotsNames.length; i++ )
			{
				if ( desName == SlotsNames[i] )
				{
					selectionID = i;
				}
			}
			mcCurrentSelection = mcSelection.getChildByName("mcSelector" + selectionID) as MovieClip;
			if ( value )
			{
				var desFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
				mcCurrentSelection.filters = [desFilter];
				mcCurrentSelection.alpha = .5;
			}
			else
			{
				mcCurrentSelection.filters = [];
				mcCurrentSelection.alpha = 1;
			}
		}
		
		public function SetMeditationButtonEnabled( value : Boolean )
		{
			if (!bIsCiri)
			{
				if ( value )
				{
					mcMeditationBtnBck.alpha = 1;
					mcInputFeedback.appendButton( BTN_ID_MEDITATION, NavigationCode.GAMEPAD_X, KeyCode.SPACE, "[[panel_title_meditation]]", true );
				}
				else
				{
					mcMeditationBtnBck.alpha = 0.5;
					mcInputFeedback.removeButton( BTN_ID_MEDITATION, true );
				}
			}
		}

		public function setCiriItem( itemPath : String, itemName : String, itemDescription : String )
		{
			if ( itemPath != "" )
			{
				mcIconLoaderMedalion.source = "img://" + itemPath;
			}
			else
			{
				mcIconLoaderMedalion.source = "";
			}
						
			textFieldMedalionUp.htmlText = itemName;
			textFieldMedalionUp.htmlText = CommonUtils.toUpperCaseSafe(textFieldMedalionUp.htmlText);
			textFieldMedalion.htmlText = itemDescription;
			textFieldMedalion.visible = true;
			textFieldMedalionUp.visible = true;
		}

		override public function SetScaleFromWS( scale : Number ) : void
		{
		}
		
		// NGE
		public function DisableRadialInput( disable : Boolean )
		{
			disableRadialInput = disable;
		}
		// NGE
	}
}
