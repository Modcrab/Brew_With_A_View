package red.game.witcher3.controls
{    
	import flash.display.MovieClip;
	import flash.events.Event;
	import scaleform.clik.core.UIComponent;
	
	public class W3MessageQueue extends UIComponent
	{
		public var mcBackground:MovieClip;
		public var mcImages:MovieClip;
		public var txtMessage:W3TextArea;
		public var _showingMessage:Boolean = false;
		
		private var messageQueue:Array;
		
		private var currentOnShowEndFunc:Function = null;

		function W3MessageQueue()
		{
			messageQueue = new Array();
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		private var _msgsEnabled:Boolean = true;
		public function get msgsEnabled() : Boolean { return _msgsEnabled; }
		public function set msgsEnabled(value:Boolean):void
		{
			if (_msgsEnabled != value)
			{
				_msgsEnabled = value;
				
				if (_msgsEnabled)
				{
					tryShowMessage();
				}
			}
		}

		public function PushMessage(message:String, imageName:String = "", onShowFunc:Function = null, onShowEndFunc:Function = null):void
		{
			var showingMessage:Boolean = ShowingMessage();
		 
			var messageObject:Object = new Object();
			messageObject.message = message;
			if (imageName == "")
			{
				messageObject.imageName = "none";
			}
			else
			{
				messageObject.imageName = imageName;
			}
			messageObject.onShowFunc = onShowFunc;
			messageObject.onShowEndFunc = onShowEndFunc;
			messageQueue.push(messageObject);
		 
			if (!showingMessage)
			{
				tryShowMessage();
			}
		}

		public function ShowingMessage():Boolean
		{
			return _showingMessage || messageQueue.length > 0;
		}
		
		// Called from last frame of movieclip
		public function OnShowMessageEnded():void
		{
			_showingMessage = false;
			
			if (currentOnShowEndFunc != null)
			{
				currentOnShowEndFunc();
				currentOnShowEndFunc = null;
			}
			
			tryShowMessage();
		}
		
		protected function tryShowMessage():void
		{
			if (!msgsEnabled)
			{
				return;
			}
			
			if (messageQueue.length > 0 && !_showingMessage)
			{	
				var currentMessage:Object = messageQueue[0];
				txtMessage.text = currentMessage.message;
				
				if (mcImages)
				{
					mcImages.gotoAndStop(currentMessage.imageName);
				}
				
				txtMessage.validateNow();
				
				if (currentMessage.onShowFunc)
				{
					currentMessage.onShowFunc();
				}
				
				/*var subBackgroundChild:MovieClip = mcBackground.getChildByName("mcMegaChild") as MovieClip;
				if (subBackgroundChild)
				{
					if (txtMessage.textField.textHeight > 90)
					{
						subBackgroundChild.height = 180;
					}
					else
					{
						subBackgroundChild.height = 90;
					}
				}*/
				
				currentOnShowEndFunc = currentMessage.onShowEndFunc;
				
				gotoAndPlay("Show");
				messageQueue.splice(0, 1);
				_showingMessage = true;
			}
		}
		
		public function trySkipMessage():Boolean
		{
			if (_showingMessage && currentLabel == "Showing")
			{
				gotoAndPlay("Hiding");
				return true;
			}
			
			return false;
		}
	}
}
