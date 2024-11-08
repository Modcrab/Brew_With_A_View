package red.game.witcher3.slots
{
	import adobe.utils.CustomActions;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.inventory_menu.ModuleContainer;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * Slot in the inventory grid
	 * red.game.witcher3.slots.SlotInventoryGrid
	 * @author Yaroslav Getsevich
	 */
	public class SlotInventoryGrid extends SlotBase implements IInventorySlot
	{
		private static const ENABLE_DEBUG_IDX:Boolean = false;
		
		// selection offsets:
		protected var so_bottom:Number = 6;
		protected var so_top:Number = 9;
		protected var so_left_right:Number = 4;
		protected var so_left_padding:Number = 1;
		
		public var textIdx:TextField;
		public var mcGridBackground:MovieClip;
		public var equipedIcon:MovieClip;
		
		
		public function SlotInventoryGrid()
		{
			if (equipedIcon)
			{
				equipedIcon.visible = false;
			}
		}
		
		override public function set index(value:uint):void
		{
			super.index = value;
			
			if (textIdx && ENABLE_DEBUG_IDX)
			{
				textIdx.text = String(value);
			}
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			if (_data && equipedIcon)
			{
				equipedIcon.visible = _data.isEquipped;
			}
			
			if (mcStateDropTarget)
			{
				if ( _data && _data.highlighted )
				{
					mcStateDropTarget.visible = true;
					mcStateDropTarget.alpha = 1;
				}
				else
				{
					mcStateDropTarget.visible = false;
				}
			}
		}
		
		protected var _isOverburdened:Boolean = false;
		public function setOverburdened(value:Boolean):void
		{
			if (_isOverburdened != value && mcGridBackground)
			{
				_isOverburdened = value;
				if (_isOverburdened)
				{
					mcGridBackground.gotoAndPlay("Overburdened");
				}
				else
				{
					mcGridBackground.gotoAndPlay("Normal");
				}
			}
		}
		
		protected var _uplink:IInventorySlot;
		public function get uplink():IInventorySlot { return _uplink }
		public function set uplink(value:IInventorySlot):void
		{
			_uplink = value;
			mouseEnabled = !_uplink;
			if (_uplink)
			{
				var upLinkSprite:DisplayObject = _uplink as DisplayObject;
				upLinkSprite.parent.addChild(upLinkSprite);
			}
		}
		
		public function get highlight():Boolean { return _highlight }
        public function set highlight(value:Boolean):void
		{
			_highlight = value;
			invalidateState();
		}
		
		override public function toString():String
		{
			return 	"SlotInventoryGrid [ " + this.name + " ] index: " + this.index;
		}
		
		override public function cleanup():void
		{
			super.cleanup();
			
			wipeIndicators();
			gridSize = 1;
			_uplink = null;
			mouseEnabled = true;
			
			if (equipedIcon)
			{
				equipedIcon.visible = false;
			}
		}
		
		protected function wipeIndicators():void
		{
			_currentIdicator = null;
			resetIndicators();
		}
		
		override public function get selectable():Boolean
		{
			return super.selectable && _uplink == null && !_isEmpty;
		}
		
		override protected function updateSize()
		{
			super.updateSize();
			
			var len:int = _indicators.length;
			var targetRect:Rectangle = getSlotRect();
			
			for (var i:int; i < len; i++)
			{
				var curIndicator:MovieClip = _indicators[i];
				updateItemSize(curIndicator, targetRect);
			}
			
			if (mcHitArea)
			{
				updateItemSize(mcHitArea, targetRect)
			}
			if (mcColorBackground)
			{
				updateItemSize(mcColorBackground, targetRect);
			}
			if (mcCantEquipIcon)
			{
				mcCantEquipIcon.x =  targetRect.x + targetRect.width / 2
				mcCantEquipIcon.y =  targetRect.y + targetRect.height / 2
			}
			if (equipedIcon)
			{
				const ei_margin = 14;
				
				equipedIcon.width = targetRect.width + ei_margin;
				equipedIcon.height = targetRect.height + ei_margin;
				
				equipedIcon.x = targetRect.x + targetRect.width / 2;
				equipedIcon.y = targetRect.y + targetRect.height / 2;
				
				//updateItemSize(equipedIcon, targetRect);
			}
			
			if (mcSlotOverlays)
			{
				mcSlotOverlays.updateSize(getSlotRect());
			}
		}
		
		protected function updateItemSize(targetObject:MovieClip, targetRect:Rectangle):void
		{
			if (targetObject != null && targetObject == mcStateSelectedActive)
			{
				const selection_x_offset = 2; // to fix wrong asset size
				
				
				// custom rescale for selection
				targetObject.width = targetRect.width;
				targetObject.height = targetRect.height;
				targetObject.x = targetRect.x + targetObject.width / 2;
				targetObject.y = targetRect.y + targetObject.height / 2;
				
				return;
			}
			else if (targetObject as UIComponent)
			{
				(targetObject as UIComponent).setActualSize(targetRect.width, targetRect.height);
			}
			else
			{
				targetObject.width = targetRect.width;
				targetObject.height = targetRect.height;
			}
			targetObject.x = targetRect.x + targetObject.width / 2;
			targetObject.y = targetRect.y + targetObject.height / 2;
		}
		

		
		public function tryExecuteAssignedAction():void
		{
			if (useContextMgr)
			{
				//if (selected)
				//{
					callContextFunction();
				//}
			}
		}
		
		override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			if (useContextMgr)
			{
				var superMouseEvent:MouseEventEx = event as MouseEventEx;
				
				if (superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
				{
					callContextFunction();
				}
			}
			else
			{
				super.handleMouseDoubleClick(event);
			}
		}
		
		protected function callContextFunction():void
		{
			if (!owner)
			{
				// standalone slot
				return;
			}
			
			var dataStub:ItemDataStub = data as ItemDataStub;
			var parentModule:CoreMenuModule = getParentModule();
			
			if (parentModule && dataStub)
			{
				var paramsList:Array = [];
				
				paramsList.push("enter-gamepad_A");
				paramsList.push(dataStub.id);
				paramsList.push(dataStub.slotType);
				paramsList.push(parentModule.dataBindingKey);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnMouseInputHandled', paramsList ) );
			}
		}
		
		protected function getParentModule():CoreMenuModule
		{
			var curParent:DisplayObjectContainer = owner;
			var parentModule:CoreMenuModule = curParent as CoreMenuModule;
			
			while (!parentModule && curParent && curParent.parent)
			{
				curParent = curParent.parent;
				parentModule = curParent as CoreMenuModule;
			}
			return parentModule;
		}
		
		override protected function updateMouseContext():void
		{
			var dataStub:ItemDataStub = data as ItemDataStub;
			var parentModule:CoreMenuModule = getParentModule();
			
			if (parentModule && dataStub)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetMouseInventoryComponent', [parentModule.dataBindingKey, dataStub.slotType] ) );
			}
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			if (!useContextMgr) // #J hack for ItemSelectMenu (mutagen selection) and preparation
			{
				super.executeDefaultAction(keyCode, event);
			}
		}
		
	}
}
