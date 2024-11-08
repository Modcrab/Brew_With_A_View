package red.game.witcher3.tooltips
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.controls.W3UILoaderPaperdollSlot;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.interfaces.IAnchorable;
	import red.game.witcher3.menus.common.W3StatsListItem;
	import red.game.witcher3.controls.W3ScrollingList
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.data.DataProvider;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * Items tooltip
	 * Used in the Hud Loot module only
	 * @author Yaroslav Getsevich
	 */
	public class TooltipItem extends TooltipBase implements IAnchorable
	{
		protected static const PADDING_DESCRIPTION:Number = -5;
		protected static const MIN_WIDTH:Number = 554;
		protected static const MIN_HEIGHT:Number = 210;
		protected static const MAX_WIDTH:Number = 550;
		protected static const MAX_HEIGHT:Number = 1000;

		public var tfItemName:TextField;
		public var tfItemTitle:TextField;
		public var tfItemRarity:TextField;
		public var tfItemType:TextField;

		public var mcIconLoader:W3UILoaderPaperdollSlot;
		//public var mcIconLoader:W3UILoaderSlot;

		public var mcPriceIcon:MovieClip;
		public var mcWeightIcon:MovieClip;
		public var mcDurabilityIcon:MovieClip;
		public var tfPriceValue:TextField;
		public var tfWeightValue:TextField;
		public var tfDurabilityValue:TextField;
		public var tfDescription:TextField;

		public var mcStatsList:RenderersList;
		public var mcTextDescription:W3TextArea;
		public var mcBackground:Sprite;
		public var mcTitleBackground:Sprite;

		protected var _iconPath:String;


		public function TooltipItem()
		{
			super();
			visible = false;
		}

		override protected function populateData():void
		{
			super.populateData();
			
		}
	}
}
