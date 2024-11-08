package red.game.witcher3.menus.meditation_menu 
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Meditation clock assest
	 * @author Yaroslav Getsevich
	 */
	public class DayQuarterIndicator extends UIComponent
	{
		public var fxIconN:Sprite;
		public var fxIconE:Sprite;
		public var fxIconS:Sprite;
		public var fxIconW:Sprite;
		
		protected var _currentTime:Number;
		protected var _selectedSprite:Sprite;
		
		public function DayQuarterIndicator() 
		{
			fxIconN.alpha = 0;
			fxIconE.alpha = 0;
			fxIconS.alpha = 0;
			fxIconW.alpha = 0;
		}
		
		public function get currentTime():Number { return _currentTime }
		public function set currentTime(value:Number):void
		{
			var targetSprite:Sprite;
			_currentTime = value;
			if ((_currentTime > 21 ||  _currentTime <= 3))
			{
				targetSprite = fxIconS;
			}
			else
			if (_currentTime > 3 && _currentTime <= 9)
			{
				targetSprite = fxIconW;
			}
			else
			if (_currentTime > 9 && _currentTime <= 15)
			{
				targetSprite = fxIconN;
			}
			else
			if (_currentTime > 15 && _currentTime < 21)
			{
				targetSprite = fxIconE;
			}
			if (targetSprite != _selectedSprite)
			{
				if (_selectedSprite)
				{
					GTweener.removeTweens(_selectedSprite);
					GTweener.to(_selectedSprite, 1.5, { alpha:0 }, { ease:Sine.easeIn } );
					//_selectedSprite.visible = false;
				}
				_selectedSprite = targetSprite;
				GTweener.removeTweens(_selectedSprite);
				GTweener.to(_selectedSprite, 1.5, { alpha:1 }, { ease:Sine.easeOut } );
				//_selectedSprite.visible = true;
			}
		}
		
	}

}