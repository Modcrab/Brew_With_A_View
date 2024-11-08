package red.game.witcher3.menus.inventory_menu
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.menus.startscreen.W3StartScreenVideoObject;
	import red.game.witcher3.constants.DebugDataProvider;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.interfaces.IAbstractItemContainerModule;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotsListPaperdoll;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	/**
	 * Paperdoll, center  module in the inventory screen
	 * @author Yaroslav Getsevich
	 */
	public class ModulePaperdoll extends ModulePaperdollBase
	{
		// weapons
		public var mcPaperDollSlot1 : SlotPaperdoll;
		public var mcPaperDollSlot2 : SlotPaperdoll;
		public var mcPaperDollSlot3 : SlotPaperdoll;
		public var mcPaperDollSlot4 : SlotPaperdoll;
		
		// potions
		public var mcPaperDollSlot5 : SlotPaperdoll;
		public var mcPaperDollSlot6 : SlotPaperdoll;
		public var mcPaperDollSlot19 : SlotPaperdoll;
		public var mcPaperDollSlot20 : SlotPaperdoll;
		
		// bombs
		public var mcPaperDollSlot7 : SlotPaperdoll;
		public var mcPaperDollSlot13 : SlotPaperdoll;
		
		// quick
		public var mcPaperDollSlot8 : SlotPaperdoll;
		public var mcPaperDollSlot14 : SlotPaperdoll;
		
		// armor
		public var mcPaperDollSlot9 : SlotPaperdoll;
		public var mcPaperDollSlot10 : SlotPaperdoll;
		public var mcPaperDollSlot11 : SlotPaperdoll;
		public var mcPaperDollSlot12 : SlotPaperdoll;
		
		// horse
		public var mcPaperDollSlot15 : SlotPaperdoll;
		public var mcPaperDollSlot16 : SlotPaperdoll;
		public var mcPaperDollSlot17 : SlotPaperdoll;
		public var mcPaperDollSlot18 : SlotPaperdoll;
		
		public var tfCurrentState : TextField;
		public var tfPotions : TextField;
		public var tfPockets : TextField;
		public var tfPetards : TextField;
		public var tfMasks : TextField;
		
		public var mcSegmentBorderWeapons : MovieClip;
		public var mcSegmentBorderArmor   : MovieClip;
		public var mcSegmentBorderPotion  : MovieClip;
		public var mcSegmentBorderBombs   : MovieClip;
		public var mcSegmentBorderHorse   : MovieClip;
		
		public var mcPreviewIcon : MovieClip;

		protected var _previewMode:Boolean;
		protected var _moduleDisplayName : String = "";
		
		protected var _sectionsData:Array = [];

		public function ModulePaperdoll()
		{
			dataBindingKey = "inventory.paperdoll";
			mcPreviewIcon.visible = false;
			
			// id map:
			// 1 2
			// 3 4
			// 5
			
			// params:
			// id, left, right, up, down, list[]
			
			createSection(1,  -1,  2, -1,  3, mcSegmentBorderWeapons, [mcPaperDollSlot1, mcPaperDollSlot2, mcPaperDollSlot3, mcPaperDollSlot4]); // weapons
			createSection(2,   1, -1, -1,  4, mcSegmentBorderArmor, [mcPaperDollSlot9, mcPaperDollSlot10, mcPaperDollSlot11, mcPaperDollSlot12]); // armor
			createSection(3,  -1,  4,  1,  5, mcSegmentBorderPotion, [mcPaperDollSlot5, mcPaperDollSlot6, mcPaperDollSlot19, mcPaperDollSlot20]); // potions
			createSection(4,   3, -1,  2,  5, mcSegmentBorderHorse, [mcPaperDollSlot15, mcPaperDollSlot16, mcPaperDollSlot17, mcPaperDollSlot18]); // horse
			createSection(5,  -1,  4,  3, -1, mcSegmentBorderBombs, [mcPaperDollSlot7, mcPaperDollSlot8, mcPaperDollSlot13, mcPaperDollSlot14]); // quick / bombs
			
			mcPaperDollSlot13.selectable = false;
		}

		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.grid.paperdoll", [handlePaperdollDataSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.grid.paperdoll.item.update", [handlePaperdollUpdateItem]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.grid.paperdoll.items.update", [handlePaperdollUpdateItems]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.grid.paperdoll.name', [handleModuleNameSet]));			 // #B obsolete ?
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.grid.paperdoll.pockets', [handlePocketsSlotsNameSet])); // #B change to function
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.grid.paperdoll.potions', [handlePotionsSlotsNameSet])); // #B change to function
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.grid.paperdoll.petards', [handlePetardsSlotsNameSet])); // #B change to function
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'inventory.grid.paperdoll.masks', [handleMasksSlotsNameSet])); // #B change to function
			
			updateSectionBorders();
		}
		
		public function get previewMode():Boolean { return _previewMode; }
		public function set previewMode(value:Boolean):void
		{
			_previewMode = value;
			if (mcPreviewIcon)
			{
				mcPreviewIcon.visible = value;
			}
		}
		
		private function createSection(id:int, nLeft:int, nRight:int, nUp:int, nDown:int, border:MovieClip, list:Array):void
		{
			var newSection:Object = { };
			
			newSection.id = id;
			newSection.nLeft = nLeft;
			newSection.nRight = nRight;
			newSection.nUp = nUp;
			newSection.nDown = nDown;
			newSection.list = list;
			newSection.border = border;
			
			var len:int = list.length;
			for ( var i:int = 0; i < len; i++)
			{
				(list[i] as SlotPaperdoll).sectionId = id;
			}
			
			_sectionsData.push(newSection);
		}
		
		private function getSectionData(id:int):Object
		{
			if (_sectionsData)
			{
				var len:int = _sectionsData.length;
				
				for ( var i:int = 0; i < len; i++)
				{
					var curData:Object = _sectionsData[i];
					
					if (curData.id == id)
					{
						return curData;
					}
				}
			}
			
			return null;
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			
			if (event.handled || details.value != InputValue.KEY_DOWN)
			{
				return;
			}
			
			var selectedSlot :SlotPaperdoll = mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
			
			if (focused && selectedSlot && selectedSlot.sectionId != -1)
			{
				var selectedSection:int = selectedSlot.sectionId;
				var sectionData:Object = getSectionData(selectedSlot.sectionId);
				
				if (sectionData)
				{
					var nextSection:int = -1;
					var nextSectionData:Object;
					
					switch (details.navEquivalent)
					{
						case NavigationCode.RIGHT_STICK_LEFT:
							nextSection = sectionData.nLeft;
							break;
						case NavigationCode.RIGHT_STICK_RIGHT:
							nextSection = sectionData.nRight;
							break;
						case NavigationCode.RIGHT_STICK_UP:
							nextSection = sectionData.nUp;
							break;
						case NavigationCode.RIGHT_STICK_DOWN:
							nextSection = sectionData.nDown;
							break;
					}
					
					if (nextSection != -1)
					{
						nextSectionData =  getSectionData(nextSection);
						
						if (nextSectionData && nextSectionData.list && (nextSectionData.list as Array).length > 0)
						{
							mcPaperdoll.selectedIndex = (nextSectionData.list[0] as SlotPaperdoll).index;
							event.handled = true;
						}
						else
						{
							throw new Error("Cant find section " + selectedSlot.sectionId + " data for paperdol component!");
						}
					}
				}
				else
				{
					throw new Error("Cant find section " + selectedSlot.sectionId + " data for paperdol component!");
				}
			}
		}
		
		override public function startSelectModeWithValidSlots(slotList:Array):void
		{
			super.startSelectModeWithValidSlots(slotList);
			
			const GROUP_DISABLED_ALPHA = .1;
			
			// #Y TODO: refact
			mcSegmentBorderWeapons.alpha = (mcPaperDollSlot1.selectable || mcPaperDollSlot2.selectable || mcPaperDollSlot3.selectable || mcPaperDollSlot4.selectable) ? 1 : GROUP_DISABLED_ALPHA;
			mcSegmentBorderPotion.alpha = tfPotions.alpha = (mcPaperDollSlot5.selectable || mcPaperDollSlot6.selectable || mcPaperDollSlot19.selectable || mcPaperDollSlot20.selectable) ? 1 : GROUP_DISABLED_ALPHA;
			mcSegmentBorderBombs.alpha = tfPetards.alpha = (mcPaperDollSlot7.selectable /*|| mcPaperDollSlot13.selectable*/) ? 1 : GROUP_DISABLED_ALPHA;
			mcSegmentBorderArmor.alpha = (mcPaperDollSlot9.selectable || mcPaperDollSlot10.selectable || mcPaperDollSlot11.selectable || mcPaperDollSlot12.selectable) ? 1 : GROUP_DISABLED_ALPHA;
			mcSegmentBorderHorse.alpha = (mcPaperDollSlot15.selectable || mcPaperDollSlot16.selectable || mcPaperDollSlot17.selectable || mcPaperDollSlot18.selectable) ? 1 : GROUP_DISABLED_ALPHA;
			tfPockets.alpha = (mcPaperDollSlot8.selectable || mcPaperDollSlot14.selectable) ? 1 : GROUP_DISABLED_ALPHA;
		}
		
		override public function endSelectionMode():void
		{
			super.endSelectionMode();
		
			// #Y TODO: refact
			mcSegmentBorderWeapons.alpha = 1;
			mcSegmentBorderPotion.alpha = 1;
			mcSegmentBorderBombs.alpha = 1;
			mcSegmentBorderArmor.alpha = 1;
			mcSegmentBorderHorse.alpha = 1;
			tfPotions.alpha = 1;
			tfPetards.alpha = 1;
			tfPockets.alpha = 1;
			tfMasks.alpha = 1;	// NGE
			
			mcPaperDollSlot8.selectable = true;
			mcPaperDollSlot14.selectable = true;
			
			mcPaperDollSlot7.selectable = true;
			mcPaperDollSlot13.selectable = false;
			
			// #Y TEMP, JUST FOR ANIMATION TEST
			updateSectionBorders();
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			
			// #Y TEMP, JUST FOR ANIMATION TEST
			updateSectionBorders();
		}
		
		override protected function updateActiveContext(currentSlot:SlotPaperdoll):void
		{
			super.updateActiveContext(currentSlot);
		
			// #Y TEMP, JUST FOR ANIMATION TEST
			updateSectionBorders();
		}
		
		// #Y TEMP, JUST FOR ANIMATION TEST
		protected function updateSectionBorders():void
		{
			var selectedSlot :SlotPaperdoll = mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
			
			if (_sectionsData)
			{
				var len:int = _sectionsData.length;
				
				for ( var i:int = 0; i < len; i++)
				{
					var curData:Object = _sectionsData[i];
					var targetFrame:uint = 1;
					
					if ((curData.list as Array).indexOf(selectedSlot) > -1 && focused > 0)
					{
						targetFrame = 2;
					}
					else
					{
						targetFrame = 1;
					}
					
					curData.border.gotoAndStop(targetFrame);
				}
				
			}
		}
		
		
		/*
		 * 				- Witcher Script data setters -
		 */

		protected function handleModuleNameSet(  name : String ):void
		{
			_moduleDisplayName = name;
			tfCurrentState.htmlText = name;
		}

		protected function handlePocketsSlotsNameSet(  name : String ):void
		{
			if (tfPockets)
			{
				tfPockets.htmlText = name;
			}
		}

		protected function handlePotionsSlotsNameSet(  name : String ):void
		{
			if (tfPotions)
			{
				tfPotions.htmlText = name;
			}
		}

		protected function handlePetardsSlotsNameSet(  name : String ):void
		{
			if (tfPetards)
			{
				tfPetards.htmlText = name;
			}
		}
		
		protected function handleMasksSlotsNameSet(  name : String ):void
		{
			if (tfMasks)
			{
				tfMasks.htmlText = name;
			}
		}
		
		override public function toString() : String
		{
			return "[W3 ModulePaperdoll]";
		}
		
	}
}
