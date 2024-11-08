package red.game.witcher3.menus.mainmenu
{
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import red.core.CoreMenu;
	import scaleform.gfx.Extensions;
	import flash.utils.getTimer;

	import scaleform.clik.events.InputEvent;
	import red.core.constants.KeyCode;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.data.InputAxisData;

	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.easing.Quadratic;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.core.CoreMenu;

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;

	import flash.display.BitmapData;
	import flash.display.Bitmap;

	public class CreditsMenu extends CoreMenu
	{
		public var tfScrollingText1 : TextField;
		public var tfScrollingText2 : TextField;
		public var mcCurrentSection : MovieClip;
		public var scrollbackground : MovieClip;
		public var mcSkipIndicator	: MovieClip;
		
		public var mcThanks : MovieClip;
		public var mcLovingMemory : MovieClip;

		private var _showThankYouNote : Boolean = false;
		private var _scrollingTexts : Vector.< String > = new Vector.< String >();
		private var _fadeTimer:Timer;
		private var _sectionTimer:Timer;
		private var _sectionTimerStartTime:Number;
		private var _skipButtonShown : Boolean;
		private var _displayTime : Number;
		private var _delay : Number;
		private var _canClose : Boolean = false;
		private var _scrollingSpeed : Number = 75;
		protected var targetTweens:Vector.<TweenEx> = new Vector.<TweenEx>();
		protected static const FADE_DURATION : Number = 1000;
		
		protected static const STAGE_HEIGHT : Number = 1080;
		
		public static const STOP_VIDEO : String = "StopVideo";

		public function CreditsMenu()
		{
			super();
			//SHOW_ANIM_DURATION = 0;
			SHOW_ANIM_OFFSET = 0;
			_enableMouse = false;
			scrollbackground.alpha = 0;
		}

		override protected function get menuName():String
		{
			return "CreditsMenu";
		}

		protected override function configUI():void
		{
			super.configUI();

			_fadeTimer = new Timer( 3300 );
			_fadeTimer.addEventListener( TimerEvent.TIMER, OnFadeTimer, false, 0, true );
			
			mcSkipIndicator.alpha = 0;

			var btnSkip : InputFeedbackButton = mcSkipIndicator.btnSkip as InputFeedbackButton;
			btnSkip.clickable = false;
			btnSkip.label = "[[panel_button_dialogue_skip]]";
			btnSkip.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.ESCAPE);
			btnSkip.validateNow();
			
			tfScrollingText1.autoSize = "left";
			//tfScrollingText1.border = true;
			tfScrollingText1.multiline = true;
			tfScrollingText1.wordWrap = true;

			tfScrollingText2.autoSize = "left";
			//tfScrollingText2.border = true;
			tfScrollingText2.multiline = true;
			tfScrollingText2.wordWrap = true;
			
			mcCurrentSection.alpha = 0;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			mcThanks.addEventListener(CreditsMenu.STOP_VIDEO, lovingMemoryStopVideo);
			mcThanks.addEventListener(Event.COMPLETE, thankYouFinished);
			mcLovingMemory.addEventListener(CreditsMenu.STOP_VIDEO, lovingMemoryStopVideo);
			mcLovingMemory.addEventListener(Event.COMPLETE, lovingMemoryFinished);
		}

		public function setCreditsText(string:String,displayTime:Number,delay:Number,posX: int, posY: int):void
		{

			
			if (posX > 890)
			{
				mcCurrentSection.tfCurrent.htmlText = "<p align=\"right\">" + string +"</p>";
				mcCurrentSection.tfCurrent.x = -mcCurrentSection.tfCurrent.width/2;
				mcCurrentSection.y = 1080;
				//mcCurrentSection.x = 1960;
			}
			else
			{
				mcCurrentSection.tfCurrent.htmlText = string;
				mcCurrentSection.tfCurrent.x = 0;
				mcCurrentSection.y = 1080;
				mcCurrentSection.x = - 50 -mcCurrentSection.tfCurrent.width;
			}

			mcCurrentSection.tfCurrent.height = mcCurrentSection.tfCurrent.textHeight + 10;
			mcCurrentSection.tfCurrent.y = - mcCurrentSection.height / 2;
			
			
			_displayTime = displayTime;
			_delay = delay;
			mcCurrentSection.alpha = 0;
			mcCurrentSection.scaleX = 2;
			mcCurrentSection.scaleY = 2;
			mcCurrentSection.x = posX;
			mcCurrentSection.y = posY;			
			
			GTweener.to(mcCurrentSection, 0.2 , { alpha : 1, scaleX : 1, scaleY : 1, x:posX, y:posY },  { onComplete:handleSectionShowed } );

		}
		
		protected function handleSectionShowed(curTween:GTween):void
		{
			var animposoffset = mcCurrentSection.x +25;
			GTweener.to(mcCurrentSection, _displayTime , { scaleX : 0.9, scaleY : 0.9 ,x:animposoffset },  {  onComplete:handleSectionFinished } );
		}

		protected function handleSectionFinished(curTween:GTween):void
		{
			if ( _sectionTimer )
			{
				_sectionTimer.removeEventListener( TimerEvent.TIMER, OnSectionTimer );
			}
			_sectionTimer = new Timer( _delay * 1000 );
			_sectionTimerStartTime = getTimer();
			_sectionTimer.start();
			GTweener.to(mcCurrentSection, 0.2 , { alpha : 0 } );
			_sectionTimer.addEventListener( TimerEvent.TIMER, OnSectionTimer, false, 0, true );
		}
		

		private function OnSectionTimer( event:TimerEvent ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSectionHidden" ) );
			_sectionTimer.stop();
			_sectionTimer.removeEventListener( TimerEvent.TIMER, OnSectionTimer );
		}

		private function IsAnyScrollingText() : Boolean
		{
			return _scrollingTexts.length > 0;
		}
		
		private function GetFirstScrollingText() : String
		{
			if ( !IsAnyScrollingText() )
			{
				return null;
			}

			var str : String = _scrollingTexts[ 0 ];
			_scrollingTexts.splice( 0, 1 );
			return str;
		}
		
		public function setScrollingSpeed( scrollingSpeed : Number )
		{
			_scrollingSpeed = scrollingSpeed;
		}
		
		public function addScrollingText(string:String):void
		{
			_scrollingTexts.push( string );
		}

		public function startScrollingText():void
		{
			var str : String = GetFirstScrollingText();
			if ( !str )
			{
				return;
			}
			scrollbackground.alpha = 1;
			ScrollIn( tfScrollingText1, str );
		}

		public function setThankYouText(string:String):void
		{
			_showThankYouNote = true;
			mcThanks.mcThankYouNote.tfThankYouNote.htmlText = string;
		}
		
		private var _restartSectionTimer : Boolean = false;
		
		public function changedConstraintedState( entered : Boolean ):void
		{
			trace("Minimap changedConstraintedState " + entered + " ----------------------------------------");
			if ( entered )
			{
				if ( _sectionTimer && _sectionTimer.running )
				{
					_sectionTimer.stop();
					_sectionTimer.delay -= ( getTimer() - _sectionTimerStartTime );
					_restartSectionTimer = true;
					
					trace("Minimap STOPPING " + _sectionTimer.delay );
				}
			}
			else
			{
				if ( _sectionTimer && _restartSectionTimer )
				{
					_sectionTimerStartTime = getTimer();
					_sectionTimer.start();
					_restartSectionTimer = false;

					trace("Minimap STARTING " + _sectionTimer.delay );
				}
			}
			
			GTweener.pauseTweens( mcCurrentSection, entered );
			GTweener.pauseTweens( tfScrollingText1, entered );
			GTweener.pauseTweens( tfScrollingText2, entered );
		}
		
		private function ScrollIn( textField : TextField, string : String )
		{
			textField.htmlText = string;

			// start position - invisible just below bottom of the screen
			// end position - visible aligned to bottom
			var startPosition : int = STAGE_HEIGHT;
			var endPosition : int = STAGE_HEIGHT - textField.height;
			var distanceToMove = Math.abs( startPosition - endPosition );
	
			textField.y = startPosition;
			GTweener.to( textField, distanceToMove / _scrollingSpeed, { y: endPosition },  { onComplete:OnScrolledIn } );
		}

		protected function OnScrolledIn( curTween:GTween ):void
		{
			var textField : TextField = curTween.target as TextField;
			
			ScrollOut( textField );
			
			var freeTextField : TextField = GetOtherTextField( textField );
			var str : String = GetFirstScrollingText();
			if ( !str )
			{
				return;
			}
			ScrollIn( freeTextField, str );
		}

		private function ScrollOut( textField : TextField )
		{
			// start position - visible aligned to bottom
			// end position - invisible just up to the top of the screen
			var startPosition : int = textField.y;
			var endPosition : int = -textField.height;
			var distanceToMove = Math.abs( startPosition - endPosition );
	
			textField.y = startPosition;
			GTweener.to( textField, distanceToMove / _scrollingSpeed, { y: endPosition },  { onComplete:OnScrolledOut } );
		}

		protected function OnScrolledOut( curTween:GTween )
		{
			var textField : TextField = curTween.target as TextField;
			
			if ( _scrollingTexts.length == 0 )
			{
				if ( _canClose )
				{
					//show the "in loving memory clip" before closing out
					if ( _showThankYouNote )
						mcThanks.gotoAndPlay("start");
					else
						mcLovingMemory.gotoAndPlay("start");
					
					//we now call closeMenu() after the clip has finished playing: lovingMemoryFinished()				
				}
				else
				{
					// we need to wait for last textfield to scroll out
					_canClose = true;
				}
			}
		}

		private function thankYouFinished( event : Event ) : void
		{
			mcLovingMemory.gotoAndPlay("start");
		}

		private function lovingMemoryStopVideo( event : Event ) : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnStopVideo" ) );
		}
		
		private function lovingMemoryFinished( event : Event ) : void
		{
			closeMenu();
		}
		
		private function GetOtherTextField( textField : TextField ) : TextField
		{
			if ( textField == tfScrollingText1 )
			{
				return tfScrollingText2;
			}
			return tfScrollingText1;
		}
		
		public function SkipConfirmShow():void
		{
			_skipButtonShown = true;
			_fadeTimer.stop();
			effectFade( mcSkipIndicator, 1, 300 );
			_fadeTimer.reset();
			_fadeTimer.start();
		}

		public function SkipConfirmHide():void
		{
			_skipButtonShown = false;
			_fadeTimer.stop();
			effectFade( mcSkipIndicator, 0, 300 );
		}

		private function OnFadeTimer( event:TimerEvent ):void
		{
			SkipConfirmHide();
		}

		protected function effectFade( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			tweenEx = TweenEx.to( time, target, { alpha:value }, { paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete } );
			targetTweens.push(tweenEx);
		}

		protected function handleTweenComplete( tween : TweenEx ) : void
		{
			pauseTweenOn(tween.target);
		}

		protected function pauseTweenOn( target : Object )
		{
			for (var i : int = targetTweens.length -1; i > -1 ; i-- )
			{
				if ( target == targetTweens[i].target )
				{
					targetTweens[i].paused = true;
					targetTweens.splice(i, 1);
				}
			}
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
            var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);

			if (!event.handled && keyUp)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B :
					case NavigationCode.GAMEPAD_X :
						if ( mcSkipIndicator.alpha > 0.1 )
						{
							SkipConfirmHide();
							closeMenu();
							return;
						}
						break;
				}
				SkipConfirmShow();
			}

			if (keyUp && !event.handled )
			{
				switch(details.code)
				{
					case KeyCode.SPACE :
					case KeyCode.ESCAPE :
						if ( mcSkipIndicator.alpha > 0.1 )
						{
							SkipConfirmHide();
							closeMenu();
							return;
						}
						break;
				}
				SkipConfirmShow();
			}
		}
	}
}
