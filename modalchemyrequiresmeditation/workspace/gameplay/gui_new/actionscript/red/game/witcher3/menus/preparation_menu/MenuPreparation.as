package red.game.witcher3.menus.preparation_menu 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3RenderToTextureHolder;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.menus.journal.QuestListModule;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotSkillGrid;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.menus.character_menu.CharacterModeBackground;
	
	/**
	 * Preporation menu
	 * @author Getsevich Yaroslav
	 */
	public class MenuPreparation extends CoreMenu
	{
		//public var moduleGrid:PreparationDropdownMenu;
		public var mcGridModule:PreparationTabbedModule;
		public var moduleSlots:ModulePreparationSlots;
		public var moduleMonster:ModuleMonsterTrack;
		public var mcSelectionMode:CharacterModeBackground;
		public var toxicityBar:ToxicityBar;
		public var tooltipAnchor:MovieClip;
		public var background:MovieClip;
		
		public var mcRenderToTextureHolder:W3RenderToTextureHolder;
		
		protected var _cachedSlotData:Object;
		
		function MenuPreparation()
		{
			super();
			if (mcSelectionMode) { mcSelectionMode.deactivate(); }
			//InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
		}
		
		override protected function get menuName():String { return "PreparationMenu" }
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			_contextMgr.defaultAnchor = tooltipAnchor;
			_contextMgr.addGridEventsTooltipHolder(stage);
			
			mcGridModule.mcSlotsListGrid.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleItemAction, false, 0, true);
			moduleSlots.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleSlotAction, false, 0, true);
			
			if (mcSelectionMode) 
			{ 
				mcSelectionMode.deactivate();
				mcSelectionMode.setCaption("[[panel_preparation_equip_dialog_title]]");
			}
			
			registerRenderTarget( "test_nopack", 1024, 1024 );
		}
		
		protected function startSelectionMode(targetSlot:SlotInventoryGrid) : void
		{
			mcSelectionMode.activate(targetSlot);
			moduleSlots.mcSlotsList.ignoreSelectable = false;
			moduleSlots.MakeUnselectableUnlessCorrectSlot(targetSlot);
			moduleSlots.mcSlotsList.ReselectIndexIfInvalid(moduleSlots.mcSlotsList.selectedIndex);
			
			mcGridModule.enabled = false;
			moduleMonster.enabled = false;
			currentModuleIdx = 0;
			_cachedSlotData = targetSlot.data;
		}
		
		protected function endSelectionMode() : void
		{
			mcSelectionMode.deactivate();
			
			moduleSlots.MakeAllSelectable();
			
			mcGridModule.enabled = true;
			moduleMonster.enabled = true;
			currentModuleIdx = 0;
			_cachedSlotData = null;
		}
		
		override protected function handleInputNavigate(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled && mcSelectionMode.isActive();
			if (inputEnabled)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B:
						endSelectionMode();
						event.handled = true;
						event.stopImmediatePropagation();
						return;
						break;
				}
			}
			super.handleInputNavigate(event);
		}
		
		// Start slot selection mode
		protected function handleItemAction(event:SlotActionEvent):void
		{			
			var targetSlot:SlotInventoryGrid = event.targetSlot as SlotInventoryGrid;
			if (targetSlot.data == null)
			{
				return;
			}
			
			if (!mcGridModule.canEquip(targetSlot))
			{
				return;
			}
			
			startSelectionMode(targetSlot);
		}
		
		// Equip / Unequp skill 
		protected function handleSlotAction(event:SlotActionEvent):void
		{	
			var currentPaperdoll:SlotPaperdoll = event.targetSlot as SlotPaperdoll;
			
			if (!currentPaperdoll)
			{
				throw new Error("GFX - MenuPreperation trying to handle slot action on unknown slot data");
			}
			
			if (_cachedSlotData != null)
			{
				callEquipItem(_cachedSlotData, currentPaperdoll.equipID);
			}
			else if (!currentPaperdoll.isEmpty())
			{
				mcGridModule.onSetTabCalled(Math.max(0, currentPaperdoll.data.prepItemType - 1));
				callUnequipItem(currentPaperdoll.equipID);
			}
			else
			{
				mcGridModule.onSetTabCalled(Math.max(0, currentPaperdoll.data.prepItemType - 1));
				currentModuleIdx = 0;
			}
		}
		
		protected function callEquipItem(object:Object, equipID:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipItemPrep', [object.id, equipID] ));
			
			if (mcSelectionMode.visible)
			{
				endSelectionMode();
			}
		}
		
		protected function callUnequipItem(equipID:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipItemPrep', [equipID] ));
		}
	}

}