package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;

	/**
	 * Tooltip for map menu questavailable
	 * TODO: Use common tooltip manager
	 * @author Getsevich Yaroslav
	 */
	public class TooltipMap extends UIComponent
	{
		private const TITLE_PADDING:Number = 25;
		private const TITLE_MAX_WIDTH_FOR_TRACKED:Number = 460;
		private const TITLE_MAX_WIDTH:Number = 520;
		private const TRACKER_DEFAULT_Y:Number = 10; // -
		private const PADDING_LEFT:Number = 15;
		private const PADDING_BOTTOM:Number = 35;
		private const TEXT_BLOCK_PADDING:Number	= 4;
		private const TRACKED_BLOCK_PADDING:Number	= 6;
		
		public var txtTitle:TextField;
		public var txtDescription:TextField;
		public var txtTracked:TextField;
		public var trackIndicator:MovieClip;
		public var trackedBackground:MovieClip;
		public var delimiterLine:MovieClip;
		public var background:MovieClip;
		
		protected var _data:Object;

		public function TooltipMap()
		{
			txtTracked.text =  "[[panel_journal_legend_tracked]]";
			txtTracked.width = txtTracked.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			txtTracked.visible = false;
			trackIndicator.visible = false;
			trackedBackground.width = trackIndicator.width + txtTracked.textWidth + TITLE_PADDING;
			trackedBackground.visible = false;
			
			mouseChildren = mouseEnabled = false;
			visible = false; 
		}

		public function ShowTooltip(value:Object, isArabicAligmentMode : Boolean):void
		{
			_data = value;
			if (_data)
			{
				var isTracked:Boolean = _data.tracked;
				var maxTitleWidth:Number = isTracked ? TITLE_MAX_WIDTH_FOR_TRACKED : (TITLE_MAX_WIDTH + CommonConstants.SAFE_TEXT_PADDING);
				var titleText:String = isArabicAligmentMode ? ("<p align=\"right\">" + _data.title +"</p>") : _data.title;
				var descText:String = isArabicAligmentMode ? ("<p align=\"right\">" + _data.description +"</p>") : _data.description;
				
				// title
				txtTitle.multiline = false;
				txtTitle.wordWrap = false;
				//txtTitle.width = maxTitleWidth;
				
				txtTitle.htmlText = _data.title;
				txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);				
				if (txtTitle.textWidth > maxTitleWidth)
				{
					//txtTitle.width = maxTitleWidth;
					txtTitle.multiline = true;
					txtTitle.wordWrap = true;
				}
				else
				{
					//txtTitle.width = txtTitle.textWidth +CommonConstants.SAFE_TEXT_PADDING;
				}
				txtTitle.height = txtTitle.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				// description
				txtDescription.htmlText = descText;
				txtDescription.height = txtDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				// align controls
				delimiterLine.y = txtTitle.y + txtTitle.textHeight + TEXT_BLOCK_PADDING;
				txtDescription.y = delimiterLine.y + TEXT_BLOCK_PADDING;
				
				if ( isArabicAligmentMode )
				{
					//txtTitle.x = txtDescription.x + txtDescription.width - txtTitle.width;
					if (isTracked)
					{
						//trackIndicator.x = txtTitle.x - trackIndicator.width - TRACKED_BLOCK_PADDING;
						txtTracked.x = trackIndicator.x - txtTracked.width;
					}
				}
				else
				{
					//txtTitle.x = PADDING_LEFT;
					
					if (isTracked)
					{
						//trackIndicator.x = txtTitle.x + txtTitle.width;
						txtTracked.x = trackIndicator.x + trackIndicator.width;
					}
				}
				
				trackIndicator.visible = isTracked;
				txtTracked.visible = isTracked;
				trackedBackground.visible = isTracked;
				background.height = txtDescription.height + txtTitle.height + PADDING_BOTTOM;
				
				visible = true;
			}
			else
			{
				visible = false;
			}
		}

		public function HideTooltip():void
		{
			visible = false;
		}
		
	}
}
