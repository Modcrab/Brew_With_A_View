package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;

	import fl.transitions.easing.Strong;
	import flash.events.Event;

	import scaleform.gfx.InteractiveObjectEx;

	import red.game.witcher3.hud.modules.quests.HudQuestContainer;
	import red.game.witcher3.utils.motion.TweenEx;
	import red.game.witcher3.hud.modules.quests.HudQuestObjectiveList;

	public class HudModuleQuests extends HudModuleBase
	{
		public var mcSystemQuestContainer : HudQuestContainer;

		public function HudModuleQuests()
		{
			super();
			
			visible = false;

			InteractiveObjectEx.setHitTestDisable( this, true );
			mouseEnabled = tabEnabled = mouseChildren = tabChildren = false;
		}

		override public function get moduleName():String
		{
			return "QuestsModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			
			this.alpha = 1;

			registerDataBinding( 'hud.quest.system.name',		onSystemQuestNameSet );
			registerDataBinding( 'hud.quest.system.name.color',	onSystemQuestNameColorSet );
			registerDataBinding( 'hud.quest.system.objectives',	onSystemObjectiveDataSet);

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		//-------------------------------------------------------------------------------------------------------------------

		public function /* WitcherScript */ ShowTrackedQuest( show : Boolean )
		{
			if ( show )
			{
				mcSystemQuestContainer.alpha = 1;
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
			else
			{
				mcSystemQuestContainer.alpha = 0;
			}
		}

		public function /* WitcherScript */ UpdateObjectiveCounter( index : int, text : String ) : void
		{
			mcSystemQuestContainer.UpdateObjectiveCounter( index, text );
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function /* WitcherScript */ UpdateObjectiveHighlight( index : int, state : Boolean ) : void
		{
			mcSystemQuestContainer.HighlightObjective( index , state );
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function /* WitcherScript */ UpdateObjectiveUnhighlightAll() : void
		{
			mcSystemQuestContainer.UnhighlightAllObjectives();
		}

		//-------------------------------------------------------------------------------------------------------------------

		private function onSystemQuestNameSet( name:String ):void
		{
			mcSystemQuestContainer.onQuestNameSet(name);
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		private function onSystemQuestNameColorSet( color : int ):void
		{
			mcSystemQuestContainer.onQuestNameColorSet( color );
		}
		
		public function SetSystemQuestInfo( name:String, color:int, difficult:Boolean ):void
		{
			mcSystemQuestContainer.onQuestNameSet(name);
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			mcSystemQuestContainer.onQuestNameColorSet( color );
			mcSystemQuestContainer.onDifficultyUpdate(difficult);
		}

		private function onSystemObjectiveDataSet( gameData:Object, index:int ):void
		{
			mcSystemQuestContainer.onObjectiveDataSet( gameData, index );
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}
		
		//-------------------------------------------------------------------------------------------------------------------

		override public function ShowTutorialHighlight ( show : Boolean, tutorialName : String )
		{
			if ( show )
			{
				if ( mcTutorialHighlight )
				{
					var calculatedX : Number;
					var calculatedY : Number;
					var calculatedWidth : Number;
					var calculatedHeight : Number;

					calculatedWidth = mcSystemQuestContainer.mcQuestObjectiveList.tfQuestName.textWidth + 10;
					if( mcSystemQuestContainer.mcQuestObjectiveListItem1.tfObjective.textWidth >  calculatedWidth )
					{
						calculatedWidth = mcSystemQuestContainer.mcQuestObjectiveListItem1.tfObjective.textWidth + 10;
					}
					calculatedHeight = mcSystemQuestContainer.mcQuestObjectiveList.tfQuestName.textHeight + mcSystemQuestContainer.mcQuestObjectiveListItem1.tfObjective.textHeight + 40;
					mcTutorialHighlight.x = mcSystemQuestContainer.x + mcSystemQuestContainer.mcQuestObjectiveList.x - 5;
					mcTutorialHighlight.y = mcSystemQuestContainer.y;
				}
			}
			super.ShowTutorialHighlight ( show , tutorialName );
		}
	}
}
