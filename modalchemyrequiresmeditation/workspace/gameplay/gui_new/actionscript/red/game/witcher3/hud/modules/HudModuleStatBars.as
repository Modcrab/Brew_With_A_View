package red.game.witcher3.hud.modules
{
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

	import red.game.witcher3.hud.modules.statbars.HudStatBarStamina;
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class HudModuleStatBars extends HudModuleBase
	{
		public var mcHealthBar:MovieClip;
		public var mcStaminaBar:HudStatBarStamina;		
		public var mcToxicityBar:MovieClip;
		public var mcExperienceBar:MovieClip;
		public var mcBlood:MovieClip;
		public var mcLevelUpIndicator:MovieClip;
		public var mcBarGlow : MovieClip;
		public var mcMovingIndicator : MovieClip;
		public var mcGlowMask : MovieClip;

		private var _healthBarMask:MovieClip;
		private var _toxicityBarMask:MovieClip;
		private var _staminaBarMask:MovieClip;
		private var _experienceBarMask:MovieClip;

		private static const BAR_LERP_SPEED:Number = 1000;
		private static const FADE_IN_DURATION:Number = 1000;	

		private var glowTimer : Timer;

		public function HudModuleStatBars() 
		{
			super();
			trace( "Minimap HudModuleStatBars::HudModuleStatBars" );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "StatBarsModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();	
			
			x = 200;
			y = 100;
			z = 100;
			scaleX = 1;
			scaleY = 1;
			visible = true;

			mcStaminaBar.percentNeeded = 0.0;

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			trace( "Minimap HudModuleStatBars::configUI" );
		}
		
		public function setVitality( value:Number, maxValue:Number ):void
		{
			var percent : Number = maxValue > 0.0 ? value / maxValue : 0.0;
			mcHealthBar.percent = percent;
			mcHealthBar.validateNow(); // snappy response time
			
			//#B
			mcBlood.percent = percent;
			mcBlood.validateNow();
		}
		
		public function setStamina( value:Number, maxValue:Number ):void
		{
			mcStaminaBar.percent = maxValue > 0.0 ? value / maxValue : 0.0;
			mcStaminaBar.validateNow(); // snappy response time
		}
		
		public function setToxicity( value:Number, maxValue:Number ):void
		{
			mcToxicityBar.percent = maxValue > 0.0 ? value / maxValue : 0.0;
			mcToxicityBar.validateNow(); // snappy response time
		}	
		
		//#B
		public function setExperience( value:Number, maxValue:Number ):void
		{
			mcExperienceBar.percent = maxValue > 0.0 ? value / maxValue : 0.0;
			mcExperienceBar.validateNow(); // snappy response time
		}
		
		public function setLevelUpVisible(value:Boolean):void
		{
			if (value)
			{
				mcLevelUpIndicator.gotoAndPlay('newLevel');
			}
			else
			{
				mcLevelUpIndicator.gotoAndStop('stop');
			}
		}
		
		public function reset():void
		{
			mcHealthBar.reset();
			mcStaminaBar.reset();
			mcToxicityBar.reset();
			mcExperienceBar.reset(); //#B
			
			// Snappy response time
			mcHealthBar.validateNow();
			mcStaminaBar.validateNow();
			mcToxicityBar.validateNow();
			mcExperienceBar.validateNow(); //#B
		}
		
		//#B
		public function StartHeavyAttackIndicatorAnimation( time : Number ) : void
		{
			StopHeavyAttackIndicatorAnimation();
			//trace("Bidon StartHeavyAttackIndicatorAnimation "+time);
			TweenEx.to( time, mcMovingIndicator, { x:335 }, { paused:false, ease:None.easeNone, onComplete: handleHeavyAttackIndicatorAnimationFinished } );
		}
		
		private function handleHeavyAttackIndicatorAnimationFinished()
		{
			StopHeavyAttackIndicatorAnimation();
			//trace("Bidon " + "handleHeavyAttackIndicatorAnimationFinished");
			//GameInterface.callEvent('OnHeavyAttackAnimationFinished');
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHeavyAttackAnimationFinished' ) );
			
		}
		
		public function StopHeavyAttackIndicatorAnimation( ) : void
		{
			TweenEx.pauseTweenOn(mcMovingIndicator);
			mcMovingIndicator.x = 40;
		}
		
		public function ShowStatbarsGlow( time : Number ) : void
		{
			TweenEx.pauseTweenOn(mcBarGlow);
			mcBarGlow.alpha = 0;
			TweenEx.to( 200, mcBarGlow, { alpha:1 }, { paused:false, ease:Strong.easeInOut } );
			// set timer (time)
			if (glowTimer)
			{
				glowTimer.stop();
			}
			glowTimer = new Timer(time, 1);
			glowTimer.addEventListener(TimerEvent.TIMER, glowTimerFinishedCounting);
			glowTimer.start();
		}	
		
		function glowTimerFinishedCounting(event:TimerEvent):void 
		{
			HideStatbarsGlow();
			//GameInterface.callEvent('OnHeavyAttackGlowFinished');
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHeavyAttackGlowFinished' ) );
		}
		
		public function HideStatbarsGlow() : void
		{
			TweenEx.pauseTweenOn(mcBarGlow);
			TweenEx.to( 200, mcBarGlow, { alpha:0 }, { paused:false, ease:Strong.easeInOut } );
		}	
		
		public function ShowStaminaIndicator( value : Number, maxValue : Number ) : void
		{
			mcStaminaBar.percentNeeded =  maxValue > 0.0 ? value / maxValue : 0.0;
		}
		
	//{region Overrides
	// ------------------------------------------------
	
		override protected function draw():void
		{			
			super.draw();
		}

	}
	
}
