package red.game.witcher3.menus.journal
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.questList.QuestItemRenderer;
	import scaleform.clik.events.InputEvent;
	
	public class MonsterQuestItemRenderer extends QuestItemRenderer
	{
		public var mcIconLoader : W3UILoader;
		
		public function MonsterQuestItemRenderer()
		{
			super();
			readEventName = "OnQuestRead";
		}

		override protected function configUI():void
		{
			super.configUI();
		}

		override public function setData( data:Object ):void
		{
			super.setData( data );
			if (! data )
			{
				return;
			}
			if ( data.monsterIcon )
			{
				mcIconLoader.source = data.monsterIcon;
			}
		}

		override protected function CanHideFeedbackIcon() : Boolean
		{
			return !data.isActive;
		}
	}
}