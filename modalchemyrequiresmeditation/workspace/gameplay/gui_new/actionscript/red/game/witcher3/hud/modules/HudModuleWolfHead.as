package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.wolfHead.StaminaIndicator;
	import red.game.witcher3.hud.modules.wolfHead.W3StatIndicator;
	import red.game.witcher3.hud.modules.wolfHead.WolfMedallion;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.motion.Tween;
	import red.game.witcher3.hud.modules.signinfo.HudItemInfo;

	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.events.TimerEvent;

	public class HudModuleWolfHead extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// Variable
		//-------------------------------------------------------------------------------------------------------------------

		public var mcHealthBar 			: W3StatIndicator;
		public var mcToxicityBar 		: W3StatIndicator;
		public var mcExperienceBar 		: W3StatIndicator;
		public var mcLockedToxicityBar 	: W3StatIndicator;
		public var mcStaminaBar 		: StaminaIndicator;
		public var mcWolfsHead 			: WolfMedallion;
		public var mcAdrenalinePoints 	: MovieClip;
		public var mcBckCircle 			: MovieClip;
		public var mcSignText 			: MovieClip;
		public var mcSignSlot 	 		: HudItemInfo;
		public var mcSkull	 	 		: MovieClip;
		public var mcSkullBck			: MovieClip;
		public var mSignReady			: MovieClip;
		public var mcNewLevelIndcator	: MovieClip;
		public var mcFocusProgressbar	: MovieClip;
		
		//Mutation
		public var mcMutationFeedback	: MovieClip;
		
		public var focusbar 			: MovieClip

		private var mcSignTextTween 	: Tween; // #B kill im
		
		private var m_neededStaminaTimeOutID : uint;
		private var m_signTextTimeOutID : uint;
		
		private var pendingSignText	: String = "";
		private var isCiriMainPlayer : Boolean = false;
		private var isAlwaysDisplayed : Boolean = false;

		private var greenHealthBar : MovieClip;
		
		
		public function HudModuleWolfHead()
		{
			super();
		}

		override public function get moduleName():String
		{
			return "WolfHeadModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			focusbar = mcAdrenalinePoints.getChildByName( "mcFocusProgressbar") as MovieClip;
			alpha = 0.0;
			
			mcNewLevelIndcator.visible = false;
			
			greenHealthBar = mcHealthBar["mcBar"];
			
			if (mcMutationFeedback)
			{
				mcMutationFeedback.visible = false;
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setVitality( _Percentage : Number )
		{
			var hp : Number = _Percentage * 100;
			
			mcHealthBar.value = hp;
			mcHealthBar.mcBackgroundHealth.value = hp;
			
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function setStamina( _Percentage : Number )
		{
			mcStaminaBar.value = _Percentage * 100;

			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );

			if ( _Percentage == 1 )
			{
				setSignIconDimmed(false);
				mSignReady.gotoAndPlay("show");
			}
			else
			{
				setSignIconDimmed(true);
			}
		}

		public function setToxicity( _Percentage : Number )
		{
			if ( !isCiriMainPlayer )
			{
				mcToxicityBar.value =  _Percentage * 100;

				if ( _Percentage >= 0.5 )
					UpdateGreenHealthBar( _Percentage );
				else
					greenHealthBar.gotoAndStop(1);
				
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
		}

		private function UpdateGreenHealthBar( _Percentage : Number )
		{
			var greenVal: Number = ((_Percentage - 0.5)/0.5) * 50; // [(x - min)/(max- min)] * 50 frames
			greenHealthBar.gotoAndStop( Math.round(greenVal));
		}
		
		public function setExperience( _Percentage : Number )
		{
			mcExperienceBar.value = _Percentage * 100;

			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function setLockedToxicity( _Percentage : Number )
		{
			if ( !isCiriMainPlayer )
			{
				mcLockedToxicityBar.value =  _Percentage * 100;
			}
		}

		public function setDeadlyToxicity( value : Boolean )
		{
			if ( !isCiriMainPlayer )
			{
				if ( value )
				{
					mcSkull.gotoAndStop( "deadly" );
				}
				else
				{
					mcSkull.gotoAndStop( "normal" );
				}
			}
		}

		public function showStaminaNeeded( percent : Number )
		{
			mcStaminaBar.ShowAmountNeeded( percent );
			
			clearTimeout( m_neededStaminaTimeOutID );
			m_neededStaminaTimeOutID = setTimeout( hideStaminaNeeded, 2000 );

			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function hideStaminaNeeded()
		{
			clearTimeout( m_neededStaminaTimeOutID );
			
			mcStaminaBar.HideAmountNeeded();
		}

		public function switchWolfActivation( _Activate : Boolean )
		{
			if ( _Activate)
			{
				mcWolfsHead.StartGlow();
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
			else
			{
				mcWolfsHead.StopGlow();
			}
		}

		public function setSignIcon( value : String ) : void
		{
			mcSignSlot.IconName = value;
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function setSignText( value : String ) : void
		{
			mcSignText.textField.text = value;

			if ( stateMachine.current != 'Hide' )
			{
				mcSignText.alpha = 1;
				pendingSignText = "";
				clearTimeout( m_signTextTimeOutID );
				m_signTextTimeOutID = setTimeout( hideSignText, 2000 );

				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
			else
			{
				pendingSignText = value;
			}
		}

		public function hideSignText()
		{
			clearTimeout( m_signTextTimeOutID );
			if ( mcSignTextTween )
				mcSignTextTween.paused = true;
			mcSignTextTween = new Tween( 500, mcSignText, { alpha : 0 }, { paused:false } );
		}

		override public function SetState( value : String )
		{
			super.SetState( value );
			
			if ( value != "Hide" && pendingSignText != "" )
			{
				setSignText( pendingSignText );
			}
		}
		
		public function setSignIconDimmed( value : Boolean ) : void
		{
			mcSignSlot.IconDimmed = value;
		}

		public function setFocusPoints( value:int ):void
		{
			var focusPointClip : MovieClip;
			var blink:MovieClip = mcAdrenalinePoints.getChildByName("mcblink") as MovieClip;
			for( var i : uint = 1; i < 4; i++ )
			{
				focusPointClip = mcAdrenalinePoints.getChildByName( "mcFocusPoint" + ( i ) ) as MovieClip;
				focusPointClip.adrenaline_glow.gotoAndPlay(1);
				if ( i <= value )
				{
					focusPointClip.gotoAndStop( "reserved_up" );
				}
				else
				{
					focusPointClip.gotoAndStop( "up" );
					focusPointClip.adrenaline_glow.gotoAndStop(1);
				}
			}
			
			blink.gotoAndPlay("play");
		}
		public function UpdateFocusPointsBar(percentage: Number):void
		{
			if (focusbar)
			{
				focusbar.value = percentage * 100 / 3;
			}
		}

		public function lockFocusPoints( value:int ):void
		{
			var focusPointClip : MovieClip;
			for( var i : uint = 1; i <= value; i++ )
			{
				focusPointClip = mcAdrenalinePoints.getChildByName( "mcFocusPoint" + ( i ) ) as MovieClip;
				focusPointClip.gotoAndStop( "locked" );
			}
		}
		
		
		public function setCiriAsMainCharacter( value : Boolean )
		{
			isCiriMainPlayer = value;
			mcSkull.visible = !value;
			mcSkullBck.visible = !value;
			mcToxicityBar.visible = !value;
			mcAdrenalinePoints.visible = !value;
			if ( value )
			{
				mcWolfsHead.SetMedalionGraphic("cat");
				mcStaminaBar.SetStaminaBarGraphic("cat");
				mcWolfsHead.StopGlow();
			}
			else
			{
				mcWolfsHead.SetMedalionGraphic("wolf");
				mcStaminaBar.SetStaminaBarGraphic("wolf");
				mcWolfsHead.StopGlow();
			}
		}
		
		public function setCoatOfArms( value : Boolean )
		{
			if ( value )
			{
				mcWolfsHead.SetMedalionGraphic("coat_of_arms");
			}
			else
			{
				mcWolfsHead.SetMedalionGraphic("wolf");
			}
		}

		public function setShowNewLevelIndicator( value : Boolean )
		{
			mcNewLevelIndcator.visible = value;
		}
		
		override public function SetEnabled( value : Boolean )
		{
			//trace("GFX WOLF SetEnabled ", value);
			isEnabled = value;
			if ( !isEnabled )
			{
				SetState("Hide");
				this.alpha = 0;
				this.desiredAlpha = 0;
			}
			else if ( isAlwaysDisplayed )
			{
				SetState("OnUpdate");
				setAlwaysDisplayed(isAlwaysDisplayed);
			}
		}
		
		override public function ShowElement( bShow : Boolean, bImmediately : Boolean = false, bIgnoreState : Boolean = false ):void
		{
			//trace("GFX WOLF ShowElement bShow ", bShow, "; bImmediately ", bImmediately, "; bImmediately ", bIgnoreState, "; isAlwaysDisplayed ", isAlwaysDisplayed);
			if ( bIgnoreState )
			{
				if ( !isAlwaysDisplayed )
				{
					ShowElementFromState(bShow, bImmediately);
				}
			}
			else
			{
				stateMachine.ShowElement(bShow, bImmediately);
			}
		}

		public function setAlwaysDisplayed( value : Boolean )
		{
			//trace("GFX WOLF setAlwaysDisplayed ", value);
			
			isAlwaysDisplayed = value;
			
			if ( value )
			{
				RemoveUpdateTimer();
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
		}
		
		override function UpdateTimerFinishedCounting( event : TimerEvent ) : void
		{	
			if ( isAlwaysDisplayed )
			{
				RemoveUpdateTimer();
				return;
			}
			else
			{
				super.UpdateTimerFinishedCounting( event );
			}
		}
		
		private var _mutationFeedbackTimer : Timer;

		public function showMutationFeedback( value : int )
		{
			if ( mcMutationFeedback  )
			{
				if ( _mutationFeedbackTimer )
				{
					_mutationFeedbackTimer.stop();
					_mutationFeedbackTimer = null;
				}

				switch ( value )
				{
					case 0:
						mcMutationFeedback.visible = false;
						break;
					case 1:
						mcMutationFeedback.visible = true;
						_mutationFeedbackTimer = new Timer( 1000, 1 );
						_mutationFeedbackTimer.addEventListener(TimerEvent.TIMER, handleTimerFinished, false, 0, true );
						_mutationFeedbackTimer.start();
						break;
					case 2:
						mcMutationFeedback.visible = true;
						break;
				}
			}
		}
		
		private function handleTimerFinished(event:TimerEvent):void
		{
			mcMutationFeedback.visible = false;
			
			_mutationFeedbackTimer.stop();
			_mutationFeedbackTimer = null;
		}
	}
}
