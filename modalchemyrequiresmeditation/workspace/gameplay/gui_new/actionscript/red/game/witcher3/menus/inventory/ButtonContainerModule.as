/***********************************************************************
/** PANEL Inventory button container module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.inventory
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.constants.InventoryActionType;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.events.GridEvent;
	//import scaleform.clik.constants.NavigationCode;
	
	public class ButtonContainerModule extends UIComponent
	{
		//public var btnPreview : W3GamepadButton;
		public var btnContext : W3GamepadButton;
		public var btnRepair : W3GamepadButton;
		public var btnDrop : W3GamepadButton;
		
		protected var _activeItemDataStub:ItemDataStub;
		protected var _inputHandlers:Vector.<UIComponent>;
		
		public function ButtonContainerModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function configUI():void
		{
			super.configUI();
			setupButtons();
		}
		
		protected function setupButtons() : void
		{
			btnContext.addEventListener( ButtonEvent.CLICK, handleButtonContextActivateItem, false, 10, true );
			btnContext.navigationCode = NavigationCode.GAMEPAD_A;
			_inputHandlers.push( btnContext );
			
			btnDrop.label = "[[panel_button_common_drop]]";
			btnDrop.addEventListener( ButtonEvent.CLICK, handleButtonDropItem, false, 0 , true );
			btnDrop.navigationCode = NavigationCode.GAMEPAD_Y;
			_inputHandlers.push( btnDrop );
			
			btnRepair.label = "[[panel_button_common_repair]]";
			btnRepair.addEventListener( ButtonEvent.CLICK, handleButtonRepairItem, false, 0, true );
			btnRepair.navigationCode = NavigationCode.GAMEPAD_X;
			_inputHandlers.push( btnRepair );
			
/*			btnPreview.label = "[[panel_button_inventory_preview_char]]";
			btnPreview.addEventListener( ButtonEvent.CLICK, handleButtonPreview, false, 0, true );
			btnPreview.navigationCode = NavigationCode.GAMEPAD_L1;
			_inputHandlers.push( btnPreview );*/
		}
		
		public function SetActiveItemDataStub( inActiveItemDataStub : ItemDataStub ) : void
		{
			_activeItemDataStub = inActiveItemDataStub;
			UpdateButtons();
		}
		
		override public function toString():String
		{
			return "[W3 ButtonContainerModule: ]";
		}
		
		private function UpdateButtons() : void
		{
			if( _activeItemDataStub )
			{
				btnContext.label = GetActivateButtonLabelByActionType( _activeItemDataStub.actionType );
				btnContext.enabled = true;
				btnRepair.enabled = _activeItemDataStub.needRepair;
			}
			else
			{
				btnContext.label = "";
				btnContext.enabled = false;
				btnRepair.enabled = false;
			}
		}
		
		private function handleButtonContextActivateItem( event : ButtonEvent ):void
		{
			if ( _activeItemDataStub )
			{
				switch ( _activeItemDataStub.actionType )
				{
					case InventoryActionType.EQUIP:
						{
							if( _activeItemDataStub.equipped )
							{
								dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipItem', [_activeItemDataStub.id, -1 ] ));
								// #B here qp
								_activeItemDataStub.equipped = 0;
							}
							else
							{
								if ( _activeItemDataStub.quantity > 1 )
									dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItem', [_activeItemDataStub.id, _activeItemDataStub.slotType, _activeItemDataStub.quantity] ));
								else
									dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItem', [_activeItemDataStub.id, _activeItemDataStub.slotType, 1 ] ));
								// #B here qp
								_activeItemDataStub.equipped = _activeItemDataStub.slotType;
							}
							var displayEvent:GridEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, _activeItemDataStub );
							trace("INVENTORY handleButtonContextActivateItem  DISPLAY_TOOLTIP button container");
							dispatchEvent(displayEvent);
						}
						break;
					case InventoryActionType.UPGRADE_WEAPON:
						//FIXME: Need to select which one
						//trace("Need to select a weapon to upgrade");
						//GameInterface.callEvent( 'OnIsEnhancementSlotsFull', _activePaperdollItemDataStub.id ,_activeGridItemDataStub.id); // #B maybe fix with select weapon ?
						break;
					case InventoryActionType.UPGRADE_WEAPON_STEEL: // #B kill
					case InventoryActionType.UPGRADE_WEAPON_SILVER: // kill
					case InventoryActionType.UPGRADE_ARMOR: // kill
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUpgradeItem', [_activeItemDataStub.id ] ));
						break;
					case InventoryActionType.CONSUME:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConsumeItem', [_activeItemDataStub.id ] ));
						break;
					case InventoryActionType.READ:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnReadBook', [_activeItemDataStub.id ] ));
						//dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup' ));
						break;
					case InventoryActionType.DROP:
						if ( _activeItemDataStub.quantity > 1 )
						{
							dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnDropItem', _activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						else
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDropItem', [_activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						break;
					case InventoryActionType.TRANSFER:
						if ( _activeItemDataStub.quantity > 1 )
						{
							dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnTransferItem', _activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						else
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTransferItem', [_activeItemDataStub.id, _activeItemDataStub.quantity, -1 ] ));
						}
						break;
					case InventoryActionType.SELL:
						if ( _activeItemDataStub.quantity > 1 )
						{
							dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnSellItem', _activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						else
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSellItem', [_activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						break;
					case InventoryActionType.BUY:
						if ( _activeItemDataStub.quantity > 1 )
						{
							dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnBuyItem', _activeItemDataStub.id, _activeItemDataStub.quantity ] ));
						}
						else
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBuyItem', [_activeItemDataStub.id, _activeItemDataStub.quantity, -1 ] ));
						}
						break;
					case InventoryActionType.MOBILE_CAMPFIRE:
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCreateCampfire', [_activeItemDataStub.id, 1 ] ));
						break;
					default:
						break;
				}
				_activeItemDataStub = null;
				
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetActiveItem' ));
			}
		}
		
		private function handleButtonRepairItem( event : ButtonEvent ):void
		{
			if ( btnRepair.enabled )
			{
				//_activeItemDataStub
				dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'options.menu' ,[_activeItemDataStub.id, _activeItemDataStub.quantity]) );
				dispatchEvent( new GridEvent( GridEvent.DISPLAY_OPTIONSMENU, true, false, 0, -1, -1, null, _activeItemDataStub ));
				//event.stopImmediatePropagation();
			}
			else
			{
				trace("INVENTORY btnRepair.enabled error");
			}
		}
		
		private function handleButtonDropItem( event : ButtonEvent ):void
		{
			var quantity : int = 1;
			if ( _activeItemDataStub )
			{
				quantity = _activeItemDataStub.quantity;
				if( quantity > 1 )
				{
					dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ["OnDropItem", _activeItemDataStub.id, quantity ] ));
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnDropItem", [_activeItemDataStub.id, quantity ] ));
				}
			}
		}
		
		/*
		private function handleButtonPreview( event : ButtonEvent ):void
		{
			trace("INVENTORY: handleButtonPreview");
		}
		*/
		
		private function GetActivateButtonLabelByActionType( inventoryActionType : int ) : String
		{
			switch(inventoryActionType)
			{
				case InventoryActionType.CONSUME :
					return "[[panel_button_inventory_consume]]";
				case InventoryActionType.EQUIP :
					if( _activeItemDataStub.equipped > 0 ) // #B here change name depending on item action
					{
						return "[[panel_button_inventory_unequip]]";
					}
					return "[[panel_button_inventory_equip]]";
				case InventoryActionType.READ :
					return "[[panel_button_inventory_read]]";
				case InventoryActionType.DROP :
					return "[[panel_button_inventory_drop]]";
				case InventoryActionType.TRANSFER :
					return "[[panel_button_inventory_transfer]]";
				case InventoryActionType.SELL :
					return "[[panel_button_inventory_sell]]";
				case InventoryActionType.BUY :
					return "[[panel_button_inventory_buy]]";
				case InventoryActionType.MOBILE_CAMPFIRE :
					return "[[panel_button_inventory_create_campfire]]";
				case InventoryActionType.UPGRADE_ARMOR :
				case InventoryActionType.UPGRADE_WEAPON :
				case InventoryActionType.UPGRADE_WEAPON_SILVER :
				case InventoryActionType.UPGRADE_WEAPON_STEEL :
					return "[[panel_button_inventory_upgrade]]"; // #B localisation
			}
			return "";
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
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
