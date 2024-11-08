package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Linear;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import scaleform.clik.constants.WrappingMode;
	import scaleform.clik.events.ListEvent;
	import flash.geom.Rectangle;
	import scaleform.gfx.MouseEventEx;

	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.data.StaticMapPinData;
	import scaleform.clik.interfaces.IListItemRenderer;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.worldmap.data.CategoryData;
	import red.game.witcher3.menus.worldmap.data.CategoryPinData;
	import red.game.witcher3.menus.worldmap.data.CategoryPinInstanceData;
	import red.core.events.GameEvent;

	public class HubMapPinPanel extends UIComponent
	{
		public var mcHubMapPinCategoryButton : MovieClip;
		public var mcHubMapPinCategoryList : W3ScrollingList;
		public var mcHubMapPinArrowUp : MovieClip;
		public var mcHubMapPinArrowDown : MovieClip;
		
		public var funcCenterOnWorldPosition : Function;
		public var funcShowPinsFromCategory : Function;
		public var funcIsAnimationRunning : Function;
		
		private var _renderersListShort : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>;
		private var _renderersListLong  : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>;
		private var _expandedList : Boolean = false;
		
		private var _categories : Array = new Array;
		private var _currentCategoryIndex : int;
		private var _disabledPins : Dictionary = new Dictionary();
		
		private var _allowShowingCategoryButtonSelection : Boolean = false;
		
		private const SHORT_LIST_COUNT : int = 6;
		private const LONG_LIST_COUNT : int = 18;
		
		public static const ALL_PINS_CATEGORY			: String = "All";
		public static const ROADSIGN_PIN_TRANSLATION 	: String = "[[map_location_roadsign]]";
		public static const HARBOR_PIN_TRANSLATION		: String = "[[map_location_harbor]]";
		//public static const HERB_PIN_TRANSLATION		: String = "[[map_location_herb]]";
		public static const QUEST_PIN_TYPE    			: String = "StoryQuest";
		public static const QUEST_PIN_TRANSLATION 		: String = "[[map_location_quest]]";
		public static const USER_PIN_TYPE				: String = "User1";
		public static const USER_PIN_TRANSLATION		: String = "[[map_location_user]]";
		
		private const USER_PIN_PRIORITY			: int    = 1;

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//
		//
		
		private function __DEBUG_cleanAllCategories()
		{
			_categories.length = 0;
		}

		private function __DEBUG_addCategory( name : String ) : CategoryData
		{
			var i : int;
			for ( i = 0; i < _categories.length; ++i )
			{
				if ( name == _categories[ i ]._name )
				{
					return _categories[ i ];
				}
			}
			
			var priority			: int = 9999;
			var showUserPins		: Boolean = true;
			var showFastTravelPins	: Boolean = true;
			var showQuestPins		: Boolean = true;
			
			var categoryDefinition : CategoryDefinition = _categoryDefinitions[ name ];
			if ( categoryDefinition )
			{
				priority 			= categoryDefinition._priority;
				showUserPins		= categoryDefinition._showUserPins;
				showFastTravelPins	= categoryDefinition._showFastTravelPins;
				showQuestPins		= categoryDefinition._showQuestPins;
			}

			_categories[ _categories.length ] = new CategoryData( name, priority, showUserPins, showFastTravelPins, showQuestPins );
			return _categories[ _categories.length - 1 ];
		}

		private function __DEBUG_addPin( category : CategoryData, name : String, translation : String, priority : int ) : CategoryPinData
		{
			var i : int;
			for ( i = 0; i < category._pins.length; ++i )
			{
				if ( name == category._pins[ i ]._name )
				{
					return category._pins[ i ];
				}
			}
			category._pins[ category._pins.length ] = new CategoryPinData( name, translation, priority );
			return category._pins[ category._pins.length - 1 ];
		}

		private function __DEBUG_addInstance( pin : CategoryPinData, id : uint, worldPosition : Point, distance : Number = 0 ) : CategoryPinInstanceData
		{
			pin._instances[ pin._instances.length ] = new CategoryPinInstanceData( id, worldPosition, distance );
			return pin._instances[ pin._instances.length - 1 ];
		}
		
		//
		//
		//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		public function HubMapPinPanel()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			// NGE - new "Default" category
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.set.index', [ updateCurrentCategoryIndex ] ) );
			// NGE - new "Default" category

			initializeRenderers();
			updateRenderersVisibility();
			
			//__DEBUG_fillData();

			//mcHubMapPinCategoryList.selectOnOver = true;
			//mcHubMapPinCategoryList.focused = 1;
			//mcHubMapPinCategoryList.focusable = false;
			mcHubMapPinCategoryList.bSkipFocusCheck = true;
			
			initializeCategoryPanel( true );
			updateCategoryButtonSelection();

			addEventListener( MouseEvent.MOUSE_WHEEL,		OnMouseWheel,		false, 0, true );
			mcHubMapPinCategoryList.addEventListener( MouseEvent.MOUSE_OVER,		OnMouseOver,		false, 0, true );
			//mcHubMapPinCategoryList.addEventListener( MouseEvent.MOUSE_OUT,			OnMouseOut,			false, 0, true );
			mcHubMapPinCategoryList.addEventListener( ListEvent.ITEM_ROLL_OVER,		OnRollOver,			false, 0, true );
			//mcHubMapPinCategoryList.addEventListener( ListEvent.ITEM_ROLL_OUT,		OnRollOut,			false, 0, true );

			mcHubMapPinCategoryList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
			mcHubMapPinCategoryButton.mcArrowLeft.addEventListener(  MouseEvent.MOUSE_DOWN, handleCaterogyArrowLeft,	 false, 0, true );
			mcHubMapPinCategoryButton.mcArrowRight.addEventListener( MouseEvent.MOUSE_DOWN, handleCaterogyArrowRight, false, 0, true );
			
			mcHubMapPinArrowUp.addEventListener(   MouseEvent.MOUSE_DOWN, handleArrowUp,   false, 0, true );
			mcHubMapPinArrowDown.addEventListener( MouseEvent.MOUSE_DOWN, handleArrowDown, false, 0, true );

			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'worldmap.global.pins.disabled', 		[ setDisabledPins ] ) );
		}
		
		// NGE - new "Default" category
		// This remembers the last category you had selected
		public function updateCurrentCategoryIndex(value : int)
		{
			_currentCategoryIndex = value;
			selectSpecificCategoryPanel(value);
		}
		
		public function selectSpecificCategoryPanel(value : int)
		{
			var category : CategoryData;
			
			_expandedList = false;

			addMandatoryContents();
			sortContents();

			
			if ( _categories.length > 0 )
			{								
				category = _categories[ value ];

				mcHubMapPinCategoryList.dataProvider = new DataProvider( category._pins );
				mcHubMapPinCategoryList.validateNow(); // needed for resizeHitArea()
				
				updatePinsFromCategory( category, false );
			}
			else
			{
				_currentCategoryIndex = -1;
			}
			updateCategoryButton();
			updateArrowButtons();
			resizeHitArea();
			

			updateCategoryButton();
			updateArrowButtons();
		}
		// NGE - new "Default" category
		
		public function OnMouseWheel( event : MouseEvent )
		{
			mcHubMapPinCategoryList.invalidateData();
			mcHubMapPinCategoryList.validateNow();
			
			updateArrowButtons();
			resizeHitArea();
		}
		
		public function enableMouse( enable : Boolean )
		{
			mouseEnabled = enable;
			mouseChildren = enable;
		}
		
		public function OnMouseOver( event : MouseEvent )
		{
			if ( mouseEnabled )
			{
				if ( expandList( true ) )
				{
					resizeHitArea();
				}
			}
		}

		/*
		public function OnMouseOut( event : MouseEvent )
		{
		}
		*/
		
		public function OnRollOver( event : ListEvent )
		{
			if ( mouseEnabled )
			{
				if ( expandList( true ) )
				{
					resizeHitArea();
				}
			}
		}
		
		/*
		public function OnRollOut( event : ListEvent )
		{
		}
		*/
		
		public function OnMouseMoveFromParent(  globalMousePos : Point )
		{
			if ( mouseEnabled )
			{
				if ( expandList( isGlobalPointInsideBounds( globalMousePos ) ) )
				{
					resizeHitArea();
				}
			}
		}

		private function setDisabledPins( gameData : Object, index : int )
		{
			var array : Array;
			var i : int;
			var type : Object;
			var pinType : String;
			
			if ( index > -1 )
			{
				return;
			}

			array = gameData as Array;
			if ( array )
			{
				for ( i = 0; i < array.length; ++i )
				{
					type = array[ i ];
					if ( type )
					{
						pinType = type.pinType;
						
						if ( pinType && pinType.length > 0 )
						{
							_disabledPins[ pinType ] = pinType;
						}
					}
				}
			}
		}

		private function isGlobalPointInsideBounds( globalMousePos : Point ) : Boolean
		{
			var globalBounds : Rectangle = mcHubMapPinCategoryList.getBounds( stage );
			
			return globalMousePos.x > globalBounds.left &&
				   globalMousePos.x < globalBounds.right &&
				   globalMousePos.y > globalBounds.top &&
				   globalMousePos.y < globalBounds.bottom;
			
		}

		protected function handleIndexChanged(event:ListEvent):void
		{
			updateCategoryButtonSelection();
			resizeHitArea();
			if ( event.index != -1 )
			{
				if ( !InputManager.getInstance().isGamepad() )
				{
					centerOnPin();
				}
			}
		}

		public function handleCaterogyArrowLeft( event : MouseEventEx )
		{
			if ( !funcIsAnimationRunning() )
			{
				if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					selectPrevNextCategory( -1 );
					// since it's mouse, deselect list
					mcHubMapPinCategoryList.selectedIndex = -1;
				}
			}
		}
		
		public function handleCaterogyArrowRight( event : MouseEventEx )
		{
			if ( !funcIsAnimationRunning() )
			{
				if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					selectPrevNextCategory( 1 );
					// since it's mouse, deselect list
					mcHubMapPinCategoryList.selectedIndex = -1;
				}
			}
		}

		public function handleArrowUp( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				mcHubMapPinCategoryList.scrollPosition++;
				mcHubMapPinCategoryList.validateNow();
			
				updateArrowButtons();
				resizeHitArea();
			}
		}
		
		public function handleArrowDown( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				mcHubMapPinCategoryList.scrollPosition--;
				mcHubMapPinCategoryList.validateNow();

				updateArrowButtons();
				resizeHitArea();
			}
		}
		
		private function initializeRenderers()
		{
			var i : int;
			var renderer : HubMapPinCategoryItemRenderer;
		
			for ( i = 1; i <= LONG_LIST_COUNT; ++i )
			{
				renderer = getChildByName( "mcHubMapPinCategoryItem" + i ) as HubMapPinCategoryItemRenderer;
				if ( renderer )
				{
					renderer.funcChangePinIndex = changePinIndex;
					renderer.funcTogglePin = togglePin;
					renderer.funcIsPinDisabled = isPinDisabled;
					
					if ( i <= SHORT_LIST_COUNT )
					{
						_renderersListShort.push( renderer );
					}
					else
					{
						renderer.visible = false;
					}
					_renderersListLong.push( renderer );
				}
			}
			
			mcHubMapPinCategoryList.itemRendererList = _renderersListShort;
		}

		public function clearCategoryPanel()
		{
			__DEBUG_cleanAllCategories();
		}
		
		public function initializeCategoryPanel( onStart : Boolean = false )
		{
			//trace("Minimap1 ------------- initializeCategoryPanel " + _categories.length );
			
			_expandedList = false;
			if ( _categories.length > 0 )
			{
				//_currentCategoryIndex = 0;
			}
			
			addMandatoryContents();
			sortContents();

			// NGE - new "Default" category
			//selectPrevNextCategory( 0, onStart );
			var category : CategoryData;

			if ( _categories.length > 0 )
			{
				_currentCategoryIndex = ( _currentCategoryIndex + _categories.length ) % _categories.length;
				category = _categories[ _currentCategoryIndex ];

				mcHubMapPinCategoryList.dataProvider = new DataProvider( category._pins );
				mcHubMapPinCategoryList.validateNow(); // needed for resizeHitArea()
				
				updatePinsFromCategory( category, onStart );
			}
			else
			{
				_currentCategoryIndex = -1;
			}
			updateCategoryButton();
			updateArrowButtons();
			resizeHitArea();
			// NGE - new "Default" category
			
			updateCategoryButton();
			updateArrowButtons();
		}

		public function updateCategoryPanel()
		{
			if ( _currentCategoryIndex > -1 )
			{
				var category : CategoryData = _categories[ _currentCategoryIndex ];

				var renderers : Vector.< IListItemRenderer > = mcHubMapPinCategoryList.getRenderers();
				var i : int;
			
				for ( i = 0; i < renderers.length; ++i )
				{
					var index : int = i + mcHubMapPinCategoryList.scrollPosition;
					if ( index < category._pins.length )
					{
						var pin : CategoryPinData = category._pins[ index ];

						var item : HubMapPinCategoryItemRenderer = renderers[ i ] as HubMapPinCategoryItemRenderer;
						if ( item )
						{
							item.setCounter( pin._index, pin._instances.length );
						}
					}
				}
			}
			
			mcHubMapPinCategoryList.selectedIndex = -1;
		}
		
		private function addMandatoryContents()
		{
			var currCategory : CategoryData;
			var i : int;

			if ( _categories.length == 0 )
			{
				__DEBUG_addCategory( ALL_PINS_CATEGORY );
			}
			
			for ( i = 0; i < _categories.length; ++i )
			{
				currCategory = _categories[ i ] as CategoryData;
				__DEBUG_addPin( currCategory, USER_PIN_TYPE, USER_PIN_TRANSLATION, USER_PIN_PRIORITY );
			}
		}
			
		private function sortContents()
		{
			var i,j : int;
			var category : CategoryData;
			var pin : CategoryPinData;
			
			_categories.sortOn("_priority", Array.NUMERIC );
			
			for ( i = 0; i < _categories.length; ++i )
			{
				category = _categories[ i ] as CategoryData;
				
				category._pins.sortOn("_priority", Array.NUMERIC );
				
				for ( j = 0; j < category._pins.length; ++j )
				{
					pin = category._pins[ j ] as CategoryPinData;
					pin._instances.sortOn("_distance", Array.NUMERIC );
				}
			}
		}
		
		public function selectPrevNextCategory( dir : int, onStart : Boolean = false )
		{
			var category : CategoryData;

			if ( _categories.length > 0 )
			{
				_currentCategoryIndex = ( _currentCategoryIndex + dir + _categories.length ) % _categories.length;
				category = _categories[ _currentCategoryIndex ];

				mcHubMapPinCategoryList.dataProvider = new DataProvider( category._pins );
				mcHubMapPinCategoryList.validateNow(); // needed for resizeHitArea()
				
				updatePinsFromCategory( category, onStart );
			}
			else
			{
				_currentCategoryIndex = -1;
			}
			updateCategoryButton();
			updateArrowButtons();
			resizeHitArea();
			
			// NGE - new "Default" category
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnFiltersChanged', [_currentCategoryIndex] ) );
		}
		
		private function updatePinsFromCategory( category : CategoryData, onStart : Boolean )
		{
			if ( funcShowPinsFromCategory != null )
			{
				if ( _currentCategoryIndex == 0 )
				{
					// pass null to indicate there all pins should be visible
					funcShowPinsFromCategory( null, true, true, true, _disabledPins, onStart );
				}
				else
				{
					funcShowPinsFromCategory( category._pins, category._showUserPins, category._showFastTravelPins, category._showQuestPins, _disabledPins, onStart );
				}
			}
		}
		
		public function updateCategoryButtonSelection()
		{
			mcHubMapPinCategoryButton.mcSelection.visible = _allowShowingCategoryButtonSelection && ( mcHubMapPinCategoryList.selectedIndex == -1 );
		}
		
		public function updateCategoryButton()
		{
			if ( _currentCategoryIndex == -1 )
			{
				mcHubMapPinCategoryButton.tfCategoryName.text = "";
				mcHubMapPinCategoryButton.tfCategoryName.text = CommonUtils.toUpperCaseSafe(mcHubMapPinCategoryButton.tfCategoryName.text);
				
			}
			else
			{
				mcHubMapPinCategoryButton.tfCategoryName.text = "[[map_category_" + _categories[ _currentCategoryIndex ]._name + "]]";
				mcHubMapPinCategoryButton.tfCategoryName.text = CommonUtils.toUpperCaseSafe(mcHubMapPinCategoryButton.tfCategoryName.text);
				//mcHubMapPinCategoryButton.tfCategoryName.text = _categories[ _currentCategoryIndex ]._name;
			}
		}
		
		public function updateArrowButtons()
		{
			var pinCount : int = 0;
			if ( _currentCategoryIndex > -1 )
			{
				pinCount = _categories[_currentCategoryIndex]._pins.length;
			}
			
			//trace("Minimap1 ", mcHubMapPinCategoryList.TotalRenderers, mcHubMapPinCategoryList.scrollPosition, pinCount );
			
			mcHubMapPinArrowUp.visible   = mcHubMapPinCategoryList.TotalRenderers + mcHubMapPinCategoryList.scrollPosition < pinCount;
			mcHubMapPinArrowDown.visible = mcHubMapPinCategoryList.scrollPosition > 0;
		}

		override public function handleInput( event : InputEvent ) : void
		{
            var details : InputDetails = event.details;
            var keyDown : Boolean = ( details.value == InputValue.KEY_DOWN );
            var keyPress : Boolean = ( details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD );
            var keyUp : Boolean = ( details.value == InputValue.KEY_UP );
			
			if ( details.code == KeyCode.W ||
				 details.code == KeyCode.S ||
				 details.code == KeyCode.A ||
				 details.code == KeyCode.D )
			{
				// wsad is meant to scroll map, not filters
				return;
			}
			if ( details.code == 1000 )
			{
				expandList( false );
				resizeHitArea();
				resetSelection();
			}
			else if ( details.code >= KeyCode.PAD_DIGIT_UP && details.code <= KeyCode.PAD_DIGIT_RIGHT )
			{
				expandList( true );
				resizeHitArea();
			}

			// ignore released keys except left trigger (needed for showing/hiding pins in in item renderer)
			if ( !keyPress && details.code != KeyCode.PAD_LEFT_TRIGGER)
			{
				return;
			}

			// ignore up and down keys
			if ( details.code == KeyCode.UP || details.code == KeyCode.DOWN )
			{
				return;
			}

			var pinCount : int = 0;
			if ( _currentCategoryIndex > -1 )
			{
				pinCount = _categories[_currentCategoryIndex]._pins.length;
			}

			if ( ( details.code == KeyCode.PAD_DIGIT_DOWN && mcHubMapPinCategoryList.selectedIndex == -1 ) /*||
				 ( details.code == KeyCode.PAD_DIGIT_UP   && mcHubMapPinCategoryList.selectedIndex == pinCount - 1 )*/ )
			{
			}
			else
			{
				mcHubMapPinCategoryList.handleInput(event);
			}
			
			// ignore events that were already handled by list
			if (event.handled)
			{
				updateArrowButtons();
				return;
			}

            switch( details.code )
			{
				case KeyCode.PAD_DIGIT_UP:
					if ( mcHubMapPinCategoryList.selectedIndex > -1 )
					{
						resetSelection();
					}
					break;
				case KeyCode.PAD_DIGIT_DOWN:
					if ( mcHubMapPinCategoryList.selectedIndex == 0 )
					{
						mcHubMapPinCategoryList.selectedIndex = -1;
					}
					else
					{
						if ( pinCount > mcHubMapPinCategoryList.TotalRenderers )
						{
							// scroll up first
							mcHubMapPinCategoryList.scrollPosition = pinCount - mcHubMapPinCategoryList.TotalRenderers;
						}
						mcHubMapPinCategoryList.selectedIndex = pinCount - 1;
					}
					updateArrowButtons();
					break;
				case KeyCode.PAD_DIGIT_LEFT:
					if ( keyDown )
					{
						if ( !funcIsAnimationRunning() )
						{
							if ( mcHubMapPinCategoryList.selectedIndex == -1 )
							{
								selectPrevNextCategory( -1 );
							}
							else
							{
								changePinIndexForSelectedItem( -1 );
							}
						}
					}
					break;
				case KeyCode.PAD_DIGIT_RIGHT:
					if ( keyDown )
					{
						if ( !funcIsAnimationRunning() )
						{
							if ( mcHubMapPinCategoryList.selectedIndex == -1 )
							{
								selectPrevNextCategory( 1 );
							}
							else
							{
								changePinIndexForSelectedItem( 1 );
							}
						}
					}
					break;
			}
			
			super.handleInput( event );
		}
		
		private function expandList( expand : Boolean )
		{
			if ( _expandedList == expand )
			{
				return false;
			}
			
			_expandedList = expand;
			
			if ( _expandedList )
			{
				mcHubMapPinCategoryList.itemRendererList = _renderersListLong;
				mcHubMapPinCategoryList.invalidateData();
				mcHubMapPinCategoryList.validateNow();
			}
			else
			{
				mcHubMapPinCategoryList.itemRendererList = _renderersListShort;
			}
			
			updateArrowButtons();
			updateRenderersVisibility();
			
			return true;
		}
		
		private function resizeHitArea()
		{
			var left : Number = NaN;
			var right : Number = NaN;
			var top : Number = NaN;
			var bottom : Number = NaN;
			var bounds : Rectangle;
			
			if ( mcHubMapPinArrowUp.visible )
			{
				bounds = mcHubMapPinArrowUp.getBounds( this );
				if ( isNaN( top ) || top > bounds.top )
				{
					top = bounds.top;
				}
			}
			if ( mcHubMapPinArrowDown.visible )
			{
				bounds = mcHubMapPinArrowDown.getBounds( this );
				if ( isNaN( bottom ) || bottom < bounds.bottom )
				{
					bottom = bounds.bottom;
				}
			}

			if ( _currentCategoryIndex > -1 && _categories.length > 0 )
			{
				var category : CategoryData = _categories[ _currentCategoryIndex ];

				var renderers : Vector.< IListItemRenderer > = mcHubMapPinCategoryList.getRenderers();
				var i : int;
			
				for ( i = 0; i < renderers.length; ++i )
				{
					var index : int = i + mcHubMapPinCategoryList.scrollPosition;
					if ( index < category._pins.length )
					{
						var item : HubMapPinCategoryItemRenderer = renderers[ i ] as HubMapPinCategoryItemRenderer;
						if ( item )
						{
							bounds = item.getBounds( this );
							if ( isNaN( left ) || left > bounds.left )
							{
								left = bounds.left;
							}
							if ( isNaN( right ) || right < bounds.right )
							{
								right = bounds.right;
							}
							if ( isNaN( top ) || top > bounds.top )
							{
								top = bounds.top;
							}
							if ( isNaN( bottom ) || bottom < bounds.bottom )
							{
								bottom = bounds.bottom;
							}
						}
					}
				}
			}
	
			mcHubMapPinCategoryList.x = left;
			mcHubMapPinCategoryList.y = top;
			mcHubMapPinCategoryList.scaleX = ( ( right - left ) / 100 );
			mcHubMapPinCategoryList.scaleY = ( ( bottom - top ) / 100 );
		}

		private function resetSelection()
		{
			mcHubMapPinCategoryList.scrollPosition = 0;
			mcHubMapPinCategoryList.selectedIndex = -1;
			updateArrowButtons();
		}

		private function updateRenderersVisibility()
		{
			var i : int;
			var renderer : HubMapPinCategoryItemRenderer;

			for ( i = SHORT_LIST_COUNT + 1; i <= LONG_LIST_COUNT; ++i )
			{
				if ( _expandedList )
				{
					if ( _currentCategoryIndex > -1 )
					{
						if ( i - 1 >= _categories[ _currentCategoryIndex ]._pins.length )
						{
							break;
						}
					}
				}

				renderer = getChildByName( "mcHubMapPinCategoryItem" + i ) as HubMapPinCategoryItemRenderer;
				if ( renderer )
				{
					renderer.visible = _expandedList;
				}
			}
			
			if ( _expandedList )
			{
				renderer = getChildByName( "mcHubMapPinCategoryItem" + LONG_LIST_COUNT ) as HubMapPinCategoryItemRenderer;
			}
			else
			{
				renderer = getChildByName( "mcHubMapPinCategoryItem" + SHORT_LIST_COUNT ) as HubMapPinCategoryItemRenderer;
			}
			if ( renderer )
			{
				mcHubMapPinArrowUp.y = renderer.y;
			}
		}
		
		private function changePinIndexForSelectedItem( dir : int )
		{
			var item : HubMapPinCategoryItemRenderer;

			item = mcHubMapPinCategoryList.getRendererAt( mcHubMapPinCategoryList.selectedIndex, mcHubMapPinCategoryList.scrollPosition ) as HubMapPinCategoryItemRenderer;
			if ( item )
			{
				changePinIndex( item, dir );
			}
		}
		
		private function changePinIndex( item : HubMapPinCategoryItemRenderer, dir : int )
		{
			var category : CategoryData;
			var pin : CategoryPinData;
			var selectedItem : HubMapPinCategoryItemRenderer;

			if ( funcIsAnimationRunning() )
			{
				return;
			}

			selectedItem = mcHubMapPinCategoryList.getRendererAt( mcHubMapPinCategoryList.selectedIndex, mcHubMapPinCategoryList.scrollPosition ) as HubMapPinCategoryItemRenderer;
			
			if ( item != selectedItem )
			{
				// wait for next click until it gets selected
				return;
			}
			
			if ( !item )
			{
				return;
			}

			category = _categories[ _currentCategoryIndex ];
			if ( category )
			{
				pin = category._pins[ mcHubMapPinCategoryList.selectedIndex ];
				if ( pin )
				{
					pin._index = ( pin._index + dir + pin._instances.length ) % pin._instances.length;
					//if ( pin._index + dir >= 0 && pin._index + dir < pin._instances.length )
					{
						//pin._index += dir;
						item.setCounter( pin._index, pin._instances.length );
						
						centerOnPin();
					}
				}
			}
		}

		private function togglePin( pinName : String )
		{
			if ( isPinDisabled( pinName ) )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDisablePin', [ pinName, false ] ) );
				delete _disabledPins[ pinName ];
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDisablePin', [ pinName, true ] ) );
				_disabledPins[ pinName ] = pinName;
			}
			
			if ( _currentCategoryIndex > -1 )
			{
				updatePinsFromCategory( _categories[ _currentCategoryIndex ], false );
			}

			//__printDisabledPins();
		}
		
		private function isPinDisabled( pinName : String ) : Boolean
		{
			return _disabledPins.hasOwnProperty( pinName );
		}
		
		private function __printDisabledPins()
		{
			trace("Minimap1 -------------------------------" );
			for each ( var pinName : String in _disabledPins )
			{
				trace("Minimap1 ", pinName );
			}
		}
		
		private function centerOnPin()
		{
			var category : CategoryData;
			var pin      : CategoryPinData;
			var instance : CategoryPinInstanceData;
			
			category = _categories[ _currentCategoryIndex ];
			if ( category )
			{
				pin = category._pins[ mcHubMapPinCategoryList.selectedIndex ];
				if ( pin )
				{
					instance = pin._instances[ pin._index ];
					if ( instance )
					{
						if ( funcCenterOnWorldPosition != null )
						{
							funcCenterOnWorldPosition( instance._worldPosition, true );
						}
					}
				}
			}
		}
		
		public function addPinInstance( pinData : StaticMapPinData )
		{
			var currCategory : CategoryData;
			var currPin : CategoryPinData;

			if ( pinData.isPlayer || pinData.type == 'Herb' )
			{
				// always ignore player and herbs
				return;
			}
			else if ( pinData.isUserPin )
			{
				// add instance to all categories
				var i : int;

				for ( i = 0; i < _categories.length; ++i )
				{
					//trace("Minimap1 DISTANCE ", pinData.id, pinData.filteredType, "?", "?", pinData.distance );
					currCategory = _categories[ i ] as CategoryData;
					currPin      = __DEBUG_addPin( currCategory, USER_PIN_TYPE, USER_PIN_TRANSLATION, USER_PIN_PRIORITY );
								   __DEBUG_addInstance( currPin, pinData.id, new Point( pinData.posX, pinData.posY ), pinData.distance );
				}
			}
			else
			{
				var type				: String = pinData.filteredType;
				var translation			: String = pinData.label;
				var category			: String;
				var priority			: int = 999999;
				
				var pinTypeDef : PinTypeDefinition = _pinTypeDefinitions[ type ];
				if ( pinTypeDef )
				{
					category = pinTypeDef._category;
					priority = pinTypeDef._priority;
				}

				if ( pinData.isFastTravel )
				{
					if ( type == 'RoadSign' )
					{
						translation = ROADSIGN_PIN_TRANSLATION;
					}
					else if ( type == 'Harbor' )
					{
						translation = HARBOR_PIN_TRANSLATION;
					}
				}
				if ( pinData.isQuest )
				{
					// force using common quest pin
					type = QUEST_PIN_TYPE;
					translation = QUEST_PIN_TRANSLATION;
				}
				/*
				else if ( type == 'Herb' )
				{
					translation = HERB_PIN_TRANSLATION; //'[[panel_map_open_waypoint_panel]]'
				}
				*/

				//trace("Minimap1 DISTANCE ", pinData.id, type, category, priority, pinData.distance );
	
	
				currCategory     = __DEBUG_addCategory( ALL_PINS_CATEGORY );
					currPin      = __DEBUG_addPin( currCategory, type, translation, priority );
								   __DEBUG_addInstance( currPin, pinData.id, new Point( pinData.posX, pinData.posY ), pinData.distance );
				
				if ( category )
				{
					currCategory     = __DEBUG_addCategory( category );
						currPin      = __DEBUG_addPin( currCategory, type, translation, priority );
									   __DEBUG_addInstance( currPin, pinData.id, new Point( pinData.posX, pinData.posY ), pinData.distance );
							
					// NGE - new "Default" category
					if( (category == "General" || category == "Quests" || category == "NPCs" || category == "Buffs") || type == 'Entrance')
					{
						currCategory     = __DEBUG_addCategory( "Default" );
						currPin     	 = __DEBUG_addPin( currCategory, type, translation, priority );
										   __DEBUG_addInstance( currPin, pinData.id, new Point( pinData.posX, pinData.posY ), pinData.distance );
					}
					// NGE - new "Default" category
				}
			}
		}
		
		public function removePinInstance( id : uint )
		{
			var currCategory : CategoryData;
			var currPin : CategoryPinData;
			var i, j, k : int;

			for ( i = 0; i < _categories.length; ++i )
			{
				currCategory = _categories[ i ] as CategoryData;
				for ( j = 0; j < currCategory._pins.length; ++j )
				{
					currPin = currCategory._pins[ j ] as CategoryPinData;
					
					for ( k = 0; k < currPin._instances.length ; ++k )
					{
						if ( currPin._instances[ k ]._id == id )
						{
							currPin._instances.splice( k, 1 );
							currPin._index = 0;
							break;
						}
					}
				}
			}
		}
		
		public function OnControllerChanged( isUsingGamepad )
		{
			_allowShowingCategoryButtonSelection = isUsingGamepad;
			updateCategoryButtonSelection();
			resizeHitArea();
		}

		/*
		private function __DEBUG_fillData()
		{
			var currCategory : CategoryData;
			var currPin : CategoryPinData;
			
			currCategory     = __DEBUG_addCategory( "All" );
				currPin      = __DEBUG_addPin( currCategory, "User1", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 100, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 200, 200 ) );
				currPin      = __DEBUG_addPin( currCategory, "User2", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
				currPin      = __DEBUG_addPin( currCategory, "Horse", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 100, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 200, 200 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 200 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
				currPin      = __DEBUG_addPin( currCategory, "RoadSign", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );

			currCategory    = __DEBUG_addCategory( "Crafting" );
				currPin      = __DEBUG_addPin( currCategory, "MonsterNest", 0 );
				currPin      = __DEBUG_addPin( currCategory, "Entrance", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
				currPin      = __DEBUG_addPin( currCategory, "StoryQuest", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 200, 200 ) );

			currCategory    = __DEBUG_addCategory( "Exploration" );
				currPin      = __DEBUG_addPin( currCategory, "PlaceOfPower", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
				currPin      = __DEBUG_addPin( currCategory, "NotDiscoveredPOI", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 0 ) );
				currPin      = __DEBUG_addPin( currCategory, "Herb", 0 );
							   __DEBUG_addInstance( currPin, new Point( 200, 200 ) );
				currPin      = __DEBUG_addPin( currCategory, "Shopkeeper", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
				currPin      = __DEBUG_addPin( currCategory, "Prostitute", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
				currPin      = __DEBUG_addPin( currCategory, "Rift", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
				currPin      = __DEBUG_addPin( currCategory, "Teleport", 0 );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );
							   __DEBUG_addInstance( currPin, new Point( 0, 100 ) );

		}
		*/
		
		private var _categoryDefinitions : Object =
		{														//   USER, FASTTRAVEL, QUEST
			'All'						: new CategoryDefinition( 1, true, true, true ),
			'Default'					: new CategoryDefinition( 2, true, true, true ), // NGE - new "Default" category
			'General'					: new CategoryDefinition( 3, true, true, false ),
			'Quests'					: new CategoryDefinition( 4, true, true, true ),
			'Exploration'				: new CategoryDefinition( 5, true, true, false ),
			'NPCs'						: new CategoryDefinition( 6, true, true, false ),
			'Buffs'						: new CategoryDefinition( 7, true, true, false )/*,
			'Test'						: new CategoryDefinition( 7, true, true, false )*/
		};
		
		private var _pinTypeDefinitions : Object =
		{
			'RoadSign'					: new PinTypeDefinition( "General", 101 ),
			'Harbor'					: new PinTypeDefinition( "General", 102 ),
			'NoticeBoardFull'			: new PinTypeDefinition( "General", 103 ),
			'NoticeBoard'				: new PinTypeDefinition( "General", 104 ),
			'PlayerStash'				: new PinTypeDefinition( "General", 105 ),
			'PlayerStashDiscoverable'	: new PinTypeDefinition( "General", 106 ),
			'Horse'						: new PinTypeDefinition( "General", 107 ),
			
			'StoryQuest'				: new PinTypeDefinition( "Quests", 201 ),
			'ChapterQuest'				: new PinTypeDefinition( "Quests", 202 ),
			'SideQuest'					: new PinTypeDefinition( "Quests", 203 ),
			'MonsterQuest'				: new PinTypeDefinition( "Quests", 204 ),
			'TreasureQuest'				: new PinTypeDefinition( "Quests", 205 ),
			'QuestReturn'				: new PinTypeDefinition( "Quests", 206 ),
			'HorseRace'					: new PinTypeDefinition( "Quests", 207 ),
			'NonQuestHorseRace'			: new PinTypeDefinition( "Quests", 208 ),
			'BoatRace'					: new PinTypeDefinition( "Quests", 209 ),
			'QuestBelgard'				: new PinTypeDefinition( "Quests", 210 ),
			'QuestCoronata'				: new PinTypeDefinition( "Quests", 212 ),
			'QuestVermentino'			: new PinTypeDefinition( "Quests", 212 ),
			'QuestAvailable'			: new PinTypeDefinition( "Quests", 213 ),
			'QuestAvailableHoS'			: new PinTypeDefinition( "Quests", 214 ),
			'QuestAvailableBaW'			: new PinTypeDefinition( "Quests", 215 ),

			'Entrance'					: new PinTypeDefinition( "Exploration", 301 ),
			'NotDiscoveredPOI'			: new PinTypeDefinition( "Exploration", 302 ),
			'NotDiscoveredPOI_1'		: new PinTypeDefinition( "Exploration", 303 ),
			'NotDiscoveredPOI_2'		: new PinTypeDefinition( "Exploration", 304 ),
			'NotDiscoveredPOI_3'		: new PinTypeDefinition( "Exploration", 305 ),
			'MonsterNest'				: new PinTypeDefinition( "Exploration", 306 ),
			'MonsterNest_1'				: new PinTypeDefinition( "Exploration", 307 ),
			'MonsterNest_2'				: new PinTypeDefinition( "Exploration", 308 ),
			'MonsterNest_3'				: new PinTypeDefinition( "Exploration", 309 ),
			'MonsterNestDisabled'		: new PinTypeDefinition( "Exploration", 310 ),
			'TreasureHuntMappin'		: new PinTypeDefinition( "Exploration", 316 ),
			'TreasureHuntMappin_1'		: new PinTypeDefinition( "Exploration", 317 ),
			'TreasureHuntMappin_2'		: new PinTypeDefinition( "Exploration", 318 ),
			'TreasureHuntMappin_3'		: new PinTypeDefinition( "Exploration", 319 ),
			'TreasureHuntMappinDisabled': new PinTypeDefinition( "Exploration", 320 ),
			'SpoilsOfWar'				: new PinTypeDefinition( "Exploration", 321 ),
			'SpoilsOfWar_1'				: new PinTypeDefinition( "Exploration", 322 ),
			'SpoilsOfWar_2'				: new PinTypeDefinition( "Exploration", 323 ),
			'SpoilsOfWar_3'				: new PinTypeDefinition( "Exploration", 324 ),
			'SpoilsOfWarDisabled'		: new PinTypeDefinition( "Exploration", 325 ),
			'BanditCamp'				: new PinTypeDefinition( "Exploration", 326 ),
			'BanditCamp_1'				: new PinTypeDefinition( "Exploration", 327 ),
			'BanditCamp_2'				: new PinTypeDefinition( "Exploration", 328 ),
			'BanditCamp_3'				: new PinTypeDefinition( "Exploration", 329 ),
			'BanditCampDisabled'		: new PinTypeDefinition( "Exploration", 330 ),
			'BanditCampfire'			: new PinTypeDefinition( "Exploration", 331 ),
			'BanditCampfire_1'			: new PinTypeDefinition( "Exploration", 332 ),
			'BanditCampfire_2'			: new PinTypeDefinition( "Exploration", 333 ),
			'BanditCampfire_3'			: new PinTypeDefinition( "Exploration", 334 ),
			'BanditCampfireDisabled'	: new PinTypeDefinition( "Exploration", 335 ),
			'BossAndTreasure'			: new PinTypeDefinition( "Exploration", 336 ),
			'BossAndTreasure_1'			: new PinTypeDefinition( "Exploration", 337 ),
			'BossAndTreasure_2'			: new PinTypeDefinition( "Exploration", 338 ),
			'BossAndTreasure_3'			: new PinTypeDefinition( "Exploration", 339 ),
			'BossAndTreasureDisabled'	: new PinTypeDefinition( "Exploration", 340 ),
			'Contraband'				: new PinTypeDefinition( "Exploration", 341 ),
			'Contraband_1'				: new PinTypeDefinition( "Exploration", 342 ),
			'Contraband_2'				: new PinTypeDefinition( "Exploration", 343 ),
			'Contraband_3'				: new PinTypeDefinition( "Exploration", 344 ),
			'ContrabandDisabled'		: new PinTypeDefinition( "Exploration", 345 ),
			'ContrabandShip'			: new PinTypeDefinition( "Exploration", 346 ),
			'ContrabandShip_1'			: new PinTypeDefinition( "Exploration", 347 ),
			'ContrabandShip_2'			: new PinTypeDefinition( "Exploration", 348 ),
			'ContrabandShip_3'			: new PinTypeDefinition( "Exploration", 349 ),
			'ContrabandShipDisabled'	: new PinTypeDefinition( "Exploration", 350 ),
			'RescuingTown'				: new PinTypeDefinition( "Exploration", 351 ),
			'RescuingTown_1'			: new PinTypeDefinition( "Exploration", 352 ),
			'RescuingTown_2'			: new PinTypeDefinition( "Exploration", 353 ),
			'RescuingTown_3'			: new PinTypeDefinition( "Exploration", 354 ),
			'RescuingTownDisabled'		: new PinTypeDefinition( "Exploration", 355 ),
			'DungeonCrawl'				: new PinTypeDefinition( "Exploration", 356 ),
			'DungeonCrawl_1'			: new PinTypeDefinition( "Exploration", 357 ),
			'DungeonCrawl_2'			: new PinTypeDefinition( "Exploration", 358 ),
			'DungeonCrawl_3'			: new PinTypeDefinition( "Exploration", 359 ),
			'DungeonCrawlDisabled'		: new PinTypeDefinition( "Exploration", 360 ),
			'Hideout'					: new PinTypeDefinition( "Exploration", 361 ),
			'HideoutDisabled'			: new PinTypeDefinition( "Exploration", 362 ),
			'InfestedVineyard'			: new PinTypeDefinition( "Exploration", 363 ),
			'InfestedVineyard_1'		: new PinTypeDefinition( "Exploration", 364 ),
			'InfestedVineyard_2'		: new PinTypeDefinition( "Exploration", 365 ),
			'InfestedVineyard_3'		: new PinTypeDefinition( "Exploration", 366 ),
			'InfestedVineyardDisabled'	: new PinTypeDefinition( "Exploration", 367 ),
			'Plegmund'					: new PinTypeDefinition( "Exploration", 368 ),
			'WineContract'				: new PinTypeDefinition( "Exploration", 369 ),
			'KnightErrant'				: new PinTypeDefinition( "Exploration", 370 ),
			'SignalingStake'			: new PinTypeDefinition( "Exploration", 371 ),			
			'Boat'						: new PinTypeDefinition( "Exploration", 372 ), 	// NGE - new "Default" category
			
			'Shopkeeper'				: new PinTypeDefinition( "NPCs", 501 ),
			'Archmaster'				: new PinTypeDefinition( "NPCs", 502 ),
			'Blacksmith'				: new PinTypeDefinition( "NPCs", 503 ),
			'Armorer'					: new PinTypeDefinition( "NPCs", 504 ),
			'Hairdresser'				: new PinTypeDefinition( "NPCs", 505 ),
			'Alchemic'					: new PinTypeDefinition( "NPCs", 506 ),
			'Herbalist'					: new PinTypeDefinition( "NPCs", 507 ),
			'Innkeeper'					: new PinTypeDefinition( "NPCs", 508 ),
			'Enchanter'					: new PinTypeDefinition( "NPCs", 509 ),
			'Prostitute'				: new PinTypeDefinition( "NPCs", 510 ),
			'Hairdresser'				: new PinTypeDefinition( "NPCs", 511 ),
			'Torch'						: new PinTypeDefinition( "NPCs", 512 ),
			'WineMerchant'				: new PinTypeDefinition( "NPCs", 513 ),
			'DyeMerchant'				: new PinTypeDefinition( "NPCs", 514 ),
			'Cammerlengo'				: new PinTypeDefinition( "NPCs", 515 ),

			'PlaceOfPower'				: new PinTypeDefinition( "Buffs", 601 ),
			'PlaceOfPower_1'			: new PinTypeDefinition( "Buffs", 602 ),
			'PlaceOfPower_2'			: new PinTypeDefinition( "Buffs", 603 ),
			'PlaceOfPower_3'			: new PinTypeDefinition( "Buffs", 604 ),
			'PlaceOfPowerDisabled'		: new PinTypeDefinition( "Buffs", 605 ),
			'Whetstone'					: new PinTypeDefinition( "Buffs", 606 ),
			'GrindStone'				: new PinTypeDefinition( "Buffs", 607 ),
			'ArmorRepairTable'			: new PinTypeDefinition( "Buffs", 608 ),
			'AlchemyTable'				: new PinTypeDefinition( "Buffs", 609 ),
			'MutagenDismantle'			: new PinTypeDefinition( "Buffs", 610 ),
			'Bookshelf'					: new PinTypeDefinition( "Buffs", 611 )/*,
			
			'Herb'						: new PinTypeDefinition( "Test", 941 )
			*/
		};

	}
}

class CategoryDefinition
{
	public var _priority : int;
	public var _showUserPins : Boolean;
	public var _showFastTravelPins : Boolean;
	public var _showQuestPins : Boolean;
	
	public function CategoryDefinition( priority : int, showUserPins : Boolean, showFastTravelPins : Boolean, showQuestPins : Boolean )
	{
		_priority			= priority;
		_showUserPins		= showUserPins;
		_showFastTravelPins	= showFastTravelPins;
		_showQuestPins		= showQuestPins;
	}
}

class PinTypeDefinition
{
	public var _category : String;
	public var _priority : int;
	
	public function PinTypeDefinition( category : String, priority : int )
	{
		_category = category;
		_priority = priority;
	}
	
	public function toString() : String
	{
		return "[C] " + _category + " [P] " + _priority;
	}
};
