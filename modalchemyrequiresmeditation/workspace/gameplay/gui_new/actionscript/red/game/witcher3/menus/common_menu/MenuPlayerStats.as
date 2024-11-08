package red.game.witcher3.menus.common_menu 
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.PlayerStatsData;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Players stats in the top panel
	 * @author Getsevich Yaroslav
	 */
	public class MenuPlayerStats extends UIComponent
	{
		public var mcLevelStat:MenuLevelIndicator;
		public var tfMoney:TextField;
		public var tfWeight:TextField;
		
		protected var _data:PlayerStatsData;
		protected var _weightTextGlowRed:GlowFilter;
		protected var _weightTextGlowWhite:GlowFilter;
		
		public function setLevel(level:Number, exp:Number, targetExp:Number):void
		{
			mcLevelStat.setLevel(String(level));
			mcLevelStat.setLevelProgress(exp, targetExp);
		}
		
		public function setWeight(value:Number, maxValue:Number):void
		{
			tfWeight.htmlText = value + " / " + maxValue;
			
			if (value > maxValue)
			{
				tfWeight.textColor = 0xFF2222;
				
				if (!_weightTextGlowRed)
				{
					_weightTextGlowRed = new GlowFilter(0xB70000, 1, 16, 16, 1.5, BitmapFilterQuality.HIGH);
				}
				
				tfWeight.filters = [_weightTextGlowRed];
			}
			else
			{
				tfWeight.textColor = 0xFFFFFF;
				
				if (!_weightTextGlowWhite)
				{
					_weightTextGlowWhite = new GlowFilter(0xFFFFFF, 1, 16, 16, 1.5, BitmapFilterQuality.HIGH);
				}
				
				tfWeight.filters = [_weightTextGlowWhite];
			}
			
			
		}
		
		public function setMoney(value:Number):void 
		{ 
			tfMoney.text = String(value); 
		}
	}
}