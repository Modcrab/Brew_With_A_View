package red.game.witcher3.popups 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;	
	import red.core.constants.KeyCode;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.menus.blacksmith.ModuleBlacksmithGrid;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.controls.MouseCursor;
	
	/**
	 * Item selection popup for quets Q604
	 * red.game.witcher3.popups.ItemSelectionPopupMenu
	 * @author Getsevich Yaroslav
	 */
	public class ItemSelectionPopupMenu extends CorePopup
	{
		static const ACTION_SELECT_ITEM:uint = 0;
		static const ACTION_CLOSE:uint = 1;
		
		// NGE
		static const ACTION_LEFT:uint = 2;
		static const ACTION_RIGHT:uint = 3;
		// NGE
		
		public var mcPlayerGridModule:ModuleBlacksmithGrid;
		public var mcInputFeedback:ModuleInputFeedback;
		public var txtItemName:TextField;
		
		// NGE
		public var txtDescription:TextField;
		public var txtCategory:TextField;
		public var mcBackground:MovieClip;
		public var mcInputFeedbackLeft:ModuleInputFeedback;
		public var mcInputFeedbackRight:ModuleInputFeedback;
		private var categoryInputFeedbackSet:Boolean;		
		// NGE
		
		private var _overlayCanvas : MovieClip;
		private var _mouseCursor   : MouseCursor;
		
		public function ItemSelectionPopupMenu()
		{
			_enableInputValidation = true;
		}
		
		override protected function get popupName():String { return "ItemSelectionPopup" }
		override protected function configUI():void
		{
			super.configUI();
			
			registerDataBinding( "ItemList", handleItemListData );			
			
			mcPlayerGridModule.mcPlayerGrid.filterKeyCodeFunction = isKeyCodeValid;
			mcPlayerGridModule.mcPlayerGrid.filterNavCodeFunction = isNavEquivalentValid;
			
			mcInputFeedback.filterKeyCodeFunction = isKeyCodeValid;
			mcInputFeedback.filterNavCodeFunction = isNavEquivalentValid;
			
			mcInputFeedback.buttonAlign = "center";
			mcInputFeedback.directWsCall = false;
			mcInputFeedback.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserAction, false, 0, true);
			
			setupInputFeedback();
			
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			mcPlayerGridModule.mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, handleItemSelected, false, 0 , true);
			mcPlayerGridModule.mcPlayerGrid.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleItemActivate, false, 0, true);
			//mcPlayerGridModule.mcPlayerGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick, false, 0, true);
			
			//mcPlayerGridModule.addEventListener(Event.ACTIVATE, handlePlayerGridActivated, false, 0, true);
			//mcPlayerGridModule.addEventListener(Event.DEACTIVATE, handlePlayerGridDeactivate, false, 0, true);
			mcPlayerGridModule.active = true;
			mcPlayerGridModule.focused = 1;
			mcPlayerGridModule.mcPlayerGrid.ignoreGridPosition = true;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			_overlayCanvas = new MovieClip();
			_overlayCanvas.mouseChildren = _overlayCanvas.mouseEnabled = false;
			addChild(_overlayCanvas);
			
			_mouseCursor = new MouseCursor(_overlayCanvas);
		}
		
		private function setupInputFeedback():void
		{
			var bindingsList:Array = [];
			var itemSelectBinding:KeyBindingData = new KeyBindingData();
			var closeBinding:KeyBindingData = new KeyBindingData();
			
			itemSelectBinding.actionId = ACTION_SELECT_ITEM;
			itemSelectBinding.label = "[[panel_button_inventory_select]]";
			itemSelectBinding.keyboard_keyCode = KeyCode.E;
			itemSelectBinding.gamepad_navEquivalent = NavigationCode.GAMEPAD_A;
			bindingsList.push(itemSelectBinding);
			
			closeBinding.actionId = ACTION_CLOSE;
			closeBinding.label = "[[panel_button_common_close]]";
			closeBinding.keyboard_keyCode = KeyCode.ESCAPE;
			closeBinding.gamepad_navEquivalent = NavigationCode.GAMEPAD_B;
			bindingsList.push(closeBinding);
			
			mcInputFeedback.handleSetupButtons(bindingsList);
		}
		
		private function handleUserAction(event:InputFeedbackEvent):void
		{
			var inputEvent:InputEvent = event.inputEventRef;
			
			if (inputEvent)
			{
				if (inputEvent.details.value != InputValue.KEY_UP || !event.isMouseEvent)
				{
					return;
				}
			}
			
			trace("GFX handleUserAction event.isMouseEvent ", event.isMouseEvent);
			
			switch (event.actionId)
			{
				case ACTION_SELECT_ITEM:
					
					var selectedItem:SlotBase = mcPlayerGridModule.mcPlayerGrid.getSelectedRenderer() as SlotBase;
					
					if (selectedItem) // only for buttonClick event
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCallSelectItem', [ uint(selectedItem.data.id) ] ) );
					}
					
					break;
					
				case ACTION_CLOSE:
					
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseSelectionPopup') );
					
					break;
			}
		}
		
		private function handleItemListData(data:Array):void
		{
			// dummy
		}
		
		private function handleItemSelected(event:ListEvent):void
		{
			var selectedItem:SlotBase = event.itemRenderer as SlotBase;
			
			if (selectedItem && selectedItem.data)
			{
				var itemData:ItemDataStub = selectedItem.data as ItemDataStub;
				txtItemName.text = CommonUtils.toUpperCaseSafe(itemData.itemName);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemSelected', [ uint(selectedItem.data.id) ] ) ); // NGE
			}
		}
		
		private function handleItemActivate(event:SlotActionEvent):void
		{
			var selectedItem:SlotBase = event.targetSlot as SlotBase;
			
			if (selectedItem && selectedItem.data)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCallSelectItem', [ uint(selectedItem.data.id) ] ) );
			}			
		}
		
		// NGE
		public function deselectItem():void
		{			
			txtDescription.text = "";			
			txtItemName.text = "";
		}
		
		public function setItemDescription(description:String):void
		{			
			txtDescription.text = description;			
			mcInputFeedback.y = txtItemName.y + txtItemName.height + txtDescription.textHeight + 5;
			mcBackground.height = mcInputFeedback.y - mcBackground.y + mcInputFeedback.height;
		}
		
		public function setCategory(category:String):void
		{
			txtCategory.text = category;
		}
		
		public function showCategoryButtons(show : Boolean):void
		{
			if(show && !categoryInputFeedbackSet)
			{
				setupCategoryInputFeedback();
			}
		
			mcInputFeedbackLeft.visible = show;
			mcInputFeedbackRight.visible = show;
		}
		
		private function setupCategoryInputFeedback():void
		{
			var bindingsListLeft:Array = [];
			var bindingsListRight:Array = [];
			var navigateLeft:KeyBindingData = new KeyBindingData();
			var navigateRight:KeyBindingData = new KeyBindingData();
			
			mcInputFeedbackLeft.filterKeyCodeFunction = isKeyCodeValid;
			mcInputFeedbackLeft.filterNavCodeFunction = isNavEquivalentValid;			
			mcInputFeedbackLeft.buttonAlign = "right";
			mcInputFeedbackLeft.directWsCall = false;
			mcInputFeedbackLeft.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserActionCategory, false, 0, true);
			
			mcInputFeedbackRight.filterKeyCodeFunction = isKeyCodeValid;
			mcInputFeedbackRight.filterNavCodeFunction = isNavEquivalentValid;			
			mcInputFeedbackRight.buttonAlign = "left";
			mcInputFeedbackRight.directWsCall = false;
			mcInputFeedbackRight.addEventListener(InputFeedbackEvent.USER_ACTION, handleUserActionCategory, false, 0, true);
			
			navigateLeft.actionId = ACTION_LEFT;
			navigateLeft.label = "";
			navigateLeft.keyboard_keyCode = KeyCode.NUMBER_1;
			navigateLeft.gamepad_navEquivalent = NavigationCode.GAMEPAD_L1;
			bindingsListLeft.push(navigateLeft);
			
			navigateRight.actionId = ACTION_RIGHT;
			navigateRight.label = "";
			navigateRight.keyboard_keyCode = KeyCode.NUMBER_3;
			navigateRight.gamepad_navEquivalent = NavigationCode.GAMEPAD_R1;
			bindingsListRight.push(navigateRight);
			
			mcInputFeedbackLeft.handleSetupButtons(bindingsListLeft);
			mcInputFeedbackRight.handleSetupButtons(bindingsListRight);
			
			categoryInputFeedbackSet = true;
		}
		
		private function handleUserActionCategory(event:InputFeedbackEvent):void
		{
			var inputEvent:InputEvent = event.inputEventRef;
			
			if (inputEvent)
			{
				if (inputEvent.details.value != InputValue.KEY_UP || !event.isMouseEvent)
				{
					return;
				}
			}
			
			trace("GFX handleUserAction event.isMouseEvent ", event.isMouseEvent);
			
			switch (event.actionId)
			{
				case ACTION_LEFT:					
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangeCategory', [-1] ) );					
					break;
					
				case ACTION_RIGHT:					
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangeCategory', [1]) );					
					break;
			}
		}
		// NGE
	}

}
