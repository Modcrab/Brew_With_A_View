package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.utils.motion.TweenEx;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.text.TextField;

	import fl.transitions.easing.Strong;
	import flash.display.FrameLabel;

	public class HudModuleInteractions extends HudModuleBase
	{
		private static const HOLD_DELAY:Number = 200;
		
		public var mcHoldInteraction : MovieClip;
		public var mcInteraction : MovieClip;
		public var mcIcon : MovieClip;
		
		private var mcFocusInteractionIcon : MovieClip;
		
		private var _btnInteraction : InputFeedbackButton;
		private var _btnHoldInteraction : InputFeedbackButton;
		private var _holdIndicatorDisplayed : Boolean;
		private var _holdIndicatorData : KeyBindingData;
		private var _cachedInputEvent : InputEvent;
		
		private var _startHoldShowing:Boolean = false;
		private var _holdDelayTimer:Timer;

		public function HudModuleInteractions()
		{
			super();
		}
		
		override public function get moduleName():String
		{
			return "InteractionsModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
	
			_btnInteraction = mcInteraction.btnInteract as InputFeedbackButton;
			_btnInteraction.clickable = false;
			_btnInteraction.dontSwapAcceptCancel = true;
			
			_btnHoldInteraction = mcHoldInteraction.btnInteract as InputFeedbackButton;
			_btnHoldInteraction.clickable = false;
			_btnHoldInteraction.dontSwapAcceptCancel = true;
			
			visible = true;
			alpha = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleHoldInput, false, 0, true);
			
			if ( !Extensions.isScaleform )
			{
				showDebugData();
			}
			
			var classRef : Class = getDefinitionByName( "tempIcon_new" ) as Class;
			if ( !classRef )
			{
				trace("GFX Cannot find definition 'tempIcon_new'!");
				return;
			}

			mcFocusInteractionIcon = new classRef() as MovieClip;
			if ( !classRef )
			{
				trace("GFX Cannot create movie clip!");
				return;
			}
			
			mcFocusInteractionIcon.visible = false;
			mcFocusInteractionIcon.alpha = 1;
			
			mcHoldInteraction.visible = false;

			addChild( mcFocusInteractionIcon );
		}

		public function SetVisibility( visibleIcon : Boolean, visibleInteraction : Boolean )
		{
			mcIcon.visible                     = visibleIcon;
			mcInteraction.visible              = visibleInteraction;
		}

		public function SetVisibilityEx( visibleIcon : Boolean, visibleIconPicture : Boolean, visibleInteraction : Boolean, visibleInteractionButton : Boolean, visibleInteractionActionName : Boolean )
		{
			mcIcon.visible                     = visibleIcon;
			mcIcon.mcPicture.visible           = visibleIconPicture;
			mcInteraction.visible              = visibleInteraction;
			mcInteraction.btnInteract.visible  = visibleInteractionButton;
			mcInteraction.mcActionName.visible = visibleInteractionActionName;
		}

		public function SetPositions( iconX : Number, iconY : Number )
		{
			mcIcon.x        = iconX;
			mcIcon.y        = iconY;
			mcInteraction.x = iconX;
			mcInteraction.y = iconY - 40;
		}

		public function EnableHoldIndicator(gpadKeyCode:int, kbKeyCode:int, label:String, holdDuration:Number):void
		{
			_holdIndicatorData = new KeyBindingData();
			_holdIndicatorData.keyboard_keyCode = kbKeyCode;
			_holdIndicatorData.gamepad_keyCode = gpadKeyCode;			
			_holdIndicatorData.label = label;
			_holdIndicatorData.holdDuration = holdDuration * 1000; // convert (s) - > (ms)
			destroyHoldTimer();
			
			_inputMgr.enableHoldEmulation = true;
			InputManager.getInstance().addInputBlocker(false, "HUD_INTERACTION_HOLD");
		}

		public function DisableHoldIndicator():void
		{
			destroyHoldTimer();
			_holdIndicatorData = null;
			tryRestoreInteraction();
			
			_inputMgr.enableHoldEmulation = false;
			InputManager.getInstance().removeInputBlocker("HUD_INTERACTION_HOLD");
		}

		public function SetInteractionIcon( iconText : String )
		{
			mcIcon.mcPicture.gotoAndStop( iconText );
		}

		public function SetInteractionText( interactionText : String )
		{
			mcInteraction.mcActionName.tfActionName.text = interactionText;
		}

		public function SetInteractionKey( value : int, valuePC : int )
		{
			if ( _btnInteraction )
			{
				var buttonName : String = "NONE";
				switch ( value )
				{
					case KeyCode.PAD_B_CIRCLE:
					case KeyCode.PAD_X_SQUARE:
					case KeyCode.PAD_Y_TRIANGLE:
					case KeyCode.PAD_LEFT_TRIGGER:
						_btnInteraction.setDataFromStage("", -1, value);
						break;
					case KeyCode.PAD_A_CROSS:
					case KeyCode.E:
						_btnInteraction.setDataFromStage(NavigationCode.GAMEPAD_A, valuePC);
						break;
					default:
						_btnInteraction.setDataFromStage("", valuePC, value );
						break;
				}
				
				
			}
		}

		public function SetInteractionIconAndText( iconText : String, interactionText : String )
		{
			SetInteractionIcon( iconText );
			SetInteractionText( interactionText );
		}

		public function SetInteractionKeyIconAndText( key : int, keyPC : int, iconText : String, interactionText : String )
		{
			SetInteractionKey( key, keyPC );
			SetInteractionIcon( iconText );
			SetInteractionText( interactionText );
		}

		public function SetHoldDuration( value : Number ):void
		{
			if ( _btnInteraction )
			{
				if (value > 0) value *= 1000; // to ms
				_btnInteraction.holdDuration = value;
			}
		}

		override public function SetScaleFromWS( scale : Number ) : void
		{
			SetScaleAnimation(mcInteraction, scale, FADE_DURATION);
			SetScaleAnimation(mcIcon, scale, FADE_DURATION);
		}

        public function /* WitcherScript */ AddFocusInteractionIcon( id : int, actionName : String ) : void
		{
			if ( mcFocusInteractionIcon )
			{
				mcFocusInteractionIcon.visible = true;
				mcFocusInteractionIcon.x = -2000;
				mcFocusInteractionIcon.y = -2000;
				mcFocusInteractionIcon.scaleX = desiredScale;
				mcFocusInteractionIcon.scaleY = desiredScale;
				mcFocusInteractionIcon.mcPicture.gotoAndStop( actionName );
            }
        }

		public function /* WitcherScript */ RemoveFocusInteractionIcon( id : int ):void
		{
			if ( mcFocusInteractionIcon )
			{
				mcFocusInteractionIcon.visible = false;
			}
        }

		public function /* WitcherScript */ UpdateFocusInteractionIconPosition( id : int, posX : Number, posY : Number ) : void
		{
            if ( mcFocusInteractionIcon )
			{
				mcFocusInteractionIcon.x = posX;
				mcFocusInteractionIcon.y = posY;
			}
        }
		
		private function holdDelayIndicator(event:Event = null):void
		{
			_startHoldShowing = true;
			destroyHoldTimer();
			if (_cachedInputEvent)
			{
				handleHoldInput(_cachedInputEvent);
				_cachedInputEvent = null;
			}
		}
		
		private function handleHoldInput(event:InputEvent):void
		{
			if (!_holdIndicatorData) return;
			
			var details:InputDetails = event.details;
			
			
			var gpadHoldCode:int = _holdIndicatorData.gamepad_keyCode;
			if (_inputMgr.swapAcceptCancel)
			{
				if (gpadHoldCode == KeyCode.PAD_A_CROSS)
				{
					gpadHoldCode = KeyCode.PAD_B_CIRCLE;
				}
				else
				if (gpadHoldCode == KeyCode.PAD_B_CIRCLE)
				{
					gpadHoldCode = KeyCode.PAD_A_CROSS;
				}
			}
			
			var checkKeyCode:Boolean = details.code == gpadHoldCode || details.code == _holdIndicatorData.keyboard_keyCode;
			if (!checkKeyCode)
			{
				return;
			}
			else
			{
				_cachedInputEvent = null;
			}
			
			//trace("GFX HOLD  [", details.navEquivalent, details.code, "] ", _holdDelayTimer, _startHoldShowing, "|  ",  details.value);
			if (_holdDelayTimer && details.value != InputValue.KEY_UP)
			{
				if (details.value == InputValue.KEY_DOWN)
				{
					_cachedInputEvent = event;
				}
				_holdDelayTimer.reset();
				_holdDelayTimer.start();
				
				// waiting some time befor showing indicator to avoid showing on press
				return;
			}
			else
			if (checkKeyCode && !_holdDelayTimer && !_startHoldShowing && details.value != InputValue.KEY_UP)
			{
				if (details.value == InputValue.KEY_DOWN)
				{
					_cachedInputEvent = event;
				}
				_holdDelayTimer = new Timer(HOLD_DELAY, 1);
				_holdDelayTimer.addEventListener(TimerEvent.TIMER, holdDelayIndicator, false, 0, true);
				_holdDelayTimer.start();
				return;
			}
			
			if (details.value == InputValue.KEY_DOWN)
			{
				if (!_holdIndicatorDisplayed)
				{
					_btnHoldInteraction.holdDuration = 0; // reset
					_btnHoldInteraction.setDataFromStage("", _holdIndicatorData.keyboard_keyCode, _holdIndicatorData.gamepad_keyCode);
					_btnHoldInteraction.holdDuration = (_holdIndicatorData.holdDuration - HOLD_DELAY);
					_btnHoldInteraction.validateNow();
					_btnHoldInteraction.handleHoldInput(event);
					_btnHoldInteraction.holdCallback = holdCallback;
					
					mcHoldInteraction.mcActionName.tfActionName.text = _holdIndicatorData.label;
					mcHoldInteraction.visible = true;
					
					_holdIndicatorDisplayed = true;
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnRequestShowHold"));
					
					// use alpha to avoid conflict with SetVisibilityEx and SetVisibility functions
					mcInteraction.alpha = 0;
					
					// force show immediately
					pauseTweenOn(this);
					//visible = true;
					//alpha = 1;
				}
			}
			else
			if (details.value == InputValue.KEY_UP)
			{
				tryRestoreInteraction();
			}
			
		}
		
		private function holdCallback():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnHoldInteractionCallback"));
			tryRestoreInteraction();
		}
		
		// try restore interaction after holdIndicator is hidden
		private function tryRestoreInteraction():void
		{
			_cachedInputEvent = null;
			
			_btnHoldInteraction.holdCallback = null;
			_btnHoldInteraction.setDataFromStage("", -1, -1, 0);
			_btnHoldInteraction.holdDuration = 0;
			
			_startHoldShowing = false;
			_holdIndicatorDisplayed = false;
			
			mcInteraction.alpha = 1;
			mcHoldInteraction.visible = false;
			
			pauseTweenOn(this);
			
			destroyHoldTimer();
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnRequestHideHold"));			
		}
		
		private function destroyHoldTimer():void
		{
			if (_holdDelayTimer)
			{
				_holdDelayTimer.stop();
				_holdDelayTimer.removeEventListener(TimerEvent.TIMER, holdDelayIndicator, false);				
				_holdDelayTimer = null;
			}
		}
		
		private function showDebugData():void
		{
			SetInteractionKey(KeyCode.PAD_A_CROSS,KeyCode.F);
			ShowElementFromState(true, true);
			SetInteractionText("Interact");
		}

	}
}
