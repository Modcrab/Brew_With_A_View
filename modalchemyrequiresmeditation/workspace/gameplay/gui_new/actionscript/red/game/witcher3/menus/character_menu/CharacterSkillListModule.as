package red.game.witcher3.menus.character_menu 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3Button;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	// #J TODO: if we need more of this kind of class, group generic logic into a generic controller or rename this to something like W3TabListController
	public class CharacterSkillListModule extends CoreMenuModule
	{
		public var txfCategoryName:TextField;
		public var txfNumPoints:TextField;
		public var mcCategoryList:W3ScrollingList;
		public var mcSkillTreeSlotList:CharacterSkillSlotsList;
		
		public var numSkillPointsAvailable:int = 0;
		
		private static var _dataBindingKey:String = "character.skills.grid.internal";
		private static var CATEGORY_LIST_PADDING:Number = 37;
		
		private var _categoryData:Array = new Array();
		private var _categories:Array = new Array();
		
		private var _leftStickNavigation:Boolean = false;
		private var _lastSelectedRow:int = 0;
		private var _fromLeft:Boolean = false;
		
		private var _inputSymbolIDA:int = -1;
		private var _inputSymbolIDX:int = -1;
		private var _inputSymbolIDPad:int = -1;
		
		private var _buySkillBtnRef:Button = null;
		private var _pointsCount:int = 0;
		
        public function set BuySkillBtnRef(value:Button):void {
			_buySkillBtnRef = value;
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey, [handleListData] ) );
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			mcCategoryList.addEventListener( ListEvent.INDEX_CHANGE, OnListItemClicked, false, 0, true );
			mcSkillTreeSlotList.addEventListener( ListEvent.INDEX_CHANGE, OnSkillTreeClicked, false, 0, true );
			
			mcCategoryList.focusable = false
			
			mcSkillTreeSlotList.enabled = true;
			mcSkillTreeSlotList.visible = true;
			mcSkillTreeSlotList.focusable = false;
			
			_inputHandlers.push(mcSkillTreeSlotList);
		}
		
		override public function hasSelectableItems():Boolean
		{
			if (mcSkillTreeSlotList.getSelectedRenderer() == null || (mcSkillTreeSlotList.getSelectedRenderer() as SlotBase).data == null)
			{
				return false;
			}
			
			return true;
		}
		
		protected function OnSkillTreeClicked( event:ListEvent ):void
		{
			UpdateSkillInfo();
		}
		
		protected function UpdateSkillInfo():void
		{
			if (_inputSymbolIDA != -1) 
			{ 
				InputFeedbackManager.removeButton(this, _inputSymbolIDA); 
				_inputSymbolIDA = -1;
			}
			
			if (_inputSymbolIDX != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDX);
				_inputSymbolIDX = -1;
				if (_buySkillBtnRef) _buySkillBtnRef.enabled = false
			}
			
			var currentSkill:SlotSkillGrid = mcSkillTreeSlotList.getSelectedRenderer() as SlotSkillGrid;
			
			if (currentSkill && currentSkill.data && focused)
			{
				if (currentSkill.data.level > 0 && !currentSkill.data.isEquipped)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1, "panel_character_skill_equip"); // #J not sure what PC control will be (if any)
				}
				
				if (currentSkill.data.level < currentSkill.data.maxLevel && currentSkill.data.updateAvailable && _pointsCount > 0)
				{
					var text:String = currentSkill.data.level == 0 ? "panel_character_popup_title_buy_skill" : "panel_character_popup_title_upgrade_skill";
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.ENTER, text);
					
					if (_buySkillBtnRef) 
					{
						_buySkillBtnRef.label = text;
						_buySkillBtnRef.enabled = true;
					}
				}
			}
			
			InputFeedbackManager.updateButtons(this);
		}
		
		protected function OnListItemClicked( event:ListEvent ):void
		{
			if (event.index < _categories.length)
			{
				SetCategoryText(_categories[event.index]);
				if (mcSkillTreeSlotList)
				{
					mcSkillTreeSlotList.data = _categoryData[event.index];
					mcSkillTreeSlotList.validateNow();
					
					if (focused == 1 && (mcSkillTreeSlotList.getSelectedRenderer() == null || (mcSkillTreeSlotList.getSelectedRenderer() as SlotBase).data == null))
					{
						stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE, false, false));
					}
					
					var currentSlot:SlotBase = mcSkillTreeSlotList.getSelectedRenderer() as SlotBase;
					
					if (currentSlot != null && currentSlot.data != null)
					{
						currentSlot.activeSelectionEnabled = this.focused;
					}
					
					if (_leftStickNavigation && _lastSelectedRow >= 0)
					{
						_leftStickNavigation = false;
						
						var numColumns:int = mcSkillTreeSlotList.numColumns;
						var numElements:int = _categoryData[event.index].length;
						
						if (!_fromLeft)
						{
							mcSkillTreeSlotList.selectedIndex = Math.min(Math.floor(_categoryData[event.index].length / numColumns), _lastSelectedRow) * numColumns;
						}
						else
						{
							var currentSearchIndex:int = (_lastSelectedRow + 1) * numColumns - 1;
							
							while (currentSearchIndex > 0)
							{
								var currentRenderer:SlotBase = mcSkillTreeSlotList.getRendererAt(currentSearchIndex) as SlotBase;
								
								if (currentRenderer && (currentRenderer.data != null || !currentRenderer.isEmpty()))
								{
									mcSkillTreeSlotList.selectedIndex = currentSearchIndex;
									break;
								}
								
								currentSearchIndex -= numColumns;
							}
							
							if (currentSearchIndex < 0)
							{
								mcSkillTreeSlotList.findSelection();
							}
						}
					}
					else
					{
						mcSkillTreeSlotList.findSelection();
					}
				}
			}
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			
			//mcSkillTreeSlotList.focused = value;
			//mcCategoryList.focused = value;
			
			if (focused)
			{
				var currentSkill:SlotBase = mcSkillTreeSlotList.getRendererAt(mcSkillTreeSlotList.selectedIndex) as SlotBase;
				
				if (currentSkill)
				{
					currentSkill.showTooltip();
				}
			}
			
			//_inputSymbolIDPad
			if (focused && _inputSymbolIDPad == -1)
			{
				_inputSymbolIDPad = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_LR, -1, "panel_button_common_change_tab"); // #J for pc, could put arrow keys but keycode not currently supported
			}
			else if (!focused && _inputSymbolIDPad != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDPad);
				_inputSymbolIDPad = -1;
			}
			
			var currentSlot:SlotBase = mcSkillTreeSlotList.getSelectedRenderer() as SlotBase;
			
			if (currentSlot)
			{
				currentSlot.activeSelectionEnabled = value;
			}
			
			
			// #J Note because of SetItemSlotTooltip(), we don't need to call InputFeedbackManager.updateButtons(this); directly, if you remove it please add the call
			
			UpdateSkillInfo();
		}
		
		private function SetCategoryText(categoryInfo:Array):void
		{
			if (txfCategoryName)
			{
				if (categoryInfo.length > 0)
				{
					txfCategoryName.text = categoryInfo[0] as String;
				}
				else
				{
					txfCategoryName.text = "ERROR";
				}
			}
			
			if (txfNumPoints)
			{
				if (categoryInfo.length > 2)
				{
					txfNumPoints.text = "[[panel_character_points_spent]]";
					txfNumPoints.appendText(": " + categoryInfo[2]);
				}
				else
				{
					txfNumPoints.text = "ERROR: " + categoryInfo.length;
				}
			}
		}
		
		public function get pointsCount():int { return _pointsCount }
		public function set pointsCount(value:int):void
		{
			_pointsCount = value;
		}
		
		public function stableUpdateData(value:Array):void
		{
			handleListData(value, -1);
		}
		
		public function handleListData(gameData:Object, index:int):void 
		{
			if (!gameData)
				return;
			
			fillDataProvider(gameData);
			
			repositionListRenderers();
		}
		
		// #J hacky way to avoid having to detangle initialization flow which is setting the tooltip before the tooltip system is ready for it
		public function fireFirstTooltip():void
		{
			var currentSelectedSkill:SlotBase = mcSkillTreeSlotList.getSelectedRenderer() as SlotBase;
			if (currentSelectedSkill)
			{
				currentSelectedSkill.showTooltip();
			}
		}
		
		private function fillDataProvider(gameData:Object):void
		{
			_categoryData.length = 0;
			_categories.length = 0;
				
			var data:Array = gameData as Array;
			var currentCategoryIndex:uint = 0;
			var categoryDataArray:Array = new Array();
			var categoryPoints:Number = 0;
			
			var categoryIndex = 0;
			var i:int;
			var cat_it:int;
			var dataCategory:String = "";
			
			// This may seem a little costly way to do things but it has the advantage of not assuming anything about the data order
			for (i = 0; i < data.length; ++i)
			{
				dataCategory = data[i].dropDownLabel as String
				
				categoryIndex = -1;
				for (cat_it = 0; cat_it < _categories.length; ++cat_it)
				{
					if (_categories[cat_it][0] == dataCategory)
					{
						categoryIndex = cat_it;
						break;
					}
				}
				
				// Hasn't been seen before, create and add the arrays needed to track this newly found category
				if (categoryIndex == -1)
				{
					categoryIndex = _categoryData.length;
					
					categoryDataArray = new Array();
					categoryDataArray.push(dataCategory);
					categoryDataArray.push(categoryIndex);
					categoryDataArray.push(data[i].skillPathPoints);
					categoryDataArray.push(data[i].color);
					_categories.push(categoryDataArray);
					
					_categoryData.push(new Array());
				}
				
				// Add in new item data to categories
				//_categories[categoryIndex][2] += data[i].level;
				_categoryData[categoryIndex].push(data[i]);
			}
			
			if (_categoryData.length != _categories.length)
			{
				throw new Error("GFX - Something went terribly wrong when organizing received data");
			}
			
			mcCategoryList.dataProvider = new DataProvider(_categories);
			mcCategoryList.GenerateRenderers();
			mcCategoryList.validateNow();
			mcCategoryList.enabled = true;
			
			if (mcCategoryList.selectedIndex == -1)
			{
				mcCategoryList.focused = focused;
				mcCategoryList.selectedIndex = 0;
			}
			else
			{
				SetCategoryText(_categories[mcCategoryList.selectedIndex]);
			}
			
			var prevTreeSelect:int = mcSkillTreeSlotList.selectedIndex;
			
			if (mcCategoryList.selectedIndex == -1) 
			{ 
				mcSkillTreeSlotList.data = _categoryData[0];
			}
			else
			{
				mcSkillTreeSlotList.data = _categoryData[mcCategoryList.selectedIndex];
			}
			
			mcSkillTreeSlotList.validateNow();
			
			if (prevTreeSelect == -1)
			{
				mcSkillTreeSlotList.selectedIndex = 0;
			}
			else
			{
				mcSkillTreeSlotList.selectedIndex = prevTreeSelect;
			}
			
			stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE, false, false));
		}
		
		private function repositionListRenderers():void
		{	
			var i :int;
			var curSkillItem : CharacterSkillListItem;
			// #J the items are about 24 pixels lower than their position because of way movie clips done and I don't have access to the fla at the moment.
			var nextPosX : Number = 0;
			var nextPosY : Number = 0;
			
			for ( i = 0; i < mcCategoryList.dataProvider.length; ++i)
			{
				curSkillItem = mcCategoryList.getRendererAt(i) as CharacterSkillListItem;
				
				if (curSkillItem)
				{
					curSkillItem.x = nextPosX;
					curSkillItem.y = nextPosY;
					nextPosX += curSkillItem.width + CATEGORY_LIST_PADDING;
					curSkillItem.owner = mcCategoryList;
					curSkillItem.focusable = false;
					curSkillItem.focusTarget = mcCategoryList;
					curSkillItem.toggle = true;
					curSkillItem.allowDeselect = false;
				}
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{	
			if (!event.handled)
			{
				mcCategoryList.handleInput(event);
			}
			
			if (!focused || event.handled)
				return;
			
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if (handler)
				{
					if (handler is SlotsListBase)
					{
						(handler as SlotsListBase).handleInputNavSimple(event);
					}
					else
					{
						handler.handleInput( event );
					}

					if ( event.handled )
					{
						event.stopImmediatePropagation();
						return;
					}
				}
			}
		}
	}
}
