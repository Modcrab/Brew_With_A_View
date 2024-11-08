/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.journal
{
	import red.game.witcher3.menus.common.JournalRewards;
	
	public class MonsterHuntingSubListModule extends QuestSubListModule
	{
		//public var mcPotions : JournalRewards;
		
		public function MonsterHuntingSubListModule()
		{
			super();
			//mcPotions.dataBindingKeyReward = "journal.monsterhunting.potions.items";
			//mcPotions.titleString = "[[panel_journal_monster_hunting_recommended]]";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			//mcPotions.visible = false;
		}

		override public function toString() : String
		{
			return "[W3 MonsterHuntingSubListModule]"
		}
		
		//override protected function handleDataSet( gameData:Object, index:int ):void
		//{	
			//super.handleDataSet( gameData, index );
			//mcPotions.y = mcRewards.y + mcRewards.mcSeparatorBottom.y + 10;
			//handleDataChanged();
		//}
		
		/*
		override public function handleInput( event:InputEvent ):void 
		{
			if ( event.handled || !_focused )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if ( keyPress )
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.UP:
						if ( mcRewards.GetSelectedIndex() > -1 )
						{
							mcRewards.focused = 0;
							mcRewards.SetSelectedIndex(-1);
							event.handled = true;
							mcList.selectedIndex = mcList.dataProvider.length - 1;
						}
						else if ( mcList.selectedIndex == 0 )
						{
							mcRewards.focused = 1;
							mcRewards.SetSelectedIndex(0);
							mcRewards.FindSelectedIndex();
							event.handled = true;
							mcList.selectedIndex = - 1;
						}
						break;
					case NavigationCode.DOWN:
						if ( mcRewards.GetSelectedIndex() > -1 )
						{
							mcRewards.focused = 0;
							mcRewards.SetSelectedIndex(-1);
							event.handled = true;
							mcList.selectedIndex = 0;
						}
						else if ( mcList.selectedIndex == mcList.dataProvider.length - 1 )
						{
							mcList.selectedIndex = - 1;
							mcRewards.focused = 1;
							mcRewards.SetSelectedIndex(0);
							mcRewards.FindSelectedIndex();
							event.handled = true;
						}
						break;
					default:
						break;
				}
				if ( !event.handled )
				{
					if( mcRewards.GetSelectedIndex() > -1 )
					{
						//mcRewards.focused = 1 - mcRewards.focused;
						mcRewards.handleInput(event);
						//event.handled = true;
					}
					else if ( mcList.selectedIndex > -1 )
					{
						//mcRewards.focused = 1 - mcRewards.focused;
						mcList.handleInput(event);
						//event.handled = true;
					}
				}
			}
			event.stopImmediatePropagation();
		}*/
	}
}
