/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.gwint
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	public class GwintDeckStatsPanel extends UIComponent
	{
		protected var _deck:GwintDeck;
		
		public var txtCardCount:TextField;
		public var mcUnitCountHightlight:MovieClip;
		public var txtUnitCount:TextField;
		public var txtTotalCardValue:TextField;
		public var mcSpecialHighlight:MovieClip;
		public var txtSpecialCount:TextField;
		public var txtHeroCount:TextField;
		
		protected override function configUI():void
		{
			super.configUI();
			
		}
		
		public function set targetDeck(value:GwintDeck):void
		{
			_deck = value;
			updateStats();
		}
		
		public function highlightUnitCount():void
		{
			if (mcUnitCountHightlight)
			{
				mcUnitCountHightlight.gotoAndPlay("start");
			}
		}
		
		public function highlightSpecialCards():void
		{
			if (mcSpecialHighlight)
			{
				mcSpecialHighlight.gotoAndPlay("start");
			}
		}
		
		public function updateStats():void
		{
			if (!_deck)
			{
				throw new Error("GFX [ERROR] - trying to call updateStats in GwintDeckStatsPanel with no valid deck set");
			}
			
			if (txtCardCount)
			{
				txtCardCount.text = _deck.cardIndices.length.toString();
			}
			
			var cardManagerRef:CardManager = CardManager.getInstance();
			var totalCardValue:int = 0;
			var numSpecialCards:int = 0;
			var numHeroes:int = 0;
			var numUnits:int = 0;
			var i:int;
			var currentTemplate:CardTemplate;
			
			for (i = 0; i < _deck.cardIndices.length; ++i)
			{
				currentTemplate = cardManagerRef.getCardTemplate(_deck.cardIndices[i]);
				
				totalCardValue += currentTemplate.power;
				
				if (currentTemplate.isType(CardTemplate.CardType_Creature))
				{
					++numUnits;
				}
				else
				{
					++numSpecialCards;
				}
				
				if (currentTemplate.isType(CardTemplate.CardType_Hero))
				{
					++numHeroes;
				}
			}
			
			if (txtUnitCount)
			{
				if (numUnits < 22)
				{
					txtUnitCount.text = numUnits.toString() + "/22";
					txtUnitCount.textColor = 0xFF1C1C;
				}
				else
				{
					txtUnitCount.text = numUnits.toString();
					txtUnitCount.textColor = 0xB68E46;
				}
			}
			
			if (txtTotalCardValue)
			{
				txtTotalCardValue.text = totalCardValue.toString();
			}
			
			if (txtSpecialCount)
			{
				txtSpecialCount.text = numSpecialCards.toString() + "/10";
			}
			
			if (txtHeroCount)
			{
				txtHeroCount.text = numHeroes.toString();
			}
		}
	}
}