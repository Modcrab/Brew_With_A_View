package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.constants.ItemQuality;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IPaperdollSlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.character_menu.CharacterModeBackground;
	import red.game.witcher3.menus.common.ItemDataStub;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * Slot in the paperdoll
	 * @author Yaroslav Getsevich
	 */
	public class SlotPaperdoll extends SlotInventoryGrid implements IPaperdollSlot, IDropTarget
	{
		public var tfSlotName:TextField;
		public var defaultIcon:MovieClip;
		public var iconLock:MovieClip;
		public var mcPreviewIcon:MovieClip;
		
		public var sectionId:int = -1;
		
		protected var _slotTag:String;
		protected var _slotTypeID:int;
		protected var _equipID:int;
		
		public function SlotPaperdoll()
		{
			_defaultTooltipAnchor = "tooltipPaperdollAnchor";
			AUTO_SHOW_COLLAPSED_ICON = true;
		}
		
		protected var _selectionMode:Boolean;
		public function get selectionMode():Boolean { return _selectionMode };
		public function set selectionMode(value:Boolean):void
		{
			_selectionMode = value;
		}
		
		protected var _darkUnselectable:Boolean = true;
		public function get darkUnselectable():Boolean { return _darkUnselectable }
		public function set darkUnselectable(value:Boolean):void
		{
			_darkUnselectable = value;
		}
		
		/*
		 * 		- Drag & Drop -
		 */
		
		private var _dropEnabled:Boolean = true;
		public function get dropEnabled():Boolean { return _dropEnabled }
        public function set dropEnabled(value:Boolean):void
		{
			_dropEnabled = value;
		}
		
		override public function set dragSelection(value:Boolean):void
		{
			super.dragSelection = value;
			
			if (value && !isEmpty() && data)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnDragItemStarted", [data.id] ) );
			}
		}
		
		public function applyDrop(source:IDragTarget):void
		{
			var itemData:ItemDataStub = source.getDragData() as ItemDataStub;
			
			switch (_currentDropAction)
			{
				case SlotDragAvatar.ACTION_ENHANCE:
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyUpgrade", [ itemData.id, slotTagToType(slotTag) ]) );
					break;
				case SlotDragAvatar.ACTION_OIL:
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyOil", [ itemData.id, slotTagToType(slotTag) ]) );
					break;
				case SlotDragAvatar.ACTION_REPAIR:
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyRepairKit", [ itemData.id, slotTagToType(slotTag) ]) );
					break;
				case SlotDragAvatar.ACTION_DIY:
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyDye", [ itemData.id, slotTagToType(slotTag) ]) );
					break;
				default:
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnDropOnPaperdoll", [ itemData.id, slotTagToType(slotTag), itemData.quantity ]) );
					break;
			}
			
			// update selection
			var ownerList:SlotsListPaperdoll = owner as SlotsListPaperdoll;
			if (ownerList)
			{
				ownerList.dispatchItemClickEvent(this);
			}
		}
		
		override public function canDrag():Boolean
		{
			// we can't drag default bolts
			if (data && data.cantUnequip)
			{
				return false;
			}
			return super.canDrag();
		}
		
		// cache drop action
		private var _currentDropAction:int = SlotDragAvatar.ACTION_NONE;
		public function canDrop(dragData:IDragTarget):Boolean
		{
			var itemData:ItemDataStub = dragData.getDragData() as ItemDataStub;
			var slotData:ItemDataStub = _data as ItemDataStub;
			
			if (itemData && !isLocked)
			{
				// the same item
				
				if (slotData && slotData.id == itemData.id)
				{
					_currentDropAction = SlotDragAvatar.ACTION_NONE;
					return false;
				}
				
				// check slot type
				if (!CheckSlotsType(itemData.slotType))
				{
					// check oils and upgrades
					if (!isEmpty() && slotData)
					{
						var isSteelSword:Boolean = slotData.slotType == InventorySlotType.SteelSword;
						var isSilverSword:Boolean = slotData.slotType == InventorySlotType.SilverSword;
						var isArmor:Boolean = slotData.slotType == InventorySlotType.Armor ||
											  slotData.slotType == InventorySlotType.Boots ||
											  slotData.slotType == InventorySlotType.Gloves ||
											  slotData.slotType == InventorySlotType.Pants;
						var canBeUpgraded:Boolean = slotData.socketsCount > slotData.socketsUsedCount && !slotData.enchanted;
						
						if(slotData.quality == ItemQuality.SET && itemData.isDye && isArmor && slotData.canBeDyed)
						{
							_currentDropAction = SlotDragAvatar.ACTION_DIY;
							return true;
						}
						if (itemData.isSteelOil && isSteelSword)
						{
							_currentDropAction = SlotDragAvatar.ACTION_OIL;
							return true;
						}
						else
						if (itemData.isSilverOil && isSilverSword)
						{
							_currentDropAction = SlotDragAvatar.ACTION_OIL;
							return true;
						}
						else if (itemData.isArmorUpgrade && isArmor && canBeUpgraded)
						{
							_currentDropAction = SlotDragAvatar.ACTION_ENHANCE;
							return true;
						}
						else if (itemData.isWeaponUpgrade && (isSteelSword || isSilverSword) && canBeUpgraded)
						{
							_currentDropAction = SlotDragAvatar.ACTION_ENHANCE;
							return true;
						}
						else if (itemData.isWeaponRepairKit && (isSteelSword || isSilverSword) && slotData.durability < 100)
						{
							_currentDropAction = SlotDragAvatar.ACTION_REPAIR;
							return true;
						}
						else if (itemData.isArmorRepairKit && isArmor && slotData.durability < 100)
						{
							_currentDropAction = SlotDragAvatar.ACTION_REPAIR;
							return true;
						}
					}
					_currentDropAction = SlotDragAvatar.ACTION_ERROR;
					return false;
				}
				
				if (isEmpty())
				{
					_currentDropAction = SlotDragAvatar.ACTION_DROP;
				}
				else
				{
					_currentDropAction = SlotDragAvatar.ACTION_SWAP;
				}
				return true;
			}
			
			_currentDropAction = SlotDragAvatar.ACTION_ERROR;
			return false;
		}
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			if (avatar)
			{
				highlight = true;
			}
			else
			{
				highlight = false;
			}
			return _currentDropAction;
		}
		
		public function get dropSelection():Boolean { return _dropSelection }
        public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
			invalidateState();
		}
		
		override public function set selectable(value:Boolean):void
		{
			if (value)
			{
				//this.filters = []; // Reset the filters (not ideal if this gets more complex)
				alpha = 1;
			}
			else
			{
				if (_darkUnselectable)
				{
					//darkenIcon(0.6);
					alpha = .1;
				}
			}
			
			super.selectable = value;
		}
		
		override public function get selectable():Boolean
		{
			return _selectable;
		}
		
		override public function executeAction(keyCode:Number, event:InputEvent):Boolean
		{
			if (useContextMgr && isEmpty() && (keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE))
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnEmptySlotActivate", [this.equipID] ) );
				if (event) event.handled = true;
				trace("GFX ------------------- /handled/ B1");
				return true;
			}
			else
			{
				return super.executeAction(keyCode, event);
			}
		}
		
		override protected function defaultSlotEquipAction(itemData:Object):void
		{
			if (useContextMgr)
			{
				if (!isEmpty())
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnequipItem", [ itemData.id, -1 ] ) );
				}
			}
		}
		
		override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
				
			if (superMouseEvent && superMouseEvent.buttonIdx != MouseEventEx.LEFT_BUTTON)
			{
				return;
			}
			
			if (useContextMgr)
			{
				if (selectionMode)
				{
					dispatchEvent(new Event( CharacterModeBackground.ACCEPT, true ));
				}
				else
				if (!isEmpty())
				{
					//defaultSlotEquipAction(_data);
					callContextFunction();
				}
				else
				{
					
					executeAction(KeyCode.PAD_A_CROSS, null);
				}
			}
			else
			{
				executeDefaultAction(KeyCode.PAD_A_CROSS, null);
			}
		}
		
		/*
		 *
		 */
		
		override protected function configUI():void
		{
			super.configUI();
			initDropTarget();
			
			if (iconLock)
			{
				iconLock.visible = false;
			}
			
			if (_lockedDataProvider != CommonConstants.INVALID_STRING_PARAM)
			{
				dispatchEvent( new GameEvent(GameEvent.REGISTER, _lockedDataProvider, [setIsLocked]));
			}
			
			if (tfSlotName)
			{
				tfSlotName.mouseEnabled = false;
			}
			
			if (mcPreviewIcon)
			{
				mcPreviewIcon.visible = false;
			}
		}
		
		protected function initDropTarget():void
		{
			SlotsTransferManager.getInstance().addDropTarget(this);
		}
		
		protected var _lockedDataProvider:String = CommonConstants.INVALID_STRING_PARAM;
		[Inspectable(defaultValue=CommonConstants.INVALID_STRING_PARAM)]
		public function get lockedDataProvider():String { return _lockedDataProvider; }
		public function set lockedDataProvider(value:String):void
		{
			_lockedDataProvider = value;
		}
		
		
		protected var _isLocked:Boolean = false;
		public function get isLocked():Boolean { return _isLocked; }
		protected function setIsLocked(value:Boolean):void
		{
			_isLocked = value;
			if (value)
			{
				iconLock.visible = true;
			}
			else
			{
				iconLock.visible = false;
			}
		}
		
		override protected function updateSize()
		{
			// Ignore this
			// Use authortime configuration
		}
		
		/*
		 * 			- inspectable -
		 */
		
		[Inspectable(name = "Tooltip Alignment", type = "List", defaultValue = "Right", enumeration = "Right,Left")]
		public function get tooltipAlignment():String { return _tooltipAlignment }
		public function set tooltipAlignment(value:String):void
		{
			_tooltipAlignment = value;
		}
		
		[Inspectable(defaultValue = "0")]
		public function get slotTypeID():int {	return _slotTypeID	}
		public function set slotTypeID( value:int ):void { _slotTypeID = value; }
		
		[Inspectable(defaultValue = "0")]
		public function get equipID():int {	return _equipID	}
		public function set equipID( value:int ):void { _equipID = value; }
		
		
		[Inspectable(defaultValue = "")]
		// Hmm..
		public function get slotTag():String { return _slotTag;	}
		public function set slotTag( value:String ):void
		{
			_slotTag = value;
			
			if (tfSlotName)
			{
				if (!_slotTag)
				{
					tfSlotName.htmlText = "";
				}
				if ( _slotTag.indexOf("quick") != -1)
				{
					tfSlotName.htmlText = "";
				}
				else if ( _slotTag.indexOf("potion") != -1 )
				{
					tfSlotName.htmlText = "";
				}
				else if ( _slotTag.indexOf("petard") != -1 )
				{
					tfSlotName.htmlText = "";
				}
				else
				{
					tfSlotName.htmlText = "[[panel_inventory_paperdoll_slotname_"+_slotTag+"]]";
				}
			}
			
			if (_slotTag)
			{
				defaultIcon.gotoAndStop(_slotTag);
				defaultIcon.visible = true;
			}
			else
			{
				defaultIcon.visible = false;
			}
		}
		
		public function get slotType():int
		{
			return slotTagToType( _slotTag );
		}
		
		override protected function updateData()
		{
			super.updateData();
			if (_data && defaultIcon)
			{
				defaultIcon.visible = false;
			}
		}
		
		override public function cleanup():void
		{
			super.cleanup();
			if (_slotTag)
			{
				defaultIcon.visible = true;
				// NGE
				if(_slotTag == "quick2")
					loadIcon("icons\\inventory\\slots\\mask2.png");
				// NGE
			}
			if (_selected && InputManager.getInstance().isGamepad())
			{
				// show empty tooltip on unequip
				fireTooltipShowEvent();
			}
		}
		
		override protected function loadIcon(iconPath:String):void
		{
			super.loadIcon(iconPath);
			
			if (mcPreviewIcon)
			{
				addChild( mcPreviewIcon );
			}
		}
		
		override protected function wipeIndicators():void
		{
			//
		}
		
		// Hmmm...
		private function slotTagToType( slotTag:String ):int
		{
			var slotType:int = InventorySlotType.InvalidSlot;
			
			switch ( slotTag )
			{
				case "steel":
					slotType = InventorySlotType.SteelSword;
					break;
				case "silver":
					slotType = InventorySlotType.SilverSword;
					break;
				case "armor":
					slotType = InventorySlotType.Armor;
					break;
				case "gloves":
					slotType = InventorySlotType.Gloves;
					break;
				case "trousers":
					slotType = InventorySlotType.Pants;
					break;
				case "boots":
					slotType = InventorySlotType.Boots;
					break;
				case "trophy":
					slotType = InventorySlotType.Trophy;
					break;
				case "quick1":
					slotType = InventorySlotType.Quickslot1;
					break;
				case "quick2":
					slotType = InventorySlotType.Quickslot2;
					break;
				case "rangeweapon":
					slotType = InventorySlotType.RangedWeapon;
					break;
				case "petard1":
					slotType = InventorySlotType.Petard1;
					break;
				case "petard2":
					slotType = InventorySlotType.Petard1;
					break;
				case "potion1":
					slotType = InventorySlotType.Potion1;
					break;
				case "potion2":
					slotType = InventorySlotType.Potion2;
					break;
				case "potion3":
					slotType = InventorySlotType.Potion3;
					break;
				case "potion4":
					slotType = InventorySlotType.Potion4;
					break;
				case "mutagen1":
					slotType = InventorySlotType.Mutagen1;
					break;
				case "mutagen2":
					slotType = InventorySlotType.Mutagen2;
					break;
				case "mutagen3":
					slotType = InventorySlotType.Mutagen3;
					break;
				case "mutagen4":
					slotType = InventorySlotType.Mutagen4;
					break;
				case "bolt":
					slotType = InventorySlotType.Bolt;
					break;
					
				
				// Horse inventory:
				
				case "horseBag":
					slotType = InventorySlotType.HorseBag;
					break;
				case "horseBlinders":
					slotType = InventorySlotType.HorseBlinders;
					break;
				case "horseSaddle":
					slotType = InventorySlotType.HorseSaddle;
					break;
				case "horseTrophy":
					slotType = InventorySlotType.HorseTrophy;
					break;
					
				default:
					break;
			}
			return slotType;
		}
		
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SLOT] fireTooltipShowEvent; isMouseTooltip: ", isMouseTooltip, "; ", _data);
			var displayEvent:GridEvent;
			
			if (!(activeSelectionEnabled || !InputManager.getInstance().isGamepad()) && isParentEnabled())
			{
				return;
			}
			
			if (_data)
			{
				if (_data.prepItemType == 3)
				{
					displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, null);
					
					if (!_data.showExtendedTooltip)
					{
						displayEvent.tooltipContentRef = "ItemDescriptionTooltipRef";
					}
					else
					{
						displayEvent.tooltipContentRef = "ItemTooltipRef";
					}
					//displayEvent.tooltipMouseContentRef = "ItemTooltipRef_mouse";
					displayEvent.tooltipDataSource = "OnGetAppliedOilTooltip";
					displayEvent.tooltipForceSetDataSource = true;
					displayEvent.tooltipCustomArgs = [ equipID ];
					displayEvent.isMouseTooltip = isMouseTooltip;
					displayEvent.anchorRect = getGlobalSlotRect();
					displayEvent.tooltipAlignment = _tooltipAlignment;
					//displayEvent.defaultAnchor = _defaultTooltipAnchor;
					dispatchEvent(displayEvent);
				}
				else
				{
					super.fireTooltipShowEvent(isMouseTooltip);
				}
			}
			else
			{
				displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, null);
				displayEvent.tooltipMouseContentRef = "TooltipEmptySlotRef";
				displayEvent.tooltipContentRef = "TooltipEmptySlotRef";
				displayEvent.tooltipDataSource = "OnGetEmptyPaperdollTooltip";
				displayEvent.tooltipForceSetDataSource = true;
				displayEvent.tooltipCustomArgs = [ equipID, isLocked ];
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				displayEvent.tooltipAlignment = _tooltipAlignment;
				//displayEvent.defaultAnchor = _defaultTooltipAnchor;
				dispatchEvent(displayEvent);
				_tooltipRequested = true;
			}
		}
		
		// hmm..
		public function CheckSlotsType( checkSlotType : int ) : Boolean
		{
			var curSlotTag:int = slotTagToType(slotTag);

			if( checkSlotType == InventorySlotType.Petard1 )
			{
				if ( curSlotTag == InventorySlotType.Petard2 )
				{
					//return true;
				}
			}
			else if ( checkSlotType == InventorySlotType.Petard2 )
			{
				return false;
				/*if ( curSlotTag == InventorySlotType.Petard1 )
				{
					//return true;
				}*/
			}
			/*else if( checkSlotType == InventorySlotType.Quickslot1 )
			{
				if ( curSlotTag == InventorySlotType.Quickslot2 )
				{
					return true;
				}
			}
			else if ( checkSlotType == InventorySlotType.Quickslot2 )
			{
				if ( curSlotTag == InventorySlotType.Quickslot1 )
				{
					return true;
				}
			}*/
			else if ((checkSlotType == InventorySlotType.Potion1 || checkSlotType == InventorySlotType.Potion2 ||
				 checkSlotType == InventorySlotType.Potion3 || checkSlotType == InventorySlotType.Potion4) &&
				(curSlotTag == InventorySlotType.Potion1 || curSlotTag == InventorySlotType.Potion2 ||
				 curSlotTag == InventorySlotType.Potion3 || curSlotTag == InventorySlotType.Potion4))
			{
				return true;
			}
			else if( checkSlotType == InventorySlotType.Potion1 )
			{
				if ( curSlotTag == InventorySlotType.Potion2 )
				{
					return true;
				}
			}
			else if ( checkSlotType == InventorySlotType.Potion2 )
			{
				if ( curSlotTag == InventorySlotType.Potion1 )
				{
					return true;
				}
			}
			
			return checkSlotType == curSlotTag;
		}
		
		override public function toString():String
		{
			return "SlotPaperdoll [" + this.name + "] ";
		}
	}

}
