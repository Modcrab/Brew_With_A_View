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
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IPaperdollSlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import flash.geom.Rectangle;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * Slot in the paperdoll
	 * @author Yaroslav Getsevich
	 */
	public class SlotCrafting extends SlotInventoryGrid
	{
		public var mcMissingIngredient    : MovieClip;
		public var mcCraftableBackground  : MovieClip;
		public var mcFrameBkg			  : MovieClip;
		public var mcVendorIcon 		  : MovieClip;
		public var tfVendorQuantity	      : TextField;
		
		public var mcCollapsedTooltipIcon : MovieClip;
		
		public function SlotCrafting()
		{
			mcVendorIcon.mouseEnabled = false;
			mcVendorIcon.mouseChildren = false;
			tfVendorQuantity.mouseEnabled = false;
		}
		
		override protected function configUI():void
		{
			super.configUI();
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
		
		override protected function handleIconLoaded(event:Event):void
		{
			super.handleIconLoaded(event);
		
			if (mcCollapsedTooltipIcon) addChild(mcCollapsedTooltipIcon);
		}
		
		override protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			super.handleControllerChanged(event);
		}
		
		override protected function handleMouseClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			
			if (!data || data.vendorQuantity < 1)
			{
				return;
			}
			
			if (superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				//#Y TEMP for this prototype will use direct call
				
				trace("" )
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnBuyIngredient", [ int(data.id), Boolean( (data.reqQuantity - data.quantity) == 1) ] ) );
			}
		}
		
		override public function executeAction(keyCode:Number, event:InputEvent):Boolean
		{
			if (!data)
			{
				return false;
			}
			
			if ( keyCode == KeyCode.PAD_Y_TRIANGLE )
			{
				//#Y TEMP for this prototype will use direct call
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnBuyIngredient", [ int(data.id), Boolean( (data.reqQuantity - data.quantity) == 1) ] ) );
			}
			
			return false;
		}
		
		override protected function loadIcon(iconPath:String):void
		{
			super.loadIcon(iconPath);
			
			if (tfVendorQuantity)
			{
				addChild( tfVendorQuantity );
			}
			
			if (mcVendorIcon )
			{
				addChild( mcVendorIcon );
			}
		}
		
		override public function get selectable():Boolean
		{
			return _selectable && !isEmpty();
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			
			if( !data )
			{
				visible = false;
			}
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			if (!data)
			{
				visible = false;
				return;
			}
			
			visible = true;
			
			if (mcVendorIcon && tfVendorQuantity)
			{
				if (_data.vendorQuantity > 0)
				{
					mcVendorIcon.visible = true;
					tfVendorQuantity.visible = true;
					tfVendorQuantity.text = _data.vendorQuantity + "";
				}
				else
				{
					mcVendorIcon.visible = false;
					tfVendorQuantity.visible = false;
				}
			}
			
			if (_data.reqQuantity)
			{
				mcSlotOverlays.SetQuantity(_data.quantity + "/" + _data.reqQuantity);
				mcSlotOverlays.SetQuantityCraftingColor(_data.reqQuantity <= _data.quantity);
			}
			
			if (mcMissingIngredient)
			{
				mcMissingIngredient.visible = _data.quantity < _data.reqQuantity;
			}
		}
		
		override public function getSlotRect():Rectangle
		{
			if (mcHitArea)
			{
				return new Rectangle( mcHitArea.x - mcHitArea.width / 2, mcHitArea.y - mcHitArea.height / 2, mcHitArea.width, mcHitArea.height );
			}
			else
			{
				return super.getSlotRect();
			}
		}
		
		override protected function selectingTooltipShowCheck():Boolean
		{
			return true;
		}
		
		protected var _mouseOverTrigger : Boolean = false;
		override protected function handleMouseOver(event:MouseEvent):void
		{
			_mouseOverTrigger = true;
			super.handleMouseOver( event );
		}
		
		override protected function handleMouseOut(event:MouseEvent):void
		{
			_mouseOverTrigger = false;
			super.handleMouseOut(event);
		}
		
		// #Y HOTFIX TTP: 115188 Cert 2(30.03.2015)
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			// trace("GFX [SlotBase][", this, "] fireTooltipShowEvent, activeSelectionEnabled  ", activeSelectionEnabled, "; _mouseOverTrigger ", _mouseOverTrigger, "; isParentEnabled() ", isParentEnabled());
			
			if ( ( activeSelectionEnabled || ( !InputManager.getInstance().isGamepad() && _mouseOverTrigger ) ) && _data && isParentEnabled())
			{
				_mouseOverTrigger = false;
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				//displayEvent.isMouseTooltip = isMouseTooltip;
				//displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				displayEvent.tooltipContentRef = "IngredientTooltipRef";
				dispatchEvent(displayEvent);
				_tooltipRequested = true;
			}
		}
		
		// diabled
		override protected function updateItemSize(targetObject:MovieClip, targetRect:Rectangle):void {	}
		override protected function defaultSlotEquipAction(itemData:Object):void { }
	}

}
