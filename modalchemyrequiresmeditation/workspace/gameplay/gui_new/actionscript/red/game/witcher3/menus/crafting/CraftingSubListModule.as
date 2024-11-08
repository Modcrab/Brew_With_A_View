/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.crafting
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.menus.common.JournalRewardModule;
	import red.game.witcher3.utils.CommonUtils;

	public class CraftingSubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var mcCraftFeedback : MovieClip;

		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

		public function CraftingSubListModule()
		{
			super();
			mcRewards.dataBindingKeyReward = "crafting.sublist.items";
			mcRewards.titleString = "[[panel_alchemy_required_ingridients]]";
			mcCraftFeedback.tfCraft.htmlText = "[[panel_alchemy_craft_item]]";
			mcCraftFeedback.tfCraft.htmlText = CommonUtils.toUpperCaseSafe(mcCraftFeedback.tfCraft.htmlText);
			dataBindingKey = "crafting.sublist";
		}

		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent(new GameEvent(GameEvent.REGISTER, dataBindingKey + '.showfeedback', [ShowCraftingFeedback]));
		}

		override public function toString() : String
		{
			return "[W3 CraftingSubListModule]"
		}

		public function ShowCraftingFeedback(bShow : Boolean):void
		{
			mcCraftFeedback.visible = bShow;
		}
	}
}
