package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	
	/**
	 * Item renderer for inventory tooltip
	 * @author Getsevich Yaroslav
	 */
	public class TooltipSocketRenderer extends TooltipStatRenderer
	{
		protected var SOCKET_ICON_PADDING:Number = 8;
		protected var SOCKET_SMALL_PADDING:Number = 10;
		protected var TEXT_ICON_PADDING:Number = 15;
		protected var RIGHT_ANCHOR:Number = 415;
		protected var TEXTFIELD_LENGTH:Number = 320;
		
		public var mcIcon:MovieClip;
		private var tempValue:String;
		
		public function TooltipSocketRenderer()
		{
			if (mcIcon)
			{
				_iconShift = mcIcon.width + SOCKET_ICON_PADDING;
			}
		}

		override protected function updateText():void
		{
			
				if (mcIcon && data.type)
				{
					if (!CoreComponent.isArabicAligmentMode)
					{
						mcIcon.x = 0;
						
					}
					else
					{
						mcIcon.x = RIGHT_ANCHOR;
					}
					mcIcon.gotoAndStop(data.type);
				}
			
			
			
			super.updateText();
			
			if (!CoreComponent.isArabicAligmentMode)
			{
				tfStatValue.x = mcIcon.x + mcIcon.width + SOCKET_ICON_PADDING;
				
			}
			else
			{
				var format: TextFormat = new TextFormat();
				format.align = TextFormatAlign.RIGHT;
				tfStatValue.x = mcIcon.x - mcIcon.width/3 - tfStatValue.textWidth;
				textField.setTextFormat(format);
			}
			
		}
		override protected function updateTextFieldSize():void
		{
			
				super.updateTextFieldSize();
				
			
			if (data.type == "empty")
			{
				if (!CoreComponent.isArabicAligmentMode)
				{
					tfStatValue.x = mcIcon.x + mcIcon.width + SOCKET_ICON_PADDING;
				}
				else
				{
					tfStatValue.x = mcIcon.x - tfStatValue.textWidth - SOCKET_SMALL_PADDING; 
				}
			}
			else
			if (tfStatValue)
			{
				if (data.value)
				{
					tfStatValue.visible = true;
					if (CoreComponent.isArabicAligmentMode)
					{
						
						textField.x = tfStatValue.x - ( textField.width * 2  - textField.textWidth );
						
					}
				}
				else
				{
					tfStatValue.visible = false;
					if (CoreComponent.isArabicAligmentMode)
					{
						textField.x = mcIcon.x -  mcIcon.width - SOCKET_ICON_PADDING;
					}
					else
					{
						textField.x = mcIcon.x + mcIcon.width + SOCKET_ICON_PADDING;
					}
				}
			}
			
		}
		
	}
}
