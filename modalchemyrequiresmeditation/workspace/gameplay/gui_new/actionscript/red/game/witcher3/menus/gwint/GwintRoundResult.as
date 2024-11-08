package red.game.witcher3.menus.gwint
{
	class GwintRoundResult
	{
		private var roundScores:Vector.<int>;
		private var roundWinner:int;
		
		public function get played():Boolean
		{
			return roundScores != null;
		}
		
		public function getPlayerScore(playerID:int) : int
		{
			if (played && playerID != CardManager.PLAYER_INVALID)
			{
				return roundScores[playerID];
			}
			
			return -1;
		}
		
		public function reset():void
		{
			roundScores = null;
		}
		
		public function get winningPlayer():int
		{
			if (roundWinner != -1)
			{
				return roundWinner;
			}
			
			if (played)
			{
				if (roundScores[CardManager.PLAYER_1] == roundScores[CardManager.PLAYER_2])
				{
					return CardManager.PLAYER_INVALID;
				}
				else if (roundScores[CardManager.PLAYER_1] > roundScores[CardManager.PLAYER_2])
				{
					return CardManager.PLAYER_1;
				}
				else
				{
					return CardManager.PLAYER_2;
				}
			}
			
			return CardManager.PLAYER_INVALID;
		}
		
		public function setResults(player1Score:int, player2Score:int, winner:int):void
		{
			if (played)
			{
				throw new Error("GFX - Tried to set round results on a round that already had results!");
			}
			
			roundScores = new Vector.<int>();
			
			roundScores.push(player1Score);
			roundScores.push(player2Score);
			roundWinner = winner;
		}
		
		public function toString():String
		{
			if (roundScores != null)
			{
				return "[ROUND RESULT] p1Score: " + roundScores[0] + ", p2Score: " + roundScores[1] + ", roundWinner: " + roundWinner;
			}
			else
			{
				return "[ROUND RESULT] empty!";
			}
		}
	}
}