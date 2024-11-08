package red.game.witcher3.hud.modules.quests
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import scaleform.clik.data.ListData;

	import red.game.witcher3.hud.modules.HudModuleQuests;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.InteractiveObjectEx;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.ListEvent;

	import red.game.witcher3.utils.motion.TweenEx;

	import fl.transitions.easing.Strong;
	import flash.events.Event;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class HudQuestContainer extends UIComponent
	{

	//{region Art clips
	// ------------------------------------------------
		public var mcDifficultyIcon:MovieClip;
		public var mcQuestObjectiveList:HudQuestObjectiveList;
		public var mcQuestObjectiveListItem1:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem2:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem3:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem4:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem5:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem6:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem7:HudQuestObjectiveListItem;
		public var mcQuestObjectiveListItem8:HudQuestObjectiveListItem;
		public var mcArrowUp:MovieClip;
		public var mcArrowDown:MovieClip;
		public var tfOr : TextField;

	//{region Private variables
	// ------------------------------------------------

		private var _QuestType : String;

	//{region Initialization
	// ------------------------------------------------
		public function HudQuestContainer()
		{
			super();

			InteractiveObjectEx.setHitTestDisable( this, true );
			mouseEnabled = tabEnabled = mouseChildren = tabChildren = false;
		}

		[Inspectable(type = "string", defaultValue = "")]
        public function get QuestType():String { return _QuestType; }
        public function set QuestType(value:String):void {
            _QuestType = value;
        }

	//{region Overrides
	// ------------------------------------------------

		override protected function configUI():void
		{
			super.configUI();

			alpha = 0;
			if (mcDifficultyIcon)
			{
				mcDifficultyIcon.visible = false;
			}
		}

	//{region Updates
	// ------------------------------------------------

		public function onDifficultyUpdate( tooDifficulty:Boolean ):void
		{
			if (mcDifficultyIcon)
			{
				mcDifficultyIcon.visible = tooDifficulty;
			}
		}
	
		public function onQuestNameSet( name:String ):void
		{
			mcQuestObjectiveList.onQuestNameSet( name );
		}

		public function onQuestNameColorSet( color : int ):void
		{
			mcQuestObjectiveList.onQuestNameColorSet( color );
		}

		public function onObjectiveDataSet( gameData:Object, index:int ):void
		{
			mcQuestObjectiveList.selectedIndex = -1;
			mcQuestObjectiveList.validateNow();
			
			var dataArray:Array = gameData as Array;
			if ( index > 0 )
			{
				//...
			}
			else if ( gameData )
			{
				mcQuestObjectiveList.dataProvider = new DataProvider( dataArray );
			}
			
			mcQuestObjectiveList.selectedIndex = getHighlightedIndex();
			mcQuestObjectiveList.validateNow();
			mcQuestObjectiveList.repositionRenderers();
			repositionOrSeparator();
			repositionArrowDown();
			updateArrows();
		}

	//{region Effects
	// ------------------------------------------------
		
		private function getHighlightedIndex() : int
		{
			for ( var i = 0;  i < mcQuestObjectiveList.dataProvider.length; i++ )
			{
				if ( mcQuestObjectiveList.dataProvider[ i ].isHighlighted )
				{
					return i;
				}
			}
			return -1;
		}
		
		public function UpdateObjectiveCounter( index : int, text : String ) : void
		{
			var rendererIndex : int = index - mcQuestObjectiveList.scrollPosition;

			var item : HudQuestObjectiveListItem = mcQuestObjectiveList.getRendererAt( rendererIndex ) as HudQuestObjectiveListItem;
			if ( item )
			{
				var curDataProvider : DataProvider = mcQuestObjectiveList.dataProvider as DataProvider;
				if ( curDataProvider )
				{
					curDataProvider[ index ].name = curDataProvider[ index ].label = text;
					curDataProvider.invalidate();

					item.tfObjective.htmlText = text;
					item.ShowNewFeedback();
				}
			}
		}

		public function HighlightObjective( index : int, state : Boolean ) : void
		{
			mcQuestObjectiveList.selectedIndex = index;
			mcQuestObjectiveList.validateNow();
			updateArrows();
			
			var rendererIndex : int = index - mcQuestObjectiveList.scrollPosition;

			var item : HudQuestObjectiveListItem = mcQuestObjectiveList.getRendererAt( rendererIndex ) as HudQuestObjectiveListItem;
			if ( item )
			{
				item.Highlight( state );
			}
			mcQuestObjectiveList.invalidateData();
		}

		public function UnhighlightAllObjectives() : void
		{
			var renderers : Vector.< IListItemRenderer > = mcQuestObjectiveList.getRenderers();
			for ( var i : int = 0; i < renderers.length; i++ )
			{
				var item : HudQuestObjectiveListItem = renderers[ i ] as HudQuestObjectiveListItem;
				if ( item )
				{
					item.Highlight( false );
				}
			}
			mcQuestObjectiveList.invalidateData();
		}
		
		private function repositionOrSeparator()
		{
			var renderers : Vector.< IListItemRenderer > = mcQuestObjectiveList.getRenderers();
			if ( renderers && renderers.length >= 2 )
			{
				var first  : HudQuestObjectiveListItem = renderers[ 0 ] as HudQuestObjectiveListItem;
				var second : HudQuestObjectiveListItem = renderers[ 1 ] as HudQuestObjectiveListItem;
				if ( first && second )
				{
					if ( first.data && first.data.isMutuallyExclusive && second.data && second.data.isMutuallyExclusive )
					{
						tfOr.visible = true;
						tfOr.y = second.y - 15;
						second.y += tfOr.textHeight;
						return;
					}
				}
			}
			tfOr.visible = false;
		}
		
		public function repositionArrowDown()
		{
			var renderers : Vector.< IListItemRenderer > = mcQuestObjectiveList.getRenderers();
			for ( var i = renderers.length - 1; i >= 0; --i )
			{
				var item : HudQuestObjectiveListItem = renderers[ i ] as HudQuestObjectiveListItem;
				if ( item )
				{
					if ( item.visible )
					{
						mcArrowDown.y = item.y + item.tfObjective.height - 3;
						return;
					}
				}
			}
		}
		
		public function updateArrows()
		{
			var rendererCount : int = mcQuestObjectiveList.getRenderers().length;
			var dataCount : int = mcQuestObjectiveList.dataProvider.length;
			if ( dataCount <= rendererCount )
			{
				mcArrowUp.visible = false;
				mcArrowDown.visible = false;
			}
			else
			{
				mcArrowUp.visible = ( mcQuestObjectiveList.scrollPosition > 0 );
				mcArrowDown.visible = ( rendererCount + mcQuestObjectiveList.scrollPosition < dataCount );
			}
		}
	}
}
