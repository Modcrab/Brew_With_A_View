/***********************************************************************
/** Notice Board Menu class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.noticeboard
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3GamepadButton;
	import flash.text.TextField;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListPreset;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.MouseEventEx;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.CoreComponent;

	import red.game.witcher3.controls.W3DirectionalScrollingList;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;

	public class NoticeBoardMenu extends CoreMenu
	{
		public var tfTitle			: TextField;
		public var tfDescription	: TextField;
		public var btnConfirm		: InputFeedbackButton;
		public var btnQuit			: InputFeedbackButton;
		
		public var mcCloseBtn : ConditionalCloseButton;

		public var mcList	 : W3DirectionalScrollingList;
		public var mcErrand1 : NoticeboardListItem;
		public var mcErrand2 : NoticeboardListItem;
		public var mcErrand3 : NoticeboardListItem;
		public var mcErrand4 : NoticeboardListItem;
		public var mcErrand5 : NoticeboardListItem;
		public var mcErrand6 : NoticeboardListItem;

		private var fluffOffset : int = 9;

		public function NoticeBoardMenu()
		{
			super();
			
			_enableInputValidation = true;
			upToCloseEnabled = false;
			
			btnConfirm.label = "[[panel_button_common_take]]";
			btnConfirm.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
			btnConfirm.clickable = false;
			
			btnQuit.label = "[[panel_button_common_exit]]"
			btnQuit.setDataFromStage(NavigationCode.GAMEPAD_B, -1);
			btnQuit.addEventListener(MouseEvent.CLICK, onQuitClicked, false, 0, true);
			btnQuit.clickable = false;
			
			mcList.activeSelectionVisible = true;
			mcList.internalRenderers = false;
			//mcList.focusable = false;
		}

		override protected function get menuName():String
		{
			return "NoticeBoardMenu";
		}

		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'noticeboard.errands.list', [handleDataSet] ) );
			
			setupMouseEvents();
			
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, handleInput, false, 1, true );
			
			mcList.addEventListener( ListEvent.ITEM_DOUBLE_CLICK, onItemClicked, false, 0, true );
			mcList.addEventListener( ListEvent.INDEX_CHANGE, onItemSelected, false, 0, true );
			mcList.selectedIndex = 1;
			mcList.focused = 1;

			
			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
			}
			
			//InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}
		
		protected function setupMouseEvents():void
		{
			attachEventsToItem(mcErrand1);
			attachEventsToItem(mcErrand2);
			attachEventsToItem(mcErrand3);
			attachEventsToItem(mcErrand4);
			attachEventsToItem(mcErrand5);
			attachEventsToItem(mcErrand6);
			
			stage.addEventListener(MouseEvent.CLICK, onStageClick, false, 1, true);
		}
		
		protected function attachEventsToItem( item : NoticeboardListItem ) : void
		{
			item.addEventListener(MouseEvent.CLICK, onNoticeBoardItemClicked, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_OVER, onNoticeBoardItemMouseOver, false, 0, true);
			//item.addEventListener(MouseEvent.MOUSE_OUT, onNoticeBoardItemMouseOut, false, 0, true);
		}
		
		protected function onNoticeBoardItemClicked(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				onItemClicked(null);
				event.stopImmediatePropagation();
			}
			else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				hideAnimation();
				event.stopImmediatePropagation();
			}
		}
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			hideAnimation();
		}
		
		protected function onStageClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				hideAnimation();
				event.stopImmediatePropagation();
			}
		}
		
		//protected var _lastMouseOveredItem:int = -1;
		protected function onNoticeBoardItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:NoticeboardListItem = event.currentTarget as NoticeboardListItem;

			//_lastMouseOveredItem = mcList.getRenderers().indexOf(currentTarget);
			mcList.selectedIndex = currentTarget.index;
		}
		
		//protected function onNoticeBoardItemMouseOut(event:MouseEvent):void
		//{
			//_lastMouseOveredItem = -1;
			//if (!InputManager.getInstance().isGamepad())
			//{
			//	mcList.selectedIndex = -1;
			//}
		//}
		
		//protected function handleControllerChange(event:ControllerChangeEvent):void
		//{
		//	_lastMouseOveredItem = -1;
		//	
		//	if (event.isGamepad)
		//	{
		//		if (mcList.selectedIndex == -1)
		//		{
		//			mcList.selectedIndex = 0;
		//		}
		//	}
		//	else
		//	{
		//		mcList.selectedIndex = -1;
		//	}
		//}

		public function setTitle( value : String ) : void
		{
			if( tfTitle )
			{
				tfTitle.htmlText = value;
			}
		}

		public function setSelectedIndex( value : int ) : void
		{
			if( mcList )
			{
				mcList.selectedIndex = value;
			}
		}

		public function setDescription( value : String ) : void
		{
			if( tfDescription )
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					value = "<p align=\"right\">" + value +"</p>";
				}
				tfDescription.htmlText = value;
			}
		}

		private function onItemClicked( event : ListEvent ):void
		{
			if (mcList.selectedIndex == -1)
			{
				return;
			}
			
			var renderer : NoticeboardListItem =  mcList.getRendererAt( mcList.selectedIndex ) as NoticeboardListItem;
			if(renderer)
			{
				if ( renderer.visible && renderer.enabled )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTakeQuest', [ renderer.data.tag] ) );
					renderer.visible = false;
					renderer.enabled = false;
					renderer.selectable = false;
					setTitle("");
					setDescription("");
					
					//if (InputManager.getInstance().isGamepad())
					//{
						TrySelectNextOne();
					//}
				}
			}
		}

		private function TrySelectNextOne() : void
		{
			var idx : int;
			var renderer : NoticeboardListItem;
			var newSelected : Boolean = false;
			var allListChecked : Boolean = false;
			idx = mcList.selectedIndex;

			while ( !newSelected )
			{
				idx ++;
				if ( idx > mcList.data.length - 1 )
				{
					idx = 0;
					if ( allListChecked )
					{
						return;
					}
					allListChecked = true;
				}
				renderer = mcList.getRendererAt( idx ) as NoticeboardListItem;
				if ( renderer )
				{
					if ( renderer.visible )
					{
						mcList.selectedIndex = idx;
						newSelected = true;
					}
				}
			}
		}

		private function onItemSelected( event : ListEvent ):void
		{
			var renderer : NoticeboardListItem =  mcList.getRendererAt( event.index ) as NoticeboardListItem;
			if(renderer && renderer.data)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnErrandSelected', [ renderer.data.tag ] ) );
			}
		}

		protected function handleDataSet( gameData : Object, index : int ) : void
		{
			var dataArray : Array = gameData as Array;

			trace("GFX -------------------- Set data: handleDataSet ", gameData, index);
			
			if ( dataArray )
			{
				mcList.data = dataArray;
				mcList.validateNow();
			}
		}

		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			//trace("Bidon: rmHI key:" + details.value + " code " + details.code + " navE " + details.navEquivalent);
			
			if ( (details.value == InputValue.KEY_DOWN  && (details.code == KeyCode.ENTER || details.code == KeyCode.E)) || (keyPress && details.navEquivalent == NavigationCode.GAMEPAD_A) )
			{
				onItemClicked(null);
				event.handled = true;
			}

			if ( !event.handled )
			{
				trace("JOURNAL : mcList.handleInputAxis rmHI key:" + details.value + " code " + details.code + " navE " + details.navEquivalent);
				mcList.handleInputPreset( event );
			}
		}
		
		
		protected function onQuitClicked(event:MouseEvent):void
		{
			hideAnimation();
		}
	}
}
