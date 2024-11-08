package red.game.witcher3.menus.common_menu
{
	import flash.text.TextField;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * Players level indicator with text and progress bar
	 * @author Getsevich Yaroslav
	 */
	public class MenuLevelIndicator extends UIComponent
	{
		public var tfValue:TextField;
		public var tfLabel:TextField;
		public var txtExp:TextField;
		public var levelProgress:StatusIndicator;
		
		override protected function configUI():void
		{
			super.configUI();
			tfLabel.htmlText = "[[panel_inventory_level]]";
			tfLabel.htmlText = CommonUtils.toUpperCaseSafe(tfLabel.htmlText);
			
			if (txtExp)
			{
				txtExp.text = "";
			}
		}
		
		public function setLevel(value:String):void
		{
			tfValue.text = value;
		}
		
		public function setLevelProgress(value:Number, maxValue:Number):void
		{
			levelProgress.maximum = maxValue;
			levelProgress.value = value;
			
			if (txtExp)
			{
				txtExp.text = value.toString() + "/" + maxValue.toString();
			}
		}
		
	}

}
