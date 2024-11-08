package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	
	 // Why SlotPaperdoll ???
	//public class SlotSkillGrid extends SlotBase implements IInventorySlot
	public class SlotSkillGrid extends SlotPaperdoll implements IInventorySlot
	{
		public var slotBackground:MovieClip;
		public var txtLevel:TextField;
		public var skillCounterBkg:MovieClip;
		//public var equipedIcon:Sprite;
		public var unlockAnim:MovieClip;
		public var mcCollapsedTooltipIcon : MovieClip;
		public var coreFrame: MovieClip;
		
		private var _isFirstDataUpdate:Boolean;
		private var _isUnlockedAnimPlayed:Boolean;
		
		public function SlotSkillGrid()
		{
			_isLocked = false;
			if (iconLock)
			{
				iconLock.visible = false;
				iconLock.mouseEnabled = false;
				iconLock.mouseChildren = false;
			}
			if (equipedIcon)
			{
				equipedIcon.visible = false;
				equipedIcon.mouseEnabled = false;
				equipedIcon.mouseChildren = false;
			}
			if (txtLevel) txtLevel.mouseEnabled = false;
			
			dropEnabled = false;
			
			_isFirstDataUpdate = true;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			var hitArea:MovieClip = getHitArea() as MovieClip;
			if (hitArea)
			{
				hitArea.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			}
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
		
		override public function get isLocked():Boolean
		{
			return _isLocked;
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			if (!_data) return;
			if (skillCounterBkg) { skillCounterBkg.gotoAndStop(1); }
			//trace("GFX * update slot data [", this, "]", _data.maxLevel, _data.level);
			
			if (_data.color && slotBackground && _data.level > 0 && !_data.isCoreSkill)
			{
				slotBackground.gotoAndStop(_data.color);
			}
			else
			{
				slotBackground.gotoAndStop("SC_None");
			}
			
			if (_data.maxLevel && _data.maxLevel > 0 && !_data.isCoreSkill && _data.hasRequiredPointsSpent)
			{
				if (_data.level == 0)
				{
					txtLevel.text = "";
					txtLevel.visible = false;
					if (skillCounterBkg) {	skillCounterBkg.visible = false; }
				}
				else
				{
					txtLevel.text = _data.level;
					txtLevel.visible = true;
					if (skillCounterBkg) { skillCounterBkg.visible = true; }
				}
				
				if (_data.level >= _data.maxLevel)
				{
					txtLevel.textColor = 0xfff0e6;
					if (skillCounterBkg) { skillCounterBkg.gotoAndStop(2); }
				}
			}
			else
			{
				txtLevel.visible = false;
				if (skillCounterBkg) { skillCounterBkg.visible = false; }
			}
			applyAvailability();
		}
		
		override protected function handleIconLoaded(event:Event):void
		{
			super.handleIconLoaded(event);
			
			if (iconLock) addChild(iconLock);
			if (hitArea) addChild(hitArea);
			if (skillCounterBkg) addChild(skillCounterBkg);
			if (txtLevel) addChild(txtLevel);
			if (mcCollapsedTooltipIcon) addChild(mcCollapsedTooltipIcon);
			
			if (_imageLoader.content)
			{
				if (_data.level < 1 && !_data.hasRequiredPointsSpent)
				{
					_imageLoader.content.alpha = 0.2;
				}
				else
				{
					_imageLoader.content.alpha = 1;
				}
			}
		}
		
		protected function handleMouseUp(event:MouseEvent):void
		{
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx)
			{
				switch (eventEx.buttonIdx)
				{
					case MouseEventEx.RIGHT_BUTTON:
						fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
						break;
					case MouseEventEx.MIDDLE_BUTTON:
						// equip ?
						break;
					default:
						break;
				}
			}
		}
		
		protected function applyAvailability():void
		{
			this.filters = []; // Reset the filters
			
			if (equipedIcon)
			{
				
				equipedIcon.visible = _data.isEquipped;
				equipedIcon.gotoAndStop(_data.color);
				if (_data.isCoreSkill)
				{
					equipedIcon.alpha = 0.5;
					if (coreFrame)
					{
						coreFrame.visible = true;
						coreFrame.gotoAndStop(_data.color);
					}
				}
				else
				{
					equipedIcon.alpha = 1;
					coreFrame.visible = false;
				}
				
			
			}
			
			this.alpha = 1;
			if (_data.level < 1 && !_data.hasRequiredPointsSpent)
			{
				//darkenIcon(0.2);
				
				if (_imageLoader.content)
				{
					_imageLoader.content.alpha = 0.2;
				}
				
				_isLocked = true;
			}
			else
			{
				_isLocked = false;
				
				if (_imageLoader.content)
				{
					_imageLoader.content.alpha = 1;
				}
				
			}
			
			if (unlockAnim && _data.playUpgradeAnimation)
			{
				unlockAnim.gotoAndPlay(2);
				_data.playUpgradeAnimation = false;
			}
			
			iconLock.visible = false;
		}
		
		override protected function setBackgroundColor():void
		{
			mcColorBackground.setBySkillType(_data.color);
		}
		
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX ** [SlotSkillGRID][", this, this.owner, "] fireTooltipShowEvent ", activeSelectionEnabled, isParentEnabled());
			
			if (!(activeSelectionEnabled || !InputManager.getInstance().isGamepad()) && isParentEnabled())
			{
				return;
			}
			
			if (_data)
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.tooltipContentRef = "SkillTooltipRef";
				displayEvent.tooltipDataSource = "OnGetGridSkillTooltipData";
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				
				_tooltipRequested = true;
				dispatchEvent(displayEvent);
			}
		}
		
		override protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX ** [SlotSkillMutagen][", this, "] fireTooltipHideEvent ", _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}
		
		/*
		 * 	 Actions
		 */
		
	 	override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			//trace("GFX SlotSkillgrid::handleMouseDoubleClick");
			
			if (canExecuteAction())
			{
				executeDefaultAction(KeyCode.PAD_A_CROSS, null);
			}
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			//trace("GFX SlotSkillgrid::executeDefaultAction");
			
			if ( !selectable || ( event && event.details && ( event.details.value != InputValue.KEY_UP ) ) )
			{
				return;
			}
			
			if (keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE)
			{
				fireActionEvent(InventoryActionType.EQUIP, SlotActionEvent.EVENT_ACTIVATE);
				
				if (event)
				{
					event.handled = true;
				}
			}
			else
			if (keyCode == KeyCode.PAD_X_SQUARE || keyCode == KeyCode.E)
			{
				fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
				
				if (event)
				{
					event.handled = true;
				}
			}
		}
		
		override public function executeAction(keyCode:Number, event:InputEvent):Boolean
		{
			if (canExecuteAction())
			{
				executeDefaultAction(keyCode, event);
				return true;
			}
			return false;
		}
		
		/*
		 * 		- Drag & Drop -
		 */
		
		override public function canDrag():Boolean
		{
			return _data && !isLocked && _data.level > 0 && !data.isCoreSkill;
		}
		
		override public function canDrop(dragData:IDragTarget):Boolean
		{
			return false;
		}
		
		override protected function initDropTarget():void
		{
			// none
		}
		
	}
}
