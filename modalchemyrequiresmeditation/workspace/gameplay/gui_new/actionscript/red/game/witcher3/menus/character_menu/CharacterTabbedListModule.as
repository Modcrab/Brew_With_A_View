package red.game.witcher3.menus.character_menu
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.W3Button;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.modules.CollapsableTabbedListModule;
	import red.game.witcher3.modules.TabbedScrollingListModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotDragAvatar;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotsTransferManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.scrollbar.ScrollBar;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	
	public class CharacterTabbedListModule extends CollapsableTabbedListModule implements IDropTarget
	{
		public static const TabIndex_Sword 		: int = 0;
		public static const TabIndex_Signs 		: int = 1;
		public static const TabIndex_Alchemy 	: int = 2;
		public static const TabIndex_Perks 		: int = 3;
		public static const TabIndex_Mutagens 	: int = 4;
		
		public var mcStateDropTarget:MovieClip;
		public var mcGridMask:MovieClip;
		
		public var mcSkillSlotList:CharacterSkillSlotsList;
		public var mcMutagenSlotList:SlotsListGrid;
		
		public var txtSpentPoints:TextField;
		
		protected var mcNumSkillPoints:Array;
		protected var mcNumSkillsLearnt:Array;
		
		private var _disableMutagenEquipping:Boolean;
		private var _inputSymbolIDX:int = -1;
		private var _pointsCount:int = 0;
		
		public var iconLock1:MovieClip;
		public var iconLock2:MovieClip;
		public var iconLock3:MovieClip;
		
		public function CharacterTabbedListModule()
		{
			mcNumSkillPoints = new Array();
			mcNumSkillPoints.push(0);
			mcNumSkillPoints.push(0);
			mcNumSkillPoints.push(0);
			mcNumSkillPoints.push(0);
			
			mcNumSkillsLearnt = new Array();
			mcNumSkillsLearnt.push(0);
			mcNumSkillsLearnt.push(0);
			mcNumSkillsLearnt.push(0);
			mcNumSkillsLearnt.push(0);
			
			mcMutagenSlotList.dropEnabled = false;
			mcStateDropTarget.visible = false;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			updateLockedIcons();
			setTabData(new DataProvider( [ { icon:"Sword", locKey:"[[panel_character_skill_sword]]" },
										   { icon:"Signs", locKey:"[[panel_character_skill_signs]]" },
										   { icon:"Alchemy", locKey:"[[panel_character_skill_alchemy]]" },
										   { icon:"Perks", locKey:"[[panel_character_perks_name]]" },
										   { icon:"Mutagens", locKey:"[[panel_inventory_paperdoll_slotname_mutagen]]" } ] ));
			
			addToListContainer(mcSkillSlotList);
			addToListContainer(mcMutagenSlotList);
			
			if (mcSkillSlotList)
			{
				mcSkillSlotList.focusable = false;
				_inputHandlers.push(mcSkillSlotList);
				mcSkillSlotList.addEventListener( ListEvent.INDEX_CHANGE, onSkillSelectionChanged, false, 0, true );
			}
			
			if (mcMutagenSlotList)
			{
				mcMutagenSlotList.focusable = false;
				_inputHandlers.push(mcMutagenSlotList);
				mcMutagenSlotList.visible = false;
				mcMutagenSlotList.handleScrollBar = true;
				mcMutagenSlotList.ignoreGridPosition = true;
				mcMutagenSlotList.addEventListener( ListEvent.INDEX_CHANGE, onMutagenSelectionChanged, false, 0, true );
			}
			
			SlotsTransferManager.getInstance().addDropTarget(this);
		}
		
		public function get pointsCount():int { return _pointsCount }
		public function set pointsCount(value:int):void
		{
			_pointsCount = value;
		}
		
		private var _buySkillBtnRef:Button = null;
        public function set BuySkillBtnRef(value:Button):void {
			_buySkillBtnRef = value;
		}
		
		override protected function onTabListItemSelected( event:ListEvent ):void
		{
			super.onTabListItemSelected(event);
			
			updatePointsSpentTextField();
			updateLockedIcons();
		}
		
		override protected function state_colapsed_begin():void
		{
			super.state_colapsed_begin();
			
			updatePointsSpentTextField();
		}
		
		override protected function state_Open_begin():void
		{
			super.state_Open_begin();
			
			updatePointsSpentTextField();
		}
		
		protected function updatePointsSpentTextField():void
		{
			var currentIndex:int = mcTabList.selectedIndex;
			
			if (currentIndex != TabIndex_Mutagens)
			{
				if (txtSpentPoints)
				{
					updateLockedIcons();
					txtSpentPoints.visible = true;
					txtSpentPoints.text = "[[panel_character_points_spent]]";
					txtSpentPoints.appendText(": " + mcNumSkillPoints[currentIndex]);
					txtSpentPoints.text = CommonUtils.toUpperCaseSafe(txtSpentPoints.text);
					
				}

			}
			else
			{
				if (txtSpentPoints)
				{
					txtSpentPoints.visible = false;
				}
			
			}
			
		}
		public function updateLockedIcons()
		{
			var txtValue1 = iconLock1.getChildByName("txtValue") as TextField;
			var txtValue2 = iconLock2.getChildByName("txtValue") as TextField;
			var txtValue3 = iconLock3.getChildByName("txtValue") as TextField;
			var unlockval1:Number;
			var unlockval2:Number;
			var unlockval3:Number;
			var currentIndex:int = mcTabList.selectedIndex;
			
			switch(currentIndex)
			{
				case TabIndex_Sword:
					unlockval1 	= 	8;
					unlockval2 	=	20;
					unlockval3 	=	30;
					break;
					
				case TabIndex_Signs:
					unlockval1 	= 	6;
					unlockval2 	=	18;
					unlockval3 	=	28;
					break;
					
				case TabIndex_Alchemy:
					unlockval1 	= 	8;
					unlockval2 	=	20;
					unlockval3 	=	28;
					break;
					
				
			}
			
			txtValue1.text = unlockval1.toString();
			txtValue2.text = unlockval2.toString();
			txtValue3.text = unlockval3.toString();
				
			if (txtSpentPoints && currentIndex != TabIndex_Mutagens && currentIndex != TabIndex_Perks)
			{
				
				iconLock1.visible = true;
				iconLock2.visible = true;
				iconLock3.visible = true;
				
				if (mcNumSkillPoints[currentIndex] >= unlockval1  )
				{
					iconLock1.visible = false;
				}
				
				if (mcNumSkillPoints[currentIndex] >= unlockval2 )
				{
					iconLock2.visible = false;
				}
				
				if (mcNumSkillPoints[currentIndex] >= unlockval3)
				{
					iconLock3.visible = false;
				}
			}
			else
			{
				iconLock1.visible = false;
				iconLock2.visible = false;
				iconLock3.visible = false;
			}
		}
		
		protected function onSkillSelectionChanged( event:ListEvent ):void
		{
			mcGridMask.visible = false;
			mcListContainer.mask = null;
			updateInputFeedback();
		}
		
		protected function onMutagenSelectionChanged( event:ListEvent ):void
		{
			mcGridMask.visible = true;
			mcListContainer.mask = mcGridMask;
			updateInputFeedback();
		}
		
		override protected function updateInputFeedbackButtons():void
		{
			super.updateInputFeedbackButtons();
			
			if (_buySkillBtnRef)
			{
				_buySkillBtnRef.visible = false;
			}
			
			if (_inputSymbolIDX != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDX);
				_inputSymbolIDX = -1;
			}
			
			if (isOpen)
			{
				if (_inputSymbolIDA != -1)
				{
					InputFeedbackManager.removeButton(this, _inputSymbolIDA);
					_inputSymbolIDA = -1;
				}
				
				if (_hideInputFeedback)
				{
					return;
				}
				
				if (mcTabList.selectedIndex == TabIndex_Mutagens)
				{
					var currentMutagen:SlotInventoryGrid = mcMutagenSlotList.getSelectedRenderer() as SlotInventoryGrid;
					
					if (currentMutagen && currentMutagen.data && focused && !disableMutagenEquipping)
					{
						_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_character_skill_equip"); // Text was generic (not skill specific) last time checked)
					}
				}
				else
				{
					var currentSkill:SlotSkillGrid = mcSkillSlotList.getSelectedRenderer() as SlotSkillGrid;
					
					if (currentSkill && currentSkill.data && focused)
					{
						if ((parent as MenuCharacter).moduleSkillSlot.hasSkillSlotUnlocked() && currentSkill.data.level > 0 && !currentSkill.data.isCoreSkill)
						{
							_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_character_skill_equip");
						}
						
						if (currentSkill.data.level < currentSkill.data.maxLevel && currentSkill.data.updateAvailable && _pointsCount > 0)
						{
							var text:String = currentSkill.data.level == 0 ? "panel_character_popup_title_buy_skill" : "panel_character_popup_title_upgrade_skill";
							_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.E, text);
							
							if (_buySkillBtnRef)
							{
								_buySkillBtnRef.label = text;
								_buySkillBtnRef.enabled = true;
								
								if (!InputManager.getInstance().isGamepad())
								{
									_buySkillBtnRef.visible = true;
								}
							}
						}
					}
				}
			}
		}
		
		override protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			super.handleControllerChange(event);
			
			if (_buySkillBtnRef)
			{
				if (event.isGamepad)
				{
					_buySkillBtnRef.visible = false;
				}
				else if (mcSkillSlotList.visible)
				{
					var currentSkill:SlotSkillGrid = mcSkillSlotList.getSelectedRenderer() as SlotSkillGrid;
					if (currentSkill && currentSkill.data && currentSkill.data.level < currentSkill.data.maxLevel)
					{
						_buySkillBtnRef.visible = true;
					}
				}
				
			}
		}
		
		override protected function updateSubData(index:int):void
		{
			super.updateSubData(index);
			
			if (index == TabIndex_Mutagens)
			{
				for (var i:int = 0; i < mcMutagenSlotList.getRenderersCount(); ++i)
				{
					var currentSlot:SlotInventoryGrid = mcMutagenSlotList.getRendererAt(i) as SlotInventoryGrid;
					if (currentSlot)
					{
						currentSlot.useContextMgr = false;
					}
				}
			}
			
			updatePointsSpentTextField();
		}
		
		override protected function setSubData(index:int, data:Array):void
		{
			super.setSubData(index, data);
			
			var tabItem:AdvancedTabListItem = mcTabList.getRendererAt(index) as AdvancedTabListItem;
			
			var numSkillPoints:int = 0;
			var numSkills:int = 0;
			
			if (index != TabIndex_Mutagens)
			{
				var currentData:Object;
				for (var i = 0; i < data.length; ++i)
				{
					currentData = data[i];
					
					if (!currentData.isCoreSkill && currentData.level > 0)
					{
						++numSkills;
						numSkillPoints += currentData.level;
					}
				}
				
				mcNumSkillPoints[index] = numSkillPoints;
				mcNumSkillsLearnt[index] = numSkills;
			}
			
			if (tabItem)
			{
				switch (index)
				{
				case TabIndex_Sword:
					tabItem.setText( mcNumSkillsLearnt[TabIndex_Sword].toString() );
					break;
				case TabIndex_Signs:
					tabItem.setText( mcNumSkillsLearnt[TabIndex_Signs].toString() );
					break;
				case TabIndex_Alchemy:
					tabItem.setText( mcNumSkillsLearnt[TabIndex_Alchemy].toString() );
					break;
				case TabIndex_Perks:
					tabItem.setText( mcNumSkillsLearnt[TabIndex_Perks].toString() );
					break;
				case TabIndex_Mutagens:
					tabItem.setText( countMutagens( data ).toString() );
					break;
				}
			}
		}
		
		private function countMutagens( data : Array ) : int
		{
			var i, len, sum;
			
			sum = 0
			len = data.length;

			for ( i = 0; i < len; ++i )
			{
				sum += data[ i ].quantity;
			}
			return sum;
		}
		
		override protected function setAllowSelectionHighlight(allowed:Boolean):void
		{
			super.setAllowSelectionHighlight(allowed);
			
			var currentSlotItem:SlotBase;
			var i:int;
			
			if (mcSkillSlotList)
			{
				mcSkillSlotList.validateNow();
				for (i = 0; i < mcSkillSlotList.getRenderersLength(); ++i)
				{
					currentSlotItem = mcSkillSlotList.getRendererAt(i) as SlotBase;
					
					if (currentSlotItem)
					{
						currentSlotItem.activeSelectionEnabled = allowed;
					}
				}
			}
			
			if (mcMutagenSlotList)
			{
				mcMutagenSlotList.validateNow();
				for (i = 0; i < mcMutagenSlotList.getRenderersLength(); ++i)
				{
					currentSlotItem = mcMutagenSlotList.getRendererAt(i) as SlotBase;
					
					if (currentSlotItem)
					{
						currentSlotItem.activeSelectionEnabled = allowed;
					}
				}
			}
		}
		
		override public function getDataShowerForTab(index:int):UIComponent
		{
			if (index != TabIndex_Mutagens)
			{
				return mcSkillSlotList;
			}
			else
			{
				return mcMutagenSlotList;
			}
		}
		
		/*
		 *  DRAG & DROP
		 */
		
		private var _dropEnabled:Boolean = true;
		public function get dropEnabled():Boolean { return _dropEnabled }
        public function set dropEnabled(value:Boolean):void
		{
			_dropEnabled = value;
		}
		
		private var _dropSelection:Boolean;
		public function get dropSelection():Boolean { return _dropSelection; }
        public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
			mcStateDropTarget.visible = _dropSelection && !InputManager.getInstance().isGamepad() && SlotsTransferManager.getInstance().isDragging();
		}
		
		public function get disableMutagenEquipping():Boolean { return _disableMutagenEquipping; }
		public function set disableMutagenEquipping(value:Boolean):void
		{
			_disableMutagenEquipping = value;
			updateInputFeedbackButtons();
		}
		
		public function canDrop(sourceObject:IDragTarget):Boolean
		{
			// check if child
			var curObject:DisplayObject = sourceObject as DisplayObject;
			while (curObject && curObject.parent)
			{
				if (this == curObject)
				{
					return false;
					break;
				}
				curObject = curObject.parent;
			}
			return true;
		}
		
		public function applyDrop(sourceObject:IDragTarget):void
		{
			var mutagenSlot:SlotSkillMutagen = sourceObject as SlotSkillMutagen;
			var skillSlot:SlotSkillSocket = sourceObject as SlotSkillSocket;
			
			if (mutagenSlot)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipMutagen', [mutagenSlot.slotType] ));
			}
			else
			if (skillSlot)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipSkill', [ uint( skillSlot.getDragData().slotId) ] ));
			}
		}
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			if (avatar)
			{
				var mutagenSlot:SlotSkillMutagen = avatar.getSourceContainer() as SlotSkillMutagen;
				var skillSlot:SlotSkillSocket = avatar.getSourceContainer() as SlotSkillSocket;
				
				if (mutagenSlot)
				{
					if (currentlySelectedTabIndex != CharacterTabbedListModule.TabIndex_Mutagens)
					{
						onSetTabCalled(CharacterTabbedListModule.TabIndex_Mutagens)
					}
				}
				else
				if (skillSlot)
				{
					if (skillSlot.data)
					{
						onSetTabCalled(skillSlot.data.tabId);
					}
					else
					if (currentlySelectedTabIndex == CharacterTabbedListModule.TabIndex_Mutagens)
					{
						onSetTabCalled(CharacterTabbedListModule.TabIndex_Sword);
					}
				}
			}
			return SlotDragAvatar.ACTION_GRID_DROP;
		}
	}
}
