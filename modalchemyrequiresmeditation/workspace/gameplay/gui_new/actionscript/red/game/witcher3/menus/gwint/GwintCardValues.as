package red.game.witcher3.menus.gwint
{
	import flash.utils.Dictionary;
	public class GwintCardValues
	{
		public var weatherCardValue:Number;
		public var hornCardValue:Number;
		public var drawCardValue:Number;
		public var scorchCardValue:Number;
		public var summonClonesCardValue:Number;
		public var unsummonCardValue:Number;
		public var improveNeighboursCardValue:Number;
		public var nurseCardValue:Number;
		
		private var _bufferedDictionary:Dictionary;
		public function getEffectValueDictionary():Dictionary
		{
			if (_bufferedDictionary == null)
			{
				_bufferedDictionary = new Dictionary();
				_bufferedDictionary[CardTemplate.CardEffect_Horn] = hornCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_Draw] = drawCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_Draw2] = drawCardValue * 2;
				_bufferedDictionary[CardTemplate.CardEffect_Scorch] = scorchCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_SummonClones] = summonClonesCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_UnsummonDummy] = unsummonCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_ImproveNeighbours] = improveNeighboursCardValue;
				_bufferedDictionary[CardTemplate.CardEffect_Nurse] = nurseCardValue;
			}
			
			return _bufferedDictionary;
		}
	}
}