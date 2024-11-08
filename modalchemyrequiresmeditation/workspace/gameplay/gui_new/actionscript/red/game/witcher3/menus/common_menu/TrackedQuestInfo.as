/***********************************************************************
/** MenuHub - Tracked Quest info container
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import flash.text.TextField;

	public class TrackedQuestInfo extends UIComponent
	{
		public var tfQuest : TextField;
		public var tfObjective : TextField;
		private var _gap : Number;
		private var questIsTracked : Boolean = false;

		override protected function configUI():void
		{
			tfQuest.htmlText = "";
			tfObjective.htmlText = "";
			tfQuest.text = "";
			tfObjective.text = "";
			_gap = 10;
			//_gap = tfObjective.y - tfQuest.y + tfQuest.textHeight;
			super.configUI();
		}

		public function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray : Array = gameData as Array;
			questIsTracked = false;
			if ( dataArray )
			{
				trace("Bidon dataArray "+dataArray);
				trace("Bidon gameData "+gameData);
				trace("Bidon dataArray[0] "+dataArray[0]);
				if ( dataArray[0].questName != "" )
				{
					tfQuest.htmlText = dataArray[0].questName;
					questIsTracked = true;
				}
				if ( dataArray[0].objectiveName != "" )
				{
					questIsTracked = true;
					tfObjective.htmlText = dataArray[0].objectiveName;
					tfObjective.y = tfQuest.y + tfQuest.textHeight + _gap;
				}
			}
			else
			{
				tfQuest.htmlText = "";
				tfObjective.htmlText = "";
				tfQuest.text = "";
				tfObjective.text = "";
			}
			trace("Bidon hds questIsTracked " + questIsTracked);
		}

		public function IsAnyItemToDisplay() : Boolean
		{
			trace("Bidon ");
			trace("Bidon IsAnyItemToDisplay questIsTracked "+questIsTracked);
			trace("Bidon ");
			return questIsTracked;
		}
	}
}