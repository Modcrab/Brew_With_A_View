package red.game.witcher3.tooltips
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Tooltip for inventory item 
	 * Control scheme [MOUSE + KEYBOARD]
	 * @author Getsevich Yaroslav
	 */
	public class TooltipInventoryMouse extends TooltipInventory
	{		
		protected const LEFT_EDGE:Number = 0;
		protected const RIGHT_EDGE:Number = 395;
		
		public var mcDelimiter1:Sprite;
		public var mcDelimiter2:Sprite;
		public var mcDelimiter3:Sprite;
		public var mcOilIndicator:Sprite;
		public var txtOilInfo:TextField;
		
		override protected function configUI():void
		{
			super.configUI();
			mcPropertyList.isHorizontal = true;
			_comparisonTooltipRef = "ItemTooltipRef_mouse";
			
			_availableNameWidthConst = 450;
		}
		
		override protected function populateItemData()
		{
			super.populateItemData();
			
			var curHeight:Number = 0;
			
			tfItemName.width = RIGHT_EDGE;
			tfItemName.height = tfItemName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			tfItemRarity.x = LEFT_EDGE;
			tfItemType.x = RIGHT_EDGE - tfItemType.width;
			
			
			if (mcEnchantedTypeIcon && mcEnchantedTypeIcon.visible)
			{
				mcEnchantedTypeIcon.x = tfItemType.x - mcEnchantedTypeIcon.width - ENCHANT_ICON_PADDING;
			}
			
			if (mcPrimaryStat.visible)
			{
				delDescription.visible = true;
				curHeight = delDescription.y + BLOCK_PADDING;
			}
			else
			{
				delDescription.visible = false;
				curHeight = delTitle.y + BLOCK_PADDING;
			}
			
			curHeight = alignElement(tfDescription, curHeight, BLOCK_PADDING);
			curHeight = alignElement(mcAttributeList, curHeight, BLOCK_PADDING);
			
			if (!tfDescription.visible && !mcAttributeList.visible)
			{
				//mcDelimiter1.visible = false;
			}
			else
			{
				//mcDelimiter1.visible = true;
				//curHeight = alignElement(mcDelimiter1, curHeight, BLOCK_PADDING);
			}
			
			if (!_data.appliedEnchantmentInfo)
			{
				curHeight = alignElement(mcSocketList, curHeight, BLOCK_PADDING);
			}
			else
			{
				if (tfEnchantmentInfo.textHeight > mcEnchantmentIcon.height)
				{
					tfEnchantmentInfo.y = curHeight;
					mcEnchantmentIcon.y = tfEnchantmentInfo.y + tfEnchantmentInfo.height / 2;
				}
				else
				{
					mcEnchantmentIcon.y = curHeight + mcEnchantmentIcon.height / 2;
					tfEnchantmentInfo.y = mcEnchantmentIcon.y - tfEnchantmentInfo.textHeight / 2;
				}
				
				curHeight += (Math.max(tfEnchantmentInfo.textHeight, mcEnchantmentIcon.height) + BLOCK_PADDING);
			}
			
			if (_data.appliedOilInfo)
			{
				mcOilInfo.y = curHeight;
				mcOilInfo.visible = true;
				
				txtOilInfo.y = curHeight;
				txtOilInfo.htmlText = _data.appliedOilInfo;
				txtOilInfo.visible = true;
				
				curHeight += (txtOilInfo.textHeight + BLOCK_PADDING);
				//tfItemRarity.y = curHeight + tfItemRarity.textHeight;
			}
			else
			{
				mcOilInfo.visible = false;
				txtOilInfo.visible = false;
				
			}
			
			curHeight = alignElement(tfRequiredLevel, curHeight, BLOCK_PADDING);
			curHeight = alignElement(mcDelimiter2, curHeight, BLOCK_PADDING);
			
			curHeight = alignElement(mcPropertyList, curHeight, BLOCK_PADDING);
			
			if (btnCompareHint.visible)
			{
				const button_padding = 22;
				
				//curHeight = alignElement(mcDelimiter3, curHeight, BLOCK_PADDING);
				
				btnCompareHint.y = curHeight + button_padding;
				curHeight += button_padding * 2 + BLOCK_PADDING;
				
				btnCompareHint.x = RIGHT_EDGE - btnCompareHint.actualWidth;
				
				//mcDelimiter3.visible = true;
			}
			else
			{
				//mcDelimiter3.visible = false;
			}
			
			mcBackground.height = curHeight + backgroundAdditionalHeight;
		}
		
		override protected function cutTextFieldContent(textField:TextField, maxLines:Number):void
		{
			//
		}
		
		private function alignElement(target:DisplayObject, yPosition:Number, padding:Number):Number
		{
			if (target && target.visible)	
			{
				var targetComponent:UIComponent = target as UIComponent;
				
				target.y = yPosition;
				
				if (targetComponent && targetComponent.actualHeight)
				{
					return yPosition + targetComponent.actualHeight + padding;
				}
				else
				{
					return yPosition + target.height + padding;
				}
			}
			
			return yPosition;
		}
		
	}

}
