/***********************************************************************
/** PANEL journal treasure hunting quest main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.journal
{
	import red.game.witcher3.controls.W3RenderToTextureHolder;
	import red.game.witcher3.menus.glossary.GlossaryTextureSubListModule;

	public class MonsterHuntingJournalMenu extends QuestJournalMenu
	{
		//public var mcMonsterImage : GlossaryTextureSubListModule;
		public var mcMonsterTexture : W3RenderToTextureHolder;

		/********************************************************************************************************************
				INIT
		/ ******************************************************************************************************************/

		public function MonsterHuntingJournalMenu()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			
			registerRenderTarget( "test_nopack", 1024, 1024 );
		}

		override protected function SetDataBindings() : void
		{
			mcTextAreaModule.dataBindingKey = "journal.monsterhunting.description";
			mcObjectiveListModule.dataBindingKey = "journal.monsterhunting.objectives.list";
			mcObjectiveListModule.mcRewards.dataBindingKeyReward = "journal.monsterhunting.objectives.list.reward.items";
			//mcMonsterImage.dataBindingKey = "journal.monsterhunting.image";
			//mcMonsterImage.imagePathPrefix = "img://textures/journal/bestiary/";
		}

		override protected function get menuName():String
		{
			return "JournalMonsterHuntingMenu";
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			//mcMonsterImage.visible = value;
		}
	}
}