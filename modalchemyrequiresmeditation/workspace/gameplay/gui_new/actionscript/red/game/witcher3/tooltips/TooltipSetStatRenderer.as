package red.game.witcher3.tooltips
{
	import red.core.CoreComponent;
	/**
	 * red.game.witcher3.tooltips.TooltipSetStatRenderer
	 * @author ...
	 */
	public class TooltipSetStatRenderer extends TooltipStatRenderer
	{
		private static const ACTIVE_TEXT_COLOR:Number = 0x009F00;
		private static const RIGHT_ANCHOR:Number = 430;
		private var cachedPosition:Number = 0;
		
		public function TooltipSetStatRenderer()
		{
			TEXT_PADDING = 8;
			
			if (textField)
			{
				cachedPosition = textField.x;
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
						
			if (_data && _data.active)
			{
				var _tempValue:String;
				
				if(CoreComponent.isArabicAligmentMode)
				{
					textField.text = data.name;
					_tempValue = textField.text;
					textField.htmlText = "<p align=\"right\">" + _tempValue + "</p>";
				}

				textField.textColor = ACTIVE_TEXT_COLOR;
				tfStatValue.textColor = ACTIVE_TEXT_COLOR;

			}
			
			if (!CoreComponent.isArabicAligmentMode)
			{
					if (data.value == "")
					{
						textField.x = tfStatValue.x;
						tfStatValue.text = "";
					}
					else
					{
						textField.x = cachedPosition;
					}
			}
			else
			{
				if (data.value == "")
					{
						textField.x = RIGHT_ANCHOR - textField.textWidth;
						tfStatValue.text = "";
					}
					else
					{
						tfStatValue.x = RIGHT_ANCHOR - tfStatValue.textWidth;
						textField.x = tfStatValue.x - textField.textWidth - 10;
					}
			}
			tfStatValue.y = textField.y + ( textField.textHeight - tfStatValue.textHeight ) / 2;
			
			
		}
		
	}

}
