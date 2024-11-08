package red.game.witcher3.popups 
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.MessageButton;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.data.SysMessageData;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.controls.ScrollBar;
	
	/**
	 * System (TRC) message
	 * @author Getsevich Yaroslav
	 */
	public class SystemMessageModule extends UIComponent 
	{
		private static const DEF_SCALE_MIN:Number = .3;
		private static const DEF_SCALE_MAX:Number = 1.3;
		private static const DEF_ANIM_DURATION:Number = .6
		private static const DEF_BACKGROUND_WIDTH:Number = 155;
		private static const BUTTOND_PADDING:Number = 15;
		private static const HEIGHT_PADDING: Number = 10;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
		
		
		public var tfTitle:TextField;
		public var tfMessage:W3TextArea;
		public var messageScrollbar:ScrollBar;
		public var mcInputFeedback:ModuleInputFeedback;
		public var mcBackground:MovieClip;
		public var mcInputBackground: MovieClip;
		
		public var mcProgressBar:StatusIndicator;
		public var tfProgress:TextField;
		protected var _progress:Number;
		
		protected var _isShown:Boolean = false;
		protected var _isHidden:Boolean = true;
		
		public function SystemMessageModule()
		{
			cleanup();
			mcInputFeedback.buttonAlign = "center";
			mcInputFeedback.directWsCall = false;
			mcInputFeedback.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserAction, false, 0, true);
			
			mcProgressBar.value = 0;
			mcProgressBar.minimum = 0;
			mcProgressBar.maximum = 1;
			mcProgressBar.visible = false;
			tfProgress.visible = false;
		}
		
		public function isShown():Boolean
		{
			return _isShown;
		}
		
		public function isHidden():Boolean
		{
			return _isHidden;	
		}
		
		protected var _data:SysMessageData;
		public function get data():SysMessageData { return _data }
		public function set data(value:SysMessageData):void
		{
			_data = value;
			cleanup();
			if (_data)
			{
				populateData();
				populateButtons(_data.buttonList);
			}
		}
		
		// value = [0..100]
		public function get progress():Number { return _progress }
		public function setProgress(value:Number, displayText:String):void
		{
			_progress = value;
			if (_progress < 0)
			{
				mcProgressBar.visible = false;
				tfProgress.visible = false;
			}
			else
			{
				if (!mcProgressBar.visible)
				{
					mcProgressBar.visible = true;
					tfProgress.visible = true;
				}
				mcProgressBar.value = value / 100;
				if (displayText == "_SHOW_PERC_")
				{
					tfProgress.text = String(Math.round(value)) + "%";
				}
				else
				{
					tfProgress.text = displayText;
				}
			}
		}
		
		public function show(backwardAnim:Boolean = false):void
		{
			_isHidden = false;
			_isShown = true;
			visible = true;
			alpha = 0
			scaleX = scaleY = (backwardAnim ? DEF_SCALE_MAX : DEF_SCALE_MIN);
			GTweener.removeTweens(this);
			GTweener.to(this, DEF_ANIM_DURATION, { alpha:1, scaleX:1, scaleY:1 }, { ease:Exponential.easeOut, onComplete:handleShown } )
		}
		
		public function hide(backwardAnim:Boolean = false):void
		{
			_isHidden = true;
			visible = true;
			var targetScale = backwardAnim ? DEF_SCALE_MIN : DEF_SCALE_MAX;
			GTweener.removeTweens(this);
			GTweener.to(this, DEF_ANIM_DURATION, { alpha:0, scaleX:targetScale, scaleY:targetScale }, { ease:Exponential.easeOut, onComplete:handleHidden } )
		}
		var curHeight:Number;
		protected function populateData():void
		{
			
			
			
			tfTitle.htmlText = _data.titleText;
			tfMessage.htmlText = _data.messageText;
			tfMessage.validateNow();
			if (tfTitle.text == "")
			{
				tfMessage.y = 22.15;
				messageScrollbar.y = 22.15;
			}
			curHeight = tfMessage.y + tfMessage.textField.textHeight + HEIGHT_PADDING;
			tfMessage.focused = 1;
			//tfMessage.height = tfMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			if ( mcProgressBar && mcProgressBar.visible )
			{
				mcProgressBar.y = curHeight;
				curHeight = curHeight + HEIGHT_PADDING;
			}
			if (tfProgress && tfProgress.visible )
			{
				tfProgress.y = curHeight;
				curHeight = curHeight + HEIGHT_PADDING;
			}
			mcBackground.height =  curHeight + FINAL_HEIGHT_PADDING;
			mcInputBackground.y  = mcBackground.height - mcInputBackground.height / 2;
			mcInputFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;
			
			//mcBackground.height = DEF_BACKGROUND_WIDTH + tfMessage.height;
			//mcProgressBar.y = tfMessage.y + tfMessage.height;
			//tfProgress.y = mcProgressBar.y + mcProgressBar.height;
			//mcInputFeedback.y = mcBackground.y + mcBackground.height - mcInputFeedback.height / 2 - BUTTOND_PADDING;
		}
		
		protected function populateButtons(buttonsList:Array):void
		{
			if (buttonsList)
			{
				var bindingsList:Array = [];
				var len:int = buttonsList.length;
				for (var i:int = 0; i < len; i++)
				{
					var curData:Object = buttonsList[i];
					var curActionId:int = curData.id;
					var newBinding:KeyBindingData = new KeyBindingData();
					newBinding.actionId = curActionId;
					if (curData.label)
					{
						newBinding.label = curData.label;
					}
					else
					{
						newBinding.label = MessageButton.getLocalizedLabel(curActionId);
					}
					newBinding.keyboard_keyCode = MessageButton.getPcKeyCode(curActionId);
					newBinding.gamepad_navEquivalent = MessageButton.getGamepadNavCode(curActionId);
					bindingsList.push(newBinding);
				}
				mcInputFeedback.handleSetupButtons(bindingsList);
				
				if (len == 0)
				{
					mcInputBackground.visible = false;
				}
			}
			else
			{
				trace("GFX <ERROR>[SystemMessageModule] invalid buttonsList");
			}
		}
		
		protected function cleanup():void
		{
			tfTitle.text = "";
			tfMessage.text = "";
			mcInputFeedback.cleanupButtons();
		}
		
		protected function handleShown(tweenInstance:GTween):void
		{
			dispatchEvent(new Event(Event.ACTIVATE));
		}
		
		protected function handleHidden(tweenInstance:GTween):void
		{
			_isShown = false;
			visible = false;
			dispatchEvent(new Event(Event.DEACTIVATE));
		}
		
		protected function handleUserAction(event:InputFeedbackEvent):void
		{			
			if (_data)
			{
				event.messageId = _data.id	
			}
		}
		
	}
}
