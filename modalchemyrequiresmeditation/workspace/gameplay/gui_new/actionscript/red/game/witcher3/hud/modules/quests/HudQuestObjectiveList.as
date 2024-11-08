package red.game.witcher3.hud.modules.quests
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.interfaces.IListItemRenderer;
	import flash.text.TextField;

	import red.game.witcher3.utils.motion.TweenEx;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import flash.events.Event;
	import red.game.witcher3.utils.CommonUtils;

	public class HudQuestObjectiveList extends W3ScrollingList
	{
		public var tfQuestName:TextField;
		public var mcQuestTextShadow : MovieClip;
		public var mcTitleLineSeparator : MovieClip;

		public function HudQuestObjectiveList()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
		}

		public function onQuestNameSet( name:String ):void
		{
			if ( tfQuestName )
			{
				tfQuestName.wordWrap = true;
				tfQuestName.text = CommonUtils.toUpperCaseSafe(name);
				mcQuestTextShadow.width = tfQuestName.textWidth + 10;
				mcQuestTextShadow.height = 32 + (tfQuestName.numLines - 1) * 22.65;
				mcTitleLineSeparator.y = 33 + (tfQuestName.numLines - 1) * 22.65;
			}
		}

		public function onQuestNameColorSet( color : int ) : void
		{
			if ( tfQuestName )
			{
				tfQuestName.textColor = color;
			}
		}

		public function repositionRenderers():void
		{
			var nextPosY : Number = mcTitleLineSeparator.y + 32.0;
			var renderer : HudQuestObjectiveListItem;
			var len : uint = _renderers.length;

			for ( var i : uint = 0; i < len; ++i )
			{
				renderer = getRendererAt( i ) as HudQuestObjectiveListItem;
				if ( renderer )
				{
					renderer.y = nextPosY;
					nextPosY += renderer.tfObjective.height + 3;
				}
			}
		}
	}
}