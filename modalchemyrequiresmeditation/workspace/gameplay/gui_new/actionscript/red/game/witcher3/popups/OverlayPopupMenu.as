package red.game.witcher3.popups
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.MouseCursorComponent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.Extensions;
	import scaleform.clik.controls.UILoader;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import red.game.witcher3.menus.overlay.BookItemRenderer;
	
	/**
	 * Notifications, cursor, load/save indicator, etc
	 * @author Getsevich Yaroslav
	 */
	public class OverlayPopupMenu extends CorePopup
	{
		public var notificationModule:NotificationModule;
		public var mouseCursor:MouseCursorComponent;
		public var mcIndicatorLoad:MovieClip;
		public var mcIndicatorSave:MovieClip;
		public var mcInpuFeedback:ModuleInputFeedback;
		
		protected var _mouseShown:Boolean;
		protected var _enableInputMgr:Boolean;
		protected var _notificationQueue:Vector.<Object>;
		protected var _safeRectCanvas:Sprite;
		
		public function OverlayPopupMenu()
		{
			_enableHoldEmulation = false;
			_enableInputDeviceCheck = false;
			InputDelegate.getInstance().disableInputEvents(true);
			
			_notificationQueue = new Vector.<Object>;
			notificationModule.addEventListener(Event.DEACTIVATE, handleNotificationHidden, false, 0, true);
			mouseCursor = new MouseCursorComponent(this);
			mouseCursor.visible = false;
			
			mcInpuFeedback.clickable = false;
		}
		
		override protected function get popupName():String { return "OverlayPopup" }
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			if (!Extensions.isScaleform)
			{
				startDebugMode();
			}
		}
		
		public function /*Witcher Script*/ showSafeRect(value:Boolean):void
		{
			if (_safeRectCanvas)
			{
				removeChild(_safeRectCanvas);
				_safeRectCanvas = null;
			}
			if (value)
			{
				_safeRectCanvas = new Sprite();
				addChild(_safeRectCanvas);
				
				var safeRect:Rectangle = CommonUtils.getScreenRect();
				var safeOffsetX:Number = safeRect.width * .05;
				var safeOffsetY:Number = safeRect.height * .05;
				var grCanvas:Graphics = _safeRectCanvas.graphics;
				
				grCanvas.lineStyle(1, 0xFF0000);
				grCanvas.moveTo(safeRect.x + safeOffsetX, _safeRectCanvas.y + safeOffsetY);
				grCanvas.lineTo(safeRect.x + safeRect.width - safeOffsetX, safeRect.y + safeOffsetY);
				grCanvas.lineTo(safeRect.x + safeRect.width - safeOffsetX, safeRect.y + safeRect.height - safeOffsetY);
				grCanvas.lineTo(safeRect.x + safeOffsetX, safeRect.y + safeRect.height - safeOffsetY);
				grCanvas.lineTo(safeRect.x + safeOffsetX, safeRect.y + safeOffsetY);
				
				grCanvas.lineStyle(.5, 0xFF0000, .6);
				grCanvas.moveTo(safeRect.x + safeOffsetX, safeRect.height / 2);
				grCanvas.lineTo(safeRect.x + safeRect.width - safeOffsetX, safeRect.height / 2);
				grCanvas.moveTo(safeRect.width / 2, safeRect.y + safeOffsetY);
				grCanvas.lineTo(safeRect.width / 2, safeRect.y + safeRect.height - safeOffsetY);
			}
		}
		
		public function /*Witcher Script*/ updateInputFeedback():void
		{
			mcInpuFeedback.refreshButtonList();
			updateMouseEventListeners();
		}
		
		public function /*Witcher Script*/ appendBinding(actionId:int, gpadCode:String, kbCode:int, label:String, contextId:int = -1):void
		{
			mcInpuFeedback.appendButton(actionId, gpadCode, kbCode, label, true, contextId);
		}
		
		public function /*Witcher Script*/ removeBinding(actionId:int, contextId:int = -1):void
		{
			mcInpuFeedback.removeButton(actionId, true, contextId);
		}
		
		public function /*Witcher Script*/ removeAllContextBinding(contextId:int):void
		{
			mcInpuFeedback.removeAllContextButtons(contextId);
		}
		
		public function /*Witcher Script*/ showMouseCursor(value:Boolean):void
		{
			_mouseShown = value;
			mouseCursor.visible = _mouseShown;
			updateMouseEventListeners();
		}
		
		public function /*Witcher Script*/ showNotification(msgText:String, msgDuration:Number = 0, queued:Boolean = false):void
		{
			if (notificationModule.isShown())
			{
				if (queued)
				{
					_notificationQueue.push( { messageText : msgText, duration : msgDuration } );
				}
				else
				{
					_notificationQueue.length = 0;
					_notificationQueue.push( { messageText : msgText, duration : msgDuration } );
					notificationModule.hide()
				}
			}
			else
			{
				notificationModule.show(msgText, msgDuration);
			}
		}
		
		public function /*Witcher Script*/ hideNotification():void
		{
			if (notificationModule.isShown())
			{
				notificationModule.hide();
			}
		}
		
		public function /*Witcher Script*/ clearNotificationsQueue():void
		{
			if (notificationModule.isShown())
			{
				notificationModule.hide();
			}
			
			_notificationQueue.length = 0;
		}
		
		public function /*Witcher Script*/ showLoadIdicator():void
		{
			mcIndicatorLoad.gotoAndPlay("activate");
		}
		
		public function /*Witcher Script*/ hideLoadIdicator(immediateHide:Boolean = false):void
		{
			mcIndicatorLoad.gotoAndPlay(immediateHide ? "inactive" : "finish");
		}
		
		public function /*Witcher Script*/ showSaveIdicator():void
		{
			mcIndicatorSave.gotoAndPlay("activate");
		}
		
		public function /*Witcher Script*/ hideSaveIdicator(immediateHide:Boolean = false):void
		{
			mcIndicatorSave.gotoAndPlay(immediateHide ? "inactive" : "finish");
		}
		
		public function /*Witcher Script*/ setMouseCursorType(type:int):void
		{
			if (mouseCursor)
			{
				mouseCursor.cursorType = type;
			}
		}
		
		private var _logoLoader : UILoader;
		public function /*Witcher Script*/ showEP2Logo( show : Boolean, fadeInterval : Number, posX : int, posY : int, filename : String = null )
		{
			if ( show )
			{
				if ( addEP2Logo( filename, fadeInterval, posX, posY ) )
				{
					if ( fadeInterval > 0 )
					{
						GTweener.to( _logoLoader, fadeInterval, { alpha : 1 }, { ease:Sine.easeOut } );
					}
				}
			}
			else
			{
				if ( fadeInterval <= 0 )
				{
					removeEP2Logo();
				}
				else
				{
					GTweener.to( _logoLoader, fadeInterval, { alpha : 0 }, { ease:Sine.easeOut, onComplete : handleLogoHidden } );
				}
			}
		}
		
		protected function handleLogoHidden(tweenInstant:GTween)
		{
			removeEP2Logo();
		}
		
		private function addEP2Logo( filename : String, fadeInterval : Number, posX : int, posY : int ) : Boolean
		{
			removeEP2Logo();
			
			if ( !filename || filename.length == 0 )
			{
				return false;
			}
			
			_logoLoader = new UILoader;
			if ( fadeInterval > 0 )
			{
				_logoLoader.alpha = 0;
			}
			_logoLoader.x = posX;
			_logoLoader.y = posY;
			_logoLoader.source = filename;
			addChild( _logoLoader );
			
			return true;
		}
		
		private function removeEP2Logo()
		{
			if ( _logoLoader )
			{
				removeChild( _logoLoader );
				_logoLoader = null;
			}
		}
		
		protected function handleNotificationHidden(event:Event):void
		{
			if (_notificationQueue.length)
			{
				var nextNotify:Object = _notificationQueue.shift();
				notificationModule.show(nextNotify.messageText, nextNotify.duration);
			}
		}
		
		protected function updateMouseEventListeners():void
		{
			InputDelegate.getInstance().disableInputEvents(_enableInputMgr || _mouseShown);
		}
		
		private var _debugTimer:Timer;
		protected function startDebugMode():void
		{
			showMouseCursor(true);
			Mouse.hide();
			
			showNotification("Gamepad detected.<br/>Control sheme changed", 2000);
			//showNotification("Next notification in 3. Awesome message. Bananana Banana Banana Banana", 2000);
			//showNotification("Next notification in 2", 2000);
			//showNotification("Next notification in 1", 2000, true);
			//showNotification("Test notification <br/ > some text <br/ > By the way, here we have an <font color = '#FF0000'> awesome red text </font> ", 6000, true);
			
			showLoadIdicator();
			
			_debugTimer = new Timer(2000, 1);
			_debugTimer.addEventListener(TimerEvent.TIMER, handleDebugTimer, false, 0, true);
			_debugTimer.start();
			
			showSafeRect(true);
		}
		
		private function handleDebugTimer(event:TimerEvent):void
		{
			_debugTimer.stop();
			_debugTimer = null;
			hideLoadIdicator();
		}
		
	}
}
