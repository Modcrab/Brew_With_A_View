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

	// modcrab
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.events.Event;
	// -----
	

	/**
	 * Time selection in the meditation menu
	 * @author Yaroslav Getsevich
	 */
	public class MeditationClock extends UIComponent
	{
		protected static const MAGNITUDE_DEAD_ZONE:Number = .75;
		protected static const MAGNITUDE_DEC_DEAD_ZONE:Number = .1;
		protected static const MAGNITUDE_TIME_DELTA:Number = .5;
		protected static const MAGNITUDE_CHARGE = 15;
		protected static const PC_BUTTON_PADDING = 12;

		protected static const MAX_WAIT_HOURS:uint = 24;
		protected static const NUM_ANIM_FRAMES:uint = 72;
		protected static const NUM_FRAMES_PER_HOUR:uint = 3;
		
		protected static const CLOCK_CENTER:Number = 326;
		
		public var lbSelectedHours:TextField;
		public var txtDuration:TextField;
		public var selectedTimeIndicator:ClockIndicator;
		public var dayQuarterIndicator:DayQuarterIndicator;
		public var arrowTarget:MovieClip;
		public var arrowCurrent:MovieClip;
		public var centerOfClock:MovieClip;
		public var edgeOfClock:MovieClip;
		
		public var mcActivateButton:InputFeedbackButton;
		public var mcActivateButtonPc:InputFeedbackButton;
		public var mcBackground:MovieClip;
		
		// ----- modAlchemyRequiresMeditation -----
		public var mcModAlchemyButton:InputFeedbackButton;
		public var mcModAlchemyButtonPc:InputFeedbackButton;
		public var mcModCurrentTimeBackground:MovieClip;
		private var _modIsSleeping : Boolean = false;
		private var _modAlchemyButtonPromptLabelSet : Boolean = false;
		private var _modAlchemyButtonPromptPCPositioned : Boolean = false;
		private var _modAlchemyButtonPromptLabel :String = "";
		private var _modMeditateButtonPromptLabel :String = "";
		private var _modSleepButtonPromptLabel :String = "";
		private var _modCancelButtonPromptLabel :String = "";
		private var _modDurationTextPrefix :String = "";
		private var _modcrabEntranceAnimationTargetY :Number;
		private var _modcrabEntranceAnimationStarted :Boolean = false;
		private var _modcrabEntranceAnimationStopped :Boolean = false;
		// ----------------------------------------
		
		private var _globalCenter:Point;
		private var _mouseDownOnClock:Boolean;
		private var _lastClickLocation:Point;
		private var _lastClickTime:Number;
		private var _timeFormat24HR:Boolean;
		
		protected var _selectedTime:uint;
		protected var _currentTime:uint;
		protected var _currentTimeMin:uint;
		protected var _currentlyRenderedTime:int;
		private var _animationTimer : Timer;
		private var _isMeditating : Boolean;
        private var _stopMeditationReq : Boolean;
        private var bMeditationBlocked : Boolean = false;
		private var prevMagnitude:Number = 0;
		private var bufMagnitude:Number = 0;
		protected var durationText:String = "";
	
		public var mcFrameMed:MovieClip;
		public var mcFinishMeditationGlow:MovieClip;
		private var _maxRadius : Number;
		
		private var _labelActivateButton:String;
		private var _labelMeditateUntil:String;
		
		public var timeChangeCallback : Function;
		
		public function MeditationClock()
		{
			_mouseDownOnClock = false;
			_selectedTime = 1000;
			_currentTime = 1000;
			_currentTimeMin = 1000;
			_isMeditating = false;
            _stopMeditationReq = false;
			_currentlyRenderedTime = 0;
			
			_lastClickLocation = new Point(0, 0);
			_lastClickTime = 0;
			
			edgeOfClock.stage
			_globalCenter = centerOfClock.localToGlobal(new Point(0, 0));
			var edgePoint:Point = edgeOfClock.localToGlobal(new Point(0, 0));
			_maxRadius = Math.sqrt(Math.pow(edgePoint.x - _globalCenter.x, 2) + Math.pow(edgePoint.y - _globalCenter.y, 2));
			
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			stage.doubleClickEnabled = true;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			//lbSelectedHours.htmlText = "[[panel_meditationclock_selected_hours]]";
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.hours', [setCurrentHours]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.minutes', [setCurrentMin]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.hours.update', [updateCurrentHours]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.blocked', [blockClock]));

			// ----- modAlchemyRequiresMeditation -----
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.sleeping',                		 [setIsSleeping]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.alchemy.prompt.label',    		 [setAlchemyButtonPromptLabel]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.meditate.prompt.label',   		 [setMeditateButtonPromptLabel]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.sleep.prompt.label',      		 [setSleepButtonPromptLabel]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.cancel.prompt.label',             [setCancelButtonPromptLabel]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.duration.text.prefix',			 [setDurationTextPrefix]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.entrance',                		 [modcrabDoEntranceAnimation]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.entrance.stop',                   [modcrabStopEntranceAnimation]));
			// ----------------------------------------

			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
			
			txtDuration.mouseEnabled = false;
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			mcActivateButton.setDataFromStage(NavigationCode.GAMEPAD_A, -1);
			
			_labelActivateButton = "[[panel_name_skillcategory_meditation]]";
			_labelMeditateUntil = "[[panel_meditationclock_med_hours]]";
			
			mcActivateButtonPc.clickable = true;
			mcActivateButtonPc.label = _labelActivateButton; // default
			mcActivateButtonPc.addEventListener(ButtonEvent.PRESS, handleActionButtonPress, false, 0, true);
			mcActivateButtonPc.setDataFromStage("", KeyCode.E);
			mcActivateButtonPc.validateNow();
			
			if (!_isMeditating)
			{
				txtDuration.text = durationText;
				txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
			}
			mcActivateButton.clickable = false;
			//mcActivateButton.visible = InputManager.getInstance().isGamepad(); //TODO: Renable this code once the InputManager works properly
		
			// ----- modMeditationClockFlickerFix -----
			// disable all of the problematic elements until the data is set for first time
			arrowTarget.visible = false;
			arrowCurrent.visible = false;
			txtDuration.visible = false;
			lbSelectedHours.visible = false;
			mcActivateButton.visible = false;
			mcActivateButtonPc.visible = false;
			// ----------------------------------------
		
			// ----- modAlchemyRequiresMeditation -----
			mcModAlchemyButton.setDataFromStage(NavigationCode.GAMEPAD_Y, -1);
			mcModAlchemyButton.clickable = false;
			mcModAlchemyButton.visible = false;
		
			mcModAlchemyButtonPc.setDataFromStage("", KeyCode.L);
			mcModAlchemyButtonPc.clickable = true;
			mcModAlchemyButtonPc.addEventListener(ButtonEvent.PRESS, modcrabHandleAlchemyButtonPress, false, 0, true);
			mcModAlchemyButtonPc.validateNow();
			mcModAlchemyButtonPc.visible = false;

			mcModCurrentTimeBackground.visible = false;

			this.alpha = 0;
			this.visible = true;
			_modcrabEntranceAnimationTargetY = this.y;
			this.y = _modcrabEntranceAnimationTargetY + 700;
			// ----------------------------------------
		}
		
		
		public function setLabels(btnLabel:String, txtLabel:String):void
		{
			//_labelActivateButton = btnLabel; // ----- modAlchemyRequiresMeditation -----
			_labelMeditateUntil = txtLabel;
			
			//mcActivateButtonPc.label = _labelActivateButton; // ----- modAlchemyRequiresMeditation -----
			mcActivateButtonPc.updateDataFromStage();
			mcActivateButtonPc.validateNow();
			//mcActivateButtonPc.x =  CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2; ----- modAlchemyRequiresMeditation -----
			
			updateTimeMeditateText();
		}
		
		public function get isMeditating():Boolean { return _isMeditating; }
		public function set isMeditating( value : Boolean):void { _isMeditating = value; }

		public function get selectedTime():uint { return _selectedTime; }
		public function set selectedTime(value:uint ):void
		{
			// ----- modMeditationClockFlickerFix -----
			// reenable the arrow and prompts the first time the data is set
			arrowTarget.visible = true;
			mcActivateButton.visible = true;
			mcActivateButtonPc.visible = true;
			// ----------------------------------------
			
			// ----- modAlchemyRequiresMeditation -----
			ModcrabUpdateButtonPrompts();
			// ----------------------------------------
			
			if (_selectedTime == value)
				return;

			_selectedTime = value;

			if (!_isMeditating)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_clock_tick"]));
			}
			
			
			/*var timeLapse:int = _selectedTime - _currentTime;
			if (timeLapse < 0)
			{
				timeLapse += 24;
			}*/
			
			//panel_meditationclock_sleep_hours
			
			updateTimeMeditateText();
			durationText = txtDuration.text;
			
			//txtDuration.appendText(": " + String(timeLapse));
			
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_meditation_select_time"]));

			if (_selectedTime == _currentTime)
			{
				//arrowTarget.visible = false;
				arrowTarget.rotation = timeConvertedForFlashRotation(_selectedTime) / 24 * 360;
				selectedTimeIndicator.progress = 0;
				selectedTimeIndicator.visible = false;
			}
			else
			{
				//arrowTarget.visible = true;
				arrowTarget.rotation = timeConvertedForFlashRotation(_selectedTime) / 24 * 360;
				selectedTimeIndicator.visible = true;
				var hoursMoved:uint = (_selectedTime < _currentTime) ? (24 + _selectedTime - _currentTime) : (_selectedTime - _currentTime);
				selectedTimeIndicator.progress = 1 + Math.ceil((hoursMoved / 24) * NUM_ANIM_FRAMES);
			}
			
			if ( timeChangeCallback != null )
			{
				timeChangeCallback( _currentTime );
			}
			
		}
		
		protected function updateTimeMeditateText()
		{
			var formattedTime : String = "";
			var hours : uint = _selectedTime;
			
			if ( !_timeFormat24HR )
			{
				if (hours >= 12)
				{
					if ( hours > 12 )
					{
						hours -= 12;
					}
						
					if (hours < 10)
					{
						formattedTime += "0";
					}

					formattedTime += hours + ":00 PM";
				}
				else
				{
					if ( hours == 0 )
					{
						hours = 12;
					}
					
					if (hours < 10)
					{
						formattedTime += "0";
					}
					
					formattedTime += hours + ":00 AM";
				}
			}
			else
			{
				if (hours < 10)
				{
					formattedTime += "0";
				}
				
				formattedTime += _selectedTime.toString() + ":00";
			}
			
			// ----- modMeditationClockFlickerFix -----
			txtDuration.visible = true;
			// ----------------------------------------
		
			// ----- modAlchemyRequiresMeditation -----
			//txtDuration.text = _labelMeditateUntil;
			//txtDuration.appendText(" " + formattedTime);
			txtDuration.text = _modDurationTextPrefix;
			txtDuration.appendText(" " + formattedTime);
			// ----------------------------------------
			txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
		}

		public function get currentTime():uint { return _currentTime; }
		public function set currentTime(value:uint):void
		{
			// ----- modMeditationClockFlickerFix -----
			// reenable the arrow and prompts the first time the data is set
			arrowCurrent.visible = true;
			mcActivateButton.visible = true;
			mcActivateButtonPc.visible = true;
			// ----------------------------------------
			
			// ----- modAlchemyRequiresMeditation -----
			ModcrabUpdateButtonPrompts();
			// ----------------------------------------
			
			if (_currentTime == value)
				return;

			_currentTime = value;

			if (!_isMeditating)
			{
				dayQuarterIndicator.currentTime = _currentTime;
				arrowCurrent.rotation = timeConvertedForFlashRotation(_currentTime) / 24 * 360;
				selectedTimeIndicator.rotation = timeConvertedForFlashRotation(_currentTime) / 24 * 360;

                if (_currentTime != _selectedTime)
                {
                    var hoursMoved:uint = (_selectedTime < _currentTime) ? (24 + _selectedTime - _currentTime) : (_selectedTime - _currentTime);
                    selectedTimeIndicator.progress = 1 + Math.ceil((hoursMoved / 24) * NUM_ANIM_FRAMES);
                }
			}
			
			
			updateCurrentTimeString();
		}

		public function get currentTimeMin():uint { return _currentTimeMin; }
		public function set currentTimeMin(value:uint):void
		{
			_currentTimeMin = value;

			updateCurrentTimeString();
		}

		public function updateCurrentTimeString():void
		{
			// ----- modMeditationClockFlickerFix -----
			lbSelectedHours.visible = true;
			// ----------------------------------------
			
			lbSelectedHours.htmlText = "[[panel_meditationclock_current_time]]";
			lbSelectedHours.htmlText = CommonUtils.toUpperCaseSafe(lbSelectedHours.htmlText);

			var timePeriod : String = "";
			var hours : uint = _currentTime;
			var mins  : uint = _currentTimeMin;
			
			if ( !_timeFormat24HR )
			{
				if (hours >= 12)
				{
					if ( hours > 12 )
						hours -= 12;

					timePeriod += " PM";
				}
				else
				{
					if ( hours == 0 )
						hours = 12;

					timePeriod += " AM";
				}
			}

				
			var timeString:String = " ";
			if (hours < 10)
			{
				timeString += "0";
			}
			timeString += hours + ":";
			if (mins < 10)
			{
				timeString += "0";
			}
			
			timeString += mins + timePeriod;
			lbSelectedHours.htmlText += timeString;
			lbSelectedHours.htmlText = CommonUtils.toUpperCaseSafe(lbSelectedHours.htmlText);
		}

		protected function handleControllerChange( event:ControllerChangeEvent ):void
		{
			// ----- modAlchemyRequiresMeditation -----
			//if (_isMeditating)
			//{
			//	txtDuration.htmlText = event.isGamepad ? "[[panel_common_cancel]]" : "";
			//	txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
			//}
			
			//mcActivateButtonPc.x =  CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2;
			// ----------------------------------------

			//mcActivateButton.visible = event.isGamepad; /// wtf
		}

		private function timeConvertedForFlashRotation(value:uint):uint
		{
			var transformedTime:uint = value + 12;
			if (transformedTime > 23)
			{
				transformedTime -= 24;
			}
			return transformedTime;
		}

		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			if (event.handled)
			{
				return;
			}
			
			var details : InputDetails = event.details;
			
            if (_isMeditating && details.value == InputValue.KEY_UP)
            {
                switch(details.navEquivalent)
				{
                case NavigationCode.GAMEPAD_B:
                case NavigationCode.ESCAPE:
                    stopMeditation();
					event.handled = true;
                    break;
                }
                return;
            }
			
			if (!_isMeditating)
			{
				CommonUtils.convertWASDCodeToNavEquivalent(details);
				
				if (details.code == KeyCode.E)
				{
					details.navEquivalent = NavigationCode.ENTER;
				}
				
				if (details.code == KeyCode.PAD_LEFT_STICK_AXIS )
				{
					var axisData : InputAxisData = InputAxisData(details.value);
					var magnitude : Number = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
					
					if (magnitude < MAGNITUDE_DEAD_ZONE)
					{
						prevMagnitude = magnitude;
						return;
					}

					if ( prevMagnitude > magnitude && Math.abs(prevMagnitude - magnitude) > 0.0005 )
					{
						prevMagnitude = magnitude;
						return;
					}
					
					prevMagnitude = magnitude;
							
					setSelectedTimeBasedOffPosition(axisData.xvalue, axisData.yvalue);

					event.handled = true;
				}
				else if (details.value == InputValue.KEY_UP && details.fromJoystick == false )
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_A:
					case NavigationCode.ENTER:
						if (!bMeditationBlocked)
						{
							applySelectedTime();
							event.handled  = true;
						}
						else
						{
							dispatchEvent( new GameEvent(GameEvent.CALL, 'OnMeditateBlocked' ));
						}
						break;
					case NavigationCode.UP:
					case NavigationCode.RIGHT:
						if (!_mouseDownOnClock && !_isMeditating )
						{
							var targetTime:uint = selectedTime + 1;
							if (targetTime > 23)
							{
								targetTime = 0;
							}

							trace("GFX - Triggered clock left/up");
							selectedTime = targetTime;

							event.handled = true;
						}
						break;
					case NavigationCode.DOWN:
					case NavigationCode.LEFT:
						if (!_mouseDownOnClock && !_isMeditating )
						{
							selectedTime = selectedTime == 0 ? 23 : (selectedTime - 1);
							event.handled = true;
						}
						break;
					}
				}
			}
		}
		
		protected function handleMouseWheel(event:MouseEvent):void
		{
			if (_isMeditating || bMeditationBlocked)
				return;
				
			if (event.delta > 0)
			{
				var targetTime:uint = selectedTime + 1;
				if (targetTime > 23)
				{
					targetTime = 0;
				}
				selectedTime = targetTime;
			}
			else
			{
				selectedTime = selectedTime == 0 ? 23 : (selectedTime - 1);
			}
		}
		
		protected function handleMouseDown(event:MouseEvent):void
		{
			if (_isMeditating || bMeditationBlocked)
				return;

			// Get the clock positon
			var relativeX:Number = event.stageX - _globalCenter.x;
			var relativeY:Number = _globalCenter.y - event.stageY;

			// Calculate distance
			var distanceFromCenter:Number = Math.sqrt(Math.pow(relativeX, 2) + Math.pow(relativeY, 2));

			if (distanceFromCenter <= _maxRadius)
			{
				_mouseDownOnClock = true;

				// Calculate new selectedTime is appropriate
				setSelectedTimeBasedOffPosition(relativeX, relativeY);
			}
		}

		protected function handleMouseMove(event:MouseEvent):void
		{
			if (_isMeditating || bMeditationBlocked )
			{
				_mouseDownOnClock = false;
				return;
			}

			if (_mouseDownOnClock)
			{
				// Get the clock positon
				var relativeX = event.stageX - _globalCenter.x;
				var relativeY = _globalCenter.y - event.stageY;

				setSelectedTimeBasedOffPosition(relativeX, relativeY);
			}
		}

		protected function handleMouseUp(event:MouseEvent):void
		{
			_mouseDownOnClock = false;
		}

		protected function handleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				if (_isMeditating)
					return;
				
				var distanceFromLastClick = Math.sqrt(Math.pow(event.stageX - _lastClickLocation.x, 2) + Math.pow(event.stageY - _lastClickLocation.y, 2));
				var timeSinceLastClick:Number = getTimer() - _lastClickTime;
				
				_lastClickLocation.x = event.stageX;
				_lastClickLocation.y = event.stageY;
				_lastClickTime = getTimer();
				
				// Get the clock positon
				var relativeX = event.stageX - _globalCenter.x;
				var relativeY = _globalCenter.y - event.stageY;
				
				var distanceFromCenter:Number = Math.sqrt(Math.pow(relativeX, 2) + Math.pow(relativeY, 2));
				
				if (distanceFromCenter <= _maxRadius)
				{
					setSelectedTimeBasedOffPosition(relativeX, relativeY);
				
					if (timeSinceLastClick > 500 || distanceFromLastClick > 30)
					{
						return;
					}
					
					if (bMeditationBlocked)
					{
						dispatchEvent( new GameEvent(GameEvent.CALL, 'OnMeditateBlocked' ));
						return;
					}
					else if (selectedTime != currentTime)
					{
						applySelectedTime();
					}
				}
			}
			else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				if (_isMeditating)
				{
					stopMeditation();
				}
			}
		}

		protected function setSelectedTimeBasedOffPosition(posX:Number, posY:Number):void
		{
			var angle:Number = InputUtils.getAngleRadians( posX, posY );

			// Making sure angle is between 0 and 2 * PI. GetAngleRadians already checks less than 0
			if (angle > ( 2 * Math.PI))
			{
				angle -= 2 * Math.PI;
			}

			// Shift the angle to hour offset (3/4 of a day since midnight (0) is 270 degrees) and bound it to 360 degrees if it goes over
			angle += 3 * Math.PI / 2;
			if (angle > (Math.PI * 2))
			{
				angle -= (Math.PI * 2);
			}

			// The .5 is to make it round properly when converted to in (ie if it was 2.7, it is now 3.2 which rounds to 3 and
			// if it was 2.2, it is now 2.7 which still rounds to 2).
			var hour:int = int(angle * 12.0 / Math.PI + 0.5);

			// Since the angles are given in the reverse direction the clock goes, we have to flip the values
			hour = 12 - hour;
			if (hour < 0)
			{
				hour += 24;
			}

			selectedTime = hour;
		}

		protected function setCurrentHours(value:int):void
		{
			_currentlyRenderedTime = value * NUM_FRAMES_PER_HOUR;
			currentTime = value;
			selectedTime = value;
		}

		protected function setCurrentMin(value:int):void
		{
			currentTimeMin = value;
		}

		protected function updateCurrentHours(value:int):void
		{
			currentTime = value;

			if (_isMeditating)
			{
				if (value == selectedTime && (_currentlyRenderedTime % NUM_FRAMES_PER_HOUR == 0) && (_currentlyRenderedTime / NUM_FRAMES_PER_HOUR) == selectedTime)
				{
					stopMeditation();
				}
			}
		}

		protected function blockClock(value:Boolean):void
		{
            if (!value && _isMeditating)
            {
                _stopMeditationReq = true;
            }
		}

		protected function applySelectedTime():void
		{
			if (selectedTime != currentTime && !_isMeditating)
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnMeditate', [Number(selectedTime)] ));
				_isMeditating = true;
                _stopMeditationReq = false;
				_animationTimer = new Timer(20, 1);
				_animationTimer.addEventListener(TimerEvent.TIMER, animationTimerTrigger);
				_animationTimer.start();
				
				trace("GFX - trying to apply selected timem currentTime: " + _currentTime.toString() + ", targetTime:" + selectedTime.toString());

				mcActivateButton.setDataFromStage(NavigationCode.GAMEPAD_B, -1);
				
				//mcActivateButtonPc.label = "[[panel_common_cancel]]"; // ----- modAlchemyRequiresMeditation -----
				mcActivateButtonPc.setDataFromStage("", KeyCode.ESCAPE);
				mcActivateButtonPc.validateNow();
				//mcActivateButtonPc.x =  CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2; // ----- modAlchemyRequiresMeditation -----
				
				// ----- modAlchemyRequiresMeditation -----
				ModcrabUpdateButtonPrompts();
				// ----------------------------------------
				
				if (InputManager.getInstance().isGamepad())
				{
					// ----- modAlchemyRequiresMeditation -----
					//txtDuration.htmlText = "[[panel_common_cancel]]";
					//txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
					// ----------------------------------------
					
				}
				else
				{
					//txtDuration.htmlText = "";
					//txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
					
				}
				
				
				
			}
		}

        protected function stopMeditation():void
        {
            if (_isMeditating)
            {
				mcActivateButton.setDataFromStage(NavigationCode.GAMEPAD_A, -1);
				
				//mcActivateButtonPc.label = _labelActivateButton; // ----- modAlchemyRequiresMeditation -----
				mcActivateButtonPc.setDataFromStage("", KeyCode.E);
				mcActivateButtonPc.validateNow();
				//mcActivateButtonPc.x =  CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2; // ----- modAlchemyRequiresMeditation -----
				
				// ----- modAlchemyRequiresMeditation -----
				//txtDuration.htmlText = durationText;
				//txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
				// ----------------------------------------

                trace("GFX - Made call to stop meditation");
                dispatchEvent( new GameEvent(GameEvent.CALL, 'OnStopMeditate') );
                _stopMeditationReq = true;
				if ( mcFinishMeditationGlow )
				{
					mcFinishMeditationGlow.gotoAndPlay("start");
				}
				
            }
        }
		
		protected function handleActionButtonPress( event : ButtonEvent ) : void
		{
			if (_isMeditating)
			{
				stopMeditation();
			}
			else if (!bMeditationBlocked)
			{
				applySelectedTime();
			}
			else
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnMeditateBlocked' ));
			}
		}
		
		function animationTimerTrigger( event : TimerEvent ) : void
		{
			if (!_isMeditating)
			{
				_animationTimer.stop();
				return;
			}

			var allowedTime:uint = currentTime;
			var meditationTimeLeft:int;
			var currentRenderedTime:int = Math.floor(_currentlyRenderedTime / NUM_FRAMES_PER_HOUR);
			
			if (currentRenderedTime > 23)
			{
				currentRenderedTime -= 24;
			}
			
			trace("GFX --------------------------------------------------------------------------------------");
			trace("GFX Updating Meditation animation");
			trace("GFX ----------------------------------------------------------============================");
			trace("GFX - CurrentlyRendereredTime: " + _currentlyRenderedTime);
			trace("GFX - allowed time: " + allowedTime);
			trace("GFX - selected time: " + selectedTime);
			trace("GFX - num frames per hour: " + NUM_FRAMES_PER_HOUR);
			trace("GFX - calculated hour: "  + currentRenderedTime);
			trace("GFX - _stopMeditationReq: " + _stopMeditationReq);

			if ((_currentlyRenderedTime % NUM_FRAMES_PER_HOUR != 0) || currentRenderedTime != allowedTime)
			{
				_currentlyRenderedTime += 1;
				trace("GFX - _currentlyRenderedTime after the fact: " + _currentlyRenderedTime);

				if (_currentlyRenderedTime > NUM_ANIM_FRAMES )
				{
					_currentlyRenderedTime -= NUM_ANIM_FRAMES;
				}

				// Update the position and rotations and icons
				// {
				dayQuarterIndicator.currentTime = currentRenderedTime;

				var currentRotation:Number = _currentlyRenderedTime + 12 * NUM_FRAMES_PER_HOUR;
				if (currentRotation >= NUM_ANIM_FRAMES)
				{
					currentRotation -= NUM_ANIM_FRAMES;
				}
				currentRotation = currentRotation / NUM_ANIM_FRAMES * 360;

				arrowCurrent.rotation = currentRotation;
				selectedTimeIndicator.rotation = currentRotation;
				var targetProgress:int = (selectedTime * NUM_FRAMES_PER_HOUR) < _currentlyRenderedTime ? (24 + selectedTime) * NUM_FRAMES_PER_HOUR - _currentlyRenderedTime : selectedTime * NUM_FRAMES_PER_HOUR - _currentlyRenderedTime;
				trace("GFX - settingTarget progress: " + targetProgress);
				++targetProgress;
				selectedTimeIndicator.progress = targetProgress;
				// }

				//txtDuration.text = "[[panel_meditationclock_med_hours]]";
				//meditationTimeLeft = selectedTime > currentAnimationTimeHours ? selectedTime - currentAnimationTimeHours : selectedTime + 24 - currentAnimationTimeHours;
				//txtDuration.appendText(": " + String(meditationTimeLeft == 24 ? 0 : meditationTimeLeft));

				// Animation not done trigger it again
				_animationTimer.reset();
				_animationTimer.start();
			}
			else if (currentRenderedTime == _selectedTime || _stopMeditationReq == true)
			{
				trace("GFX - done animation");
                _stopMeditationReq = false;
				//arrowTarget.visible = false;
				//selectedTimeIndicator.progress = 0;
				//selectedTimeIndicator.visible = false;
				_animationTimer.stop();
				
				stopMeditation();
                _isMeditating = false;
				ModcrabUpdateButtonPrompts(); // mod
				mcActivateButton.setDataFromStage(NavigationCode.GAMEPAD_A, -1);
				
				// mcActivateButtonPc.label = _labelActivateButton; // ----- modAlchemyRequiresMeditation -----
				mcActivateButtonPc.setDataFromStage("", KeyCode.E);
				mcActivateButtonPc.validateNow();
				//mcActivateButtonPc.x =  CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2; // ----- modAlchemyRequiresMeditation -----
				
				// ----- modAlchemyRequiresMeditation -----
				//txtDuration.text = durationText;
				//txtDuration.htmlText = CommonUtils.toUpperCaseSafe(txtDuration.htmlText);
				// ----------------------------------------
				
				//txtDuration.text = "[[panel_meditationclock_med_hours]]";
				//meditationTimeLeft = selectedTime - currentTime;
				//if (meditationTimeLeft < 0) meditationTimeLeft += 24;
				//txtDuration.appendText(": " + String(meditationTimeLeft == 24 ? 0 : meditationTimeLeft));
			}
			else
			{
				// Nothing to update this frame but meditation is not done so keep triggering timer
				// This commonly happens if the animation played faster than the engine could set the currentTime
				_animationTimer.reset();
				_animationTimer.start();
			}
		}

		public function SetBlockMeditation( value : Boolean )
		{
			bMeditationBlocked = value;
			
			if (bMeditationBlocked && mcActivateButton)
			{
				var matrix:Array = new Array();
				var amount:Number = 0.4;
				matrix=matrix.concat(  [amount, 0,      0,      0, 0]);// red
				matrix=matrix.concat(  [0,      amount, 0,      0, 0]);// green
				matrix=matrix.concat(  [0,      0,      amount, 0, 0]);// blue
				matrix = matrix.concat([0,      0,      0,      1, 0]);// alpha
				var darkenFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);

				mcActivateButton.filters = [darkenFilter];
			}
		}
		
		public function Set24HRFormat( value : Boolean )
		{
			_timeFormat24HR = value;
		}
	
		// ----- modAlchemyRequiresMeditation -----
		protected function ModcrabUpdateButtonPrompts( ) : void
		{
			var disabledColor:Number = 0x666666;
			var enabledColor:Number = 0xFFFFFF;
			var extent:Number = 150;
			var rightExtent:Number = CLOCK_CENTER + extent;
			var leftExtent:Number = CLOCK_CENTER - extent;
			var pcNavPinch:Number = 10;

			mcModAlchemyButton.setDataFromStage(NavigationCode.GAMEPAD_Y, -1);
			mcModAlchemyButtonPc.setDataFromStage("", KeyCode.L);

			// hack: change the text before we change it back later to force the color to update
			mcActivateButton.label = "HACK";
			mcActivateButtonPc.label = "HACK";
			mcModAlchemyButton.label = "HACK";
			mcModAlchemyButtonPc.label = "HACK";

			if (_modIsSleeping)
			{
				_labelActivateButton = _isMeditating ? _modCancelButtonPromptLabel : _modSleepButtonPromptLabel;
			}
			else
			{
				_labelActivateButton = _isMeditating ? _modCancelButtonPromptLabel : _modMeditateButtonPromptLabel;
			}
			mcActivateButton.label = _labelActivateButton;
			mcActivateButtonPc.label = _labelActivateButton;

			mcModAlchemyButton.label = _modAlchemyButtonPromptLabel;
			mcModAlchemyButtonPc.label = _modAlchemyButtonPromptLabel;

			mcActivateButton.overrideTextColor = enabledColor;
			mcActivateButtonPc.overrideTextColor = enabledColor;

			mcModAlchemyButton.overrideTextColor = _isMeditating ? disabledColor : enabledColor;
			mcModAlchemyButtonPc.overrideTextColor = _isMeditating ? disabledColor : enabledColor;
			mcModAlchemyButtonPc.clickable = !_isMeditating;

			// these seem to force an update, making the getViewWidth calls accurate this frame
			// without this, they will be incorrect for a frame
			mcModAlchemyButton.validateNow();
			mcModAlchemyButtonPc.validateNow();
			mcActivateButton.validateNow();
			mcActivateButtonPc.validateNow();

			// hack part 1: seems to force getViewWidth to be correct when switching from PC to gamepad nav
			mcModAlchemyButton.displayGamepadIcon();
			mcActivateButton.displayGamepadIcon();

			if (_modIsSleeping)
			{
				mcActivateButton.x = CLOCK_CENTER - (mcActivateButton.getViewWidth() * mcActivateButton.scaleX) / 2;
				mcActivateButtonPc.x = CLOCK_CENTER - mcActivateButtonPc.getViewWidth() / 2;
			}
			else
			{
				mcActivateButton.x = leftExtent;
				mcActivateButtonPc.x = leftExtent + pcNavPinch;

				mcModAlchemyButton.x = rightExtent - (mcModAlchemyButton.getViewWidth() * mcModAlchemyButton.scaleX) + 3; // add 3 as it seems to be slightly off				
				if (_modAlchemyButtonPromptPCPositioned == false) // hack: only do this once to stop it jumping around when pressing the meditation prompt
				{
					mcModAlchemyButtonPc.x = rightExtent - mcModAlchemyButtonPc.getViewWidth() - pcNavPinch;
					_modAlchemyButtonPromptPCPositioned = true;
				}
			}

			// hack part 2: I think this undoes forcing the gamepad icon to be displayed
			mcModAlchemyButton.updateDataFromStage();
			mcModAlchemyButtonPc.updateDataFromStage();
			mcActivateButton.updateDataFromStage();
			mcActivateButtonPc.updateDataFromStage();

			mcModCurrentTimeBackground.visible = !_modIsSleeping;

			if (_modIsSleeping)
			{
				mcModAlchemyButton.visible = false;
				mcModAlchemyButtonPc.visible = false;
			}
			else
			{
				mcModAlchemyButton.visible = true;
				mcModAlchemyButtonPc.visible = true;
			}
		}

		protected function modcrabHandleAlchemyButtonPress( event : ButtonEvent ) : void
		{
			if (_isMeditating)
			{
				// shouldn't be clicked
			}
			else
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnModcrabOnAlchemyPressed' ));
			}
		}

		public function modcrabDoEntranceAnimation( doEntranceAnimation : Boolean ) : void
		{
			_modcrabEntranceAnimationStarted = true;
			if( doEntranceAnimation )
			{
				addEventListener(Event.ENTER_FRAME, modcrabEntranceAnimationTick);
			}
			else
			{
				modcrabStopEntranceAnimation( true );
			}
		}
		public function modcrabStopEntranceAnimation( skipToEnd : Boolean ) : void
		{
			if (!_modcrabEntranceAnimationStarted)
				return;

			if (_modcrabEntranceAnimationStopped)
				return;

			if (skipToEnd)
			{
				this.alpha = 1;
				this.y = _modcrabEntranceAnimationTargetY;
			}

			removeEventListener(Event.ENTER_FRAME, modcrabEntranceAnimationTick);

			_modcrabEntranceAnimationStopped = true;
		}
		function modcrabEntranceAnimationTick(e : Event) : void
		{
			var alphaDone : Boolean = false;
			var positionDone : Boolean = false;

			this.alpha += 0.03;
			if (this.alpha >= 1)
			{
				this.alpha = 1;
				alphaDone = true;
			}

			var difference:Number = _modcrabEntranceAnimationTargetY - this.y;
    		this.y += difference * 0.12;
			if (Math.abs(difference) < 1)
			{
				this.y = _modcrabEntranceAnimationTargetY;
				positionDone = true;
			}

			if (alphaDone && positionDone)
			{
				modcrabStopEntranceAnimation( true );
			}
		}

		// these functions get called from the witcher script code MeditationClockMenu.ws
		protected function setIsSleeping( value : Boolean ) : void
		{
			_modIsSleeping = value;
		}
		protected function setAlchemyButtonPromptLabel( value : String ) : void
		{
			_modAlchemyButtonPromptLabel = value;
			_modAlchemyButtonPromptLabelSet = true;
		}
		protected function setMeditateButtonPromptLabel( value : String ) : void
		{
			_modMeditateButtonPromptLabel = value;
		}
		protected function setSleepButtonPromptLabel( value : String ) : void
		{
			_modSleepButtonPromptLabel = value;
		}
		protected function setCancelButtonPromptLabel( value : String ) : void
		{
			_modCancelButtonPromptLabel = value;
		}
		protected function setDurationTextPrefix( value : String ) : void
		{
			_modDurationTextPrefix = value;
		}
		// ----------------------------------------
	}
}
