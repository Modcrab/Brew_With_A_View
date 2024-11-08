package red.game.witcher3.menus.gwint
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.W3TextArea;
	import scaleform.clik.core.UIComponent;
	
	public class GwintDeckRenderer extends UIComponent
	{
		public var mcCardCount:MovieClip;
		public var mcDeckTop:MovieClip;
		
		override protected function configUI():void
		{
			super.configUI();
			_cardCount = 0;
		}
		
		private var _cardCount:int = 0;
		public function set cardCount(value:int):void
		{
			_cardCount = value;
			if (_cardCount == 0)
			{
				this.gotoAndStop(1);
				mcDeckTop.visible = false;
			}
			else
			{
				this.gotoAndStop(Math.min(50, _cardCount));
				mcDeckTop.visible = true;
			}
			
			var countW3Text:W3TextArea = mcCardCount ? mcCardCount.getChildByName("txtCount") as W3TextArea : null;
			if (countW3Text) { countW3Text.text = _cardCount.toString(); }
		}
		
		public function set factionString(value:String):void
		{
			mcDeckTop.gotoAndStop(value);
		}
	}
}