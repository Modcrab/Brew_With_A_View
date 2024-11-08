/***********************************************************************
/** PANEL WorldMap main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.MapState;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.data.StaticMapPinData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.LoadingSymbol;
	import red.game.witcher3.menus.worldmap.data.CategoryData;
	import red.game.witcher3.tooltips.TooltipMap;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.TileList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.MouseEventEx;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.events.ButtonEvent;
	
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class MapMenu extends CoreMenu
	{
		private const GOTO_WORLD_HINT_HIDDEN_Y:Number = 946;
		private const GOTO_WORLD_HINT_SHOWN_Y:Number = 870;
		
		private const TOOLTIP_POS:Number = 1006;
		private const FAST_TRAVEL_ZOOM:Number = 1;
		
		private const DROPDOWN_POS_LEFT:Number = 138;
		private const DROPDOWN_POS_RIGHT:Number = 1200;
		
		private const LAYER_UNIVERSE = 0;
		private const LAYER_HUB      = 1;
		private const LAYER_INTERIOR = 2;

		public var tfDebugInfo		: TextField;

		public var mcVisibleArea	: MovieClip;
		public var mcUniverseMap	: UniverseMap;
		public var mcHubMap			: HubMap;
		public var mcInteriorMap	: InteriorMap;

		public var tooltipAnchor	: Sprite;
		public var tooltipInstance  : TooltipMap;
		public var userPinPanel		: UserPinPanel;
		public var userPinPanelBackground : MovieClip;
		public var mcHubMapPinPanel		: MovieClip;
		public var mcHubMapQuestTracker : MovieClip;

		public var mcGotoWorldMap		: MovieClip;
		public var mapName				: MovieClip;
		public var objectivesTitleHint	: CurrentQuestMapHint;
		public var mcWorldMapButton		: MovieClip;

		private var m_fastTravelPinData	 : Object;
		private var m_trackableMappinTag : uint;
		private var m_currentLayer  	 : int = -1;
		private var m_currentState  	 : String = ""; //"GlobalMap";
		private var m_blockNavigation    : Boolean;
		private var m_loadingState       : Boolean;

		// key bindings
		private var m_action_Zoom		     : int = -1;
		private var m_action_QuestTrack      : int = -1;
		private var m_action_FastTravel      : int = -1;
		private var m_action_OpenRegion		 : int = -1;
		private var m_action_PlaceMappin	 : int = -1;
		private var m_action_MappinPanel     : int = -1;
		/*
		private var m_action_MapPreview      : int = -1;
		*/
		/*
		private var m_action_OpenWorldMap	 : int = -1;
		*/
		/*
		private var m_action_Navigate		 : int = -1;
		*/
		private var m_action_NavigateFilters : int = -1;
		
		private var m_action_GotoPlayer		 : int = -1;
		private var m_action_GotoQuest		 : int = -1;
		
		// deprecated
		private var m_action_GotoObjectives  : int = -1;
		private var m_action_GotoFastTravel  : int = -1;
		
		private var m_selectedPinData    : StaticMapPinData;
		private var m_userPinPanelShown  : Boolean;
		private var m_invalidateState    : String;
		private var m_gotoWorldHintShown : Boolean;

		private var _pendingMapContext:MapContextEvent;
		
		static public var m_debugInfo : MapDebugInfo;
		static public var m_showDebugBorders : Boolean = false; // true
		
		private var m_isLMBDown : Boolean = false;
		private var m_lastLMBPos : Point = new Point;

		static private var m_currGlobalMousePos : Point = new Point;
		static private var m_currLocalMousePos : Point = new Point;
		static private var m_isUsingGamepad : Boolean = false;
		
		public var mcPointersCanvas			: MovieClip;
		public var mcMapHitArea:Sprite;
		
		private var _lastVisitedHub : UniverseArea;
		
		public function MapMenu()
		{
			super();
			
			userPinPanel.visible = false;
			userPinPanelBackground.visible = false;
			mcHubMapPinPanel.visible = false;
			mcHubMapQuestTracker.visible = false;
			invalidateControlPanels();
			upToCloseEnabled = false;
			//objectivesTitleHint.visible = false;
			
			tfDebugInfo.visible = false; // true
			m_debugInfo = new MapDebugInfo();
			m_debugInfo.__mapMenu = this;
			
			mcHubMap.showGotoWorldHint = showGotoWorldHint;
			mcHubMap.showGotoPlayerPin = ShowGotoPlayerButton;
			mcHubMap.showGotoQuestPin  = ShowGotoQuestButton;
			mcHubMap.enableUserPinPanel  = enableUserPinPanel;
			mcHubMap.funcClearCategoryPanel = clearCategoryPanel;
			mcHubMap.funcInitializeCategoryPanel = initializeCategoryPanel;
			mcHubMap.funcUpdateCategoryPanel = updateCategoryPanel;
			mcHubMap.funcEnableCategoryPanel = enableCategoryPanel;
			mcHubMap.funcAddPinToCategoryPanel = addPinToCategoryPanel;
			mcHubMap.funcEnableQuestTracker = enableQuestTracker;
			mcHubMapPinPanel.funcCenterOnWorldPosition = centerOnWorldPosition;
			mcHubMapPinPanel.funcShowPinsFromCategory = showPinsFromCategory;
			mcHubMapPinPanel.funcIsAnimationRunning = isAnimationRunning;
			userPinPanel.enableUserPinPanel = enableUserPinPanel;
			userPinPanel.setUserMapPin = setUserMapPin;
		
			mcPointersCanvas.mouseChildren = false;
			mcPointersCanvas.mouseEnabled = false;
			PinPointersManager.getInstance().init(mcPointersCanvas);
		}
		
		
		
		

		override protected function configUI():void
		{
			//
			//trace("Minimap configUI()");
			//
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.name.set', [setMapName] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.current.area.id', [setCurrentArea] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.current.area.name', [setCurrentName] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.quest.name', [setCurrentQuest] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.objectives', [setCurrentObjectives] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.hubs.custom', [handleCustomHubs] ) ); // NGE
			
			
			_inputHandlers.push( mcUniverseMap );
			_inputHandlers.push( mcHubMap );
			_inputHandlers.push( mcInteriorMap );

			//stage.doubleClickEnabled = true;
			//stage.mouseChildren = false;
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );

			mcMapHitArea.doubleClickEnabled = true;
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_DOWN,		OnMouseDown,		false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.CLICK,			OnMouseDoubleDown,	false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_UP,			OnMouseUp,			false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_MOVE,		OnMouseMove,		false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_WHEEL,		OnMouseWheel,		false, 0, true );
			
			userPinPanelBackground.addEventListener( MouseEvent.MOUSE_DOWN,		OnUserPinBackgroundMouseDown, false, 0, true );
			userPinPanelBackground.addEventListener( MouseEvent.MOUSE_MOVE,		OnUserPinBackgroundMouseMove, false, 0, true );
			userPinPanel.addEventListener(           MouseEvent.MOUSE_MOVE,		OnUserPinBackgroundMouseMove, false, 0, true );

			mcHubMap.addEventListener(MapContextEvent.CONTEXT_CHANGE, handleMapContext, false, 0, true);
			mcHubMap.addEventListener(Event.CHANGE, handleHubMapUpdated, false, 0, true);
			mcUniverseMap.addEventListener(MapContextEvent.CONTEXT_CHANGE, handleMapContext, false, 0, true);

			initializeKeyboardButtons();
			
			if (!Extensions.isScaleform)
			{
				debugData();
			}
			
			// goto World hint
			var tfCloseHint:TextField = mcGotoWorldMap["textField"] as TextField;
			var btnCloseHint:InputFeedbackButton = mcGotoWorldMap["button"] as InputFeedbackButton;
			tfCloseHint.text = "[[panel_map_title_worldmap]]";
			btnCloseHint.label = "";
			btnCloseHint.setDataFromStage(NavigationCode.GAMEPAD_RSTICK_DOWN, -1);
			
			/*
			if (m_action_Navigate < 0)
			{
				m_action_Navigate = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_L3, 1001, "panel_button_common_navigation"); // replace 1001 with MOUSE_PAN
			}
			*/
			if ( m_action_NavigateFilters < 0 )
			{
				m_action_NavigateFilters = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_ALL, -1, "panel_map_navigate_filters");
			}

			
			UpdateLayers( LAYER_HUB, true );
			
			updateKeyboardButtons();
		}
		
		override protected function handleShowAnimComplete(instTween:GTween):void
		{
			super.handleShowAnimComplete(instTween);
			
			mcHubMap.SetMenuAnimCompleted();
		}
		
		public static function GetCurrGlobalMousePos() : Point
		{
			return m_currGlobalMousePos;
		}
		
		public static function GetCurrLocalMousePos() : Point
		{
			return m_currLocalMousePos;
		}
		
		public static function IsUsingGamepad() : Boolean
		{
			return m_isUsingGamepad;
		}
		
		public function setDefaultMapPostion(defX:Number, defY:Number):void
		{
			mcHubMap.setDefaultPosition(defX, defY);
		}
		
		public function isGotoWorldHintFullyVisible() : Boolean
		{
			if ( !mcGotoWorldMap.visible )
			{
				return false;
			}
			return mcGotoWorldMap.y <= GOTO_WORLD_HINT_SHOWN_Y;
		}
		
		public function showGotoWorldHint(value:Boolean):void
		{
			if (value && !m_gotoWorldHintShown)
			{
				mcGotoWorldMap.visible = true;
				GTweener.removeTweens(mcGotoWorldMap);
				GTweener.to(mcGotoWorldMap, .5, { y : GOTO_WORLD_HINT_SHOWN_Y }, { ease:Exponential.easeOut } );
				m_gotoWorldHintShown = true;
			}
			else if (!value && m_gotoWorldHintShown)
			{
				GTweener.removeTweens(mcGotoWorldMap);
				GTweener.to(mcGotoWorldMap, .5, { y : GOTO_WORLD_HINT_HIDDEN_Y }, { ease:Exponential.easeOut, onComplete:handleGotoWorldHintHidden } );
				m_gotoWorldHintShown = false;
			}
		}

		public function setUserMapPin( index : int, fromSelectionPanel : Boolean )
		{
			mcHubMap.setUserMapPin( index, fromSelectionPanel );
		}

		private function updateKeyboardButtons()
		{
			var show : Boolean = ( IsLayer( LAYER_HUB ) && !m_isUsingGamepad );

			if ( IsLayer( LAYER_HUB ) )
			{
				mcWorldMapButton.btnWorldMap.label = "[[panel_map_title_worldmap]]";
			}
			else
			{
				if ( _lastVisitedHub )
				{
					mcWorldMapButton.btnWorldMap.label = "[[map_location_" + _lastVisitedHub.GetWorldName() + "]]";
				}
			}
			mcWorldMapButton.btnWorldMap.updateDataFromStage();
			
			var buttonWidth         : Number = mcWorldMapButton.btnWorldMap.getViewWidth();
			var backgroundWidth     : Number = buttonWidth + 2 * 20;
			var backgroundWidthDiff : Number = backgroundWidth - mcWorldMapButton.mcBackground.width;

			mcWorldMapButton.btnWorldMap.x = -buttonWidth;
			mcWorldMapButton.mcBackground.x -= backgroundWidthDiff;
			mcWorldMapButton.mcBackground.width = backgroundWidth;
		}
		
		private function initializeKeyboardButtons()
		{
			mcWorldMapButton.btnWorldMap.clickable = true;
			mcWorldMapButton.btnWorldMap.setDataFromStage( NavigationCode.GAMEPAD_Y, KeyCode.SPACE );				
			mcWorldMapButton.btnWorldMap.visible = true;
			mcWorldMapButton.btnWorldMap.addEventListener( ButtonEvent.CLICK, handleWorldMapButtonClicked, false, 0, true );
			mcWorldMapButton.btnWorldMap.validateNow();
			mcWorldMapButton.btnWorldMap.x = - mcWorldMapButton.btnWorldMap.getViewWidth();
		}
		
		public function handleWorldMapButtonClicked( event : ButtonEvent )
		{
			if ( IsLayer( LAYER_HUB ) )
			{
				if ( mcHubMap.CanProcessInput() )
				{
					switchMap();
				}
			}
			else if ( IsLayer( LAYER_UNIVERSE ) )
			{
				if ( mcUniverseMap.CanProcessInput() )
				{
					switchMap( true );
				}
			}
		}

		override protected function handleControllerChanged(event:ControllerChangeEvent):void		
		{
			super.handleControllerChanged(event);

			//
			//trace("Minimap CONTROLLER " + event.isGamepad + " " + InputManager.getInstance().isGamepad() );
			//

			m_isUsingGamepad = InputManager.getInstance().isGamepad(); // event.isGamepad
			
			mcUniverseMap.OnControllerChanged( m_isUsingGamepad );
			mcHubMap.OnControllerChanged( m_isUsingGamepad );
			
			mcHubMapPinPanel.OnControllerChanged( m_isUsingGamepad );
			
			updateKeyboardButtons();
		}
		
		private function handleGotoWorldHintHidden(tweenInstance:GTween):void
		{
			mcGotoWorldMap.visible = false;
		}
		
		public function /* Witchescript */ RemoveUserMapPin( id : uint ):void
		{
			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.RemoveUserMapPin( id );
				
				removePinFromCategoryPanel( id );
			}
		}
		
		public function /* Witchescript */ SetMapZooms( minZoom : Number, maxZoom : Number, zoom12 : Number, zoom23 : Number, zoom34 : Number )
		{
			mcHubMap.SetMapZooms( minZoom,  maxZoom, zoom12, zoom23, zoom34 );
		}

		public function /* Witchescript */ SetMapVisibilityBoundaries( minX : int, maxX : int, minY : int, maxY : int, gradientScale : Number )
		{
			mcHubMap.SetMapVisibilityBoundaries( minX, maxX, minY, maxY, gradientScale );
		}

		public function /* Witchescript */ SetMapScrollingBoundaries( minX : int, maxX : int, minY : int, maxY : int )
		{
			mcHubMap.SetMapScrollingBoundaries( minX, maxX, minY, maxY );
		}

		public function /* Witchescript */ SetMapSettings( mapSize : Number, tileCount : int, textureSize : int, minLod : int, maxLod : int, imagePath : String, previewAvailable : Boolean, previewMode : int )
		{
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetMinMaxLod( minLod, maxLod );
			//
			//
			//

			mcHubMap.SetMapSettings( mapSize, tileCount, textureSize, minLod, maxLod, imagePath, mcVisibleArea, previewAvailable, previewMode );
		}

		public function /* Witchescript */ ReinitializeMap()
		{
			mcHubMap.ReinitializeMap();
		}
		
		public function /* Witchescript */ EnableDebugMode( enable : Boolean )
		{
			if ( tfDebugInfo )
			{
				tfDebugInfo.visible = enable;
			}
		}

		public function /* Witchescript */ EnableUnlimitedZoom( enable : Boolean )
		{
			mcHubMap.EnableUnlimitedZoom( enable );
		}

		public function /* Witchescript */ EnableManualLod( enable : Boolean )
		{
			mcHubMap.EnableManualLod( enable );
		}

		public function /* Witchescript */ ShowBorders( enable : Boolean )
		{
			m_showDebugBorders = enable;
			mcHubMap.UpdateDebugBorders();
		}

		public function /* Witchescript */ ShowToussaint( show : Boolean )
		{
			mcUniverseMap.mcUniverseMapContainer.mcToussaint.visible = show;
			mcUniverseMap.mcUniverseMapContainer.mcToussaint.enabled = show;
			mcUniverseMap.mcUniverseMapContainer.mcToussaint_mask.enabled = show;
		}
		
		public function /* Witchescript */ SetHighlightedMapPin( tag : int )
		{
			mcHubMap.setHighlightedMapPin( tag );
		}
		
		protected function setCurrentQuest(value:Object):void
		{
			mcHubMapQuestTracker.setCurrentQuest( value );
		}
		
		protected function setCurrentObjectives( value: Object )
		{
			mcHubMapQuestTracker.setCurrentObjectives( value as Array );
		}

		protected function setMapName(value:String):void
		{
			var targetTextField:TextField = mapName["textField"];
			targetTextField.text = value;
			targetTextField.text = CommonUtils.toUpperCaseSafe(targetTextField.text);
		}

		protected function setCurrentArea(areaId:int):void
		{
			mcHubMap.setCurrentAreaId( areaId );
		}

		protected function setCurrentName(areaName:String):void
		{
			_lastVisitedHub = mcUniverseMap.mcUniverseMapContainer.GetHubMapByName( areaName );
		}

		override public function setMenuState(value:String):void
		{
			super.setMenuState(value);

			removeEventListener(Event.ENTER_FRAME, handleStateValidate, false);
			addEventListener(Event.ENTER_FRAME, handleStateValidate, false, 1, true);
			m_invalidateState = value;
		}

		private function handleStateValidate(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, handleStateValidate, false);
			applyState(m_invalidateState);
		}

		private function applyState(stateName:String, changeMapLayer:Boolean = false):void
		{
			if (stateName != m_currentState)
			{
				// reset
				deactivateContext();
				m_currentState = stateName;
				invalidateControlPanels();

				// common for all states
				m_blockNavigation = false;
				if (changeMapLayer)
				{
					UpdateLayers( LAYER_HUB );
				}
				if (IsLayer(LAYER_HUB))
				{
					//
					//trace("Minimap ##### applyState " + stateName + " " + changeMapLayer );
					//
					if (m_action_Zoom < 0)
					{
						m_action_Zoom =			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_SCROLL,	KeyCode.MOUSE_SCROLL,	"panel_button_common_zoom");
					}
					if (m_action_PlaceMappin < 0)
					{
						m_action_PlaceMappin =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X,				KeyCode.RIGHT_MOUSE,	"panel_map_place_waypoint");
					}
					if (m_action_MappinPanel < 0)
					{
						m_action_MappinPanel =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X,				KeyCode.RIGHT_MOUSE,	"panel_map_open_waypoint_panel", true);
					}
					/*
					if (m_action_MapPreview < 0)
					{
						if ( mcHubMap.mcHubMapPreview.CanBeToggled() )
						{
							m_action_MapPreview = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R2,				KeyCode.Z,	"panel_map_toggle_preview" );
						}
					}
					*/
					/*
					if (m_action_OpenWorldMap < 0)
					{
						m_action_OpenWorldMap =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_Y,		-1,						"panel_map_title_worldmap");
					}
					*/
					updateGotoPinButton();
					InputFeedbackManager.updateButtons(this);
				}
				if (IsLayer(LAYER_UNIVERSE))
				{
					mcUniverseMap.updateAreaSelection();
				}
			}
		}
		
		private function handleHubMapUpdated(event:Event):void
		{
			updateGotoPinButton();
			InputFeedbackManager.updateButtons(this);
		}

		public function enableUserPinPanel(value:Boolean, stagePositionForUserPin : Point = null) : void
		{
			if ( m_userPinPanelShown != value )
			{
				if ( value )
				{
					if ( !mcVisibleArea.hitTestPoint( stagePositionForUserPin.x, stagePositionForUserPin.y ) )
					{
						return;
					}
					
					userPinPanel.btnClose.x = -userPinPanel.btnClose.getViewWidth() / 2;
				}
				
				m_userPinPanelShown = value;
				
				//m_blockNavigation = m_userPinPanelShown;
				userPinPanel.visible = m_userPinPanelShown;
				userPinPanel.enabled = m_userPinPanelShown;
				userPinPanel.focused = m_userPinPanelShown ? 1 : 0;
				userPinPanelBackground.visible = m_userPinPanelShown;
				
				if ( value )
				{
					var centerPosX, centerPosY : int;
					var finalPosX, finalPosY : int;

					centerPosX = stagePositionForUserPin.x;
					centerPosY = stagePositionForUserPin.y;
					
					// restrict to mcVisibleArea
					if ( centerPosX - userPinPanel.width / 2 < mcVisibleArea.x - mcVisibleArea.width / 2 )
					{
						centerPosX = mcVisibleArea.x - mcVisibleArea.width / 2 + userPinPanel.width / 2;
					}
					else if ( centerPosX + userPinPanel.width / 2 > mcVisibleArea.x + mcVisibleArea.width / 2 )
					{
						centerPosX = mcVisibleArea.x + mcVisibleArea.width / 2 - userPinPanel.width / 2;
					}
					
					/*
					if ( centerPosY - userPinPanel.height / 2 < mcVisibleArea.y - mcVisibleArea.height / 2 )
					{
						centerPosY = mcVisibleArea.y - mcVisibleArea.height / 2 + userPinPanel.height / 2;
					}
					else if ( centerPosY + userPinPanel.height / 2 > mcVisibleArea.y + mcVisibleArea.height / 2 )
					{
						centerPosY = mcVisibleArea.y + mcVisibleArea.height / 2 - userPinPanel.height / 2;
					}
					*/
					
					if ( m_isUsingGamepad )
					{
						// move a bit up
						finalPosX = centerPosX;
						finalPosY = centerPosY - 30;
					}
					else
					{
						finalPosX = centerPosX;
						finalPosY = centerPosY;
					}

					/*
					// restrict upper limit
					if ( finalPosY < mcVisibleArea.y - mcVisibleArea.height / 2 )
					{
						finalPosY = stagePositionForUserPin.y + userPinPanel.height / 2 + 20;
					}
					*/
					
					userPinPanel.x = finalPosX;
					userPinPanel.y = finalPosY;

					//trace("Minimap SHOW" );
				}
				else
				{
					//trace("Minimap HIDE" );
				}
			}
		}
		
		private function invalidateControlPanels():void
		{
			m_blockNavigation = false;

			if (m_action_Zoom > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_Zoom);
				m_action_Zoom = -1;
			}
			if (m_action_PlaceMappin > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
				m_action_PlaceMappin = -1;
			}
			if (m_action_MappinPanel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_MappinPanel);
				m_action_MappinPanel = -1;
			}
			/*
			if (m_action_MapPreview  > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_MapPreview );
				m_action_MapPreview  = -1;
			}
			*/

			InputFeedbackManager.updateButtons(this);
			deactivateContext();
		}

		private function handleMapContext(event:MapContextEvent):void
		{			
			_pendingMapContext = event;
			removeEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false);
			addEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false, 0, true);
		}
		
		private function pendingMapContextUpdate(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false);
			
			if (_pendingMapContext)
			{
				if (!_pendingMapContext.active)
				{
					deactivateContext();
				}
				else
				{
					activateContext(_pendingMapContext);
				}
			}
		}
		
		private function deactivateContext():void
		{
			tooltipInstance.HideTooltip();
			m_trackableMappinTag = 0;
			m_selectedPinData = null;
			cleanUpContextButtons();
			updateGotoPinButton();
			InputFeedbackManager.updateButtons(this);
		}
		
		private function cleanUpContextButtons():void
		{
			if (m_action_QuestTrack > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_QuestTrack);
				m_action_QuestTrack = -1;
			}
			if (m_action_FastTravel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_FastTravel);
				m_action_FastTravel = -1;
			}
			if (m_action_OpenRegion > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_OpenRegion);
				m_action_OpenRegion = -1;
			}
		}

		private function activateContext(event:MapContextEvent):void
		{
			try
			{
				tooltipInstance.ShowTooltip(event.tooltipData, isArabicAligmentMode);
				tooltipInstance.y = TOOLTIP_POS - tooltipInstance.actualHeight;
				m_selectedPinData = event.mapppinData;
				
				cleanUpContextButtons();
				
				//
				//trace("Minimap ##### activateContext" );
				//
				if (event.tooltipData && event.tooltipData.openRegion)
				{
					if (m_action_OpenRegion < 0)
					{
						m_action_OpenRegion = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_map_open");
					}
				}
				else
				if (event.mapppinData.isFastTravel )
				{
					if (m_action_FastTravel < 0)
					{
						m_action_FastTravel = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_map_fasttravel");
					}
				}
				else
				{
					m_trackableMappinTag = 0;
					if (m_action_QuestTrack > 0)
					{
						InputFeedbackManager.removeButton(this, m_action_QuestTrack);
						m_action_QuestTrack = -1;
					}
				}
				updateGotoPinButton();
				
				InputFeedbackManager.updateButtons(this);
			}
			catch (er:Error)
			{
				updateGotoPinButton();
				InputFeedbackManager.updateButtons(this);
			}
		}
		
		private function updateGotoPinButton():void
		{
			if ( IsLayer( LAYER_HUB ) && !MapMenu.IsUsingGamepad() )
			{
				// that depends on mouse cursor position
				return;
			}
			
			ShowGotoPlayerButton(false);
			ShowGotoQuestButton(false);
			
			if ( !IsLayer( LAYER_HUB ) )
			{
				return;	
			}

			mcHubMap.UpdateGotoButton( true );
		}
		
		private function ShowGotoPlayerButton(show:Boolean):void
		{
			//
			//trace("Minimap ##### ShowGotoPlayerButton " + show );
			//
			if (show && m_action_GotoPlayer < 0)
			{
				m_action_GotoPlayer = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.TAB, "panel_map_goto_player_pin");
			}
			else
			if (!show && m_action_GotoPlayer > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_GotoPlayer);
				m_action_GotoPlayer = -1;
			}
		}
		
		private function ShowGotoQuestButton(show:Boolean):void
		{
			//
			//trace("Minimap ##### ShowGotoQuestButton " + show );
			//
			if (show && m_action_GotoQuest < 0)
			{
				m_action_GotoQuest = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.TAB, "panel_map_goto_quest_pin");
			}
			else
			if (!show && m_action_GotoQuest > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_GotoQuest);
				m_action_GotoQuest = -1;
			}
		}
		
		private function IsLayer( layer : int )
		{
			return m_currentLayer == layer;
		}

		private function UpdateLayers( layer : int, force : Boolean = false )
		{
			//
			//trace("Minimap UpdateLayers --------------------------------------------------------------------------");
			//

			if ( layer < LAYER_UNIVERSE || layer > LAYER_INTERIOR )
			{
				throw(new Error( "Minimap Wrong layer FFS! (" + layer + ")" ));
				return;
			}
			if ( m_currentLayer == layer )
			{
				return;
			}
			deactivateContext();
			m_currentLayer = layer;

			mcUniverseMap.Enable( m_currentLayer == LAYER_UNIVERSE, force );
			mcHubMap.Enable(      m_currentLayer == LAYER_HUB,      force );
			mcInteriorMap.Enable( m_currentLayer == LAYER_INTERIOR, force );
			
			PinPointersManager.getInstance().disabled = m_currentLayer != LAYER_HUB;
		}

		override public function handleInput( event:InputEvent ):void
		{
			
			if ( m_userPinPanelShown )
			{
				userPinPanel.handleInput( event );
				event.handled = true;
				event.stopImmediatePropagation();
				return;
			}
			
			if ( event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyDown : Boolean  = (details.value == InputValue.KEY_DOWN );
			var keyUp : Boolean    = (details.value == InputValue.KEY_UP );
            var keyPress : Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);


			// ---------------------- States

			if ( event.handled || m_blockNavigation )
			{
				return;
			}

			// -------------------- Navigation

			if ( mcHubMapPinPanel.visible )
			{
				mcHubMapPinPanel.handleInput( event );
			}
			if ( mcHubMapQuestTracker.visible )
			{
				mcHubMapQuestTracker.handleInput( event );
			}

			switch ( details.code )
			{
				case KeyCode.SPACE:
					if ( keyDown )
					{
						if ( IsLayer( LAYER_UNIVERSE ) )
						{
							if ( mcUniverseMap.CanProcessInput() )
							{
								switchMap( true );
							}
						}
						else if ( IsLayer( LAYER_HUB ) )
						{
							if ( mcHubMap.CanProcessInput() )
							{
								switchMap();
							}
						}
					}
					break;
				case KeyCode.E:	
				case KeyCode.ENTER:
				case KeyCode.PAD_A_CROSS:
					if ( keyDown )
					{
						if ( IsLayer( LAYER_UNIVERSE ) && keyDown)
						{
							if ( mcUniverseMap.CanProcessInput() )
							{
								switchMap();
							}
						}
						else if ( IsLayer( LAYER_HUB ) && m_trackableMappinTag)
						{
							if ( mcHubMap.CanProcessInput() )
							{
								dispatchEvent(new GameEvent(GameEvent.CALL, "OnTrackQuest", [m_trackableMappinTag]));
							}
						}
					}
					break;

				case KeyCode.PAD_Y_TRIANGLE:
					if (keyDown)
					{
						if ( IsLayer( LAYER_UNIVERSE ) )
						{
							if ( mcUniverseMap.CanProcessInput() )
							{
								switchMap( true );
							}
						}
						else if ( IsLayer( LAYER_HUB ) )
						{
							if ( mcHubMap.CanProcessInput() )
							{
								switchMap();
							}
						}
					}
					break;

				case KeyCode.PAD_RIGHT_STICK_DOWN:

					// go from current hub to universe, but only if there is min zoom
					/*
					if ( IsLayer( LAYER_HUB ) )
					{
						if ( mcHubMap.IsMinZoom() && keyDown)
						{
							if ( mcHubMap.CanProcessInput() )
							{
								switchMap();
							}
						}
					}
					*/
					break;

				case KeyCode.PAD_RIGHT_STICK_UP:

					// go from universe to specific hub
					if ( IsLayer( LAYER_UNIVERSE ) && keyDown)
					{
						if ( mcUniverseMap.CanProcessInput() )
						{
							switchMap();
						}
					}
					break;
			}

			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				if (handler.enabled)
				{
					handler.handleInput( event );
				}
			}
		}
		
		override public function handleDebugInput( event : InputEvent )
		{
			if ( event.handled )
			{
				return;
			}
			
			if ( !mcHubMap.CanProcessInput() )
			{
				return;
			}
			
            var details 	: InputDetails 	= event.details;
			
			switch( details.code )
			{
				//case KeyCode.PAD_DIGIT_UP:
				case KeyCode.NUMPAD_4:
					if ( details.value == InputValue.KEY_UP && IsLayer( LAYER_HUB ) )
					{
						if ( m_selectedPinData )
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDebugTeleportToHighlightedMappin', [ m_selectedPinData.posX , m_selectedPinData.posY ] ) );
							event.handled = true;
						}
					}
					break;
					
				default:
					return;
			}
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
			if (m_loadingState)
			{
				event.handled = true;
				event.stopImmediatePropagation();
				return;
			}
			super.handleInputNavigate(event);
		}

		protected function switchMap( goToLastHub : Boolean = false )
		{
			//
			//trace("Minimap ##### switchMap " );
			//
			if ( IsLayer( LAYER_HUB ) )
			{
				showGotoWorldHint(false);
				UpdateLayers( LAYER_UNIVERSE );
				mcUniverseMap.centerCurrentArea(false);
				
				trace( 'Minimap @@@@@ switchMap' );
				ForceMouseMove();
				mcUniverseMap.updateAreaSelection( true );
				
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnSwitchToWorldMap'));
	
				if (m_action_Zoom > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_Zoom);
					m_action_Zoom = -1;
				}
				if (m_action_NavigateFilters > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_NavigateFilters);
					m_action_NavigateFilters = -1;
				}
				if (m_action_PlaceMappin > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
					m_action_PlaceMappin = -1;
				}
				if (m_action_MappinPanel > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_MappinPanel);
					m_action_MappinPanel = -1;
				}
				/*
				if (m_action_MapPreview  > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_MapPreview );
					m_action_MapPreview  = -1;
				}
				*/

				/*
				if (m_action_OpenWorldMap > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_OpenWorldMap);
					m_action_OpenWorldMap = -1;
				}
				*/
			}
			else
			{
				var update : Boolean = false;
				
				if ( goToLastHub )
				{
					update = mcUniverseMap.GoToHubMap( _lastVisitedHub );
				}
				else
				{
					update = mcUniverseMap.GoToSelectedHubMap();
				}

				if ( update )
				{					
					UpdateLayers( LAYER_HUB );
					
					if (m_action_Zoom < 0)
					{
						m_action_Zoom =			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_SCROLL,	1002,					"panel_button_common_zoom"); // replace 1002 with MOUSE_SCROLL
					}
					if ( m_action_NavigateFilters < 0 )
					{
						m_action_NavigateFilters = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_ALL, -1, "panel_map_navigate_filters");
					}
					if (m_action_PlaceMappin < 0)
					{
						m_action_PlaceMappin =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X,				KeyCode.RIGHT_MOUSE,	"panel_map_place_waypoint");
					}
					if (m_action_MappinPanel < 0)
					{
						m_action_MappinPanel =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X,				KeyCode.RIGHT_MOUSE,	"panel_map_open_waypoint_panel", true);
					}
					/*
					if (m_action_MapPreview  < 0)
					{
						if ( mcHubMap.mcHubMapPreview.CanBeToggled() )
						{
							m_action_MapPreview  =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R2,			KeyCode.Z,				"panel_map_toggle_preview" );
						}
					}
					*/
					
					/*
					if (m_action_OpenWorldMap < 0)
					{
						m_action_OpenWorldMap =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_Y,		-1,						"panel_map_title_worldmap");
					}
					*/
					InputFeedbackManager.updateButtons(this);
				}
			}
			InputFeedbackManager.updateButtons(this);
			updateGotoPinButton();
			updateKeyboardButtons();
		}
		
		public function OnMouseDoubleDown( event : MouseEvent )
		{
			if ( m_blockNavigation )
			{
				return;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				if ( IsLayer( LAYER_UNIVERSE ) )
				{
					if ( mcUniverseMap.CanProcessInput() )
					{
						switchMap();
					}
				}
				else if ( IsLayer( LAYER_HUB ) )
				{
					if ( mcHubMap.CanProcessInput() )
					{
						mcHubMap.OnMouseDoubleDown( eventEx.buttonIdx, new Point( event.stageX, event.stageY ) );
					}
				}
			}
		}

		
		public function OnMouseDown( event : MouseEvent )
		{
			mcWorldMapButton.btnWorldMap.mouseEnabled  = false;
			mcWorldMapButton.btnWorldMap.mouseChildren = false;

			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );

			if ( m_blockNavigation )
			{
				return;
			}

			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx )
			{
				if ( eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					m_isLMBDown = true;
					m_lastLMBPos.x = event.stageX;
					m_lastLMBPos.y = event.stageY;
					
					mcHubMapQuestTracker.enableMouse( false );
					mcHubMapPinPanel.enableMouse( false );
					mcWorldMapButton.mouseEnabled = false;
					mcWorldMapButton.mouseChildren = false;
				}
				else if ( eventEx.buttonIdx == MouseEventEx.MIDDLE_BUTTON )
				{
					if ( IsLayer( LAYER_HUB ) )
					{
						if ( mcHubMap.CanProcessInput() )
						{
							switchMap();
							return;
						}
					}
					else if ( IsLayer( LAYER_UNIVERSE ) )
					{
						if ( mcUniverseMap.CanProcessInput() )
						{
							switchMap( true );
							return;
						}
					}
				}
			}

			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseDown( eventEx.buttonIdx, m_currGlobalMousePos );
			}
		}

		public function OnMouseUp( event : MouseEvent )
		{
			mcWorldMapButton.btnWorldMap.mouseEnabled  = true;
			mcWorldMapButton.btnWorldMap.mouseChildren = true;

			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );

			if ( m_blockNavigation )
			{
				return;
			}

			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				m_isLMBDown = false;

				mcHubMapQuestTracker.enableMouse( true );
				mcHubMapPinPanel.enableMouse( true );
				mcWorldMapButton.mouseEnabled = true;
				mcWorldMapButton.mouseChildren = true;
			}
			
			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseUp( eventEx.buttonIdx, m_currGlobalMousePos );
			}
		}

		public function OnMouseMove( event : MouseEvent )
		{
			//
			//trace( "Minimap OnMouseMove!!!!!!" );
			//
			
			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );
			
			if ( IsLayer( LAYER_UNIVERSE ) )
			{
				mcUniverseMap.OnMouseMove( m_currGlobalMousePos );
			}
			else if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseMove( m_currGlobalMousePos );
				if ( mcHubMapPinPanel.visible )
				{
					mcHubMapPinPanel.OnMouseMoveFromParent( m_currGlobalMousePos );
					mcHubMapQuestTracker.OnMouseMoveFromParent( m_currGlobalMousePos );
				}
			}

			if ( m_blockNavigation )
			{
				return;
			}
			
			if ( m_isLMBDown )
			{
				var deltaX = event.stageX - m_lastLMBPos.x;
				var deltaY = event.stageY - m_lastLMBPos.y;
				m_lastLMBPos.x = event.stageX;
				m_lastLMBPos.y = event.stageY;
	
				if ( IsLayer( LAYER_UNIVERSE ) )
				{
					if ( mcUniverseMap.CanProcessInput() )
					{
						mcUniverseMap.ScrollMap( deltaX, deltaY );
					}
				}
				else if ( IsLayer( LAYER_HUB ) )
				{
					//
					//trace( "Minimap OnMouseMove " + delta.x + " " + delta.y );
					//
					if ( mcHubMap.CanProcessInput() )
					{
						mcHubMap.scrollMap( deltaX, deltaY );
					}
				}
			}
		}
		
		public function OnMouseWheel( event : MouseEvent )
		{
			if ( m_blockNavigation )
			{
				return;
			}
			
			if ( IsLayer( LAYER_UNIVERSE ) )
			{
				// nothing
			}
			else if ( IsLayer( LAYER_HUB ) )
			{
				if ( mcHubMap.CanProcessInput() )
				{
					mcHubMap.zoomMap( event.delta > 0 );
				}
			}
		}
		
		public function OnUserPinBackgroundMouseDown( event : MouseEvent )
		{
			enableUserPinPanel( false );
		}

		public function OnUserPinBackgroundMouseMove( event : MouseEvent )
		{
			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );
		}
		
		private function updateMouseCoords( stageX : Number, stageY : Number, localX : Number, localY : Number )
		{
			m_currGlobalMousePos.x = stageX;
			m_currGlobalMousePos.y = stageY;
			m_currLocalMousePos.x  = localX;
			m_currLocalMousePos.y  = localY;
		}

		private function ForceMouseMove()
		{
			if ( !m_isUsingGamepad )
			{
				mcUniverseMap.OnMouseMove( m_currGlobalMousePos );
			}
		}
		
		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}

		override protected function get menuName():String
		{
			return "MapMenu";
		}

		public function clearCategoryPanel()
		{
			mcHubMapPinPanel.clearCategoryPanel();
		}
		
		public function initializeCategoryPanel()
		{
			mcHubMapPinPanel.initializeCategoryPanel();			
			// NGE - new "Default" category
			dispatchEvent( new GameEvent( GameEvent.CALL, 'SetInitialFilters' ) );
		}
		
		public function updateCategoryPanel()
		{
			mcHubMapPinPanel.updateCategoryPanel();
		}
		
		public function enableCategoryPanel( value : Boolean )
		{
			mcHubMapPinPanel.visible = value;
		}

		public function enableQuestTracker( value : Boolean )
		{
			if ( value )
			{
				if ( !mcHubMapQuestTracker.canBeShown() )
				{
					return;
				}
			}
			mcHubMapQuestTracker.visible = value;
		}
		
		public function addPinToCategoryPanel( pinData : StaticMapPinData )
		{
			mcHubMapPinPanel.addPinInstance( pinData );
		}

		public function removePinFromCategoryPanel( id : uint )
		{
			mcHubMapPinPanel.removePinInstance( id );
			
			updateCategoryPanel();
		}

		public function centerOnWorldPosition( worldPos : Point, animate : Boolean = false )
		{
			mcHubMap.centerOnWorldPosition( worldPos, animate );
		}
		
		public function showPinsFromCategory( pins : Array, showUserPins : Boolean, showFastTravelPins : Boolean, showQuestPins : Boolean, disabledPins : Dictionary, onStart : Boolean )
		{
			mcHubMap.showPinsFromCategory( pins, showUserPins, showFastTravelPins, showQuestPins, disabledPins, onStart );
		}

		public function isAnimationRunning() : Boolean
		{
			return mcHubMap.isAnimationRunning();
		}
		
		protected function debugData():void
		{
			//
		}

		public function __UpdateDebugInfo()
		{
			if ( tfDebugInfo )
			{
				var info : String;
				info =	"Current LOD: " + 		m_debugInfo._currentLod + " (" + m_debugInfo._minLod + ", " + m_debugInfo._maxLod + ")" +
						"<BR>Zoom: " +			m_debugInfo._zoom.toFixed( 2 ) +
						"<BR>Visible tiles: " + m_debugInfo._visibleTiles +
						"<BR>Scroll posX: " +	m_debugInfo._scrollX.toFixed( 2 ) +
						"<BR>Scroll posY: " +	m_debugInfo._scrollY.toFixed( 2 ) +
						"<BR>Center: " +		m_debugInfo._pointedTileX +    " " + m_debugInfo._pointedTileY +
						"<BR>Min tile: " +		m_debugInfo._pointedMinTileX + " " + m_debugInfo._pointedMinTileY +
						"<BR>Max tile: " +		m_debugInfo._pointedMaxTileX + " " + m_debugInfo._pointedMaxTileY +
						"<BR>";
				var zoomBoundaries : Vector.< ZoomBoundary > = mcHubMap.GetZoomBoundaries();
				if ( zoomBoundaries )
				{
					for ( var i = 0; i < zoomBoundaries.length; ++i )
					{
						if ( zoomBoundaries[ i ].IsValid() )
						{
							info +=	"<BR>LOD" + ( i + 1 ) + " - (" + zoomBoundaries[ i ]._min.toFixed( 2 ) + ", " + zoomBoundaries[ i ]._max.toFixed( 2 ) + ")";
						}
					}
				}
				info +=	"<BR>";
				
				for ( var lod = m_debugInfo._minLod; lod <= m_debugInfo._maxLod; ++lod )
				{
					if ( lod == 1 )
					{
						info +=	lod + ": " + m_debugInfo._lod1Visible + " " + m_debugInfo._lod1Invisible + "<BR>";
					}
					if ( lod == 2 )
					{
						info +=	lod + ": " + m_debugInfo._lod2Visible + " " + m_debugInfo._lod2Invisible + "<BR>";
					}
					if ( lod == 3 )
					{
						info +=	lod + ": " + m_debugInfo._lod3Visible + " " + m_debugInfo._lod3Invisible + "<BR>";
					}
					if ( lod == 4 )
					{
						info +=	lod + ": " + m_debugInfo._lod4Visible + " " + m_debugInfo._lod4Invisible + "<BR>";
					}
				}

				tfDebugInfo.htmlText =  info;
			}
		}

		// NGE
		protected function handleCustomHubs(value : Object)
		{
			this.mcUniverseMap.mcUniverseMapContainer.addCustomHubs(value as Array);
		}
		// NGE
	}
}

