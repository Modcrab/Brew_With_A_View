package red.core.overlay {
	
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.StatusIndicator;
	
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class LoadingScreen extends MovieClip {
		
		private const SKIP_ACTIVE_POS:Number = 1670;
		private const SKIP_INACTIVE_POS:Number = 1740;
		
		public var mcProgressBar:StatusIndicator;
		public var mcImage:MovieClip;
		public var mcBlackscreen:MovieClip;
		public var mcSubtitles:MovieClip;
		public var btnSkipIndicator:InputFeedbackButton;
		
		private var lastFrameTimeInMS:int = 0;
		private var blackscreenAlphaAccel:Number = 0.;
		
		private var tipList:Array;
		private var _tipTimer:Timer;
		
		private var _lastSkipBtnVisibilitySet:Boolean = false;
		
		public function LoadingScreen()
		{
			// !!!DO NOT USE THE INITSTRING TO CHOOSE A LOADING SCREEN IMAGE!!!
			// BE WARNED YOU'LL HAVE YOUR CHANGES REVERTED.
			//
			// USE THE CSV FILES HERE INSTEAD
			// r4data\gameplay\globals\loadingscreen_paths.csv
			// r4data\gameplay\globals\local_loadingscreen_paths.csv
			//
			// WE SHOULDN'T LOAD A TON OF IMAGES JUST TO SHOW ONE OF THEM
			
			initializeTipList();
			
			var initString:String = "";
			if ( Extensions.enabled )
			{
				initString = ExternalInterface.call( "initString" ) as String;
			}
			trace("LoadingScreen initString: " + initString);
			
			InputManager.getInstance().init(this);
			InputManager.getInstance().setControllerType(true);	// #Y fake for now
			
			mcProgressBar.visible = false;
			mcProgressBar.minimum = 0;
			mcProgressBar.maximum = 1;
			mcProgressBar.validateNow();
			mcSubtitles.tfSubtitles.text = "";
			
			if ( ! stage )
			{
				addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			}
			else
			{
				registerLoadingScreen();
			}
		}
		
		private function handleAddedToStage( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false );
			registerLoadingScreen();
		}
		
		protected function registerLoadingScreen():void
		{
			trace("LoadingScreen registerLoadingScreen");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "registerLoadingScreen", this );
			}
		}
		
		public function showProgressBar(value:Boolean):void
		{
			mcProgressBar.visible = value;
		}
		
		/**
		 * @param	value [0..1]
		 */
		public function setProgressValue(value:Number):void
		{
			mcProgressBar.value = value;
		}
		
		public function setPlatform( platformType:uint ):void
		{
			trace("setPlatform: " + platformType);
			
			InputManager.getInstance().setPlatformType( platformType );

			if ( platformType == PlatformType.PLATFORM_PC )
			{
				initializeTipListForPC();
			}
			
			if ( btnSkipIndicator )
			{
				btnSkipIndicator.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.SPACE);
				btnSkipIndicator.label = "[[panel_button_dialogue_skip]]";
				btnSkipIndicator.clickable = false;
				btnSkipIndicator.alpha = 0;
				btnSkipIndicator.visible = false;
			}
		}
		
		public function setExpansionsAvailable( ep1 : Boolean, ep2 : Boolean )
		{
			if ( ep2 )
			{
				initializeTipListForEP2();
			}
		}
		
		public function setVideoSubtitles( text:String ):void
		{
			trace("setVideoSubtitles: " + text);
			mcSubtitles.tfSubtitles.text = text;
		}
		
		// Might want to fade it in, so separate functions
		public function setTipText( text:String ):void
		{
			trace("setTipText: " + text);
			mcSubtitles.tfSubtitles.text = text;
		}
		
		public function setPCInput(value:Boolean):void
		{
			InputManager.getInstance().setControllerType(!value);
		}
		
		public function showVideoSkip():void
		{
			if (!_lastSkipBtnVisibilitySet && btnSkipIndicator)
			{
				_lastSkipBtnVisibilitySet = true;
				
				GTweener.removeTweens(btnSkipIndicator);
				btnSkipIndicator.visible = true;
				GTweener.to(btnSkipIndicator, 1, { alpha:1, x:SKIP_ACTIVE_POS } );
			}
		}
		
		public function hideVideoSkip():void
		{
			if (_lastSkipBtnVisibilitySet && btnSkipIndicator)
			{
				_lastSkipBtnVisibilitySet = false;
				
				GTweener.removeTweens(btnSkipIndicator);
				GTweener.to(btnSkipIndicator, 1, { alpha:0, x:SKIP_INACTIVE_POS } );
			}
		}
		
		public function showImage():void
		{
			trace("showImage");
			mcImage.visible = true;
			setTipsEnabled(true);
		}
		
		public function hideImage():void
		{
			trace("hideImage");
			mcImage.visible = false;
			setTipsEnabled(false);
		}
		
		protected function setTipsEnabled(value:Boolean):void
		{
			if (value)
			{
				if (!_tipTimer)
				{
					_tipTimer = new Timer( 10000 );
					_tipTimer.addEventListener( TimerEvent.TIMER, onTipTimer, false, 0, true );
					showNextTip();
					_tipTimer.start();
				}
			}
			else
			{
				if (_tipTimer)
				{
					_tipTimer = null;
				}
			}
		}
		
		private function onTipTimer( event:TimerEvent ):void
		{
			showNextTip();
			_tipTimer.reset();
			_tipTimer.start();
		}
		
		private function showNextTip():void
		{
			if (tipList.length > 0)
			{
				var targetIndex:int = Math.min(tipList.length - 1, Math.floor(Math.random() * tipList.length));
				
				var targetString:String = tipList[targetIndex];
				
				setTipText("[[" + targetString + "]]");
				
				tipList.splice(targetIndex, 1); // Removing tips as we show them to prevent duplicate tips in same loading sequence
			}
		}
		
		public function fadeIn( fadeInTime : Number ):void
		{
			trace("fadeIn: " + fadeInTime );

			removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
			
			if ( fadeInTime <= 0. )
			{
				mcBlackscreen.visible = false;
			}
			else
			{
				mcBlackscreen.alpha = 1.;
				mcBlackscreen.visible = true;
				blackscreenAlphaAccel = -1. / fadeInTime;
				lastFrameTimeInMS = getTimer();
				
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
			}
		}
		
		public function fadeOut( fadeOutTime : Number ):void
		{
			trace("fadeOut: " + fadeOutTime );
			removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
			if ( fadeOutTime <= 0. )
			{
				mcBlackscreen.visible = true;
				onFadeOutCompleted();
			}
			else
			{
				mcBlackscreen.alpha = 0.;
				mcBlackscreen.visible = true;
				blackscreenAlphaAccel = 1. / fadeOutTime;
				lastFrameTimeInMS = getTimer();
				
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
			}
		}
		
		private function handleEnterFrame(event:Event):void
		{
			var curTime:int = getTimer();
			var timeDelta:Number = (curTime - lastFrameTimeInMS)/1000.;
			mcBlackscreen.alpha += timeDelta * blackscreenAlphaAccel;
			
			// Check the accel so not calling onFadeOutCompleted() when fading in from black
			if ( blackscreenAlphaAccel < 0 && mcBlackscreen.alpha <= 0. )
			{
				removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
				mcBlackscreen.visible = false;
			}
			else if ( blackscreenAlphaAccel > 0 && mcBlackscreen.alpha >= 1. )
			{
				removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
				onFadeOutCompleted();
			}

			lastFrameTimeInMS = curTime;
		}
		
		private function onFadeOutCompleted():void
		{
			trace("LoadingScreen fadeOutCompleted");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "fadeOutCompleted", this );
			}
		}
		
		private function initializeTipList():void
		{
			tipList = new Array();
			tipList.push("loading_screen_hint_1");
			tipList.push("loading_screen_hint_2");
			tipList.push("loading_screen_hint_100");
			tipList.push("loading_screen_hint_4");
			tipList.push("loading_screen_hint_5");
			tipList.push("loading_screen_hint_6");
			tipList.push("loading_screen_hint_7");
			tipList.push("loading_screen_hint_101");
			tipList.push("loading_screen_hint_8");
			tipList.push("loading_screen_hint_9");
			tipList.push("loading_screen_hint_11");
			tipList.push("loading_screen_hint_13");
			tipList.push("loading_screen_hint_14");
			tipList.push("loading_screen_hint_15");
			tipList.push("loading_screen_hint_16");
			tipList.push("loading_screen_hint_17");
			tipList.push("loading_screen_hint_18");
			tipList.push("loading_screen_hint_19");
			tipList.push("loading_screen_hint_20");
			tipList.push("loading_screen_hint_21");
			tipList.push("loading_screen_hint_24");
			tipList.push("loading_screen_hint_25");
			tipList.push("loading_screen_hint_26");
			tipList.push("loading_screen_hint_27");
			tipList.push("loading_screen_hint_28");
			tipList.push("loading_screen_hint_29");
			tipList.push("loading_screen_hint_30");
			tipList.push("loading_screen_hint_31");
			tipList.push("loading_screen_hint_32");
			tipList.push("loading_screen_hint_33");
			tipList.push("loading_screen_hint_103");
			tipList.push("loading_screen_hint_34");
			tipList.push("loading_screen_hint_35");
			tipList.push("loading_screen_hint_36");
			tipList.push("loading_screen_hint_38");
			tipList.push("loading_screen_hint_39");
			tipList.push("loading_screen_hint_40");
			tipList.push("loading_screen_hint_42");
			tipList.push("loading_screen_hint_43");
			tipList.push("loading_screen_hint_44");
			tipList.push("loading_screen_hint_102");
			tipList.push("loading_screen_hint_45");
			tipList.push("loading_screen_hint_46");
			tipList.push("loading_screen_hint_47");
			tipList.push("loading_screen_hint_48");
			tipList.push("loading_screen_hint_49");
			tipList.push("loading_screen_hint_51");
			tipList.push("loading_screen_hint_52");
			tipList.push("loading_screen_hint_53");
			tipList.push("loading_screen_hint_54");
			tipList.push("loading_screen_hint_55");
			tipList.push("loading_screen_hint_56");
			tipList.push("loading_screen_hint_57");
			tipList.push("loading_screen_hint_58");
			tipList.push("loading_screen_hint_59");
			tipList.push("loading_screen_hint_60");
			tipList.push("loading_screen_hint_62");
			tipList.push("loading_screen_hint_63");
			tipList.push("loading_screen_hint_105");
			tipList.push("loading_screen_hint_106");
			tipList.push("loading_screen_hint_107");
			tipList.push("loading_screen_hint_108");
			tipList.push("loading_screen_hint_109");
			tipList.push("loading_screen_hint_110");
			tipList.push("loading_screen_hint_111");
			tipList.push("loading_screen_hint_112");
			tipList.push("loading_screen_hint_113");
			tipList.push("loading_screen_hint_114");
			tipList.push("loading_screen_hint_115");
			tipList.push("loading_screen_hint_117");
			tipList.push("loading_screen_hint_118");
			tipList.push("loading_screen_hint_119");
			tipList.push("loading_screen_hint_120");
			tipList.push("loading_screen_hint_121");
			tipList.push("loading_screen_hint_122");
			tipList.push("loading_screen_hint_123");
			tipList.push("loading_screen_hint_124");
			tipList.push("loading_screen_hint_125");
			tipList.push("loading_screen_hint_65");
			tipList.push("loading_screen_hint_66");
			tipList.push("loading_screen_hint_67");
			tipList.push("loading_screen_hint_68");
			tipList.push("loading_screen_hint_69");
			tipList.push("loading_screen_hint_70");
			tipList.push("loading_screen_hint_71");
			tipList.push("loading_screen_hint_72");
			tipList.push("loading_screen_hint_73");
			tipList.push("loading_screen_hint_74");
			tipList.push("loading_screen_hint_75");
			tipList.push("loading_screen_hint_76");
			tipList.push("loading_screen_hint_77");
			tipList.push("loading_screen_hint_78");
			tipList.push("loading_screen_hint_79");
			tipList.push("loading_screen_hint_80");
			tipList.push("loading_screen_hint_81");
			tipList.push("loading_screen_hint_82");
			tipList.push("loading_screen_hint_83");
			tipList.push("loading_screen_hint_84");
			tipList.push("loading_screen_hint_85");
			tipList.push("loading_screen_hint_86");
			tipList.push("loading_screen_hint_87");
			tipList.push("loading_screen_hint_88");
			tipList.push("loading_screen_hint_89");
			tipList.push("loading_screen_hint_90");
			tipList.push("loading_screen_hint_91");
			tipList.push("loading_screen_hint_92");
			tipList.push("loading_screen_hint_93");
			tipList.push("loading_screen_hint_94");
			tipList.push("loading_screen_hint_95");
			tipList.push("loading_screen_hint_00003");
			tipList.push("loading_screen_hint_00004");
			
			tipList.push("loading_screen_hint_130");
			tipList.push("loading_screen_hint_131");
			//tipList.push("loading_screen_hint_132"); // #Y; Cooment from Tomasz Kozera: cert 1 we need to disable those loading hints from appearing - they won't be translated in time
			//tipList.push("loading_screen_hint_133"); //
			tipList.push("loading_screen_hint_134");
			tipList.push("loading_screen_hint_135");
			tipList.push("loading_screen_hint_136");
			tipList.push("loading_screen_hint_137");
			tipList.push("loading_screen_hint_138");
		}
		
		private function initializeTipListForPC():void
		{
			if ( tipList )
			{
				tipList.push("loading_screen_hint_00001");
			}
		}

		private function initializeTipListForEP2():void
		{
			if ( tipList )
			{
				tipList.push("loading_screen_hint_ep2_001");
				tipList.push("loading_screen_hint_ep2_002");
				tipList.push("loading_screen_hint_ep2_003");
				tipList.push("loading_screen_hint_ep2_004");
				tipList.push("loading_screen_hint_ep2_005");
				//tipList.push("loading_screen_hint_ep2_006"); // #Y; Cooment from Tomasz Kozera: cert 1 we need to disable those loading hints from appearing - they won't be translated in time
				tipList.push("loading_screen_hint_ep2_007");
				tipList.push("loading_screen_hint_ep2_008");
			}
		}

	}
}
