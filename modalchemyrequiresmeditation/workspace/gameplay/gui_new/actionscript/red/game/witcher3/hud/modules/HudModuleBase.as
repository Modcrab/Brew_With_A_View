package red.game.witcher3.hud.modules
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;

	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import fl.motion.easing.*;
	import fl.motion.easing.Quadratic;
	import fl.motion.easing.Linear;
	import fl.transitions.easing.Strong;
	import fl.transitions.easing.None;
	import red.game.witcher3.hud.states.*;

	import red.game.witcher3.utils.motion.TweenEx;

	public class HudModuleBase extends CoreHudModule
	{
		public var mcTutorialHighlight : MovieClip;

		protected static const TOGGLE_DURATION : Number = .6;
		protected static const FADE_DURATION : Number = 1000;
		protected var UPDATE_FADE_TIME : Number = 3000;
		protected var OPACITY_MAX : Number = 0.8;
		protected var OPACITY_MIN : Number = 0.2;
		protected var targetTweens:Vector.<TweenEx> = new Vector.<TweenEx>();
		protected var _ShowState : Boolean = false;
		protected var updateTimer : Timer;

		public var stateMachine:StateMachine;
		public var isAlwaysDynamic : Boolean = false;
		public var isEnabled : Boolean = true;
		public var desiredScale : Number = 1;
		public var desiredAlpha : Number = 0.0;
		
		protected var dontRescale : Boolean;

		public function HudModuleBase()
		{
			super();
			
			visible = false;
			
			if (mcTutorialHighlight)
			{
				mcTutorialHighlight.visible = false;
			}
			SetupStates();
			
			_enableHoldEmulation = false;
			_enableInputDeviceCheck = false;
		}

		public function SetupStates()
		{
			stateMachine = new StateMachine();
			stateMachine.addState("Show", new ShowState(this), []);
			stateMachine.addState("Hide", new HideState(this), []);
			stateMachine.addState("OnDemand", new OnDemandState(this), []);
			stateMachine.addState("OnUpdate", new OnUpdateState(this), []);

			stateMachine.setState("Hide");
		}

		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
		}

		public function SetMaxOpacity( value : Number )
		{
			OPACITY_MAX = Math.max(OPACITY_MIN, value);
			/*if ( alpha > 0 )
			{
				alpha =  OPACITY_MAX;
			}*/
		}

		public function SetEnabled( value : Boolean )
		{
			isEnabled = value;
			if ( !isEnabled )
			{
				SetState("Hide");
				this.alpha = 0;
				this.desiredAlpha = 0;
			}
		}
		
		public function getState():String
		{
			return stateMachine.getState();
		}
		
		public function SetState( value : String )
		{
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [("SetState "+value+" for "+this.moduleName )]));
			if ( value == null )
			{
				return;
			}
			if ( !isEnabled )
			{
				stateMachine.setState("Hide");
			}
			else
			{
				stateMachine.setState(value);
			}
		}

		public function ShowElement( bShow : Boolean, bImmediately : Boolean = false, bIgnoreState : Boolean = false ):void
		{
			if ( bIgnoreState )
			{
				ShowElementFromState(bShow, bImmediately);
			}
			else
			{
				stateMachine.ShowElement(bShow, bImmediately);
			}
		}

		public function SetScaleFromWS( scale : Number ) : void
		{
			SetScaleAnimation(this, scale, FADE_DURATION);
		}

		protected var _shown:Boolean;
		public function ShowElementFromState( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [("ShowElementFromState "+bShow+" for "+this.moduleName )]));
			//if (this.moduleName != "ItemInfoModule")
			//	trace("GFX [", this, "] ShowElementFromState ", bShow, bImmediately);
			
			if (_shown == bShow)
			{
				return;
			}
			
			_shown = bShow;
			if ( bImmediately )
			{
				if ( bShow )
				{
					if (!visible) visible = true;
					alpha = OPACITY_MAX;
					desiredAlpha = OPACITY_MAX;					
				}
				else
				{
					if (visible) visible = false;
					alpha = 0;
					desiredAlpha = 0;
				}
			}
			else
			{
				if ( bShow )
				{
					fadeIn();
				}
				else
				{
					fadeOut();
				}
			}
		}
		
		protected function fadeIn():void
		{
			var tweenProps:Object;
			var scaleCheck:Boolean = scaleX == desiredScale && scaleY == desiredScale;
			
			//trace("GFX [", this, "] fadeIn ");
			
			if (alpha == OPACITY_MAX && scaleCheck)
			{
				//trace("GFX -- fail");
				//pauseTweenOn(this);
				
				GTweener.removeTweens(this);
				visible = true;
				desiredAlpha = alpha;
				return;
			}
			
			if (!visible)
			{
				visible = true;
			}
			
			if (alpha != OPACITY_MAX)
			{
				//alpha = 0;
				desiredAlpha = OPACITY_MAX;
				tweenProps = { alpha: OPACITY_MAX };
			}
			
			if (!dontRescale && !scaleCheck)
			{
				if (!tweenProps) tweenProps = { };
				tweenProps.scaleX = desiredScale;
				tweenProps.scaleY = desiredScale;
			}
			
			GTweener.removeTweens(this);
			if (tweenProps)
			{
				GTweener.to(this, TOGGLE_DURATION, tweenProps, { ease:Sine.easeOut, onComplete:handleModuleShown } );
			}
		}
		
		protected function fadeOut():void
		{
			var tweenProps:Object;
			var scaleCheck:Boolean = scaleX == desiredScale && scaleY == desiredScale;
			
			//trace("GFX [", this, "] fadeOut ");
			
			if (alpha == 0 && scaleCheck)
			{
				//trace("GFX -- fail");
				GTweener.removeTweens(this);
				visible = false;
				desiredAlpha = alpha;
				return;
			}
			
			desiredAlpha = 0;
			if (alpha != desiredAlpha)
			{
				tweenProps = { alpha: 0 };
			}
			
			if (!dontRescale && !scaleCheck)
			{
				if (!tweenProps) tweenProps = { };
				tweenProps.scaleX = desiredScale;
				tweenProps.scaleY = desiredScale;
			}
			
			GTweener.removeTweens(this);
			if (tweenProps)
			{				
				GTweener.to(this, TOGGLE_DURATION, tweenProps, { ease:Sine.easeOut, onComplete:handleModuleHidden } );
			}
		}
		
		protected function handleModuleShown(tweenInstant:GTween):void
		{
			//
		}
		
		protected function handleModuleHidden(tweenInstant:GTween):void
		{
			visible = false;
		}

		public function SaveShowState( bShow : Boolean ):void
		{
			_ShowState = bShow;
		}

		public function GetSavedShowState( ) : Boolean
		{
			return _ShowState;
		}

		public function SetUpdateTimer( ) : void
		{
			if ( !updateTimer )
			{
				updateTimer = new Timer(UPDATE_FADE_TIME, 1);
				updateTimer.addEventListener(TimerEvent.TIMER, UpdateTimerFinishedCounting);
			}
			else
			{
				updateTimer.reset();
			}
			updateTimer.start();
		}

		public function ResetUpdateTimer() : void
		{
			if ( updateTimer )
			{
				updateTimer.reset();
				updateTimer.start();
			}
		}

		public function RemoveUpdateTimer() : void
		{
			if ( updateTimer )
			{
				updateTimer.stop();
				updateTimer.removeEventListener(TimerEvent.TIMER, UpdateTimerFinishedCounting);
				updateTimer = null;
			}
		}

		function UpdateTimerFinishedCounting( event : TimerEvent ) : void
		{
			RemoveUpdateTimer();
			ShowElementFromState(false, false);
		}

		public function OnUpdate( event : GameEvent ) : void
		{
			//dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', ["OnUpdate "+this.moduleName]));
			
			if ( !updateTimer )
			{
				SetUpdateTimer();
				ShowElementFromState(true, false);
			}
			else
			{
				ResetUpdateTimer();
			}
		}

		protected function effectFade( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			desiredAlpha = value;
			
			//
			//trace("Bidon " +moduleName +" effectFade scaleX"+scaleX+" scaleY"+scaleY+" alpha "+value+" desiredAlpha "+desiredAlpha);
			//
			
			tweenEx = TweenEx.to( time, target, { scaleX:desiredScale, scaleY:desiredScale, alpha:value }, { paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete } );
			targetTweens.push(tweenEx);
		}

		protected function handleTweenComplete( tween : TweenEx ) : void
		{
			//
			//trace("Bidon handleTweenComplete " +moduleName +" tween.target.name "+tween.target.name );
			//
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

		override public function get scaleX():Number
		{
			return super.actualScaleX;
		}
		override public function get scaleY():Number
		{
			return super.actualScaleY;
		}

		protected function SetScaleAnimation( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			desiredScale = value;
			//
			//trace("Bidon " +moduleName +" SetScaleAnimation scaleX" + scaleX + " scaleY" + scaleY + " alpha " + alpha+" desiredAlpha "+desiredAlpha+" value "+value );
			//
			tweenEx = TweenEx.to( time, target, { scaleX:value, scaleY:value, alpha:desiredAlpha }, {  paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete  } );
			targetTweens.push(tweenEx);
		}

		public function ShowTutorialHighlight ( show : Boolean, tutorialName : String )
		{
			if ( mcTutorialHighlight )
			{
				if ( show )
				{
					mcTutorialHighlight.gotoAndStop(tutorialName);
				}
				mcTutorialHighlight.visible = show;
			}
		}
		
		override public function toString():String 
		{
			return "HudModuleBase [ " + this.moduleName + " ]";
		}
		
		protected var isInCutscene : Boolean;
		
		public function onCutsceneStartedOrEnded( started : Boolean )
		{
		}
	}
}
