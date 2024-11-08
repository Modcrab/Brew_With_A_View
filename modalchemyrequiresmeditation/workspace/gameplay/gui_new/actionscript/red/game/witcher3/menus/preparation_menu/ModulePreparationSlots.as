package red.game.witcher3.menus.preparation_menu
{
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotsListPaperdoll;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.utils.CommonUtils;

	/**
	 * Preporation Slots
	 * @author Getsevich Yaroslav
	 */
	public class ModulePreparationSlots extends CoreMenuModule
	{
		public var mcPrepSlot1:SlotPaperdoll;
		public var mcPrepSlot2:SlotPaperdoll;
		public var mcPrepSlot3:SlotPaperdoll;
		public var mcPrepSlot4:SlotPaperdoll;
		public var mcPrepSlot5:SlotPaperdoll;
		public var mcPrepSlot6:SlotPaperdoll;
		public var mcPrepSlot7:SlotPaperdoll;
		public var mcPrepSlot8:SlotPaperdoll;
		public var mcPrepSlot9:SlotPaperdoll;
		public var mcPrepSlot10:SlotPaperdoll;
		public var mcSlotsList:SlotsListPaperdoll;

		public var txtTitlePotionsBombs:TextField;
		public var txtTitleSwordsOils:TextField;
		public var txtTitleMutagenPotions:TextField;
		public var txtPotions:TextField;
		public var txtBombs:TextField;
		public var txtSilverSword:TextField;
		public var txtSteelSword:TextField;

		private var _inputSymbolIDA:int = -1;

		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "preparations.slots.list", [handleDataSet]));

			txtTitlePotionsBombs.htmlText = "[[panel_preparation_potionsandbombs_slots_description]]";
			txtTitlePotionsBombs.htmlText = CommonUtils.toUpperCaseSafe(txtTitlePotionsBombs.htmlText);
			txtTitleSwordsOils.htmlText = "[[panel_preparation_oils_grid_name]]";
			txtTitleSwordsOils.htmlText = CommonUtils.toUpperCaseSafe(txtTitleSwordsOils.htmlText);
			txtTitleMutagenPotions.htmlText = "[[panel_preparation_mutagens_sublist_name]]";
			txtTitleMutagenPotions.htmlText = CommonUtils.toUpperCaseSafe(txtTitleMutagenPotions.htmlText);
			txtPotions.htmlText = "[[panel_inventory_paperdoll_slotname_potions]]";
			txtPotions.htmlText = CommonUtils.toUpperCaseSafe(txtPotions.htmlText);
			txtBombs.htmlText = "[[panel_inventory_paperdoll_slotname_petards]]";
			txtBombs.htmlText = CommonUtils.toUpperCaseSafe(txtBombs.htmlText);
			txtSilverSword.htmlText = "[[panel_inventory_paperdoll_slotname_silver]]";
			txtSilverSword.htmlText = CommonUtils.toUpperCaseSafe(txtSilverSword.htmlText);
			txtSteelSword.htmlText = "[[panel_inventory_paperdoll_slotname_steel]]";
			txtSteelSword.htmlText = CommonUtils.toUpperCaseSafe(txtSteelSword.htmlText);

			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			mcSlotsList.addEventListener(ListEvent.INDEX_CHANGE, onSlotsListIndexChanged, false, 0, true);
			mcSlotsList.focusable = false;
		}

		override public function set focused(value:Number):void
		{
			super.focused = value;

			UpdateSlotInputFeedback();

			updateActivateSelectionEnabled();
		}

		protected function updateActivateSelectionEnabled():void
		{
			mcSlotsList.activeSelectionVisible = focused != 0;
			mcSlotsList.updateActiveSelectionVisible();
		}

		private function onSlotsListIndexChanged( event:ListEvent ):void
		{
			UpdateSlotInputFeedback();
		}

		private function UpdateSlotInputFeedback() : void
		{
			if (_inputSymbolIDA != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDA);
				_inputSymbolIDA = -1;
			}

			if (focused)
			{
				var curPaperdoll:SlotPaperdoll = mcSlotsList.getSelectedRenderer() as SlotPaperdoll;

				if (curPaperdoll && !curPaperdoll.isEmpty() && curPaperdoll.slotTypeID != 3)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1, "panel_button_inventory_unequip"); // #J not sure what PC control will be (if any)
				}
			}

			InputFeedbackManager.updateButtons(this);
		}

		private function /*Witcher Script*/ handleDataSet( gameData:Object, index:int ):void
		{
			var i:int;
			var dataArray:Array = gameData as Array;

			if (!dataArray)
			{
				throw new Error("GFX - error: the data passed from witcher script wasn't even an array !??!");
			}

			mcSlotsList.data = dataArray;
			validateNow();

			var currentSlot:SlotInventoryGrid;

			for (i = 0; i < mcSlotsList.getRenderersLength(); ++i)
			{
				currentSlot = mcSlotsList.getRendererAt(i) as SlotInventoryGrid;
				if (currentSlot)
				{
					currentSlot.useContextMgr = false;
					if (currentSlot.data) { currentSlot.data.actionType = 0; } // #J easiest way to turn off the automatic action system
				}
			}

			updateActivateSelectionEnabled();
		}

		public function canEquipSteelOil():Boolean
		{
			return !mcPrepSlot6.isLocked; // #J not ideal way, but as long as you don't change the slot movieclip names in flash without updating here, should be fine
		}

		public function canEquipSilverOil():Boolean
		{
			return !mcPrepSlot5.isLocked; // #J not ideal way, but as long as you don't change the slot movieclip in flash without updating here, should be fine
		}

		public function MakeUnselectableUnlessCorrectSlot(targetSlot:SlotInventoryGrid):void
		{
			var i:int;

			for (i = 0; i < mcSlotsList.getRenderersLength(); ++i)
			{
				var curSlot:SlotPaperdoll = mcSlotsList.getRendererAt(i) as SlotPaperdoll;
				// #J not the most optimized if sequence but did it this way to make it easier to read
				if (curSlot && targetSlot.data)
				{
					if (curSlot.slotTypeID != targetSlot.data.prepItemType || curSlot.isLocked)
					{
						curSlot.selectable = false;
					}
					else if (curSlot.slotTypeID == 3) // oils!
					{
						if (curSlot.equipID == InventorySlotType.SilverSword && !targetSlot.data.silverOil)
						{
							curSlot.selectable = false;
						}
						else if (curSlot.equipID == InventorySlotType.SteelSword && !targetSlot.data.steelOil)
						{
							curSlot.selectable = false;
						}
					}
				}
			}
		}

		public function MakeAllSelectable():void
		{
			var i:int;

			for (i = 0; i < mcSlotsList.getRenderersLength(); ++i)
			{
				var curSlot:SlotBase = mcSlotsList.getRendererAt(i) as SlotBase;
				if (curSlot)
				{
					curSlot.selectable = true;
				}
			}
		}

		override public function handleInput( event:InputEvent ):void
		{
			if (!focused || event.handled)
				return;

			mcSlotsList.handleInputPreset(event);

			if (mcSlotsList && !event.handled)
			{
				var currentSlot:SlotInventoryGrid = mcSlotsList.getSelectedRenderer() as SlotInventoryGrid;

				// #J Empty slots can't execute actions, so we override it in this example. Ideally the system wouldn't care if slots are empty or not to send message, but would be
				// too big of a refactor at this point
				if (currentSlot)
				{
					if (event.details.value == InputValue.KEY_UP && event.details.code == KeyCode.PAD_A_CROSS)
					{
						var activateEvent:SlotActionEvent = new SlotActionEvent(SlotActionEvent.EVENT_ACTIVATE, true);
						activateEvent.actionType = 0;
						activateEvent.targetSlot = currentSlot;
						dispatchEvent(activateEvent);
					}
				}
			}
		}
	}

}
