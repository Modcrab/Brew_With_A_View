/***********************************************************************
/** PANEL journal treasure hunting quest main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.journal
{
	public class TreasureHuntingJournalMenu extends QuestJournalMenu
	{
		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		public function TreasureHuntingJournalMenu()
		{
			super();
		}
		
		override protected function SetDataBindings() : void
		{
			mcTextAreaModule.dataBindingKey = "journal.treasurequest.description";
			mcObjectiveListModule.dataBindingKey = "journal.treasure.objectives.list";
			mcObjectiveListModule.mcRewards.dataBindingKeyReward = "journal.treasure.objectives.list.reward.items";
		}

		override protected function get menuName():String
		{
			return "JournalTreasureHuntingMenu";
		}
	}
}