import red.game.witcher3.menus.worldmap.MapMenu;
class MapDebugInfo
{
	public var __mapMenu	   : MapMenu;

	public var _currentLod		: int = -1;
	public var _minLod			: int = -1;
	public var _maxLod			: int = -1;
	public var _zoom			: Number;
	public var _visibleTiles	: int = 0;
	public var _scrollX			: Number;
	public var _scrollY			: Number;
	public var _pointedTileX	: int = -1;
	public var _pointedTileY	: int = -1;
	public var _pointedMinTileX	: int = -1;
	public var _pointedMinTileY	: int = -1;
	public var _pointedMaxTileX	: int = -1;
	public var _pointedMaxTileY	: int = -1;
	
	public var _lod1Visible     : int = 0;
	public var _lod1Invisible   : int = 0;
	public var _lod2Visible     : int = 0;
	public var _lod2Invisible   : int = 0;
	public var _lod3Visible     : int = 0;
	public var _lod3Invisible   : int = 0;
	public var _lod4Visible     : int = 0;
	public var _lod4Invisible   : int = 0;

	public function __DebugInfo_SetCurrentLod( lod : int )
	{
		_currentLod = lod;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetMinMaxLod( minLod : int, maxLod : int )
	{
		_minLod = minLod;
		_maxLod = maxLod;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetZoom( zoom : Number )
	{
		_zoom = zoom;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetScroll( sx : Number, sy : Number )
	{
		_scrollX = -sx;
		_scrollY = -sy;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetPointedTile( ptx : int, pty : int )
	{
		_pointedTileX = ptx;
		_pointedTileY = pty;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetVisibleAndPointedTiles( tiles : int, mintx : int, minty : int, maxtx : int, maxty : int )
	{
		_visibleTiles = tiles;
		_pointedMinTileX = mintx;
		_pointedMinTileY = minty;
		_pointedMaxTileX = maxtx;
		_pointedMaxTileY = maxty;

		__mapMenu.__UpdateDebugInfo();
	}
	
	public function __DebugInfo_SetTileStats( lod : int, tilesVisible : int, tilesInvisible : int )
	{
		if ( lod == 1 )
		{
			_lod1Visible     = tilesVisible;
			_lod1Invisible   = tilesInvisible;
		}
		else if ( lod == 2 )
		{
			_lod2Visible     = tilesVisible;
			_lod2Invisible   = tilesInvisible;
		}
		else if ( lod == 3 )
		{
			_lod3Visible     = tilesVisible;
			_lod3Invisible   = tilesInvisible;
		}
		else if ( lod == 4 )
		{
			_lod4Visible     = tilesVisible;
			_lod4Invisible   = tilesInvisible;
		}
	}
}
