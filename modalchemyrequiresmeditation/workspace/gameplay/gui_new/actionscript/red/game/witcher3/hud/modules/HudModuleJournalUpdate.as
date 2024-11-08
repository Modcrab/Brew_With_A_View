package red.game.witcher3.hud.modules
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.hud.modules.journalupdate.QuestBookInfo;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Label;
	import red.game.witcher3.utils.motion.TweenEx;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import flash.display.MovieClip;
	import scaleform.clik.events.InputEvent;

	public class HudModuleJournalUpdate extends HudModuleBase
	{
		private const BOOK_INFO_ANIM_OFFSET:Number = 10;
		
		public var mcText : Label;
		public var mcTitle : Label;
		public var mcIconLoader : W3UILoader;
		public var mcInputFeedback:ModuleInputFeedback;
		public var displayTime:Number = 3000;
		public var lvlupanim:MovieClip;
		
		private var showTimer : Timer;
		
		private var _showInfoPanelTimer:Timer;
		private var _bookInfo:QuestBookInfo;
		private var _bookInfoData:Object;
		
		
		override public function get moduleName():String
		{
			return "JournalUpdateModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			alpha = 0;
			visible = false;
			
			mcIconLoader.visible = false;
			lvlupanim.visible = false;
			mcTitle.htmlText = "";
			mcText.htmlText = "";
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'hud.journalupdate.buttons.setup', [handleSetupButtons]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'hud.journalupdate.bookinfo', [showItemInfo]));
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		public function updateItemInfo():void
		{
			if (_bookInfo)
			{
				// TODO: UPDATE
			}
		}
		
		public function hideItemInfo():void
		{
			if (_bookInfo)
			{
				ClearJournalUpdate();
				
				GTweener.removeTweens(_bookInfo);
				removeChild(_bookInfo);
				_bookInfo = null;
				
				if (_showInfoPanelTimer)
				{
					_showInfoPanelTimer.stop();
					_showInfoPanelTimer.removeEventListener(TimerEvent.TIMER, handleBookInfoTimer, false);
				}
			}
		}
		
		private function showItemInfo(value:Object):void
		{
			trace("GFX *showBookInfo* ", _bookInfo, value);
			
			mcTitle.htmlText = "";
			mcText.htmlText = "";
			SetIcon("");
			mcInputFeedback.cleanupButtons();
			
			if (_bookInfo)
			{
				GTweener.removeTweens(_bookInfo);
				removeChild(_bookInfo);
				_bookInfo = null;
			}
			
			_bookInfoData = value;
			if (_bookInfoData)
			{
				var bookInfoClass:Class = getDefinitionByName("BookInfoPopupRef") as Class;
				
				trace("GFX  * ", value.showTime, value.itemName);
				
				SetShowTimer(value.showTime, true);
				
				_bookInfo = new bookInfoClass() as QuestBookInfo;
				_bookInfo.alpha = 0;
				
				var srect:Rectangle = CommonUtils.getScreenRect();
				var localPoint:Point = globalToLocal(new Point( srect.width / 2, srect.height ));
				
				_bookInfo.data = value;
				
				//Center bottom position
				//_bookInfo.x = localPoint.x - _bookInfo.actualWidth/2;
				//_bookInfo.y = localPoint.y - _bookInfo.actualHeight - 90;
				
				_bookInfo.y = 150;
				addChild(_bookInfo);
				
				GTweener.removeTweens(_bookInfo);
				GTweener.to(_bookInfo, 1, { alpha:1 }, { ease:Sine.easeOut } );
				
				if (_showInfoPanelTimer)
				{
					_showInfoPanelTimer.stop();
					_showInfoPanelTimer.removeEventListener(TimerEvent.TIMER, handleBookInfoTimer, false);
				}
				
				_showInfoPanelTimer = new Timer(value.showTime);
				_showInfoPanelTimer.addEventListener(TimerEvent.TIMER, handleBookInfoTimer, false, 0, true);
				_showInfoPanelTimer.start();
			}
		}
		
		private function handleBookInfoTimer(event:Event = null):void
		{
			if (_showInfoPanelTimer)
			{
				_showInfoPanelTimer.stop();
				_showInfoPanelTimer.removeEventListener(TimerEvent.TIMER, handleBookInfoTimer, false);
			}
			
			if (_bookInfo)
			{
				GTweener.removeTweens(_bookInfo);
				GTweener.to(_bookInfo, 1, { alpha:0  },{ ease:Sine.easeOut, onComplete:handelBookInfoHidden } );
			}
		}
		
		private function handelBookInfoHidden():void
		{
			if (_bookInfo)
			{
				GTweener.removeTweens(_bookInfo);
				removeChild(_bookInfo);
			}
		}
		
		public function ShowJournalUpdate( value : String, title : String, time : Number  ) : void
		{
			if ( isEnabled )
			{
				mcTitle.htmlText = CommonUtils.toUpperCaseSafe(title);
				mcText.htmlText = CommonUtils.toUpperCaseSafe(value);
				SetShowTimer(time);
				mcText.validateNow();
				mcInputFeedback.y = mcText.y + mcText.textField.textHeight + mcInputFeedback.height / 2;
			}
		}
		
		public function SetIcon( value : String  ) : void
		{
			if ( value == "")
			{
				mcIconLoader.visible = false;
			}
			else
			{
				mcIconLoader.visible = true;
				mcIconLoader.source = "img://" + value;
			}
		}

		public function SetJournalUpdateStatus( value : int ) : void
		{
			if(lvlupanim){lvlupanim.visible = false;}
			if ( value == 0 )
			{
				return;
			}
			if( value == 6)
			{
				if(lvlupanim){lvlupanim.visible = true; lvlupanim.gotoAndPlay(1);}
			}
			if ( value == 7)
			{
				if(lvlupanim){lvlupanim.visible = false;}
			}
			
			gotoAndStop(value);
		}
		
		public function PauseShowTimer( value : Boolean ):void
		{
			if (_showInfoPanelTimer)
			{
				if (_showInfoPanelTimer)
				{
					_showInfoPanelTimer.stop();
				}
				else
				{
					_showInfoPanelTimer.start();
				}
			}
			
			if (showTimer)
			{
				if (value)
				{
					showTimer.stop();
				}
				else
				{
					showTimer.start();
				}
			}
		}

		public function SetShowTimer( time : Number, noCallback:Boolean = false ) : void
		{
			if ( time == 0 )
			{
				if ( showTimer )
				{
					showTimer.stop();
				}
				return;
			}
			if ( !showTimer )
			{
				displayTime = time;
				showTimer = new Timer(time, 1);
				
				if (noCallback) 
				{
					showTimer.addEventListener(TimerEvent.TIMER, ShowTimerFinishedCountingNoCallback, false, 0, true);
				}
				else
				{
					showTimer.addEventListener(TimerEvent.TIMER, ShowTimerFinishedCounting, false, 0, true);
				}
				
			}
			else if ( time != displayTime )
			{
				displayTime = time;
				showTimer.stop();
				showTimer.removeEventListener(TimerEvent.TIMER, ShowTimerFinishedCounting);
				showTimer.removeEventListener(TimerEvent.TIMER, ShowTimerFinishedCountingNoCallback);
				showTimer = null;
				
				showTimer = new Timer(time, 1);				
				
				if (noCallback) 
				{
					showTimer.addEventListener(TimerEvent.TIMER, ShowTimerFinishedCountingNoCallback, false, 0, true);
				}
				else
				{
					showTimer.addEventListener(TimerEvent.TIMER, ShowTimerFinishedCounting, false, 0, true);
				}
			}
			else
			{
				showTimer.reset();
			}
			showTimer.start();
		}

		public function ResetShowTimer() : void
		{
			if ( showTimer )
			{
				showTimer.reset();
				showTimer.start();
			}
		}

		public function RemoveShowTimer() : void
		{
			if ( showTimer )
			{
				showTimer.stop();
				showTimer.removeEventListener(TimerEvent.TIMER, ShowTimerFinishedCounting);
				showTimer.removeEventListener(TimerEvent.TIMER, ShowTimerFinishedCountingNoCallback);
				showTimer = null;
			}
		}

		function ShowTimerFinishedCounting( event : TimerEvent ) : void 
		{
			trace("GFX * ShowTimerFinishedCounting ");
			
			RemoveShowTimer();
			ShowElementFromState(false, false);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRemoveUpdate' ) );
		}
		
		function ShowTimerFinishedCountingNoCallback( event : TimerEvent ) : void 
		{
			trace("GFX * ShowTimerFinishedCountingNoCallback ");
			
			RemoveShowTimer();
			ShowElementFromState(false, false);
		}

		public function ClearJournalUpdate()
		{
			RemoveShowTimer();
			ShowElementFromState(false, false);
			mcTitle.htmlText = "";
			mcText.htmlText = "";
			SetIcon("");
			mcInputFeedback.cleanupButtons();
		}

		override public function SetState( value : String )
		{
			trace("GFX * SetState ", value);
			
			super.SetState( value );
			if ( !isEnabled || value == "Hide" )
			{
				ClearJournalUpdate();
				if ( alpha != 0 && _ShowState )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowUpdateEnd' ) );
				}
				_ShowState = false;
			}
		}

		override protected function handleModuleHidden(tweenInstant:GTween):void
		{
			super.handleModuleHidden(tweenInstant);
			
			if( alpha == 0 && _ShowState)
			{
				_ShowState = false;
				RemoveShowTimer();
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowUpdateEnd' ) );
			}
		}

		protected function handleSetupButtons( gameData:Object, index:int ) : void
		{
			mcInputFeedback.handleSetupButtons(gameData);
		}

		// #Y Remove scaling; requested by Dan, TT#73355
		override public function SetScaleFromWS( scale : Number ) : void { }
		
		override public function onCutsceneStartedOrEnded( started : Boolean )
		{
			trace( "Minimap2 HudModuleJournalUpdate::onCutsceneStartedOrEnded " + started );
			
			if ( started )
			{
				if ( !isInCutscene )
				{
					isInCutscene = true;
					x += 440;
				}
			}
			else
			{
				if ( isInCutscene )
				{
					isInCutscene = false;
					x -= 440;
				}
			}
		}
		
	}

}
