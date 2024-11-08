/***********************************************************************
/** Inventory Slot Overlays: quantity and icons
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.inventory
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.core.UIComponent;
	
	public class InventorySlotOverlay extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcDyePreviewColor:MovieClip;
		public var mcDyeColor:MovieClip;
		public var mcPreviewIcon:MovieClip;
		public var mcEnchantmentIcon:MovieClip;
		public var mcQuestIndicator:MovieClip;
		public var mcIconRepair:MovieClip;
		public var mcIconEquipped:MovieClip;
		public var mcIconNewItem:MovieClip;
		public var mcOilIndicator:Sprite;
		public var mcCollapsedTooltipIcon:MovieClip;
		public var tfQuantity:TextField;

		/********************************************************************************************************************
			COMPONENT PROPERTIES
		/ ******************************************************************************************************************/
				
		protected var _oilApplied : Boolean = false;
		protected var _equipped : Boolean = false;
		protected var _newItem : Boolean = false;
		protected var _needRepair : Boolean = false;
		protected var _dyePreview : Boolean = false;
		protected var _dyeColor : String = "";
		protected var _gridSize : int = 1;
		protected var _defaultQuantityTxtColor : uint;
		protected var _socketsContainer:Sprite;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function InventorySlotOverlay()
		{
			super();
			
			if (tfQuantity)
			{
				tfQuantity.autoSize = TextFieldAutoSize.RIGHT;
			}
			
			if (mcOilIndicator)
			{
				mcOilIndicator.visible = false;
			}
			
			if (mcIconNewItem)
			{
				mcIconNewItem.visible = false;
				mcIconNewItem.mouseEnabled = false;
			}
			
			if (mcIconEquipped)
			{
				mcIconEquipped.mouseChildren = false;
			}
			
			if (mcQuestIndicator)
			{
				mcQuestIndicator.visible = false;
			}
			
			if (mcEnchantmentIcon)
			{
				mcEnchantmentIcon.visible = false;
			}
			
			if (mcIconRepair)
			{
				mcIconRepair.visible = false;
			}
			
			if (mcPreviewIcon)
			{
				mcPreviewIcon.visible = false;
			}
			
			if (mcDyeColor)
			{
				mcDyeColor.visible = false;
			}
			
			if (mcDyePreviewColor)
			{
				mcDyePreviewColor.visible = false;
			}
			
			if (mcCollapsedTooltipIcon)
			{
				mcCollapsedTooltipIcon.visible = false;
			}
			
			_socketsContainer = new Sprite();
			addChild(_socketsContainer);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (tfQuantity)
			{
				_defaultQuantityTxtColor = tfQuantity.textColor;
				//tfQuantity.visible = false;
			}
		}
		
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/
		
		public function SetDyePreview( value : Boolean) : void
		{
			_dyePreview = value;
		}
		
		public function SetAppliedDyeColor(value:String):void
		{
			_dyeColor = value;
		}
		
		public function SetEquipped( equipped : Boolean) : void
		{
			_equipped = equipped;
		}
				
		public function GetEquipped( ) : Boolean
		{
			return _equipped;
		}
		
		public function SetIsNew( isNew : Boolean) : void
		{
			_newItem = isNew;
		}
		
		public function SetNeedRepair( needRepair : Boolean) : void
		{
			_needRepair = needRepair;
		}
		
		public function SetQuantity( quantity : String) : void
		{
			if ( tfQuantity )
			{
				if (quantity == "0" || quantity == "1" || quantity == "")
				{
					tfQuantity.text = "";
					//tfQuantity.visible = false;
				}
				else
				{
					tfQuantity.htmlText = quantity;
					//tfQuantity.visible = true;
				}
			}
		}
		
		public function SetIsQuestItem( isQuest : Boolean , tag:String) : void
		{
			if (mcQuestIndicator)
			{
				if (isQuest == true)
				{
					mcQuestIndicator.visible = true;
					mcQuestIndicator.gotoAndStop(tag);
				}
				else
				{
					mcQuestIndicator.visible = false;
				}
			}
		}
		
		public function SetQuantityCraftingColor(enoughQty:Boolean):void
		{
			if (tfQuantity)
			{
				if (!enoughQty)
				{
					tfQuantity.textColor = 0xec1212;//red 
				}
				else
				{
					tfQuantity.textColor = 0x57D338;//green
				}
			}
		}
		
		public function SetEnchantment(showicon:Boolean, socketsCount:int):void
		{
			if (_socketsContainer)
			{
				if (!showicon && socketsCount > 0)
				{
					_socketsContainer.visible = true;
				}
				else
				{
					_socketsContainer.visible = false;
				}
			}
			
			if (mcEnchantmentIcon)
			{
				mcEnchantmentIcon.visible = showicon;
			}
		}
		
		public function SetGridSize( gridSize : int ) : void
		{
			_gridSize = gridSize;
			gotoAndStop(_gridSize);
		}
		
		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		
		public function updateIcons():void
		{
			if ( mcIconEquipped )
			{
				if (mcIconRepair.totalFrames > 1)
				{
					if(_equipped)
					{
						mcIconEquipped.gotoAndStop("equipped");
					}
					else
					{
						mcIconEquipped.gotoAndStop("none");
					}
				}
				else
				{
					mcIconRepair.visible = _equipped;
				}
			}
			
			if ( mcIconRepair )
			{
				mcIconRepair.visible = _needRepair;
			}
			
			if ( mcIconNewItem )
			{
				if(_newItem)
				{
					mcIconNewItem.visible = true;
				}
				else
				{
					mcIconNewItem.visible = false;
				}
			}
			
			if (mcDyeColor)
			{
				if (_dyeColor)
				{
					mcDyeColor.gotoAndStop(_dyeColor);
					mcDyeColor.visible = true;
				}
				else
				{
					mcDyeColor.visible = false;
				}
			}
			
			if (mcDyePreviewColor)
			{
				if (_dyePreview)
				{
					mcDyePreviewColor.visible = true;
				}
				else
				{
					mcDyePreviewColor.visible = false;
				}
			}
			
			realignIcons();
		}
		
		public function ResetIcons() : void
		{
			_equipped = false;
			_newItem = false;
			_needRepair = false;
		}
		
		/*
		 *  Oil
		 */
		
		public function setOilApplied(value:Boolean):void
		{
			_oilApplied = value;
			if (mcOilIndicator)
			{
				mcOilIndicator.visible = _oilApplied;
			}
		}
		
		
		public function setPreviewIcon(value:Boolean):void
		{
			if (mcPreviewIcon)
			{
				mcPreviewIcon.visible = value;
			}
		}
		
		protected var _targetRect:Rectangle;
		public function updateSize(targetRect:Rectangle):void
		{
			_targetRect = targetRect;
			realignIcons();
		}
		
		private function realignIcons():void
		{
			const icon_padding_top = 10;
			const icon_padding = 6;
			const newIconOffset = 20;
			
			if (_targetRect)
			{
				var repairOffset:Number = 0;
				
				if (mcQuestIndicator)
				{
					mcQuestIndicator.x = _targetRect.x + 8;
					mcQuestIndicator.y = _targetRect.y + _targetRect.height - mcQuestIndicator.height - 2;
				}
				if (mcCollapsedTooltipIcon)
				{
					mcCollapsedTooltipIcon.x = _targetRect.x + (_targetRect.width - mcCollapsedTooltipIcon.width) / 2  - 2;
					mcCollapsedTooltipIcon.y = _targetRect.y + _targetRect.height - mcCollapsedTooltipIcon.height - 2;
				}
				if ( mcDyeColor ) 
				{
						mcDyeColor.y = _targetRect.y + _targetRect.height - mcCollapsedTooltipIcon.height + 5;
				}
				if (mcOilIndicator)
				{
					mcOilIndicator.x = _targetRect.x + icon_padding;
					mcOilIndicator.y = _targetRect.y + _targetRect.height - mcOilIndicator.height - icon_padding_top;
				}
				if (mcIconNewItem && mcIconNewItem.visible)
				{
					mcIconNewItem.width = _targetRect.width;
					mcIconNewItem.height = _targetRect.height;
					mcIconNewItem.x = _targetRect.width / 2;
					mcIconNewItem.y = _targetRect.height / 2;
					repairOffset = newIconOffset;
				}
				if (mcIconRepair)
				{
					mcIconRepair.x = _targetRect.x + _targetRect.width - mcIconRepair.width - icon_padding;
					mcIconRepair.y = _targetRect.y + repairOffset + icon_padding_top;
				}
				
				if (mcEnchantmentIcon)
				{
					mcEnchantmentIcon.x = _targetRect.x + icon_padding;
					mcEnchantmentIcon.y = _targetRect.y + icon_padding;
				}
				
				if (mcPreviewIcon)
				{
					mcPreviewIcon.x = _targetRect.x + _targetRect.width / 2;
					mcPreviewIcon.y = _targetRect.y + _targetRect.height / 2;
				}
				if (tfQuantity)
				{
					tfQuantity.y =  _targetRect.y + _targetRect.height - tfQuantity.textHeight - icon_padding;
				}
			}
		}
		
		/*
		 * 	Slots
		 */
		
		private static const SOCKET_PADDING:Number = 3;
		private static const SOCKET_TOP_OFFSET:Number = 8;
		private static const SOCKET_REF:String = "SlotSocketRef";
		private var _slotsItems:Vector.<MovieClip> = new Vector.<MovieClip>;
		public function updateSlots(slotsCount:int, usedSlotsCount:int):void
		{
			if (isNaN(slotsCount) || isNaN(usedSlotsCount)) return;
			
			var i:int;
			
			for (i = 0; i < _slotsItems.length; ++i)
			{
				_slotsItems[i].gotoAndStop("empty");
			}
			
			var socketContentRef:Class = getDefinitionByName(SOCKET_REF) as Class;
			while (_slotsItems.length > slotsCount)	_socketsContainer.removeChild(_slotsItems.pop());
			while (_slotsItems.length < slotsCount)
			{
				var newIcon:MovieClip = new socketContentRef() as MovieClip;
				_socketsContainer.addChild(newIcon);
				_slotsItems.push(newIcon);
			}
			
			var maxHeight:Number = parent.height;
			for (i = 0; i < slotsCount; i++ )
			{
				_slotsItems[i].x = SOCKET_PADDING;
				_slotsItems[i].y = (SOCKET_PADDING + _slotsItems[i].height) * i + SOCKET_TOP_OFFSET;
				
				if (usedSlotsCount > 0)
				{
					_slotsItems[i].gotoAndStop("used");
					usedSlotsCount--;
				}
			}
		}
	}
}
