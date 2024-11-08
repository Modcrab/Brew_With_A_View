package red.game.witcher3.tooltips
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.RenderersList;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.utils.CommonUtils;
	// #B #Y obsolete
	/**
	 * Tooltip for statistic [GPAD]
	 * @author Getsevich Yaroslav
	 */
	public class TooltipStatistic extends TooltipBase
	{
		protected static const SMOOTH_TWEEN:Boolean = true;
		protected static const ANIM_DURATION:Number = 1;
		protected static const SAFE_TEXT_PADDING:Number = 4;
		protected static const MODULE_PADDING:Number = 12;
		protected static const LIST_PADDING:Number = 10;
		protected static const MIN_BACKGROUND_HEIGHT:Number = 143;

		public var txtTitle:TextField;
		public var txtDescription:TextField;
		public var mcStatsList:RenderersList;
		public var contentMask:Sprite;
		public var background:Sprite;
		public var delemiter:Sprite;
		public var btnExpand:MovieClip;

		public function TooltipStatistic()
		{
			//visible = false;
		}

		override protected function configUI():void
		{
			super.configUI();

			if (!Extensions.isScaleform)
			{
				displayDebugData();
			}

			// #Y Temp expand implementation:
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			if (event.handled) return;
			var details:InputDetails = event.details;

			if (details.value == InputValue.KEY_UP && (details.code == KeyCode.PAD_LEFT_THUMB))
			{
				expanded = !_expanded;
			}
		}

		override protected function expandTooltip(smoothExpand:Boolean = true):void
		{
			GTweener.removeTweens(contentMask);
			GTweener.removeTweens(delemiter);
			if (_expanded)
			{
				btnExpand.gotoAndStop(2);
				if (smoothExpand)
				{
					GTweener.to(contentMask, ANIM_DURATION, { height: this.actualHeight }, { ease:Exponential.easeOut } );
					GTweener.to(delemiter, ANIM_DURATION, { y: this.actualHeight }, { ease:Exponential.easeOut } );
				}
				else
				{
					contentMask.height = this.actualHeight;
					delemiter.y = this.actualHeight;
				}
			}
			else
			{
				btnExpand.gotoAndStop(1);
				if (smoothExpand)
				{
					GTweener.to(contentMask, ANIM_DURATION, { height: _defaultHeight }, { ease:Exponential.easeOut } );
					GTweener.to(delemiter, ANIM_DURATION, { y: _defaultHeight }, { ease:Exponential.easeOut } );
				}
				else
				{
					contentMask.height = _defaultHeight;
					delemiter.y = _defaultHeight;
				}
			}
			invalidate(INVALIDATE_POSITION);
		}

		override protected function populateData():void
		{
			super.populateData();
			if (!_data) return;
			applyStatsData();
		}

		protected function applyStatsData():void
		{
			var sumHeight:Number = MODULE_PADDING;
			//visible = true;
			txtTitle.htmlText = _data.title;
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
			txtDescription.htmlText = _data.description;
			txtDescription.height = txtDescription.textHeight + SAFE_TEXT_PADDING;
			sumHeight += txtDescription.height;
			mcStatsList.dataList = _data.statsList as Array;
			mcStatsList.validateNow();
			mcStatsList.y = txtDescription.y + txtDescription.height + LIST_PADDING;
			sumHeight += LIST_PADDING + mcStatsList.actualHeight + MODULE_PADDING;
			background.height = Math.max(MIN_BACKGROUND_HEIGHT, sumHeight);
			contentMask.height = _defaultHeight;
			delemiter.y = actualHeight;
			expandTooltip(false);
			btnExpand.visible = actualHeight > _defaultHeight;
		}

		override protected function getExtraHeight():Number
		{
			if (_expanded)
			{
				var heightDelta:Number = actualHeight - _defaultHeight;
				return heightDelta > 0 ? heightDelta : 0;
			}
			return 0;
		}

		protected function displayDebugData():void
		{
			var testData:Object = { };
			var statsList:Array = [];
			statsList.push( { label:"Test stat 1", value:"1" } );
			statsList.push( { label:"Test stat 2", value:"2" } );
			statsList.push( { label:"Test stat 3", value:"3" } );
			statsList.push( { label:"Test stat 4", value:"4" } );
			testData.title = "Stat tooltip";
			testData.description = "This";
			//testData.description = "This value should take into consideration mutagens that taken over parts of the Toxicity. So if Geralt's max toxicity is 100, hs 2 mutagens that take up 60 points ";
			testData.statsList = statsList;
			this.anchorRect = stage.getRect(parent["testAnchor"] as MovieClip);
			this.lockFixedPosition = true;
			this.data = testData;
		}

	}
}
