package red.game.witcher3.popups 
{
	import com.gskinner.motion.easing.Elastic;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.MessageButton;
	import red.game.witcher3.constants.SysMessageType;
	import red.game.witcher3.data.SysMessageData;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.menus.overlay.BasePopup;
	import red.game.witcher3.controls.MouseCursor;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	/**
	 * System messages
	 * @author Getsevich Yaroslav
	 */
	public class MessagePopupMenu extends CorePopup
	{
		private static const ANIM_DURATION:Number = 1.5;
		
		public var mcMessageModule : SystemMessageModule;
		public var mcBackground    : Sprite;
		
		private var currentMessage : SysMessageData;
		
		private var _pendedMessageId : int = -1;
		private var _progressTimer   : Timer;
		
		private var _overlayCanvas : MovieClip;
		private var _mouseCursor   : MouseCursor;
		
		public function MessagePopupMenu()
		{
			_enableInputValidation = true;
			
			RuntimeAssetsManager.getInstanse().loadLibrary();
			
			mcBackground.visible = false;
			mcMessageModule.addEventListener(Event.ACTIVATE, handleMessageShown, false, 0, true);
			mcMessageModule.addEventListener(Event.DEACTIVATE, handleMessageHidden, false, 0, true);
			mcMessageModule.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserAction, false, 0, true);
			
			var inputModule:ModuleInputFeedback = mcMessageModule.mcInputFeedback;
			if (inputModule)
			{
				inputModule.filterKeyCodeFunction = isKeyCodeValid;
				inputModule.filterNavCodeFunction = isNavEquivalentValid;
			}
			
			if (!Extensions.isScaleform)
			{
				startDebugMode();
			}
			
			mcMessageModule.visible = false;
		}
		
		override protected function get popupName():String { return "MessagePopup" }
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'message.show', [showMessage]));
			
			playStartupAnim();
			mcMessageModule.tfMessage.focused = 1;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			
			_overlayCanvas = new MovieClip();
			_overlayCanvas.mouseChildren = _overlayCanvas.mouseEnabled = false;
			addChild(_overlayCanvas);
			
			_mouseCursor = new MouseCursor(_overlayCanvas);
		}
		
		public /*Witcher Script*/ function showProgressBar(value:Number, refreshTime:Number, displayText:String):void
		{
			mcMessageModule.setProgress(value, displayText);
			
			if (value == -1)
			{
				if (_progressTimer)
				{
					_progressTimer.stop();
					_progressTimer.removeEventListener(TimerEvent.TIMER, progressUpdate);
					_progressTimer = null;
				}
			}
			else if (!_progressTimer)
			{
				_progressTimer = new Timer(refreshTime, 0);
				_progressTimer.addEventListener(TimerEvent.TIMER, progressUpdate);
				_progressTimer.start();
			}
		}
		
		public /*Witcher Script*/ function hideMessage(messageId:int):void
		{
			trace("GFX hideMessage [" + messageId + "] _pendedMessageId: ", _pendedMessageId);
			
			_pendedMessageId = -1;
			
			if (mcMessageModule.data && mcMessageModule.data.id == messageId)
			{
				mcMessageModule.hide();
				if (_progressTimer)
				{
					_progressTimer.stop();
					_progressTimer.removeEventListener(TimerEvent.TIMER, progressUpdate);
					_progressTimer = null;
				}
			}
		}
		
		protected /*Witcher Script*/ function showMessage(initData:SysMessageData):void
		{
			trace("GFX showMessage [" + initData.messageText + "] _pendedMessageId ", _pendedMessageId, "; isShown ", mcMessageModule.isShown());
			
			if (initData.id == _pendedMessageId) // _pendingMessageId allows us to cancel a show and makes sure the data were receiving matches what ws expects us to receive
			{
				_pendedMessageId = -1;
				setCurrentMessage(initData);
			}
		}
		
		public function /*Witcher Script*/ prepareMessageShowing(messageId:int):void
		{
			trace("GFX prepareMessageShowing [" + messageId + "]");
			
			_pendedMessageId = messageId;
			
			if (_pendedMessageId == -1)
			{
				mcMessageModule.hide();
			}
		}
		
		protected function setCurrentMessage(initData:SysMessageData):void
		{
			mcMessageModule.data = initData;
			mcMessageModule.show();
			_pendedMessageId = -1;
		}
		
		protected function playStartupAnim():void
		{
			mcBackground.visible = true;
			mcBackground.alpha = 0;
			GTweener.to(mcBackground, ANIM_DURATION, { alpha:1 }, { ease:Elastic.easeOut } );
		}
		
		private function handleMessageShown(event:Event):void
		{
			// Loop animation, for test
			///GTweener.to(mcMessageModule, 25, { scaleX:1.2, scaleY:1.2 } );
		}
		
		private function handleMessageHidden(event:Event = null):void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, "OnMessageHidden", [mcMessageModule.data.id] ));
		}
		
		private function handleUserAction(event:InputFeedbackEvent):void
		{
			var inputEvent:InputEvent = event.inputEventRef;
			
			if (mcMessageModule.isHidden())
			{
				return;
			}
			
			// #Y TODO: inputEvent is NULL for InputFeedbackEvent, fix it or remove this check
			// now we are checking input in filterKeyCodeFunction function (see ConfigUI)
			if (inputEvent)
			{
				var details:InputDetails = inputEvent.details;
				if ( _enableInputValidation && (!isNavEquivalentValid(details.navEquivalent) || !isKeyCodeValid(details.code)) )
				{
					// "KEY_UP" received without receiving "KEY_DOWN"
					// probably input from other context, ignore it
					return;
				}
			}
			
			if (mcMessageModule.data.type != SysMessageType.NONE)
			{
				var userActionId:int = event.actionId;
				var isPositive:Boolean = MessageButton.isPositive(userActionId);
				mcMessageModule.hide(!isPositive);
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnUserAction", [event.messageId, event.actionId]));
			}
		}
		
		private function startDebugMode():void
		{
			var buttonsList:Array = [];
			var testData:SysMessageData = new SysMessageData();
			
			testData.id = 0;
			testData.titleText = "TEST MESSAGE";
			testData.messageText = "Some message, <FONT color = '#FF0000'>just</FONT> for test.";
			
			buttonsList.push( { id:MessageButton.MB_OK } );
			buttonsList.push( { id:MessageButton.MB_CANCEL, label:"Custom cancel text" } );
			testData.buttonList = buttonsList;
			
			showMessage(testData);
		}
		
		function progressUpdate( event : TimerEvent ) : void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnProgressUpdateRequested"));
		}
	}
}
