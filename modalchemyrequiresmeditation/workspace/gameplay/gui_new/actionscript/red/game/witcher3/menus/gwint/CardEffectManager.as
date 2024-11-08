package red.game.witcher3.menus.gwint
{
	public class CardEffectManager
	{
		private var seigeP2List:Vector.<CardInstance> = new Vector.<CardInstance>();
		private var rangedP2List:Vector.<CardInstance> = new Vector.<CardInstance>();
		private var meleeP2List:Vector.<CardInstance> = new Vector.<CardInstance>();
		private var meleeP1List:Vector.<CardInstance> = new Vector.<CardInstance>();
		private var rangedP1List:Vector.<CardInstance> = new Vector.<CardInstance>();
		private var seigeP1List:Vector.<CardInstance> = new Vector.<CardInstance>();
		
		public var randomResEnabled:Boolean = false;
		public var doubleSpyEnabled:Boolean = false;
		
		public function flushAllEffects():void
		{
			meleeP1List.length = 0;
			meleeP2List.length = 0;
			rangedP1List.length = 0;
			rangedP2List.length = 0;
			seigeP1List.length = 0;
			seigeP2List.length = 0;
		}
		
		private function getEffectList(listID:int, playerID:int):Vector.<CardInstance> 
		{
			if (playerID == CardManager.PLAYER_1)
			{
				if (listID == CardManager.CARD_LIST_LOC_MELEE)
				{
					return meleeP1List;
				}
				else if (listID == CardManager.CARD_LIST_LOC_RANGED)
				{
					return rangedP1List;
				}
				else if (listID == CardManager.CARD_LIST_LOC_SEIGE)
				{
					return seigeP1List;
				}
			}
			else if (playerID == CardManager.PLAYER_2)
			{
				if (listID == CardManager.CARD_LIST_LOC_MELEE)
				{
					return meleeP2List;
				}
				else if (listID == CardManager.CARD_LIST_LOC_RANGED)
				{
					return rangedP2List;
				}
				else if (listID == CardManager.CARD_LIST_LOC_SEIGE)
				{
					return seigeP2List;
				}
			}
			
			return null;
		}
		
		public function registerActiveEffectCardInstance(cardInstance:CardInstance, listID:int, playerID:int):void
		{
			var correctList:Vector.<CardInstance> = getEffectList(listID, playerID);
			
			trace("GFX - effect was registed in list:", listID, ", for player:", playerID, " and CardInstance:", cardInstance);
			
			if (correctList)
			{
				correctList.push(cardInstance);
			}
			else
			{
				throw new Error("GFX - Failed to set effect into proper list in GFX manager. listID: " + listID.toString() + ", playerID: " + playerID);
			}
			
			CardManager.getInstance().recalculateScores();
		}
		
		public function unregisterActiveEffectCardInstance(cardInstance:CardInstance):void
		{
			trace("GFX - unregistering Effect: ", cardInstance);
			
			var indexOf:int;
			
			indexOf = seigeP2List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				seigeP2List.splice(indexOf, 1);
			}
			
			indexOf = rangedP2List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				rangedP2List.splice(indexOf, 1);
			}
			
			indexOf = meleeP2List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				meleeP2List.splice(indexOf, 1);
			}
			
			indexOf = meleeP1List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				meleeP1List.splice(indexOf, 1);
			}
			
			indexOf = rangedP1List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				rangedP1List.splice(indexOf, 1);
			}
			
			indexOf = seigeP1List.indexOf(cardInstance);
			if (indexOf != -1)
			{
				seigeP1List.splice(indexOf, 1);
			}
			
			CardManager.getInstance().recalculateScores();
		}
		
		public function getEffectsForList(listID:int, playerID:int):Vector.<CardInstance>
		{
			var effectList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var i:int;
			
			var correctList:Vector.<CardInstance> = getEffectList(listID, playerID);
			
			if (correctList)
			{
				for (i = 0; i < correctList.length; ++i)
				{
					effectList.push(correctList[i]);
				}
			}
			
			return effectList;
		}
	}
}