/***********************************************************************
/** Right click menu, curently used in inventory only : CONSOLE version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
/*	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;*/
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.events.GridEvent;
	import red.core.events.GameEvent;
	
	public class RightClickMenu_CONSOLE extends RightClickMenu
	{
		public var btnSelect : W3GamepadButton;
		public var btnQuit : W3GamepadButton;
		
		public function RightClickMenu_CONSOLE()
		{
			super();
		}

		override protected function configUI():void
		{
			btnSelect.label = "[[panel_button_common_select]]";
			btnSelect.addEventListener( ButtonEvent.CLICK, handleButtonSelect, false, 0 , true );
			btnSelect.navigationCode = NavigationCode.GAMEPAD_A;
			_inputHandlers.push( btnSelect );
			
			btnQuit.label = "[[panel_button_common_close]]";
			btnQuit.addEventListener( ButtonEvent.CLICK, handleButtonBack, false, 0 , true );
			btnQuit.navigationCode = NavigationCode.GAMEPAD_B;
			_inputHandlers.push( btnQuit );
			super.configUI();
		}

		override public function toString():String
		{
			return "[W3 RightClickMenu_CONSOLE: ]";
		}
		
		private function handleButtonSelect( event : ButtonEvent ):void
		{
			trace("INVENTORY RCM_C handleButtonSelect");

			var renderer : W3OptionsListItem = mcOptionsList.getRendererAt(mcOptionsList.selectedIndex) as W3OptionsListItem;
			if ( renderer )
			{
				dispatchEvent( new GameEvent( GameEvent.PASSINPUT, gridBindingKey ) );
				trace("INVENTORY handleButtonSelect options.menu_console itemQuantity "+itemQuantity);
				if ( itemQuantity > 1 )
				{
					dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnRightMenuOptionChoosen', itemId, itemQuantity, renderer.inventoryActionType] ));
				}
				else
				{
					trace("INVENTORY handleButtonSelect OnRightMenuOptionChoosen ");
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRightMenuOptionChoosen', [itemId, 1, renderer.inventoryActionType] ));
					//stage.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRightMenuOptionChoosen', [itemId, 1, renderer.inventoryActionType] ));
				}
				dispatchEvent( new GridEvent( GridEvent.HIDE_OPTIONSMENU, true, false, 0, -1, -1, null, null ));
			}
			else
			{
				trace("INVENTORY RCM_C renderer handleButtonSelect error");
			}
			
			//event.handled = true;
			event.stopImmediatePropagation();
		}
		
		private function handleButtonBack( event : ButtonEvent ):void
		{
			//event.handled = true;
			event.stopImmediatePropagation();
			dispatchEvent( new GameEvent( GameEvent.PASSINPUT, gridBindingKey ) );
			dispatchEvent( new GridEvent( GridEvent.HIDE_OPTIONSMENU, true, false, 0, -1, -1, null, null ));
		}
	}
}