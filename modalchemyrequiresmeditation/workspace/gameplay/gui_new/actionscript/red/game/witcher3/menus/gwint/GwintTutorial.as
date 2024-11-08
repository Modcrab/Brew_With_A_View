package red.game.witcher3.menus.gwint
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3MessageQueue;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	
	public class GwintTutorial extends UIComponent
	{
		public var mcTitleText:TextField;
		public var mcMainText:TextField;
		public var mcMeleeText:TextField;
		public var mcRangeText:TextField;
		public var mcSiegeText:TextField;
		public var mcSecondaryText:TextField;
		
		public var mcAButtonWrapper:MovieClip;
		
		private var startupDelayTimer : Timer;
		private var initialDelayActive : Boolean = true;
		
		public var onHideCallback:Function;
		 
		public var localizedStringsWithIcons:Array = null;
		
		public var allowX:Boolean = false;
		
		//protected var currentTutorialFrame:int = 1;
		public var currentTutorialFrame:int = 8; // #Y Hack
		
		public var showCarouselCB:Function;
		public var hideCarouselCB:Function;
		public var changeChoiceCB:Function;
		
		public var nextFrameRenderer:Boolean = true;
		
		public var bigSoundPlayed:Boolean = false;
		
		public var messageQueue:W3MessageQueue;
		
		public static var mSingleton:GwintTutorial;
		override protected function configUI():void
		{
			mouseEnabled = false;
			this.visible = false;
			mSingleton = this;
			super.configUI();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.tutorial.strings", [onGetTutorialStrings]));
			
			stage.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			
			mouseChildren = false;
			
			if (mcAButtonWrapper)
			{
				var btnAccept:InputFeedbackButton = mcAButtonWrapper.getChildByName("mcFeedbackButton") as InputFeedbackButton;
				
				if (btnAccept)
				{
					btnAccept.label = "[[panel_continue]]";
					
					if (InputManager.getInstance().swapAcceptCancel)
					{
						btnAccept.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.SPACE);
					}
					else
					{
						btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.SPACE);
					}
					
					btnAccept.clickable = true;
					btnAccept.visible = true;
					btnAccept.validateNow();
				}
			}
		}
		
		public function get active():Boolean
		{
			return visible && !_isPaused;
		}
		
		private var _isPaused:Boolean = false;
		public function get isPaused():Boolean { return _isPaused; }
		public function set isPaused(value:Boolean):void
		{
			if (_isPaused != value)
			{
				if (_isPaused)
				{
					initialDelayActive = true;
					startupDelayTimer = new Timer(600, 0);
					startupDelayTimer.addEventListener(TimerEvent.TIMER, updateStartTimer);
					startupDelayTimer.start();
					lastDownWasValid = false;
				}
				
				_isPaused = value;
				
				if (visible && messageQueue)
				{
					messageQueue.msgsEnabled = _isPaused;
				}
			}
		}
		
		public function OnTutorialShown(value:Boolean)
		{
			nextFrameRenderer = true;
			if (value)
			{
				if (!bigSoundPlayed)
				{
					bigSoundPlayed = true;
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_tutorial_big_appear"]));
				}
				else
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_tutorial_notification"]));
				}
			}
			else
			{
				bigSoundPlayed = false;
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_tutorial_big_disappear"]));
			}
		}
		
		private function updateStartTimer(event : TimerEvent = null ) : void
		{
			initialDelayActive = false;
			startupDelayTimer = null;
		}
		
		public function show():void
		{
			this.visible = true;
			
			if (startupDelayTimer == null && initialDelayActive)
			{
				startupDelayTimer = new Timer(600, 0);
				startupDelayTimer.addEventListener(TimerEvent.TIMER, updateStartTimer);
				startupDelayTimer.start();
			}
			
			OnTutorialShown(true);
			
			if (messageQueue)
			{
				messageQueue.msgsEnabled = false;
			}
			
			//gotoAndStop(currentTutorialFrame);
			
			InputFeedbackManager.cleanupButtons();
			
			gotoAndStop(1);
			
			//InputFeedbackManager.appendButtonById(GwintInputFeedback.nextTutorial, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_continue");
			//InputFeedbackManager.appendButtonById(GwintInputFeedback.skipTutorial, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "gwint_tutorial_skip_tutorial");
		}
		
		public function continueTutorial():void
		{
			nextFrame();
			isPaused = false;
			hideCarousel();
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			mouseEnabled = value;
		}
		
		protected var lastDownWasValid:Boolean = false;
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			
			if ((details.navEquivalent == NavigationCode.GAMEPAD_A || details.navEquivalent == NavigationCode.ENTER) && details.value == InputValue.KEY_DOWN)
			{
				lastDownWasValid = !isPaused && visible;
			}
			
			if (isPaused || !visible)
			{
				return;
			}
			
			super.handleInput(event);
			
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			
			if (!event.handled)
			{
				switch (details.navEquivalent)
				{
					/*case NavigationCode.ESCAPE:
					case NavigationCode.GAMEPAD_B:
						{
							event.handled = true;
							hide();
						}
						break;*/
					case NavigationCode.GAMEPAD_X:
						if (keyUp && !allowX)
						{
							break;
						}
					case NavigationCode.GAMEPAD_A:
					case NavigationCode.ENTER:
						if (keyUp && lastDownWasValid)
						{
							event.handled = true;
							
							incrementTutorial();
						}
						break;
				}
			}
		}
		
		protected function handleClick(event:MouseEvent):void
		{
			if (isPaused || !visible)
			{
				return;
			}
			
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				event.stopImmediatePropagation();
				incrementTutorial();
			}
		}
		
		protected function incrementTutorial():void
		{
			if (!nextFrameRenderer || initialDelayActive)
			{
				return;
			}
			
			trace("GFX Marcin ", currentTutorialFrame, totalFrames);
			if (currentTutorialFrame <= totalFrames)
			{
				nextFrameRenderer = false;
				++currentTutorialFrame;
				nextFrame();
			}
			else
			{
				hide();
			}
		}
		
		protected function hide():void
		{
			this.visible = false;
			
			OnTutorialShown(false);
			
			if (messageQueue)
			{
				messageQueue.msgsEnabled = true;
			}
			
			if (onHideCallback != null)
			{
				onHideCallback();
			}
		}
		
		public function showCarousel():void
		{
			if (showCarouselCB != null)
			{
				showCarouselCB();
			}
		}
		
		public function hideCarousel():void
		{
			if (hideCarouselCB != null)
			{
				hideCarouselCB();
			}
		}
		
		public function showCardAtIndex(index:int):void
		{
			trace("GFX showCardAtIndex", changeChoiceCB);
			if (changeChoiceCB != null)
			{
				changeChoiceCB(index);
			}
		}
		
		protected function onGetTutorialStrings(stringArray:Array):void
		{
			localizedStringsWithIcons = stringArray;
			
			if (currentFrame == 1 && localizedStringsWithIcons.length > 0 && mcMainText != null)
			{
				mcMainText.htmlText = localizedStringsWithIcons[0];
			}
		}
	}
}
