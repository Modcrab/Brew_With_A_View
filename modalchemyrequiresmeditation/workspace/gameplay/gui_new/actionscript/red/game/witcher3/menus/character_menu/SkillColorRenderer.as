package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.SkillColor;
	import scaleform.clik.controls.ListItemRenderer;
	
	/**
	 * red.game.witcher3.menus.character_menu.SkillColorRenderer
	 * @author Getsevich Yaroslav
	 */
	public class SkillColorRenderer extends ListItemRenderer
	{
		private const TEXT_PADDING = 10;
		public var mcIcon : MovieClip;
		public var tfLabel : TextField;
		
		override protected function configUI():void
		{
			super.configUI();
			
			preventAutosizing = true;
		}
		
		override public function setData(data:Object):void
		{
			super.setData(data);
			
			gotoAndStop( _data.color );
			
			tfLabel.textColor = SkillColor.enumToColor( _data.color );
			tfLabel.text = _data.colorLocName;
			tfLabel.width = tfLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			//mcIcon.x = tfLabel.x + tfLabel.textWidth / 2;
		}
		
		override public function get width():Number
		{
			const minPadding:Number = 110;
			
			if (tfLabel && mcIcon)
			{
				return minPadding; //Math.max( Math.max( tfLabel.width, mcIcon.width ), minPadding );
			}
			else
			{
				return super.width;
			}
		}
		
	}

}
