package red.game.witcher3.tooltips
{
	import scaleform.clik.events.InputEvent;
	// #B #Y obsolete
	/**
	 * Tooltip for player statistic [MOUSE]
	 * @author Getsevich Yaroslav
	 */
	public class TooltipStatistic_Mouse extends TooltipStatistic
	{
		override protected function applyStatsData():void
		{
			var sumHeight:Number = 0;

			visible = true;
			txtDescription.htmlText = _data.description;
			txtDescription.height = txtDescription.textHeight + SAFE_TEXT_PADDING;
			sumHeight += txtDescription.height;

			mcStatsList.dataList = _data.statsList as Array;
			mcStatsList.validateNow();
			mcStatsList.y = txtDescription.y + txtDescription.height + LIST_PADDING;

			sumHeight += LIST_PADDING + mcStatsList.actualHeight + MODULE_PADDING;
			background.height = sumHeight;
		}

		override public function handleInput(event:InputEvent):void { }
	}
}
