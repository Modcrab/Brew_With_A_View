package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.character_menu.SkillSocketsGroup;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class SlotSkillSocket extends SlotSkillGrid implements IDropTarget
	{
		public static var GLOW_EQUIPPED : Boolean = false;
		public static const NULL_SKILL  : String = "ESP_NotSet";
		
		public var mcRuneGlow    : MovieClip;
		public var mcColorBorder : MovieClip;
		
		protected var _slotId    : int;
		protected var _connector : String;
		
		public var skillSocketGroupRef : SkillSocketsGroup;
		
		public function SlotSkillSocket()
		{
			dropEnabled = true;
			
			if (mcRuneGlow)
			{
				mcRuneGlow.visible = false;
			}
			
			if (mcColorBorder)
			{
				mcColorBorder.visible = false;
			}
		}
		
		[Inspectable(defaultValue = "")]
		public function get connector():String { return _connector }
		public function set connector(value:String):void
		{
			_connector = value;
		}
		
		[Inspectable(defaultValue = "0")]
		public function get slotId():int { return _slotId }
		public function set slotId(value:int):void
		{
			_slotId = value;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			SlotsTransferManager.getInstance().addDropTarget(this);
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			if (mcColorBorder)
			{
				if (_data.colorBorder)
				{
					mcColorBorder.gotoAndStop(_data.colorBorder);
					mcColorBorder.visible = true;
				}
				else
				{
					mcColorBorder.visible = false;
				}
			}
		}
		
		override protected function loadIcon(iconPath:String):void
		{
			if (_data && _data.skillPath != NULL_SKILL)
			{
				super.loadIcon(iconPath);
				if (_imageLoader)
				{
					_imageLoader.visible = true;
				}
			}
			else
			{
				unloadIcon();
			}
		}
		
		override protected function applyAvailability():void
		{
			if (_data)
			{
				_isLocked = !_data.unlocked;
				iconLock.visible = _isLocked;
				updateConnector(_data.color);
			}
			
			if (equipedIcon)
			{
				if (_data && !_data.isCoreSkill)
				{
					equipedIcon.visible = _data.isEquipped;
					if (mcRuneGlow) mcRuneGlow.visible = _data.isEquipped && GLOW_EQUIPPED && _data.highlight;
				}
				else
				{
					equipedIcon.visible = false;
					if (mcRuneGlow) mcRuneGlow.visible = false;
				}
			}
		}
		
		protected function updateConnector(targetColor:String):void
		{
			if (skillSocketGroupRef != null)
			{
				skillSocketGroupRef.updateData();
			}
		}
		
		/*
		 * Tooltip
		 */
		
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("TP *** [SlotSkillSocket][", this, "] fireTooltipShowEvent ", activeSelectionEnabled, _data);
			
			if (!(activeSelectionEnabled || !InputManager.getInstance().isGamepad()) && isParentEnabled())
			{
				return;
			}
			
			if (_data)
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.tooltipContentRef = "SkillTooltipRef";
				displayEvent.tooltipMouseContentRef = "SkillTooltipRef";
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				
				if (_data.skillPath != NULL_SKILL) // Skill tooltip
				{
					displayEvent.tooltipDataSource = "OnGetSlotSkillTooltipData";
				}
				else if (_data.unlocked) // Empty tooltip
				{
					displayEvent.tooltipCustomArgs = [ _data.unlockedOnLevel ];
					displayEvent.tooltipDataSource = "OnGetEmptySlotTooltipData";
				}
				else if (_data.isMutationSkill) // Locked by mutation
				{
					displayEvent.tooltipCustomArgs = [ _data.unlockedOnLevel ];
					displayEvent.tooltipDataSource = "OnGetLockedMutationSkillSlotTooltipData";
				}
				else // Locked tooltip
				{
					displayEvent.tooltipCustomArgs = [ _data.unlockedOnLevel ];
					displayEvent.tooltipDataSource = "OnGetLockedTooltipData";
				}
				
				_tooltipRequested = true;
				dispatchEvent(displayEvent);
			}
		}
		
		override protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("TP *** [SlotSkillSocket][", this, "] fireTooltipHideEvent ", _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}
		
		override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			var selectEvent:SlotActionEvent = new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true);
			
			//trace("GFX SlotSkillSocket::handleMouseDoubleClick");
			
			if (_data && _data.skillPath && _data.skillPath != NULL_SKILL && !_selectionMode)
			{
				selectEvent.data = _data;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipSkill', [_data.slotId] ));
				cleanup();
			}
			else
			{
				super.handleMouseDoubleClick(event);
			}
			
			dispatchEvent(selectEvent);
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			//trace("GFX SlotSkillSocket::executeDefaultAction");
			
			super.executeDefaultAction(keyCode, event);
			
			if (event.handled)
			{
				var selectEvent:SlotActionEvent = new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true);
				
				if (_data && _data.skillPath && _data.skillPath != NULL_SKILL)
				{
					selectEvent.data = _data;
				}
				
				dispatchEvent(selectEvent);
			}
		}
		
		/*
		 * 		- Drag & Drop -
		 */
		
		override public function canDrag():Boolean
		{
			return super.canDrag();
		}
		
		override public function canDrop(dragData:IDragTarget):Boolean
		{
			const COLOR_PREFIX_LEN:int = 3;
			var itemData:Object = dragData.getDragData() as Object;
			
			if (itemData && itemData.color && data && data.colorBorder)
			{
				
				var colorPureName:String = itemData.color.substr(COLOR_PREFIX_LEN).toUpperCase();
				var allowedColors:String = data.colorBorder.toUpperCase();
				
				if (allowedColors.indexOf(colorPureName) < 0 )
				{
					return false;
				}
			}
			
			// swap check
			if (itemData && itemData.colorBorder && data && data.color && data.color != "SC_None")
			{
				colorPureName = data.color.substr(COLOR_PREFIX_LEN).toUpperCase();
				allowedColors = itemData.colorBorder.toUpperCase();
				
				if (allowedColors.indexOf(colorPureName) < 0 )
				{
					return false;
				}
			}
			
			return selectable && itemData && itemData.skillType && itemData.skillType != "S_Undefined" && !_isLocked;
		}
		
		override public function get dropSelection():Boolean { return _dropSelection }
        override public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
			invalidateState();
		}
		
		override public function applyDrop(source:IDragTarget):void
		{
			if (_data)
			{
				var itemData:Object = source.getDragData() as Object;
				var slotId:uint = _data.slotId;
				var skillId:uint = itemData.skillTypeId;
				
				if (skillId == _data.skillTypeId)
				{
					return;
				}
				
				if (isSkillEquipped() && itemData.slotId)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSwapSkill', [uint(skillId), slotId, uint(_data.skillTypeId), itemData.slotId] ));
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipSkill', [uint(skillId), slotId] ));
				}
				
				// update selection
				var ownerList:SlotsListPreset = owner as SlotsListPreset;
				if (ownerList)
				{
					ownerList.dispatchItemClickEvent(this);
				}
			}
		}
		
		override public function processOver(avatar:SlotDragAvatar):int
		{
			if (avatar)
			{
				highlight = true;
			}
			else
			{
				highlight = false;
			}
			
			if (data && avatar && avatar.data && (avatar.data.skillTypeId == _data.skillTypeId))
			{
				return SlotDragAvatar.ACTION_NONE;
			}
			
			return isSkillEquipped() ?  SlotDragAvatar.ACTION_SWAP : SlotDragAvatar.ACTION_DROP;
		}
		
		override protected function initDropTarget():void
		{
			SlotsTransferManager.getInstance().addDropTarget(this);
		}
		
		override public function set dragSelection(value:Boolean):void
		{
			super.dragSelection = value;
			
			// to select mutagen tab
			/*
			var selectEvent:SlotActionEvent = new SlotActionEvent(SlotActionEvent.EVENT_SELECT, true);
			selectEvent.data = data;
			dispatchEvent(selectEvent);
			*/
		}
		
		protected function isSkillEquipped():Boolean
		{
			return _data && _data.skillPath && _data.skillPath != NULL_SKILL;
		}
		
		/*
		public var tmpT:TextField;
		override public function set index(value:uint):void
		{
			super.index = value;
			if (tmpT) tmpT.text = String(value);
		}
		*/

	}

}
