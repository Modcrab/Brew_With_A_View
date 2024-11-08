/***********************************************************************
/** PANEL repair main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.blacksmith
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common.ModuleCommonPlayerGrid;
	import red.game.witcher3.menus.common.ModuleMerchantInfo;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.FiniteStateMachine;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;

	public class BlacksmithMenu extends CoreMenu
	{
		private const MENU_TAB_SOCKETS:String = "Sockets";
		private const MENU_TAB_REPAIR:String = "Repair";
		private const MENU_TAB_DISASSEMBLE:String = "Disassemble";
		private const MENU_TAB_ADD_SOCKETS:String = "AddSockets";
		
		private const STATE_SELECTION:String = "Selection";
		private const STATE_CONFIRMATION:String = "Confirmation";
		private const STATE_WAITING:String = "Waiting";
		
		private const ACTION_ACTIVATE_ID:int = 1000;
		private const ACTION_COMPARE_ID:int = 1001;
		private const ACTION_REPAIR_ALL:int = 1002;
		
		public var mcPlayerGridModule:ModuleBlacksmithGrid;
		public var tooltipAnchor:DisplayObject;
		
		public var panelSockets:ItemSocketsInfo;
		public var panelRepair:ItemRepairInfo;
		public var panelDisassemble:ItemDisassembleInfo;
		public var panelAddSocket:ItemAddSocketInfo;
		
		public var mcBkBlacksmith:MovieClip;
		public var mcBkSockets:MovieClip;
		
		private var _currentInfoPanel:BlacksmithItemPanel;
		
		public var moduleMerchantInfo:ModuleMerchantInfo;
		public var warningDisassemble:MovieClip;
		
		public var emptyListIcon:MovieClip;
		public var txtEmptyList:TextField;
		
		private var _selectdTargetItem:SlotBase;
		private var _targetItem:SlotBase;
		private var _stateMachine:FiniteStateMachine;
		
		private var _actionDisabledWarning:MovieClip;
		private var _activateInputFeedbackLabel:String;
		private var _isActionDisabled:Boolean;
		private var _xActionLabel:String;
		private var _btn_switch_sections    : int = -1;

		
		public function BlacksmithMenu()
		{
			panelAddSocket.visible = false;
			panelSockets.visible = false;
			panelRepair.visible = false;
			warningDisassemble.visible  = false;
			emptyListIcon.visible = false;
			txtEmptyList.visible = false;
			
			InputFeedbackManager.eventDispatcher = this;
			InputFeedbackManager.useOverlayPopup = false;
			
			mcBkBlacksmith.visible = true;
			mcBkSockets.visible = false;
			
			(warningDisassemble["container"]["textField"] as TextField).text = "[[panel_blacksmith_items_cant_disassemble]]";
		}
		
		public function setXActionLabel(value:String):void
		{
			_xActionLabel = value;
			
			var currentSlot:SlotBase = mcPlayerGridModule.mcPlayerGrid.getSelectedRenderer() as SlotBase;
			if (value == "")
			{
				InputFeedbackManager.removeButtonById(ACTION_REPAIR_ALL);
				
				panelRepair.btnRepairAll.visible = false;
			}
			else 
			{
				if (currentSlot)
				{
					displayItemInfo(currentSlot);
				}
				panelRepair.btnRepairAll.visible = true;
			}
		}
		
		override protected function get menuName():String { return "BlacksmithMenu"	}
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.item.update", [updateItem] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.item.list.update", [updateItemsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.merchant.info", [setMerchantInfo] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.grid.section", [setSectionsList] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			_contextMgr.defaultAnchor = tooltipAnchor;
			_contextMgr.addGridEventsTooltipHolder(stage);
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 10, true );
			mcPlayerGridModule.mcPlayerGrid.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleItemActivate, false, 0, true);
			mcPlayerGridModule.mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, handleItemSelected, false, 0 , true);
			mcPlayerGridModule.addEventListener(Event.ACTIVATE, handlePlayerGridActivated, false, 0, true);
			mcPlayerGridModule.addEventListener(Event.DEACTIVATE, handlePlayerGridDeactivate, false, 0, true);
			mcPlayerGridModule.active = true;
			mcPlayerGridModule.focused = 0;
			mcPlayerGridModule.mcPlayerGrid.ignoreGridPosition = true;
			
			_stateMachine = new FiniteStateMachine();
			_stateMachine.AddState(STATE_SELECTION, state_begin_selection, state_update_selection, null);
			_stateMachine.AddState(STATE_CONFIRMATION, state_begin_confirmation, state_update_confirmation, null);
			_stateMachine.AddState(STATE_WAITING, state_begin_waiting, state_update_waiting, null);
			
			if (_btn_switch_sections == -1 )
			{
				_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
			}

		}
	
		
		public function updateItemsList(itemsList:Array):void
		{
			for each (var curDataStub in itemsList)
			{
				mcPlayerGridModule.mcPlayerGrid.updateItemData(curDataStub);
			}
			
			mcPlayerGridModule.checkItemsCount();
		}
		
		public function updateItem(itemData:Object):void
		{
			mcPlayerGridModule.mcPlayerGrid.updateItemData(itemData);
			
			mcPlayerGridModule.checkItemsCount();
		}
		
		public function removeItem( itemId:int, keepSelectionIdx : Boolean = false):void
		{
			_stateMachine.ChangeState(STATE_SELECTION);
			_stateMachine.ForceUpdateState();
			mcPlayerGridModule.mcPlayerGrid.removeItem(itemId, keepSelectionIdx);
			
			mcPlayerGridModule.checkItemsCount();
		}
		
		public function setPlayerMoney(value:int):void
		{
			panelSockets.playerMoney = value;
			panelRepair.playerMoney = value;
			panelDisassemble.playerMoney = value;
			panelAddSocket.playerMoney = value;
		}
		
		private function setSectionsList(value:Array):void
		{
			mcPlayerGridModule.mcPlayerGrid.setItemSections( value );
			mcPlayerGridModule.displaySection( value );
		}
		
		private function setMerchantInfo(value:Object):void
		{
			moduleMerchantInfo.data = value;
		}
		
		private function handlePlayerGridActivated(event:Event):void
		{
			var currentSlot:SlotBase = mcPlayerGridModule.mcPlayerGrid.getSelectedRenderer() as SlotBase;
			
			emptyListIcon.visible = false;
			_isActionDisabled = false;
			txtEmptyList.visible = false;
			mcPlayerGridModule.visible = true;
			
			if (_currentInfoPanel)
			{
				_currentInfoPanel.visible = true;
			}
			if (currentSlot)
			{
				displayItemInfo(currentSlot);
			}
			else
			{
				_currentInfoPanel.cleanup();
			}
		}
		
		private function handlePlayerGridDeactivate(event:Event):void
		{
			emptyListIcon.visible = true;
			_isActionDisabled = true;
			txtEmptyList.visible = true;
			mcPlayerGridModule.visible = false;
			if (_currentInfoPanel)
			{
				_currentInfoPanel.visible = false;
			}
			if (_actionDisabledWarning)
			{
				_actionDisabledWarning.visible = false;
			}
			
			InputFeedbackManager.removeButtonById(ACTION_COMPARE_ID);
			InputFeedbackManager.removeButtonById(ACTION_ACTIVATE_ID);
			InputFeedbackManager.updateButtons(this);
			
			var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, -1, -1, -1, null, null);
			dispatchEvent(hideEvent);
		}
		
		private function handleItemActivate(event:SlotActionEvent):void
		{
			if (_stateMachine.currentState == STATE_SELECTION)
			{
				_targetItem = event.targetSlot as SlotBase;
				
				if (_targetItem && _targetItem.data && _targetItem.data.disableAction)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlayDeniedSound" ) );
					_targetItem = null;
				}
			}
		}
		
		private function handleItemSelected(event:ListEvent):void
		{
			_selectdTargetItem = null;
			if (_stateMachine.currentState == STATE_SELECTION)
			{
				var selectedItem:SlotBase = event.itemRenderer as SlotBase;
				displayItemInfo(selectedItem);
			}
		}
		
		private function activateSelectedItem():void
		{
			if (_stateMachine.currentState == STATE_SELECTION)
			{
				var selectedItem:SlotBase = mcPlayerGridModule.mcPlayerGrid.getSelectedRenderer() as SlotBase;
				
				if (selectedItem && selectedItem.data && !selectedItem.data.disableAction)
				{
					_targetItem = selectedItem;
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlayDeniedSound" ) );
				}
			}
		}
		
		private function displayItemInfo(targetItem:SlotBase):void
		{
			if (!_currentInfoPanel)
			{
				return;
			}
			
			if (targetItem)
			{
				var itemData:Object = targetItem.data;
				
				_currentInfoPanel.data = itemData;
				_isActionDisabled = itemData.disableAction;
				_selectdTargetItem = targetItem;
				
				if (!_isActionDisabled)
				{
					if (_activateInputFeedbackLabel)
					{
						InputFeedbackManager.appendButtonById(ACTION_ACTIVATE_ID, NavigationCode.GAMEPAD_A, KeyCode.E, _activateInputFeedbackLabel);
					}
					if (_actionDisabledWarning)
					{
						_actionDisabledWarning.visible = false;
					}
				}
				else
				{
					InputFeedbackManager.removeButtonById(ACTION_ACTIVATE_ID);
					if (_actionDisabledWarning)
					{
						_actionDisabledWarning.visible = true;
					}
				}
				
				if (_xActionLabel != "")
				{
					InputFeedbackManager.appendButtonById(ACTION_REPAIR_ALL, NavigationCode.GAMEPAD_X, KeyCode.SPACE, _xActionLabel);
				}
				
				InputFeedbackManager.updateButtons(this);
			}
		}
		
		/*
		 * Witcher Script's API
		 */
		
		public function confirmAction(value:Boolean):void
		{
			if (value)
			{
				_action_confirmed = true;
			}
			else
			{
				_stateMachine.ChangeState(STATE_SELECTION);
			}
		}
		
		public function inventoryRemoveItem( itemId:int ):void
		{
			mcPlayerGridModule.inventoryRemoveItem(itemId);
		}
		
		
		private function updateButtonsLabels()
		{
			panelAddSocket.setButtonData("[[panel_blacksmith_add_socket]]", NavigationCode.GAMEPAD_A, KeyCode.E);
			panelRepair.setButtonData("[[panel_button_common_repair]]", NavigationCode.GAMEPAD_A, KeyCode.E);
			panelDisassemble.setButtonData("[[panel_title_blacksmith_disassamble]]", NavigationCode.GAMEPAD_A, KeyCode.E);
			panelSockets.setButtonData("[[panel_title_blacksmith_sockets]]", NavigationCode.GAMEPAD_A, KeyCode.E);
		}
		
		override public function setMenuState(value:String):void
		{
			super.setMenuState(value);
			
			if (_actionDisabledWarning)
			{
				_actionDisabledWarning.visible = false;
			}
			
			if (_selectdTargetItem)
			{
				_selectdTargetItem = null;
				_stateMachine.ChangeState(STATE_SELECTION);
				_stateMachine.ForceUpdateState();
			}
			
			if (_currentInfoPanel)
			{
				_currentInfoPanel.stopProcess();
			}
			
			panelAddSocket.visible = false;
			panelSockets.visible = false;
			panelRepair.visible = false;
			panelDisassemble.visible = false;
			
			mcBkBlacksmith.visible = true;
			mcBkSockets.visible = false;
			
			switch (value)
			{
				case MENU_TAB_ADD_SOCKETS:
					
					txtEmptyList.text = "[[panel_menu_empty_list_add_sockets]]"; // TODO
					txtEmptyList.text = CommonUtils.toUpperCaseSafe(txtEmptyList.text);
					_xActionLabel = "";
					
					//_activateInputFeedbackLabel = "panel_blacksmith_add_socket";
					_activateInputFeedbackLabel = "";
					_currentInfoPanel = panelAddSocket;
					
					panelAddSocket.buttonCallback = activateSelectedItem;
					_actionDisabledWarning = null;
					mcBkBlacksmith.visible = false;
					mcBkSockets.visible = true;
					
					break;
					
				case MENU_TAB_SOCKETS:
					
					
					txtEmptyList.text = "[[panel_menu_empty_list_remove_upgrades]]";
					txtEmptyList.text = CommonUtils.toUpperCaseSafe(txtEmptyList.text);
					_xActionLabel = "";
					
					//_activateInputFeedbackLabel = "panel_title_blacksmith_sockets";
					_activateInputFeedbackLabel = "";
					_currentInfoPanel = panelSockets;
					_actionDisabledWarning = null;
					
					panelSockets.buttonCallback = activateSelectedItem;
					
					
					break;
					
				case MENU_TAB_REPAIR:
					
					
					txtEmptyList.text = "[[panel_menu_empty_list_repair]]";
					txtEmptyList.text = CommonUtils.toUpperCaseSafe(txtEmptyList.text);
					_xActionLabel = "";
					
					//_activateInputFeedbackLabel = "panel_button_common_repair";
					_activateInputFeedbackLabel = "";
					_currentInfoPanel = panelRepair;
					_actionDisabledWarning = null;
					
					panelRepair.buttonCallback = activateSelectedItem;
					
					
					break;
					
				case MENU_TAB_DISASSEMBLE:
					
					
					txtEmptyList.text = "[[panel_menu_empty_list_disassemble]]";
					txtEmptyList.text = CommonUtils.toUpperCaseSafe(txtEmptyList.text);
					_xActionLabel = "";
					
					//_activateInputFeedbackLabel = "panel_title_blacksmith_disassamble";
					_activateInputFeedbackLabel = "";
					_currentInfoPanel = panelDisassemble;
					_actionDisabledWarning = warningDisassemble;
					
					panelDisassemble.buttonCallback = activateSelectedItem;
					
					
					break;
			}
			updateButtonsLabels();
			_isActionDisabled = false;
			
			var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, -1, -1, -1, null, null);
			dispatchEvent(hideEvent);
		}
		
		/*
		 *  States
		 */
		
		// Selct Item  -------------------------------------------
		
		protected function state_begin_selection():void
		{
			_targetItem = null;
		}
		
		protected function state_update_selection():void
		{
			if (_targetItem)
			{
				_stateMachine.ChangeState(STATE_CONFIRMATION);
			}
		}
		
		// Confirmation  -------------------------------------------
		
		protected var _action_confirmed:Boolean;
		
		protected function state_begin_confirmation():void
		{
			if (_targetItem && !_isActionDisabled)
			{
				_action_confirmed = false;
				
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestConfirmation", [_targetItem.data.id, _targetItem.data.actionPrice]  ) );
			}
			else
			{
				_stateMachine.ChangeState(STATE_SELECTION);
			}
		}
		
		protected function state_update_confirmation():void
		{
			if (_action_confirmed)
			{
				_stateMachine.ChangeState(STATE_WAITING);
			}
		}
		
		// Wait  -------------------------------------------
		
		protected function state_begin_waiting():void
		{
			_currentInfoPanel.showProcessAnimation();
		}
		
		protected function state_update_waiting():void
		{
			var isInProgress:Boolean = _currentInfoPanel.isInProgress();
			if (!isInProgress && _targetItem)
			{
				switch (_currentMenuState)
				{
					case MENU_TAB_SOCKETS:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnRemoveImprovements", [_targetItem.data.id, _targetItem.data.actionPrice] ) );
						break;
					case MENU_TAB_REPAIR:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnRepairItem", [_targetItem.data.id, _targetItem.data.actionPrice] ) );
						break;
					case MENU_TAB_DISASSEMBLE:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnDisassembleItem", [_targetItem.data.id, _targetItem.data.actionPrice] ) );
						break;
					case MENU_TAB_ADD_SOCKETS:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnAddSocket", [_targetItem.data.id, _targetItem.data.actionPrice] ) );
						break;
				}
				_stateMachine.ChangeState(STATE_SELECTION);
			}
		}
		
		/*
		 * Custome handle input
		 */
		
		override public function handleInput( event:InputEvent ):void
		{
			super.handleInput(event);
			
			if ( event.handled ) return;
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			if (keyUp)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_X :
						if (_xActionLabel != "")
						{
							_inputMgr.reset();
							dispatchEvent(new GameEvent(GameEvent.CALL, 'OnRepairAllItems'));
							event.handled = true;
						}
						break;
					
					case NavigationCode.GAMEPAD_L2 :
						break;
				}
				
				if (!event.handled && details.code == KeyCode.SPACE)
				{
					if (_xActionLabel != "")
					{
						_inputMgr.reset();
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnRepairAllItems'));
						event.handled = true;
					}
				}
			}
		}
		
	}
}
