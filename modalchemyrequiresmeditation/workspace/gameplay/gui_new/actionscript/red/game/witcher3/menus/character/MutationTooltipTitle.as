package red.game.witcher3.menus.character
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	/**
	 * red.game.witcher3.menus.character.MutationTooltipTitle
	 * @author Getsevich Yaroslav
	 */
	public class MutationTooltipTitle extends UIComponent
	{
		public var mcBackground   : MovieClip;
		public var tfMutationName : TextField;
		private const TEXT_PADDING = 4;
		
		public function setText(value:String):void
		{
			
			if (CoreComponent.isArabicAligmentMode)
			{
				tfMutationName.htmlText = "<p align=\"right\">" + value + "</p>";
			}
			else
			{
				tfMutationName.text = value;
				tfMutationName.text = CommonUtils.toUpperCaseSafe( tfMutationName.text );
			}
			tfMutationName.width = tfMutationName.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			mcBackground.width = tfMutationName.x * 2 + tfMutationName.textWidth + TEXT_PADDING;
		}
		
	}

}
