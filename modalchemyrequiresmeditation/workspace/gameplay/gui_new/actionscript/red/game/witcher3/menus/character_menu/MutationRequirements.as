package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.RenderersList;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationRequirements
	 * @author Getsevich Yaroslav
	 */
	public class MutationRequirements extends UIComponent
	{
		private const LIST_PADDING:Number = 0;
		private const LIST_PADDING_AR :Number = 5;
		
		public var mcRequitementsList:RenderersList;
		public var mcBackground:MovieClip;
		public var mcLockIcon:MovieClip;
		public var tfLabelRequirements:TextField;
		private var _textValue : String;
		
		private var _data:Array;
		
		public function MutationRequirements()
		{
			
		}
		
		public function setData(data:Array):void
		{
			_data = data;
			if (CoreComponent.isArabicAligmentMode)
			{
				mcRequitementsList.alignment = TextFormatAlign.RIGHT;
				tfLabelRequirements.htmlText = "<p align=\"right\">" + _textValue + "</p>";
			}
			else
			{
				tfLabelRequirements.text = _textValue;
			}
			
			mcRequitementsList.dataList = _data;
			mcRequitementsList.validateNow();
			tfLabelRequirements.text = "[[mutation_tooltip_requirements]]";
			_textValue = tfLabelRequirements.text;
			
			
			
			
			mcBackground.height = mcRequitementsList.y + mcRequitementsList.actualHeight + LIST_PADDING;
			
			if (CoreComponent.isArabicAligmentMode)
			{
				
				mcLockIcon.x = mcBackground.x + mcBackground.width - mcLockIcon.width;
				tfLabelRequirements.x = mcLockIcon.x - tfLabelRequirements.width - LIST_PADDING_AR; 
				mcRequitementsList.x = mcLockIcon.x - LIST_PADDING_AR;
			}			
			mcLockIcon.y = ( mcBackground.height - mcLockIcon.height ) / 2;
		}
		
	}

}
