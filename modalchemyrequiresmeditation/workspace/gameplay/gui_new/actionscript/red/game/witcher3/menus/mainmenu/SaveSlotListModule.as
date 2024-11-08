/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	import red.core.constants.KeyCode;
	
	public class SaveSlotListModule extends CoreMenuModule
	{
		public var mcScrollingList:W3ScrollingList;
		public var mcSaveSlotItem1 :SaveSlotItemRenderer;
		public var mcSaveSlotItem2 :SaveSlotItemRenderer;
		public var mcSaveSlotItem3 :SaveSlotItemRenderer;
		public var mcSaveSlotItem4 :SaveSlotItemRenderer;
		public var mcSaveSlotItem5 :SaveSlotItemRenderer;
		public var mcSaveSlotItem6 :SaveSlotItemRenderer;
		public var mcSaveSlotItem7 :SaveSlotItemRenderer;
		public var mcSaveSlotItem8 :SaveSlotItemRenderer;
		public var mcSaveSlotItem9 :SaveSlotItemRenderer;
		public var mcSaveSlotItem10:SaveSlotItemRenderer;
		public var mcSaveSlotItem11:SaveSlotItemRenderer;
		
		public static const SLOT_MODE_SAVES:int = 0;
		public static const SLOT_MODE_LOAD:int = 1;
		public static const SLOT_MODE_IMPORT:int = 2;
		public static const SLOT_MODE_NEWGAME_PLUS:int = 3;
		
		public static const CST_CLOUD = 30;
		
		public var mcSlotPreview:W3UILoader;
		public var mcScrollbar : ScrollBar;
		
		public var slotMode:int;
		
		protected var saveImageTimer : Timer;
		protected var loadingSaveImageTimer : Timer;
		protected var _lastRequestedSaveImage : String;
		protected var _lastRequestedSaveImageTag : int;
		protected var _isLoadingScreenshot : Boolean = false;
		
		public var _lastMoveWasMouse:Boolean = false;
		
		public function get lastMoveWasMouse():Boolean { return _lastMoveWasMouse; }
		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (!_lastMoveWasMouse)
			{
				if (mcScrollingList.selectedIndex == -1)
				{
					mcScrollingList.selectedIndex = 0;
				}
			}
			else
			{
				if (_lastMouseOveredItem != -1)
				{
					var currentTarget:SaveSlotItemRenderer  = mcScrollingList.getRendererAt(_lastMouseOveredItem) as SaveSlotItemRenderer;
				
					if (currentTarget)
					{
						mcScrollingList.selectedIndex = currentTarget.index;
						mcScrollingList.validateNow();
					}
				}
				else
				{
					mcScrollingList.selectedIndex = _lastMouseOveredItem;
				}
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			enabled = false;
			visible = false;
			alpha = 0;
			
			if (mcScrollingList)
			{
				mcScrollingList.focusable = false;
				mcScrollingList.addEventListener(ListEvent.INDEX_CHANGE, onSaveSlotSelected, false, 0, true);
			}
			
			if (mcScrollbar)
			{
				mcScrollbar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;
			}
		}
		
		public function registerMouseEvents():void
		{
			registerMouseEventsForItem(mcSaveSlotItem1); 
			registerMouseEventsForItem(mcSaveSlotItem2); 
			registerMouseEventsForItem(mcSaveSlotItem3); 
			registerMouseEventsForItem(mcSaveSlotItem4); 
			registerMouseEventsForItem(mcSaveSlotItem5); 
			registerMouseEventsForItem(mcSaveSlotItem6); 
			registerMouseEventsForItem(mcSaveSlotItem7); 
			registerMouseEventsForItem(mcSaveSlotItem8); 
			registerMouseEventsForItem(mcSaveSlotItem9); 
			registerMouseEventsForItem(mcSaveSlotItem10);
			registerMouseEventsForItem(mcSaveSlotItem11);
			
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
		}
		
		public function unregisteredMouseEvents():void
		{
			unregisterMouseEventsForItem(mcSaveSlotItem1); 
			unregisterMouseEventsForItem(mcSaveSlotItem2); 
			unregisterMouseEventsForItem(mcSaveSlotItem3); 
			unregisterMouseEventsForItem(mcSaveSlotItem4); 
			unregisterMouseEventsForItem(mcSaveSlotItem5); 
			unregisterMouseEventsForItem(mcSaveSlotItem6); 
			unregisterMouseEventsForItem(mcSaveSlotItem7); 
			unregisterMouseEventsForItem(mcSaveSlotItem8); 
			unregisterMouseEventsForItem(mcSaveSlotItem9); 
			unregisterMouseEventsForItem(mcSaveSlotItem10);
			unregisterMouseEventsForItem(mcSaveSlotItem11);
			
			InputManager.getInstance().removeEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange);
		}
		
		protected function registerMouseEventsForItem(item:SaveSlotItemRenderer):void
		{
			item.addEventListener(MouseEvent.CLICK, onItemClicked, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 0, true);
		}
		
		protected function unregisterMouseEventsForItem(item:SaveSlotItemRenderer):void
		{
			item.removeEventListener(MouseEvent.CLICK, onItemClicked);
			item.removeEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
			item.removeEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);
		}
		
		protected function onItemClicked(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				activateSelectedSlot();
			}
		}
		
		protected var _lastMouseOveredItem:int = -1;
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:SaveSlotItemRenderer = event.currentTarget as SaveSlotItemRenderer;
			
			_lastMouseOveredItem = mcScrollingList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				mcScrollingList.selectedIndex = currentTarget.index;
			}
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				mcScrollingList.selectedIndex = -1;
			}
		}
		
		private function handleScroll(e:Event) : void
		{
			mcScrollingList.validateNow();
			if (_lastMouseOveredItem != -1 && _lastMoveWasMouse)
			{
				var currentTarget:SaveSlotItemRenderer  = mcScrollingList.getRendererAt(_lastMouseOveredItem) as SaveSlotItemRenderer;
				
				if (currentTarget)
				{
					mcScrollingList.selectedIndex = currentTarget.index;
					mcScrollingList.validateNow();
				}
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if (event.isGamepad)
			{
				if (mcScrollingList.selectedIndex == -1)
				{
					mcScrollingList.selectedIndex = 0;
				}
			}
			else
			{
				if (_lastMoveWasMouse)
				{
					mcScrollingList.selectedIndex = _lastMouseOveredItem;
				}
			}
		}
		
		public function showWithData(data:Array, targetSlotMode:int):void
		{
			slotMode = targetSlotMode;
			
			mcSlotPreview.visible = false;
			
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
			
			if (mcScrollingList)
			{
				mcScrollingList.dataProvider = new DataProvider(data);
				mcScrollingList.validateNow();
				
				if (mcScrollingList.selectedIndex == 0)
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
				}
				
				mcScrollingList.selectedIndex = 0;
			}
			
			registerMouseEvents();
			
			displaySelectedSavesScreenshot();
		}

		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
				
				unregisteredMouseEvents();
				
				if (saveImageTimer)
				{
					saveImageTimer.stop();
				}
				
				if (mcSlotPreview.visible)
				{
					mcSlotPreview.visible = false;
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnLoadSaveImageCancelled"));
				}
			}
		}

		protected function onHideComplete(curTween:GTween):void
		{
			_lastRequestedSaveImage = "";
			mcSlotPreview.source = "";
			visible = false;
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( keyUp && !event.handled )
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_B:
						{
							handleNavigateBack();
							event.handled = true;
						}
						break;
					case NavigationCode.GAMEPAD_A:
						{
							activateSelectedSlot();
							event.handled = true;
						}
						break;
					case NavigationCode.GAMEPAD_X:
						{
							tryDeleteSlot();
							event.handled = true;
						}
						break;
					case NavigationCode.GAMEPAD_L2:
						{
							activateCloudSaves();
							event.handled = true;
						}
						break;
					}
					
					if (!event.handled)
					{
						if (details.code == KeyCode.DELETE)
						{
							tryDeleteSlot();
						}
						else if (details.code == KeyCode.E)
						{
							activateSelectedSlot();
							event.handled = true;
						}
						else if (details.code == KeyCode.C)
						{
							activateCloudSaves();
							event.handled = true;
						}
					}
				}
				
				if (!event.handled)
				{
					mcScrollingList.handleInput(event);
				}
			}
		}
		
		protected function trySyncSlot():void
		{
			var currentSaveSlot:SaveSlotItemRenderer;
			
			if (slotMode != SLOT_MODE_IMPORT && slotMode != SLOT_MODE_NEWGAME_PLUS)
			{
				currentSaveSlot = mcScrollingList.getSelectedRenderer() as SaveSlotItemRenderer;
				
				if (currentSaveSlot && currentSaveSlot.data.tag != -1)
				{
					handleNavigateBack();
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnSyncSaveCalled", [currentSaveSlot.data.saveType, currentSaveSlot.data.tag, (slotMode == SLOT_MODE_SAVES)] ) );
				}
			}
		}
		
		protected function activateCloudSaves():void
		{
			if (slotMode != SLOT_MODE_IMPORT && slotMode != SLOT_MODE_NEWGAME_PLUS) {
				var ingameMenu:IngameMenu = parent as IngameMenu;
				if (ingameMenu) {
					if (ingameMenu.isCloudUserSignedIn) {
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnShowCloudModalCalled" ) );
					}
				}
			}
		}
		
		protected function tryDeleteSlot():void
		{
			var currentSaveSlot:SaveSlotItemRenderer;
			
			if (slotMode != SLOT_MODE_IMPORT && slotMode != SLOT_MODE_NEWGAME_PLUS)
			{
				currentSaveSlot = mcScrollingList.getSelectedRenderer() as SaveSlotItemRenderer;
				
				// Ignore cloud saves.
				if(currentSaveSlot.data.cloudStatus == CST_CLOUD)
					return;
				
				if (currentSaveSlot && currentSaveSlot.data.tag != -1)
				{
					var ingameMenu:IngameMenu = parent as IngameMenu;
					if (ingameMenu)
					{
						ingameMenu.setIgnoreInput(true);
					}
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnDeleteSaveCalled", [currentSaveSlot.data.saveType, currentSaveSlot.data.tag, (slotMode == SLOT_MODE_SAVES)] ) );
				}
			}
		}
		
		protected function activateSelectedSlot():void
		{
			var currentSaveSlot:SaveSlotItemRenderer = mcScrollingList.getSelectedRenderer() as SaveSlotItemRenderer;
			var ingameMenu:IngameMenu = parent as IngameMenu;
			
			if (currentSaveSlot)
			{
				switch(slotMode)
				{
				case SLOT_MODE_SAVES:
					if (ingameMenu)
					{
						ingameMenu.setIgnoreInput(true);
					}
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSaveGameCalled', [ currentSaveSlot.data.saveType, currentSaveSlot.data.tag ] ) );
					break;
				case SLOT_MODE_LOAD:
					if (ingameMenu)
					{
						ingameMenu.setIgnoreInput(true);
					}
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnLoadGameCalled', [ currentSaveSlot.data.saveType, currentSaveSlot.data.tag ] ) );
					break;
				case SLOT_MODE_IMPORT:
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnImportGameCalled', [ currentSaveSlot.data.tag ] ) );
					break;
				case SLOT_MODE_NEWGAME_PLUS:
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNewGamePlusCalled', [ currentSaveSlot.data.tag ] ) );
					break;
				}
			}
		}
		
		public function onRightClick(event:MouseEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}

		protected function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
		}
		
		protected function onSaveSlotSelected( event:ListEvent ):void
		{
			// screenshot
			if (slotMode != SLOT_MODE_IMPORT /*&& slotMode != SLOT_MODE_NEWGAME_PLUS*/ )
			{
				displaySelectedSavesScreenshot();
			}
		}
		
		protected function displaySelectedSavesScreenshot():void
		{
			var item:SaveSlotItemRenderer = mcScrollingList.getSelectedRenderer() as SaveSlotItemRenderer;
			
			if (item && item.data)
			{
				if (item.data.tag == -1) //EMPTY save slot
				{
					mcSlotPreview.visible = false;
				}
				else
				{
					setSelectedSaveSlotImage(item.data.filename, item.data.tag);
				}
				mcSlotPreview.y = item.y;
			}
			else
			{
				mcSlotPreview.visible = false;
			}
		}
		
		protected function setSelectedSaveSlotImage( filename : String, tag : int ):void
		{
			mcSlotPreview.visible = false;
			
			if (filename != "")
			{
				if (!saveImageTimer)
				{
					saveImageTimer = new Timer(200, 1);
					saveImageTimer.addEventListener(TimerEvent.TIMER, showSaveImageTimerDone);
				}
				
				stopLoadingTimer();
				
				// Protection to not retrigger an image loading if its already in process
				if (filename != _lastRequestedSaveImage || !saveImageTimer.running || (loadingSaveImageTimer && !loadingSaveImageTimer.running))
				{
					saveImageTimer.reset();
					saveImageTimer.start();
					
					_lastRequestedSaveImage = /*"img://" + */filename + ".sav";
					_lastRequestedSaveImageTag = tag;
				}
			}
		}
		
		protected function stopLoadingTimer():void
		{
			if (loadingSaveImageTimer)
			{
				if (loadingSaveImageTimer.running)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnLoadSaveImageCancelled"));
				}
				
				loadingSaveImageTimer.stop();
			}
		}
		
		protected function showSaveImageTimerDone( event : TimerEvent ) : void
		{
			if (!loadingSaveImageTimer)
			{
				loadingSaveImageTimer = new Timer(60);
				loadingSaveImageTimer.addEventListener(TimerEvent.TIMER, onLoadingSaveImageTimer);
			}
			
			loadingSaveImageTimer.reset();
			loadingSaveImageTimer.start();
			
			_isLoadingScreenshot = true;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnScreenshotDataRequested", [_lastRequestedSaveImageTag]));
		}
		
		
		protected function onLoadingSaveImageTimer( event : TimerEvent ) : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCheckScreenshotDataReady"));
		}
		
		public function onLoadingScreenshotComplete():void
		{
			if (slotMode != SLOT_MODE_IMPORT /*&& slotMode != SLOT_MODE_NEWGAME_PLUS*/)
			{
				mcSlotPreview.visible = true;
				mcSlotPreview.source = _lastRequestedSaveImage;
				
				if (loadingSaveImageTimer)
				{
					loadingSaveImageTimer.stop();
				}
			}
		}
	}
}