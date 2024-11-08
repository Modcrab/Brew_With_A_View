package red.core
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Mouse;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.MouseCursor;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.ItemDragEvent;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	import red.game.witcher3.slots.SlotsTransferManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.InteractiveObjectEx;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class CoreMenu extends CoreComponent
	{
		public static const CURRENT_MODULE_INVALIDATE:String = "Core.Menu.Current.Module.Invalidate";

		protected static var SHOW_ANIM_DURATION:Number = .8;
		protected static var SHOW_ANIM_OFFSET:Number = 500;

		protected var _modules:Vector.<CoreMenuModule> = new Vector.<CoreMenuModule>();
		protected var _mouseCursor:MouseCursor;
		protected var _dragCanvas:Sprite;
		protected var _dragManager:SlotsTransferManager;

		protected var _disableShowAnimation:Boolean;
		protected var _enableMouse:Boolean;
		protected var _overlayCanvas:MovieClip;
		protected var _contextMgr:ContextInfoManager;
		protected var _assetsMgr:RuntimeAssetsManager;
		protected var _currentModuleIdx:int;
		private var _currentModule:CoreMenuModule = null;
		protected var upToCloseEnabled:Boolean = false;
		protected var closingMenu:Boolean = false;
		public var _lastMoveWasMouse:Boolean = false;

		protected var _currentMenuState:String;
		protected var _restrictDirectClosing:Boolean;
		protected var actualModules:Vector.<CoreMenuModule> = new Vector.<CoreMenuModule>();
		public var mcBackground : MovieClip;

		protected var _inCombat:Boolean = false;

		private var _moduleChangeInputFeedback:int = -1;
		private var _initialPanelXOffset : int  = 0;
		
		protected var _loadAssets:Boolean = true;

		public function CoreMenu()
		{
			super();
			initManagers();

			if (!_disableShowAnimation)
			{
				visible = false;
			}
		}

		public function setInCombat(value:Boolean):void
		{
			_inCombat = value;
		}

		public function setMenuState(value:String):void
		{
			_currentMenuState = value;
		}

		public function setColorBlindMode(value:Boolean):void
		{
			isColorBlindMode = value;
		}
		
		public function setRestrictDirectClosing(value:Boolean):void
		{
			_restrictDirectClosing = value;
		}

		private var _blackBackground:Sprite;
		public function setBackgroundEffect(value:Boolean):void
		{
			if (_blackBackground)
			{
				removeChild(_blackBackground);
				_blackBackground = null;
			}
			if (value)
			{
				_blackBackground = CommonUtils.createFullscreenSprite(0x000000, .75);
				addChild(_blackBackground);
			}
		}

		private function initManagers():void
		{
			if (_loadAssets)
			{
				_assetsMgr = RuntimeAssetsManager.getInstanse();
				_assetsMgr.loadLibrary();
			}
			
			_contextMgr = ContextInfoManager.getInstanse();
		}

		// Keeps _overlayCanvas always on the top
		// TODO: Try to use scaleform extentions for this
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var resultChild:DisplayObject = super.addChild(child);
			if (child != _overlayCanvas && child != _blackBackground && _overlayCanvas)
			{
				super.addChild(_overlayCanvas);
			}
			return resultChild;
		}
		
		public function selectTargetModule(targetModule : CoreMenuModule):void
		{
			var i, len : int;
			
			len = _modules.length;
			for (i = 0; i < len; i++)
			{
				if (_modules[i] == targetModule)
				{
					currentModuleIdx = i;
					return;
				}
			}
		}
		
		public function get currentModuleIdx():int { return _currentModuleIdx }
		public function set currentModuleIdx(value:int):void
		{
			trace("GFX currentModuleIdx " + currentModuleIdx + " new " + value+" " + menuName);
			
			if (_modules.length < 1)
			{
				//dispatchEvent(new GameEvent(GameEvent.CALL, "OnModuleSelected", [0]));
				return;
			}
			
			actualModules.length = 0;
			var i:int;
			for (i = 0; i < _modules.length; i++)
			{
				var curModule:CoreMenuModule = _modules[i];
				
				//trace("GFX * curModule ", curModule, curModule.hasSelectableItems(), curModule.enabled);
				
				if (curModule.enabled && curModule.hasSelectableItems()) actualModules.push(curModule);
			}

			if (actualModules.length == 0)
			{
				_currentModuleIdx = -1;

				if (_currentModule != null)
				{
					_currentModule.focused = 0;
					_currentModule = null;
				}
				return;
			}

			var actualCurrentIdx:int = -1;
			var targetIndex:int = value;

			for (i = 0; i < actualModules.length; ++i)
			{
				if (actualModules[i] == _currentModule)
				{
					actualCurrentIdx = i;
				}
			}

			// #J the number of active modules has changed since this was last called, lets do this relatively
			if (actualCurrentIdx != _currentModuleIdx && actualCurrentIdx != -1)
			{
				if (value < _currentModuleIdx)
				{
					targetIndex = actualCurrentIdx - 1;
				}
				else if (value > _currentModuleIdx)
				{
					targetIndex =actualCurrentIdx + 1;
				}
			}

			targetIndex = Math.max(0, Math.min(actualModules.length - 1, targetIndex));

			// #J Disabling the module wrapping
			/*if ( value < 0 ) // #B cycling thru modules
			{
				value += actualModules.length;
			}
			else if(value > (actualModules.length - 1) )
			{
				value -= actualModules.length;
			}*/

			var newlySelectedModule:CoreMenuModule = actualModules[targetIndex];

			//trace("Minimap2 << ", targetIndex, ">> ", newlySelectedModule, " <- ", _currentModule);
			
			if (newlySelectedModule != null && newlySelectedModule != _currentModule)
			{
				if (_currentModule != null)
				{
					_currentModule.focused = 0;
				}
				if (newlySelectedModule != null) // #J check shouldn't be neccessary but why not
				{
					newlySelectedModule.focused = 1;
				}

				_currentModule = newlySelectedModule;

				_currentModuleIdx = targetIndex;
				//trace("SAVESYSTEM currentModuleIdx OnModuleSelected " + currentModuleIdx + " " + menuName);
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnModuleSelected", [_currentModuleIdx, newlySelectedModule.dataBindingKey]));
				
				//trace("Minimap2 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", newlySelectedModule.name );
			}
		}

		override protected function onCoreInit():void
		{
			registerMenu();
			initModules();
		}

		override protected function configUI():void
		{
			trace("GFX CONFIG UI [", this.menuName, "] ");
			if( mcBackground )
			{
				//mcBackground.mcVideo.OpenVideo("GUI_background.usm", true);
				if (mcBackground.mcIcon)
				{
					mcBackground.mcIcon.gotoAndStop(menuName);
				}
			}
			super.configUI();

			ShowSecondaryModules( false );
			_overlayCanvas = new MovieClip();
			_overlayCanvas.mouseChildren = _overlayCanvas.mouseEnabled = false;
			addChild(_overlayCanvas);

			_contextMgr.init(_overlayCanvas, _inputMgr);
			initDragSurface();

			if (_enableMouse)
			{
				_mouseCursor = new MouseCursor(_overlayCanvas);
			}

			tabEnabled = false;
			tabChildren = false;

			if (Extensions.isScaleform)
			{
				Mouse.hide();
			}

			// #J Give it lower priority that the modules giving them a chance to coble the input
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, checkForNavType, false, 100, true);
			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, -10, true);
			stage.addEventListener(CURRENT_MODULE_INVALIDATE, handleInitialDataSet, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 100, true);
			_inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);

			addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);

			if (!_disableShowAnimation)
			{
				showAnimation();
			}

			//updateModuleChangeInputFeedback();
		}
		
		public function setTooltipState( tooltipUpscaled : Boolean, tooltipVisibility:Boolean ):void
		{
			if (_contextMgr)
			{
				_contextMgr.setInitialState( tooltipUpscaled, tooltipVisibility);
			}
		}
		
		public function ShowSecondaryModules( value : Boolean )
		{
			if( mcBackground )
			{
				if (mcBackground.mcIcon)
				{
					mcBackground.mcIcon.visible = !value;
					//mcBackground.mcIcon.gotoAndStop(menuName);
				}
			}
		}

		protected function handleEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnMenuShown" ) );
		}

		protected function showAnimation():void
		{
			trace("HUD "+menuName+" showAnimation");
			visible = true;
			y = SHOW_ANIM_OFFSET;
			alpha = 0;
			GTweener.to(this, SHOW_ANIM_DURATION, { y:0, alpha:1 },  { ease: Exponential.easeOut, onComplete:handleShowAnimComplete } );
		}

		protected function hideAnimation():void
		{
			if (!closingMenu)
			{
				GTweener.removeTweens(this);

				GTweener.to(this, 0.3, { y:200, alpha:0 },  { ease: Exponential.easeOut, onComplete:handleHideAnimComplete } );
				
				closingMenu = true;
			}
		}

		protected function handleHideAnimComplete(instTween:GTween):void
		{
			closeMenu();
			closingMenu = false; // #J Probably not neccessary, but to be safe
		}

		protected function handleShowAnimComplete(instTween:GTween):void
		{
			addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
		}

		public function SetInitialPanelXOffset( value : int )
		{
			trace("HUD "+menuName+" SetInitialPanelXOffset "+value);
			_initialPanelXOffset = value;
			visible = true;
			var mcChild : MovieClip;
			for (var i : int = 0; i < numChildren; i++ )
			{
				mcChild = getChildAt(i) as MovieClip
				mcChild.x += _initialPanelXOffset;
			}

			GTweener.removeTweens(this);
			GTweener.to(this, SHOW_ANIM_DURATION, { alpha:1 },  { ease: Exponential.easeOut, onComplete:handleShowAnimComplete } )
		}

		protected function initDragSurface():void // #B should be in different place, not everywhere we need drag functionality
		{
			_dragCanvas = new Sprite();
			addChild(_dragCanvas);
			InteractiveObjectEx.setTopmostLevel(_dragCanvas, true);
			InteractiveObjectEx.setHitTestDisable(_dragCanvas, true);
			_dragManager = SlotsTransferManager.getInstance();
			_dragManager.init(_dragCanvas);
			_dragManager.addEventListener(ItemDragEvent.START_DRAG, handleStartDrag, false, 0, true);
			_dragManager.addEventListener(ItemDragEvent.STOP_DRAG, handleStopDrag, false, 0, true);
		}

		protected function handleStartDrag(event:ItemDragEvent):void // #B should be in different place, not everywhere we need drag functionality
		{
			if (_mouseCursor)
			{
				_mouseCursor.visible = false;
			}
		}

		protected function handleStopDrag(event:ItemDragEvent):void // #B should be in different place, not everywhere we need drag functionality
		{
			if (_mouseCursor)
			{
				_mouseCursor.visible = true;
			}
		}

		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			trace("SAVESYSTEM handleControllerChanged "+currentModuleIdx+" new "+0+" "+menuName);
			//currentModuleIdx = 0; // #Y Disabled to prevent OnModuleSelected call; TODO: Check it

			if (!event.isGamepad)
			{
				if (_modules.length > 0 && _modules[0].mcHighlight)
				{
					_modules[0].mcHighlight.highlighted = true;
				}

				for (var i:int = 1; i < _modules.length; i++)
				{
					if (_modules[i].mcHighlight) _modules[i].mcHighlight.highlighted = false;
				}
			}
			
			if (_lastMoveWasMouse && event.isGamepad)
			{
				_lastMoveWasMouse = false;
				onLastMoveStatusChanged();
			}
		}

		protected function handleInputNavigate(event:InputEvent):void
		{
			super.handleInput(event); // #B for what we call empty super ? //#J in case we ever do put something in the super :P
			
			var details:InputDetails = event.details;

			// Handle only down state to avoid jumping
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if (!event.handled)
			{
				if (keyUp && !_restrictDirectClosing)
				{
					switch (details.navEquivalent)
					{
						case NavigationCode.ESCAPE:
						case NavigationCode.GAMEPAD_B:
							if ( !_enableInputValidation || ( isNavEquivalentValid(details.navEquivalent) || isKeyCodeValid(details.code) ) )
							{
								hideAnimation();
								event.handled = true;
								event.stopImmediatePropagation();
							}
							return;
					}
				}

				if (keyDown )
				{
					CommonUtils.convertWASDCodeToNavEquivalent(details);
					
					switch (details.navEquivalent)
					{
						case NavigationCode.LEFT:
							currentModuleIdx--;
							break;
						case NavigationCode.RIGHT:
							currentModuleIdx++;
							break;
						case NavigationCode.UP:
							if (upToCloseEnabled && details.value != InputValue.KEY_HOLD)
							{
								event.handled = true;
								hideAnimation();
								return;
							}
					}
				}

				if (details.value == InputValue.KEY_DOWN)
				{
					switch (details.navEquivalent)
					{
						case NavigationCode.RIGHT_STICK_LEFT:
							currentModuleIdx--;
							break;
						case NavigationCode.RIGHT_STICK_RIGHT:
							currentModuleIdx++;
							break;
					}
				}
			}
		}
		
		protected function checkForNavType(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			if (_lastMoveWasMouse && (details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT || details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.DOWN))
			{
				_lastMoveWasMouse = false;
				onLastMoveStatusChanged();
			}
		}
		
		protected function handleInitialDataSet(event:Event):void
		{
			currentModuleIdx = 0;
		}
		
		protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
		
		public function moveMouseCursor(px:Number, py:Number):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnMoveMouseTo', [ px, py ] ) );
		}
		
		public function setMouseCursorVisibility(isVisible:Boolean):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetMouseCursorVisibility', [ isVisible ] ) );
		}
		
		public function setMouseCursorType(type:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetMouseCursorType', [ type ] ) );
		}
		
		private function registerMenu():void
		{
			trace("registerMenu: '" + menuName + "'");
			
			if ( Extensions.isScaleform )
			{
				ExternalInterface.call( "registerMenu", menuName, this );
			}
		}

		private function initModules():void
		{
			var limit:int = numChildren;

			for ( var i : int = 0; i < limit; i++)
			{
				initModule( getChildAt(i) as CoreMenuModule );
			}
			_modules.sort(sortModules);
		}

		private function initModule( curChild : CoreMenuModule )
		{
			if ( !curChild )
			{
				return;
			}
			
			for ( var i : int = 0; i < _modules.length; i++)
			{
				if ( _modules[ i ] == curChild )
				{
					return;
				}
			}

			_modules.push(curChild);
			curChild.addEventListener(Event.ACTIVATE, handleModuleActivated, false, 0, true);
			curChild.addEventListener(Event.DEACTIVATE, handleModuleDeactivated, false, 0, true);
			curChild.addEventListener(CoreMenuModule.EVENT_MOUSE_FOCUSE, handleModuleMouseFocuse, false, 0, true);
		}

		public function initModuleDynamically( curChild : CoreMenuModule )
		{
			initModule( curChild );
			_modules.sort(sortModules);
		}

		override public function setArabicAligmentMode(value:Boolean):void
		{
			super.setArabicAligmentMode(value);
			_contextMgr.isArabicAligmentMode = value;
		}
		
		public function setGameLanguage( value : String )
		{
			CoreComponent.gameLanguage = value;
		}
		
		protected function handleModuleMouseFocuse(event:Event):void
		{
			var targetModule:CoreMenuModule = event.currentTarget as CoreMenuModule;
			if (targetModule)
			{
				selectTargetModule(targetModule);
			}
		}

		private function handleModuleActivated(event:Event):void
		{
			// #Y disable for now
			//updateModuleChangeInputFeedback();
		}

		private function handleModuleDeactivated(event:Event):void
		{
			// #Y disable for now
			//updateModuleChangeInputFeedback();
		}

		protected function updateModuleChangeInputFeedback():void
		{
			var len:int = _modules.length;
			var enabledModulesCount:int = 0;

			for (var i:int = 0; i < len; i++)
			{
				if (_modules[i].enabled) enabledModulesCount++;
				if (enabledModulesCount > 1)
				{
					if (_moduleChangeInputFeedback < 0)
					{
						_moduleChangeInputFeedback = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1, "panel_button_common_change_selection");
						InputFeedbackManager.updateButtons(this);
						return;
					}

				}
			}
			if (_moduleChangeInputFeedback > 0)
			{
				InputFeedbackManager.removeButton(this, _moduleChangeInputFeedback);
				InputFeedbackManager.updateButtons(this);
				_moduleChangeInputFeedback = -1;
			}
		}

		private function sortModules(a:CoreMenuModule, b:CoreMenuModule):Number
		{
			return (a.x > b.x)? 1 : -1;
		}
		
		public function getMenuName():String
		{
			return 	menuName;
		}
		
		protected function get menuName():String
		{
			throw new Error("Override this");
			return "";
		}

		public function setCurrentModule( value : int ) : void
		{
			trace("SAVESYSTEM !!! setCurrentModule "+currentModuleIdx+" new "+value+" "+menuName);
			currentModuleIdx = value;
		}
		
		override public function toString():String
		{
			return "CoreMenu [ " + this.name + "; " + menuName + " ]";
		}
		
		protected function onLastMoveStatusChanged()
		{
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			if (!_lastMoveWasMouse)
			{
				_lastMoveWasMouse = true;
				onLastMoveStatusChanged();
			}
		}
		
		public function enableDebugInput()
		{
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleDebugInput, false, 1000, true);
		}
		
		public function handleDebugInput(event:InputEvent) { }
	}
}
