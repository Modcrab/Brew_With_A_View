package red.game.witcher3.popups
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.overlay.TutorialOverlay;
	import red.game.witcher3.menus.overlay.TutorialPopup;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	/**
	 * TUTORIALS
	 * @author Getsevich Yaroslav
	 *
	 */
	public class TutorialPopupMenu extends CorePopup
	{
		protected static const OVER_ANIM_OFFSET_X:Number = -50;
		protected static const OVER_ANIM_DURATION:Number = 0.5;
		
		// Hint animation config
		protected static const ANIM_INIT_SCALE:Number = .8;
		protected static const ANIM_DURATION:Number = .6;
		protected static const ANIM_OFFSET_Y:Number = 30;
		protected static const ANIM_OFFSET_ROT_X:Number = 0;
		protected static const ANIM_OFFSET_ROT_Y:Number = 0;
		
		protected static const DEFAULT_CENTER_Y:Number = 50;
		protected static const DEFAULT_X:Number = 0; // 0.01
		protected static const DEFAULT_Y:Number = 211; // 0.6
		
		// Default
		protected static const DEFAULT_DELAY:Number = 6000;
		
		// Highlighted area anim
		protected static const AREA_ANIM_DURATION:Number = 1;
		protected static const AREA_ANIM_INIT_SCALE:Number = 4;
		
		// Lib content refs
		protected static const CONTENT_REF:String = "TutorialPopupRef";
		protected static const AREA_REF:String = "AreaBorderRef";
		
		protected var _minDuration:Number = -1;
		protected var _data:Object;
		protected var _timer:Timer;
		protected var _areaCanvas:Sprite;
		protected var _popupContainer:Sprite;
		
		private var _resetInput:Boolean = false;
		
		public var popupInstance:TutorialPopup;
		public var tutorialOverlay:TutorialOverlay;
		
		public function TutorialPopupMenu()
		{
			_enableInputValidation = true;
			
			_areaCanvas = new Sprite();
			addChild(_areaCanvas);
			super();
			
			popupInstance.visible = false;
			popupInstance.addEventListener(Event.RESIZE, handlePopupResized, false, 0, true);
			
			tutorialOverlay.visible = false;
			
			_popupContainer = new Sprite();
			_popupContainer.addChild(popupInstance);
			addChild(_popupContainer);
		}
		
		override protected function get popupName():String { return "TutorialPopup" }
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'tutorial.hint.data', [createMessage]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'tutorial.area.highlight', [highlightAreas]));
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			_inputMgr.enableHoldEmulation = false;
			_inputMgr.enableInputDeviceCheck = false;
			_inputMgr.addInputBlocker(true, "TUTORIAL_ROOT");
			
			if (!Extensions.isScaleform)
			{
				startDebugMode();
			}
		}
		
		// used after unhiding tutorial (radial, menu, etc)
		override public function resetInput():void
		{
			super.resetInput();
			
			_resetInput = true;
		}
		
		public function playFeedbackAnimation(isCorrect:Boolean):void
		{
			if (popupInstance)
			{
				popupInstance.playFeedbackAnimation(isCorrect);
			}
		}
		
		public function removeMessage():void
		{
			hideMessage();
		}
		
		protected function createMessage(dataObj:Object):void
		{
			_data = dataObj;
			
			if (_data.fullscreen || _data.enableAcceptButton)
			{
				_inputMgr.addInputBlocker(false, "TUTORIAL_INSTANCE");
			}
			
			var visibleRect:Rectangle =  CommonUtils.getScreenRect();
			
			if (_data.fullscreen)
			{
				popupInstance.visible = false;
				tutorialOverlay.data = _data;
				tutorialOverlay.visible = true;
				
				if (_data.showAnimation)
				{
					GTweener.removeTweens(tutorialOverlay);
					tutorialOverlay.alpha = 0;
					tutorialOverlay.x = OVER_ANIM_OFFSET_X + visibleRect.x;
					GTweener.to(tutorialOverlay, OVER_ANIM_DURATION, { x : visibleRect.x, alpha : 1 }, { ease : Exponential.easeOut } );
				}
				
			}
			else
			{
				tutorialOverlay.visible = false;
				popupInstance.data = _data;
				if (_timer)
				{
					_timer.stop();
					_timer.removeEventListener(TimerEvent.TIMER, handleTimer, false);
				}
				var targetDelay:Number = _data.duration;
				if (targetDelay != -1) // -1 => no autohide
				{
					if (isNaN(targetDelay) || targetDelay == 0) targetDelay = DEFAULT_DELAY;
					_timer = new Timer(targetDelay, 1);
					_timer.addEventListener(TimerEvent.TIMER, handleTimer, false, 0, true);
					_timer.start();
				}
				
			}
		}
		
		protected function handlePopupResized(event:Event):void
		{
			setupPosition(_data.posX, _data.posY);
		}
		
		const AREA_SCALE_ACCURACY:int = 100;
		protected function highlightAreas(areasList:Array):void
		{
			var i, len:int;
			len = areasList.length;
			
			for (i = 0; i < len; i++)
			{
				var curDataObject:Object = areasList[i];
				var curArea:Sprite = createArea();
				var initScaleX, initScaleY:Number;
				var visibleRect:Rectangle =  CommonUtils.getScreenRect();
				var originSize:Rectangle = new Rectangle( 0, 0, 1920, 1080);

				/*
				var cX:Number = visibleRect.x + curDataObject.x * visibleRect.width;
				var cY:Number = visibleRect.y + curDataObject.y * visibleRect.height;
				var cWidth:Number = curDataObject.width * visibleRect.width;
				var cHeight:Number = curDataObject.height * visibleRect.height;
				*/
				/*
				var cX:Number = - visibleRect.x + curDataObject.x * originSize.width;
				var cY:Number = - visibleRect.y + curDataObject.y * originSize.height;
				var cWidth:Number = curDataObject.width * originSize.width;
				var cHeight:Number = curDataObject.height * originSize.height;
				*/
				var cX:Number = curDataObject.x * originSize.width;
				var cY:Number = curDataObject.y * originSize.height;
				var cWidth:Number = curDataObject.width * originSize.width;
				var cHeight:Number = curDataObject.height * originSize.height;
				
				cX = Math.round(cX * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				cY = Math.round(cY * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				cWidth = Math.round(cWidth * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				cHeight = Math.round(cHeight * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				
				curArea.width = cWidth;
				curArea.height = cHeight;
				curArea.x = cX + cWidth / 2;
				curArea.y = cY + cHeight / 2;
				
				initScaleX = Math.round(curArea.scaleX * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				initScaleY = Math.round(curArea.scaleY * AREA_SCALE_ACCURACY) / AREA_SCALE_ACCURACY;
				curArea.alpha = 0;
				curArea.scaleX = initScaleX * AREA_ANIM_INIT_SCALE;
				curArea.scaleY = initScaleY * AREA_ANIM_INIT_SCALE;
				
				GTweener.to(curArea, AREA_ANIM_DURATION, { scaleX:initScaleX, scaleY:initScaleY, alpha:1 }, { ease:Exponential.easeOut } );
			}
		}
		
		protected function createArea():Sprite
		{
			var areaClassRef:Class = getDefinitionByName(AREA_REF) as Class;
			var areaInstance:Sprite = new areaClassRef();
			_areaCanvas.addChild(areaInstance);
			return areaInstance;
		}
		
		protected function setupPosition(posX:Number, posY:Number):void
		{
			var visibleRect:Rectangle = CommonUtils.getScreenRect();
			var originSize:Rectangle = new Rectangle( 0, 0, 1920, 1080);
			var targetPosX:Number;
			var targetPosY:Number;
			
			trace("GFX visibleRect   -------------- ", visibleRect.x, visibleRect.y, visibleRect.width, visibleRect.height);
			
			popupInstance.visible = true;
			if ((isNaN(posX) || posX <= 0) && (isNaN(posY) || posY <= 0))
			{
				targetPosX = visibleRect.x;
				targetPosY = DEFAULT_Y;
			}
			else
			{
				/*
				targetPosX = visibleRect.x + visibleRect.width * posX;
				targetPosY = visibleRect.y + visibleRect.height * posY;
				*/
				/*
				targetPosX = -visibleRect.x + originSize.width * posX;
				targetPosY = -visibleRect.y + originSize.height * posY;
				*/
				
				targetPosX = originSize.width * posX;
				targetPosY = originSize.height * posY;
			}
			
			targetPosX += popupInstance.actualWidth / 2;
			targetPosY += popupInstance.actualHeight / 2;
			popupInstance.x = - popupInstance.actualWidth / 2;
			popupInstance.y = - popupInstance.actualHeight / 2;
			
			_popupContainer.x = targetPosX;
			_popupContainer.y = targetPosY;
			_popupContainer.alpha = 0;
			
			targetPosX += popupInstance.getPositionShiftX();
			
			// ???
			//_popupContainer.rotationX = ANIM_OFFSET_ROT_X;
			//_popupContainer.rotationY = ANIM_OFFSET_ROT_Y;
			//_popupContainer.scaleX = _popupContainer.scaleY = ANIM_INIT_SCALE;
			
			GTweener.removeTweens(_popupContainer);
			GTweener.to(_popupContainer, ANIM_DURATION, { x:targetPosX, y:targetPosY, rotationY:0, rotationX:0, alpha:1, scaleX:1, scaleY:1 }, { ease:Exponential.easeOut } );
		}
		
		protected function handleTimer(event:TimerEvent):void
		{
			_timer.removeEventListener(TimerEvent.TIMER, handleTimer, false);
			_timer.stop();
			_timer = null;
			hideMessage();
		}
		
		protected function hideMessage():void
		{
			_inputMgr.removeInputBlocker("TUTORIAL_INSTANCE");
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideTimer' ) );
		}
		
		protected function startDebugMode():void
		{
			var debugData:Object = { };
			debugData.messageText = "Please note that this happens only once the tutorial switches from using keyboard/mouse to using the controller.";
			//debugData.messageText = "Please note that this happens only once";
			debugData.messageTitle = "Test title";
			debugData.enableGlossaryLink = true;
			//debugData.enableAcceptButton = true;
			debugData.fullscreen = false;
			debugData.autosize = true;
			debugData.showAnimation = true;
			debugData.isUiTutorial = true;
			//debugData.posX = .5;
			//debugData.posY = .5;
			createMessage(debugData);
			//highlightAreas([ { x:.1, y:.1, width:.5, height:.5 } ]);
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			
			if (_resetInput)
			{
				pressedButtonsByKeys = { };
				pressedButtonsByNavEquivalent = { };
				_resetInput = false;
				return;
			}
			
			if ( _enableInputValidation && !(isNavEquivalentValid(details.navEquivalent) || isKeyCodeValid(details.code)) )
			{
				// "KEY_UP" received without receiving "KEY_DOWN"
				// probably input from other context, ignore it
				return;
			}
			
			if (popupInstance && popupInstance.visible)
			{
				popupInstance.proccedInput(event);
			}
			if (tutorialOverlay && tutorialOverlay.visible)
			{
				tutorialOverlay.proccedInput(event);
			}
		}
		
	}
}
