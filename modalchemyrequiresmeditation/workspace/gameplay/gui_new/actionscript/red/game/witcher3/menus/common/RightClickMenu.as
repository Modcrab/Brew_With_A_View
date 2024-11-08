/***********************************************************************
/** Right click menu, curently used in inventory only
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.events.GridEvent;
	
	public class RightClickMenu extends UIComponent
	{
		public var mcOptionsList : W3ScrollingList;
		public var mcOptionsListItem1 : W3OptionsListItem;
		public var mcOptionsListItem2 : W3OptionsListItem;
		public var mcOptionsListItem3 : W3OptionsListItem;
		public var mcOptionsListItem4 : W3OptionsListItem;
		public var mcOptionsListItem5 : W3OptionsListItem;
	
		protected var _inputHandlers:Vector.<UIComponent>;
		public var gridBindingKey : String = "inventory.grid.player";
		protected var itemId : uint;
		protected var itemQuantity : int = 0;
		
		public function RightClickMenu()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function configUI():void
		{
			super.configUI();
			visible = false;
			focused = 0;
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "inventory.rightclickmenu.options", [handleRightClickMenuOptionsUpdate]));
			stage.addEventListener( GameEvent.PASSINPUT, handleGetInput, false, 0, true);
			mcOptionsList.addEventListener( ListEvent.ITEM_PRESS, handleOptionsChoose, false, 0, true );
			_inputHandlers.push(mcOptionsList);
		}

		override public function toString():String
		{
			return "[W3 RightClickMenu: ]";
		}

		private function handleRightClickMenuOptionsUpdate( gameData:Object, index:int ):void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array
				mcOptionsList.dataProvider = new DataProvider( dataArray );
				mcOptionsList.invalidate();
				mcOptionsList.validateNow();
				mcOptionsList.ShowRenderers(true);
			}
		}
		
		public function SetPosition( inX : int, inY : int ) : void
		{
			// plug
		}
		
		public function handleOptionsChoose( event : ListEvent ) : void
		{
			var renderer : W3OptionsListItem = event.itemRenderer as W3OptionsListItem;
			//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakPoint', ["handleOptionsChoose START" ] ));
			
			if ( renderer )
			{
				dispatchEvent( new GameEvent( GameEvent.PASSINPUT, gridBindingKey ) );
				//dispatchEvent( new GameEvent(GameEvent.CALL, "OnRightMenuOptionChoosen", [renderer.index, renderer.data.id]));
				trace("INVENTORY handleOptionsChoose options.menu itemQuantity " + itemQuantity);
				if ( itemQuantity < 2 )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRightMenuOptionChoosen', [itemId, itemQuantity, renderer.inventoryActionType] ));
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnRightMenuOptionChoosen', itemId, itemQuantity, renderer.inventoryActionType] ));
				}
				dispatchEvent( new GridEvent( GridEvent.HIDE_OPTIONSMENU, true, false, 0, -1, -1, null, null ));
			}
		}
		
		private function handleGetInput( event : GameEvent ) : void
		{
			if ( event.eventName == "options.menu" )
			{
				stage.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakpoint', ["options menu"] ));
				SetupItem(event.eventArgs);
				focused = 1;
			}
		}
		
		private function SetupItem( data : Object )
		{
			itemId = data[0] as uint;
			itemQuantity = data[1] as int;
			trace("INVENTORY SetupItem itemQuantity "+itemQuantity);
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !focused )
			{
				//trace( " IV event.handled " + event.handled+ " ");
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
	
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
		}
	}
}