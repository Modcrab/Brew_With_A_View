package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	public class HubMapQuestTrackerItemRenderer extends BaseListItem
	{
		public var tfObjective : TextField;
		public var mcTrackIndicator : MovieClip;
		public var mcBackground : MovieClip;
		
		private var _scriptName : uint;
		
		public function HubMapQuestTrackerItemRenderer()
		{
			// constructor code
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}

		private const RIGHT_MARGIN : int = 70;
		private const LEFT_MARGIN : int = 45;
		private const TRACK_INDICATOR_SPACING : int = 15;
		
		override public function setData(data:Object):void
		{
			super.setData(data);

			if ( data )
			{
				_scriptName = data.objectiveScriptName;
				
				tfObjective.htmlText = data.objectiveName;
				tfObjective.textColor = data.highlighted ? 0xf0be38 : 0xDFDEDE;
				mcTrackIndicator.visible = data.highlighted;

				mcBackground.width = RIGHT_MARGIN + tfObjective.textWidth + ( ( data.highlighted ) ? LEFT_MARGIN : 0 );
				mcTrackIndicator.x = mcBackground.x - mcBackground.width + TRACK_INDICATOR_SPACING;
				tfObjective.width = tfObjective.textWidth;
				tfObjective.x = mcBackground.x - mcBackground.width + ( ( data.highlighted ) ? LEFT_MARGIN : 0 ) + TRACK_INDICATOR_SPACING;
			}
		}
		
		public function getScriptName() : uint
		{
			return _scriptName;
		}
	}
}
