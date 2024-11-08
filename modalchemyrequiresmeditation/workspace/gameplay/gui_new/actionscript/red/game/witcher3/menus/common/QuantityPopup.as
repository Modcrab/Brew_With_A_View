/***********************************************************************
/** Quantity tooltip, curently used in inventory only
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.events.ButtonEvent;
	import flash.text.TextField;
	import scaleform.clik.controls.Slider;
	import scaleform.clik.events.SliderEvent;
	import red.game.witcher3.constants.InventoryActionType;
	
	public class QuantityPopup extends UIComponent
	{
		public var btnSelect : W3GamepadButton; // #B its for console version
		public var btnQuit : W3GamepadButton; // #B its for console version
		public var tfCurrent : TextField;
		public var tfDescription : TextField;
		public var tfMinimal : TextField;
		public var tfMaximal : TextField;
		public var mcSlider: Slider;
		
		protected var _inputHandlers:Vector.<UIComponent>;
		protected var eventName : String;
		public var gridBindingKey : String;
		protected  var currentValue : int;
		//protected  var actionId : int;
		protected  var actionTypeID : int;
		protected  var itemId : uint;
		
		public function QuantityPopup()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function configUI():void
		{
			super.configUI();
			visible = false;
			focused = 0;
			mouseEnabled = false;
			stage.addEventListener( GameEvent.PASSINPUT, handleGetInput, false, 0, true);
			btnSelect.label = "[[panel_button_common_select]]";
			btnSelect.addEventListener( ButtonEvent.CLICK, handleButtonSelect, false, 0 , true );
			btnSelect.navigationCode = NavigationCode.GAMEPAD_A;
			_inputHandlers.push( btnSelect );
			
			btnQuit.label = "[[panel_button_common_close]]";
			btnQuit.addEventListener( ButtonEvent.CLICK, handleButtonBack, false, 0 , true );

			btnQuit.navigationCode = NavigationCode.GAMEPAD_B;
			_inputHandlers.push( btnQuit );
			mcSlider.addEventListener( SliderEvent.VALUE_CHANGE, handleSliderValueChange, false, 0 , true );
			_inputHandlers.push( mcSlider );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.quantitypopup.description', [handleQuantityPopupDescription]));
		}

		override public function toString():String
		{
			return "[W3 QuantityPopup: ]";
		}
		
		private function handleGetInput( event : GameEvent ) : void
		{
			if ( event.eventName == 'quantity.popup' )
			{
				SetupPopup(event.eventArgs);
				focused = 1;
				visible = true;
			}
		}
		
		private function SetupPopup( data : Object )
		{
			tfDescription.htmlText = "";
			tfMinimal.htmlText = "0";
			
			eventName = data[0] as String;
			
			itemId = data[1] as uint; // #B also index for right click
			currentValue = data[2] as int;
/*			if (data[3])
			{
				actionId = data[3] as int;
			}*/
			if (data[3])
			{
				actionTypeID = data[3] as int;
			}
			
			switch(eventName)
			{
				case 'OnDropItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_drop]]";
					break;
				case 'OnTransferItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_transfer]]";
					break;
				case 'OnSellItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_sell]]";
					break;
				case 'OnBuyItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_buy]]";
					break;
				case 'OnEquipItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_equip]]";
					break;
				case 'OnUnequipItem':
					tfDescription.htmlText = "[[panel_inventory_quantity_popup_unequip]]";
					break;
				case 'OnRightMenuOptionChoosen':
					tfDescription.htmlText = GetQuantityDescriptionByAction(actionTypeID);//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestQuantityPopupDescription', [actionId] ) );
					break;
				default:
					break;
			}
			
			tfMaximal.htmlText = currentValue.toString();
			tfCurrent.htmlText = currentValue.toString();
			mcSlider.minimum = 0;
			mcSlider.maximum = currentValue;
			mcSlider.value = currentValue;
		}
			
		function GetQuantityDescriptionByAction( actionValue : int ) : String
		{
			var locKey : String;
			switch( actionValue )
			{
				case InventoryActionType.EQUIP :
					locKey = "[[panel_inventory_quantity_popup_equip]]";
					break;
				case InventoryActionType.DROP :
					locKey = "[[panel_inventory_quantity_popup_drop]]";
					break;
				case InventoryActionType.TRANSFER :
					locKey = "[[panel_inventory_quantity_popup_transfer]]";
					break;
				case InventoryActionType.SELL :
					locKey = "[[panel_inventory_quantity_popup_sell]]";
					break;
				case InventoryActionType.BUY :
					locKey = "[[panel_inventory_quantity_popup_buy]]";
					break;
				case InventoryActionType.DIVIDE :
					locKey = "[[panel_inventory_quantity_popup_divide]]";
					break;
				case InventoryActionType.CONSUME :
				case InventoryActionType.MOBILE_CAMPFIRE:
				case InventoryActionType.READ :
					locKey = "ERROR";
					break;
				default:
					locKey = "ERROR";
					break;
			}
			return locKey;
		}
		
		protected function handleQuantityPopupDescription(  value : String ):void
		{
			if (tfDescription)
			{
				tfDescription.htmlText = value;
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !focused )
			{
				//trace( " IV event.handled " + event.handled+ " ");
				return;
			}
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakPoint', ["handleInput handleInput" ] ));
			
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
			event.handled = true;
		}
		
		private function handleSliderValueChange( event : SliderEvent ):void
		{
			currentValue = mcSlider.value;
			tfCurrent.htmlText = currentValue.toString();
		}
		
		private function handleButtonSelect( event : ButtonEvent ):void
		{
			focused = 0;
			visible = false;
			dispatchEvent( new GameEvent( GameEvent.PASSINPUT, gridBindingKey ) );
			//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakPoint', ["handleButtonSelect START" ] ));
			
			if ( currentValue > 0 )
			{
				if (eventName == "OnRightMenuOptionChoosen")
				{
					//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakPoint', ["handleButtonSelect OnRightMenuOptionChoosen "+actionTypeID ] ));
					dispatchEvent( new GameEvent( GameEvent.CALL, eventName, [itemId, currentValue, actionTypeID] ) );
				}
				else
				{
					//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBreakPoint', ["handleButtonSelect "+eventName+" "+currentValue ] ));
					dispatchEvent( new GameEvent( GameEvent.CALL, eventName, [itemId, currentValue] ) );
				}
			}
			event.stopImmediatePropagation();
		}
		
		private function handleButtonBack( event : ButtonEvent ):void
		{
			focused = 0;
			visible = false;
			event.stopImmediatePropagation();
			dispatchEvent( new GameEvent( GameEvent.PASSINPUT, gridBindingKey ) );
		}
	}
}