/***********************************************************************
/** Tooltip Simple class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
// #B #Y obsolete
package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.game.witcher3.interfaces.IAnchorable;
	import scaleform.gfx.Extensions;

	public class TooltipSimple extends TooltipBase implements IAnchorable
	{
		protected const SAFE_TEXT_PADDING:Number = 5;
		protected const BLOCK_PADDING:Number = 5;
		protected const BOTTOM_PADDING:Number = 5;

		public var tfName:TextField;
		public var tfDescription:TextField;

		public var delDescription:Sprite;
		public var delTitle:Sprite;
		public var mcBackground:Sprite;

		public function TooltipSimple()
		{
			//visible = false;
		}

		override protected function configUI():void
		{
			super.configUI();
			if (!Extensions.isScaleform)
			{
				applyDebugData();
			}
		}

		override protected function populateData():void
		{
			super.populateData();
			if (!_data) return;
			//visible = true;
			populateTooltipData();
			trace("HUD Tooltip Simple populateData ");
		}

		protected function populateTooltipData()
		{
			var currentHeight:Number = delTitle.y + BLOCK_PADDING;
			var currentHeightLeft:Number;
			var currentHeightRight:Number;
			trace("HUD Tooltip Simple populateTooltipData ");
			// Top block

			applyTextValue(tfName, _data.label, true,true);
			showDescription(currentHeight);
			if (tfDescription.htmlText.length > 0)
			{
				delDescription.visible = true;
				delDescription.y = tfDescription.y + tfDescription.height + BLOCK_PADDING;
				currentHeight = delDescription.y + delDescription.height;
			}
			else
			{
				delDescription.visible = false;
			}
			currentHeight += BLOCK_PADDING;
			currentHeightLeft = currentHeightRight = currentHeight;

			mcBackground.height = Math.max(currentHeightRight, currentHeightLeft);
		}

		protected function showDescription(vertOffset:Number):void
		{
			var descriptionText:String = "";
			var commonDescription:String = _data.description;
			var uniqDescription:String = _data.UniqueDescription;

			if (commonDescription /*&& commonDescription.charAt(0) != "#"*/) // #Y Check on empty localization
			{
				descriptionText = commonDescription;
			}
			if (uniqDescription /*&& uniqDescription.charAt(0) != "#"*/)
			{
				if (descriptionText.length > 0 )
				{
					descriptionText += ("<br>" + uniqDescription);
				}
				else
				{
					descriptionText += uniqDescription;
				}
			}

			trace("Tooltip Simple showDescription "+descriptionText+" .");
			tfDescription.y = vertOffset;
			tfDescription.htmlText = descriptionText;
			tfDescription.height = tfDescription.textHeight + SAFE_TEXT_PADDING;
		}

		protected function applyDebugData():void
		{
		}

	}
}
