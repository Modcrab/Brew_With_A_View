package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class SlotSkillMutagen extends SlotBase implements IDropTarget
	{
		protected static const DISABLED_ALPHA:Number = .4;
		
		public var iconLock:Sprite;
		public var background:MovieClip;
		public var mcCollapsedTooltipIcon : MovieClip;
		
		protected var _slotType:int;
		protected var _locked:Boolean;
		
		public function SlotSkillMutagen()
		{
			iconLock.visible = false;
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			
			/*
			trace("GFX ********** [SlotSkillMutagen] set data ", data);
			
			if (data)
			{
				trace("GFX * ", data.color);
			}
			*/
		}
		
		/*
		public var tmpT:TextField;
		override public function set index(value:uint):void
		{
			super.index = value;
			
			if (tmpT)
				tmpT.text = String(value);
		}
		*/
		
		[Inspectable(defaultValue = "false")]
		public function get slotType():int { return _slotType };
		public function set slotType(value:int):void
		{
			_slotType = value;
		}
		
		public function isLocked():Boolean
		{
			return _locked;
		}
		
		public function isMutEquiped():Boolean
		{
			return _data && _data.id;
		}
		
		override protected function initCollapsedIconBehavior():void
		{
			AUTO_SHOW_COLLAPSED_ICON = true;
			
			_mcCollapsedTooltipIcon = mcCollapsedTooltipIcon;
			
			if (_mcCollapsedTooltipIcon)
			{
				_mcCollapsedTooltipIcon.visible = false;
			}
			
			super.initCollapsedIconBehavior();
		}
		
		override protected function canExecuteAction():Boolean
		{
			return true;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			SlotsTransferManager.getInstance().addDropTarget(this);
		}
		
		override protected function updateData()
		{
			if (_data)
			{
				_locked = !_data.unlocked;
				iconLock.visible = _locked;
				
				if (_data.iconPath && _loadedImagePath != _data.iconPath)
				{
					_loadedImagePath = _data.iconPath;
					loadIcon(_loadedImagePath);
				}
				background.gotoAndStop(_data.color)
			}
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			if ( !selectable || !enabled)
			{
				return;
			}
			
			if (keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE)
			{
				fireActionEvent(InventoryActionType.EQUIP, SlotActionEvent.EVENT_ACTIVATE);
				if (event)
				{
					dispatchEvent(new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true));
					event.handled = true;
				}
			}
			if (keyCode == KeyCode.PAD_X_SQUARE)
			{
				fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
				if (event)
				{
					event.handled = true;
				}
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			alpha = enabled ? 1 : DISABLED_ALPHA;
		}
		
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			if (!(activeSelectionEnabled || !InputManager.getInstance().isGamepad()) && isParentEnabled())
			{
				return;
			}
			
			if (isMutEquiped())
			{
				super.fireTooltipShowEvent(isMouseTooltip);
			}
			else if (data && activeSelectionEnabled)
			{
				//trace("TP ** [SlotSkillMutagen][", this, "] fireTooltipShowEvent ");
				
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.tooltipContentRef = "SkillTooltipRef";
				displayEvent.tooltipMouseContentRef = "SkillTooltipRef";
				displayEvent.tooltipCustomArgs = [ _data.unlockedAtLevel ];
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				
				if (_data.unlocked) // Empty tooltip
				{
					displayEvent.tooltipDataSource = "OnGetMutagenEmptyTooltipData";
				}
				else // Locked tooltip
				{
					displayEvent.tooltipDataSource = "OnGetMutagenLockedTooltipData";
				}
				
				_tooltipRequested = true;
				dispatchEvent(displayEvent);
			}
		}
		
		override protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("TP ** [SlotSkillMutagen][", this, "] fireTooltipHideEvent ", _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
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
		
		override public function canDrag():Boolean
		{
			return !isLocked() && isMutEquiped();
		}
		
		public function canDrop(sourceObject:IDragTarget):Boolean
		{
			return !(sourceObject is SlotPaperdoll) && !_locked;
		}
		
		public function get dropSelection():Boolean { return _dropSelection }
        public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
			invalidateState();
		}
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			if (avatar)
			{
				_highlight = true;
			}
			else
			{
				_highlight = false;
			}
			invalidateState();
			
			return isMutEquiped() ? SlotDragAvatar.ACTION_SWAP : SlotDragAvatar.ACTION_DROP;
		}
		
		public function applyDrop(source:IDragTarget):void
		{
			var itemData:Object = source.getDragData() as Object;
			var mutSlot:SlotSkillMutagen = source as SlotSkillMutagen;
			
			if (itemData)
			{
				if (mutSlot)
				{
					if (!isMutEquiped())
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnMoveMutagenToEmptySlot', [uint(itemData.id), mutSlot.slotType, slotType ] ) );
					}
					else
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipMutagen', [uint(data.id), mutSlot.slotType] ) );
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipMutagen', [uint(itemData.id), slotType] ) );
					}
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipMutagen', [uint(itemData.id), slotType] ) );
				}
				
				// update selection
				var ownerList:SlotsListPreset = owner as SlotsListPreset;
				if (ownerList)
				{
					ownerList.dispatchItemClickEvent(this);
				}
			}
		}
		
		override public function set dragSelection(value:Boolean):void
		{
			super.dragSelection = value;
			
			// to select mutagen tab
			/*
			if (isMutEquiped())
			{
				dispatchEvent(new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true));
			}
			*/
		}
		
		override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			trace("GFX mut handleMouseDoubleClick");
			super.handleMouseDoubleClick(event);
			
			if (selectable)
			{
				// to select mutagen tab
				dispatchEvent(new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true));
			}
		}
		
	}
}
