package red.game.witcher3.hud.modules.lootpopup
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.tooltips.TooltipItem;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;

	public class HudLootItemModule extends UIComponent
	{
		//>------------------------------------------------------------------------------------------------------------------
		// Variable
		//-------------------------------------------------------------------------------------------------------------------
		// On scene elements
		public var mcLootItemsList 			: W3ScrollingList;
		public var mcLootItemsListItem1 	: HudLootItemsListItem;
		public var mcLootItemsListItem2 	: HudLootItemsListItem;
		public var mcLootItemsListItem3 	: HudLootItemsListItem;
		public var mcLootItemsListItem4 	: HudLootItemsListItem;
		public var mcScrollBar 				: ScrollBar;
		public var mcInputFeedback			: ModuleInputFeedback;
		public var tfTitle					: TextField;
		public var mcBackground				: MovieClip;

		protected 	var _inputHandlers		: Vector.<UIComponent>;
		public 		var _bWaitForKey 		: Boolean = false;

		public		var m_isPCVersion		: Boolean;

		private		var m_data				: Array;
		private 	var m_mouseOverIndex	: int;

		public		var m_indexToSelect		: int;

		private const ACTION_TAKE = 0;
		private const ACTION_TAKE_ALL = 1;
		private const ACTION_CLOSE = 2;
		private const SCROLL_PADDING = 24;
		
		private var _backgroundActualWidth:Number;
		
		protected var _lastMoveWasMouse:Boolean = false;
		
		public function set lastMoveWasMouse(value:Boolean):void
		{
			if (_lastMoveWasMouse == value)
			{
				return;	
			}
			
			_lastMoveWasMouse = value;
			
			if (!_lastMoveWasMouse)
			{
				if (mcLootItemsList.selectedIndex == -1)
				{
					mcLootItemsList.selectedIndex = 0;
				}
			}
			else
			{
				if (_lastMouseOveredItem == -1)
				{
					mcLootItemsList.selectedIndex = -1;
				}
				else
				{
					var currentTarget:HudLootItemsListItem  = mcLootItemsList.getRendererAt(_lastMouseOveredItem) as HudLootItemsListItem;
					
					if (currentTarget)
					{
						mcLootItemsList.selectedIndex = currentTarget.index;
					}
				}
				
				mcLootItemsList.validateNow();
			}
		}

		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function HudLootItemModule()
		{
			_inputHandlers = new Vector.<UIComponent>();
			tfTitle.text = "";
			tfTitle.visible = false;
			_backgroundActualWidth = 513.55;
			mcInputFeedback.buttonAlign = "center";
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
			
			mcInputFeedback.directWsCall = false;
			mcInputFeedback.appendButton(ACTION_TAKE_ALL, NavigationCode.GAMEPAD_Y, KeyCode.SPACE, "[[panel_button_common_take_all]]", false);
			mcInputFeedback.appendButton(ACTION_TAKE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_take]]", false);
			mcInputFeedback.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_button_common_close]]", true);
			mcInputFeedback.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserAction, false, 0, true);
			
			mcLootItemsList.bSkipFocusCheck = true;
			//mcLootItemsList.focusable = false;
			
			registerMouseEvents();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, true, 100, true);
			
			_inputHandlers.push( mcLootItemsList );
			mcLootItemsList.addEventListener( ListEvent.INDEX_CHANGE, handleSelectChange, false, 0, true );
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			//       #Y Disabled to prevent double 'take' function call, as we alreay have this call in 'handleInput' function
			//       TODO: If we need it for PC, find solution for this
			// mcLootItemsList.addEventListener( ListEvent.ITEM_CLICK, handleTakeButtonClick, false, 0, true );

			//mcLootItemsList.addEventListener( ListEvent.ITEM_ROLL_OVER, handleRollOver, false, 0, true );
			//mcLootItemsList.addEventListener( ListEvent.ITEM_ROLL_OUT, handleRollOut, false, 0, true );
			if ( mcLootItemsList.scrollBar )
			{
				mcLootItemsList.scrollBar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			lastMoveWasMouse = true;
		}
		
		public function registerMouseEvents()
		{
			stage.addEventListener(MouseEvent.CLICK, onStageClick, false, 1, true);
			
			mcLootItemsListItem1.addEventListener(MouseEvent.CLICK, onLootItemClicked, false, 0, true);
			mcLootItemsListItem1.addEventListener(MouseEvent.MOUSE_OVER, onLootItemMouseOver, false, 0, true);
			mcLootItemsListItem1.addEventListener(MouseEvent.MOUSE_OUT, onLootItemMouseOver, false, 0, true);
			
			mcLootItemsListItem2.addEventListener(MouseEvent.CLICK, onLootItemClicked, false, 0, true);
			mcLootItemsListItem2.addEventListener(MouseEvent.MOUSE_OVER, onLootItemMouseOver, false, 0, true);
			mcLootItemsListItem2.addEventListener(MouseEvent.MOUSE_OUT, onLootItemMouseOver, false, 0, true);
			
			mcLootItemsListItem3.addEventListener(MouseEvent.CLICK, onLootItemClicked, false, 0, true);
			mcLootItemsListItem3.addEventListener(MouseEvent.MOUSE_OVER, onLootItemMouseOver, false, 0, true);
			mcLootItemsListItem3.addEventListener(MouseEvent.MOUSE_OUT, onLootItemMouseOver, false, 0, true);
			
			mcLootItemsListItem4.addEventListener(MouseEvent.CLICK, onLootItemClicked, false, 0, true);
			mcLootItemsListItem4.addEventListener(MouseEvent.MOUSE_OVER, onLootItemMouseOver, false, 0, true);
			mcLootItemsListItem4.addEventListener(MouseEvent.MOUSE_OUT, onLootItemMouseOver, false, 0, true);
		}
		
		protected function onLootItemClicked(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				handleTakeButtonClick(null);
				event.stopImmediatePropagation();
			}
			else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				handleCloseButtonClick();
				event.stopImmediatePropagation();
			}
		}
		
		protected function onStageClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				handleCloseButtonClick();
				event.stopImmediatePropagation();
			}
		}
		
		protected var _lastMouseOveredItem:int = -1;
		protected function onLootItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:HudLootItemsListItem = event.currentTarget as HudLootItemsListItem;

			_lastMouseOveredItem = mcLootItemsList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				mcLootItemsList.selectedIndex = currentTarget.index;
			}
		}
		
		protected function onLootItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				mcLootItemsList.selectedIndex = -1;
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if (event.isGamepad)
			{
				lastMoveWasMouse = false;
			}
		}
		
		private function handleUserAction(event:InputFeedbackEvent):void
		{
			var inputEvent:InputEvent = event.inputEventRef;
			if (inputEvent)
			{
				if (inputEvent.details.value == InputValue.KEY_UP)
				{
					return;
				}
			}
			
			switch (event.actionId)
			{
				case ACTION_TAKE_ALL:
					handleTakeAllButtonClick(null);
					break;
				case ACTION_TAKE:
					handleTakeButtonClick(null);
					break;
				case ACTION_CLOSE:
					handleCloseButtonClick();
					break;
			}
		}
		
		//>---------------------------------------------------------------------------
		
		public function resizeBackground( value : Boolean ): void
		{
			if (value)
			{
				mcBackground.width = _backgroundActualWidth;
			}
			else
			{
				mcBackground.width = _backgroundActualWidth - SCROLL_PADDING;
			}
		}
		//----------------------------------------------------------------------------
		public function handleItemListData( gameData:Object, index:int ):void
		{
			var dataList:Array = gameData as Array;
			mcLootItemsList.dataProvider = new DataProvider(dataList);
			mcLootItemsList.validateNow();
			m_data = gameData as Array;
			
		
			
			if (!m_isPCVersion && mcLootItemsList.dataProvider.length > 0 )
			{
			    mcLootItemsList.selectedIndex = 0;
				CoreList( mcLootItemsList ).getRendererAt(0).selected = true; // #B check & kill
				stage.focus = CoreList( mcLootItemsList ).getRendererAt(0) as ListItemRenderer;  // #B check & kill
			}
			mcLootItemsList.validateNow();
			mcLootItemsList.selectedIndex = Math.min(m_indexToSelect, dataList.length - 1);

			var disableTake:Boolean = m_data.length < 1;

			mcInputFeedback.disableButton(ACTION_TAKE, disableTake);
			mcInputFeedback.disableButton(ACTION_TAKE_ALL, disableTake);
			
			visible = true;
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleTakeButtonClick( event:ListEvent ):void
		{
			if (_bWaitForKey)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPopupTakeItem', [ mcLootItemsList.selectedIndex ] ) );
				if ( (mcLootItemsList.dataProvider.length - 1) <= mcLootItemsList.selectedIndex )
				{
					mcLootItemsList.selectedIndex = (mcLootItemsList.dataProvider.length - 2);
					mcLootItemsList.validateNow();
				}
			}
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleTakeAllButtonClick( event:ButtonEvent = null ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPopupTakeAllItems' ) );
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleCloseButtonClick( event:ButtonEvent = null ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseLootWindow' ) );
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function handleRollOver( e: ListEvent ) :void
		{
			trace("GFX --------------------- AHHHHHHHHHH --------------------");
			/*if (!m_isPCVersion) return;

			var l_target		: ListItemRenderer 	= mcLootItemsList.getRendererAt( e.index - mcLootItemsList.scrollPosition ) as ListItemRenderer;

			var l_selectedPos 	: Point 			= l_target.parent.localToGlobal( new Point( l_target.x, l_target.y + l_target.height * 0.5) );
			var l_arrowPos 		: Point				= mcFloatingToolTip_PC.globalToLocal( l_selectedPos );

			mcFloatingToolTip_PC.visible 			= true;
			mcFloatingToolTip_PC.mcPointingArrow.y 	= l_arrowPos.y;

			mcFloatingToolTip_PC.setData( m_data[e.index] );
			//mcFloatingToolTip_PC.setData( l_target.data );

			m_mouseOverIndex = e.index - mcLootItemsList.scrollPosition;

			stage.focus = l_target;*/
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function handleRollOut( e: ListEvent ) :void
		{
			//mcFloatingToolTip_PC.visible = false;
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function handleScroll(e:Event) : void
		{
			mcLootItemsList.validateNow();
			if (_lastMouseOveredItem != -1 && _lastMoveWasMouse)
			{
				var currentTarget:HudLootItemsListItem  = mcLootItemsList.getRendererAt(_lastMouseOveredItem) as HudLootItemsListItem;
				
				if (currentTarget)
				{
					mcLootItemsList.selectedIndex = currentTarget.index;
					mcLootItemsList.validateNow();
				}
			}
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function handleSelectChange( e: ListEvent ) :void
		{
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = ( details.value == InputValue.KEY_DOWN);
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT)
			{
				lastMoveWasMouse = false;
			}
			
			//if (!event.handled)
			//{
			//	mcLootItemsList.handleInput(event);
			//}

			if ( keyPress )
			{
				if ( details.code == KeyCode.E )
				{
					//handleTakeButtonClick(null);
				}
			}
		}

	}

}
