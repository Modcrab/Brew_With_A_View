/***********************************************************************
/** Journal Legend
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.menus.journal.ObjectiveItemRenderer;
	import red.game.witcher3.utils.CommonUtils;

	public class JournalLegend extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var tfLegend : TextField;

		public var mcSeparatorMiddle : MovieClip;
		public var mcSeparatorBottom : MovieClip;
		public var mcLegendBackground : MovieClip;

		public var mcFeedbackList : W3ScrollingList;
		public var mcFeedbackListItem1 : ObjectiveItemRenderer;
		public var mcFeedbackListItem2 : ObjectiveItemRenderer;
		public var mcFeedbackListItem3 : ObjectiveItemRenderer;
		public var mcFeedbackListItem4 : ObjectiveItemRenderer;

		public var mcFeedbackQuestList : W3ScrollingList;
		public var mcFeedbackQuestListItem1 : IconItemRenderer;
		public var mcFeedbackQuestListItem2 : IconItemRenderer;
		public var mcFeedbackQuestListItem3 : IconItemRenderer;

		public var titleString : String = "[[panel_journal_quest_legend]]";
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		public var dataBindingKeyFeedbackLegend : String = "journal.legend.list";
		public var dataBindingKeyQuestFeedbackLegend : String = "journal.legend.quests.list";

		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

		public function JournalLegend()
		{
			super();
		}

		protected override function configUI():void
		{
			super.configUI();
			mouseEnabled = mouseChildren = false;

			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKeyFeedbackLegend, [handleLegendFeedbackDataSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKeyQuestFeedbackLegend, [handleLegendFeedbackQuestDataSet]));
			Init();
		}

		protected function Init() : void
		{
			if ( tfLegend )
			{
				tfLegend.htmlText = titleString;
				tfLegend.htmlText = CommonUtils.toUpperCaseSafe(tfLegend.htmlText);
			}
		}

		override public function toString() : String
		{
			return "[W3 JournalLegend]"
		}

		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/

		protected function handleLegendFeedbackDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;

			if ( index > 0 )
			{
				if (gameData)
				{
					mcFeedbackList.dataProvider = new DataProvider(dataArray);
				}
			}
			else if (gameData)
			{
				mcFeedbackList.dataProvider = new DataProvider(dataArray);
			}
			mcFeedbackList.ShowRenderers(true);
			mcFeedbackList.selectedIndex = -1;
			mcFeedbackList.focusable = false;
			//mcFeedbackList.selectable = false;

			for( var i : int = 0; i < mcFeedbackList.dataProvider.length; i++ )
			{
				var feedbackRenderer : ObjectiveItemRenderer = mcFeedbackList.getRendererAt(i) as ObjectiveItemRenderer;
				feedbackRenderer.RemoveEventListeners();
				feedbackRenderer.mouseEnabled = false;
			}
		}

		protected function handleLegendFeedbackQuestDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			if ( index > 0 )
			{
				if (gameData)
				{
					mcFeedbackQuestList.dataProvider = new DataProvider(dataArray);
				}
			}
			else if (gameData)
			{
				mcFeedbackQuestList.dataProvider = new DataProvider(dataArray);
			}

			mcFeedbackQuestList.selectedIndex = -1;
			mcFeedbackQuestList.focusable = false;
			mcFeedbackQuestList.ShowRenderers(true);
			CalculateBackgroundHeight();
		}

		protected function CalculateBackgroundHeight():void
		{
			var backgroundHeight : Number = 0;
			if( mcFeedbackQuestList.dataProvider.length < 3 )
			{
				backgroundHeight -= 120;
				mcFeedbackListItem1.y += backgroundHeight;
				mcFeedbackListItem2.y += backgroundHeight;
				mcFeedbackListItem3.y += backgroundHeight;
				mcFeedbackListItem4.y += backgroundHeight;
				mcSeparatorMiddle.y += backgroundHeight;
				mcLegendBackground.height += backgroundHeight;
				mcSeparatorBottom.y -= backgroundHeight;
			}
		}

		override public function handleInput( event:InputEvent ):void
		{
		}
	}
}
