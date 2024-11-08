package red.game.witcher3.menus.inventory_menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Crafting info for the shop
	 * @author Jason Slama
	 */
	public class PinnedCraftingInfoModule extends UIComponent
	{
		public var txtTitle : TextField;
		public var txtRecipeTitle : TextField;
		
		public var craftedItemInfo : PinnedCraftingItemInfo;
		
		public var ingredientItemInfo1 : PinnedCraftingItemInfo;
		public var ingredientItemInfo2 : PinnedCraftingItemInfo;
		public var ingredientItemInfo3 : PinnedCraftingItemInfo;
		public var ingredientItemInfo4 : PinnedCraftingItemInfo;
		public var ingredientItemInfo5 : PinnedCraftingItemInfo;
		public var ingredientItemInfo6 : PinnedCraftingItemInfo;
		public var ingredientItemInfo7 : PinnedCraftingItemInfo;
		
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
			
			txtTitle.htmlText = "[[panel_shop_title_pinned_recipe]]";
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
			
			txtRecipeTitle.htmlText = "[[panel_alchemy_required_ingridients]]";
			txtRecipeTitle.htmlText = CommonUtils.toUpperCaseSafe(txtRecipeTitle.htmlText);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.pinned.crafting.info", [setPinnedCraftingInfo] ) );
		}
		
		protected function setPinnedCraftingInfo(data:Array):void
		{
			var i:int;
			
			if (data.length > 0)
			{
				visible = true;
				
				craftedItemInfo.setItemData(data[0]);
				
				if (data.length > 1)
				{
					ingredientItemInfo1.setItemData(data[1]);
				}
				
				if (data.length > 2)
				{
					ingredientItemInfo2.setItemData(data[2]);
				}
				
				if (data.length > 3)
				{
					ingredientItemInfo3.setItemData(data[3]);
				}
				
				if (data.length > 4)
				{
					ingredientItemInfo4.setItemData(data[4]);
				}
				
				if (data.length > 5)
				{
					ingredientItemInfo5.setItemData(data[5]);
				}
				
				if (data.length > 6)
				{
					ingredientItemInfo6.setItemData(data[6]);
				}
				
				if (data.length > 7)
				{
					ingredientItemInfo7.setItemData(data[7]);
				}
			}
		}
	}
} 