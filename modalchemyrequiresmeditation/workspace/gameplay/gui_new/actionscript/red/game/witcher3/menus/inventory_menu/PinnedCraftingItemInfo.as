package red.game.witcher3.menus.inventory_menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.common.ColorSprite;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Crafting info for an Item
	 * @author Jason Slama
	 */
	public class PinnedCraftingItemInfo extends UIComponent
	{
		public var txtName 	       : TextField;
		public var txtQuantity     : TextField;
		public var iconLoader      : W3UILoader;
		public var backgroundColor : ColorSprite;
		public var mcHighlight     : MovieClip;
		
		private var iconLoaderStartY:Number = Number.POSITIVE_INFINITY;
		private var iconLoaderStartX:Number = Number.POSITIVE_INFINITY;
		
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
		}
		
		public function setItemData(data:Object):void
		{
			if (!data)
			{
				visible = false;
				return;
			}
			
			visible = true;
			
			if (data.quantity == -1)
			{
				txtQuantity.visible = false;
			}
			else
			{
				txtQuantity.visible = true;
				txtQuantity.htmlText = data.quantity + "/" + data.reqQuantity;
				
				if (data.quantity < data.reqQuantity)
				{
					txtQuantity.textColor = 0XFB8686;//red
				}
				else
				{
					txtQuantity.textColor = 0x57D338;//green
				}
			}
			var textValue: String;
			textValue = data.txtName;
			txtName.htmlText = textValue;
			if (CoreComponent.isArabicAligmentMode)
			{
				txtName.htmlText = "<p align=\"right\">" + textValue + "</p>";
			}
			
			iconLoader.source = "img://" + data.imgLoc;
			iconLoader.GridSize = data.gridSize;
			
			if (iconLoaderStartX == Number.POSITIVE_INFINITY)
			{
				iconLoaderStartX = iconLoader.x;
			}
			
			if (iconLoaderStartY == Number.POSITIVE_INFINITY)
			{
				iconLoaderStartY = iconLoader.y;
			}
			
			if (data.gridSize == 1)
			{
				iconLoader.x = iconLoaderStartX;
				iconLoader.y = iconLoaderStartY;
				iconLoader.scaleX = iconLoader.scaleY = 1;
			}
			else
			{
				iconLoader.x = iconLoaderStartX + 12;
				iconLoader.y = iconLoaderStartY - 10;
				iconLoader.scaleX = iconLoader.scaleY = 0.6;
			}
			
			if (mcHighlight)
			{
				mcHighlight.visible = data.highlight;
			}
			
			if (data.quality)
			{
				backgroundColor.setByItemQuality(data.quality);
				backgroundColor.visible = true;
			}
			else
			{
				backgroundColor.visible = false;
			}
		}
	}
}
