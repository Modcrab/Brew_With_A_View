package red.game.witcher3.menus.gwint
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
	public class CardTemplate
	{
		// #J the following defines need to match the ws!!
	
		// Faction Indexes
		// {
		public static const FactionId_Error				:int = -1;
		public static const FactionId_Neutral			:int = 0;
		public static const FactionId_No_Mans_Land		:int = 1;
		public static const FactionId_Nilfgaard 		:int = 2;
		public static const FactionId_Northern_Kingdom	:int = 3;
		public static const FactionId_Scoiatael			:int = 4;
		public static const FactionId_Skellige			:int = 5;
		// }
		
		// Card Type Flags (bit array!)
		// {
		public static const CardType_None				:uint = 0;
		public static const CardType_Melee				:uint = 1;
		public static const CardType_Ranged				:uint = 2;
		public static const CardType_RangedMelee		:uint = 3;
		public static const CardType_Siege				:uint = 4;
		public static const CardType_SeigeRangedMelee	:uint = 7;
		public static const CardType_Creature			:uint = 8;
		public static const CardType_Weather			:uint = 16;
		public static const CardType_Spell				:uint = 32;
		public static const CardType_Row_Modifier		:uint = 64;
		public static const CardType_Hero				:uint = 128;
		public static const CardType_Spy				:uint = 256;
		public static const CardType_Friendly_Effect	:uint = 512;
		public static const CardType_Offsensive_Effect	:uint = 1024;
		public static const CardType_Global_Effect		:uint = 2048;
		// }
		
		// Card Power Ids
		// {
		public static const CardEffect_None				:int = 0;
		public static const CardEffect_Backstab			:int = 1;
		public static const CardEffect_Morale_Boost		:int = 2;
		public static const CardEffect_Ambush			:int = 3;
		public static const CardEffect_ToughSkin		:int = 4;
		public static const CardEffect_Bin2				:int = 5;
		public static const CardEffect_Bin3				:int = 6;
		public static const CardEffect_MeleeScorch		:int = 7;
		public static const CardEffect_11th_card		:int = 8;
		public static const CardEffect_Clear_Weather	:int = 9;
		public static const CardEffect_Pick_Weather		:int = 10;
		public static const CardEffect_Pick_Rain		:int = 11;
		public static const CardEffect_Pick_Fog			:int = 12;
		public static const CardEffect_Pick_Frost		:int = 13;
		public static const CardEffect_View_3_Enemy		:int = 14;
		public static const CardEffect_Resurect			:int = 15;
		public static const CardEffect_Resurect_Enemy	:int = 16;
		public static const CardEffect_Bin2_Pick1		:int = 17;
		public static const CardEffect_Melee_Horn		:int = 18;
		public static const CardEffect_Range_Horn		:int = 19;
		public static const CardEffect_Siege_Horn		:int = 20;
		public static const CardEffect_Siege_Scorch		:int = 21;
		public static const CardEffect_Counter_King		:int = 22;
		// }
		// Card Effect Flags (continues from other)
		// {
		public static const CardEffect_Melee			:int = 23;
		public static const CardEffect_Ranged			:int = 24;
		public static const CardEffect_Siege			:int = 25;
		public static const CardEffect_UnsummonDummy	:int = 26;
		public static const CardEffect_Horn				:int = 27;
		public static const CardEffect_Draw				:int = 28;	// Deprecated
		public static const CardEffect_Scorch			:int = 29;
		public static const CardEffect_ClearSky			:int = 30;
		public static const CardEffect_SummonClones		:int = 31;
		public static const CardEffect_ImproveNeighbours:int = 32;
		public static const CardEffect_Nurse			:int = 33;
		public static const CardEffect_Draw2			:int = 34;
		public static const CardEffect_SameTypeMorale	:int = 35;
		// }
		// Episode One Effects
		// {
		public static const CardEffect_AgileReposition	:int = 36;
		public static const CardEffect_RandomRessurect	:int = 37;
		public static const CardEffect_DoubleSpy		:int = 38;
		public static const CardEffect_RangedScorch		:int = 39;
		public static const CardEffect_SuicideSummon	:int = 40;
		// }
		// Episode Two Effects
		// {
		public static const CardEffect_Mushroom			:int = 41;
		public static const CardEffect_Morph			:int = 42;
		public static const CardEffect_WeatherResistant	:int = 43;
		public static const CardEffect_GraveyardShuffle	:int = 44;
		// }
	
		/*---------------------------------------
		 *  Witcher Script variables
		 *---------------------------------------*/
		public var index:int;
		public var title:String;
		public var description:String;
		public var power:int;
		public var imageLoc:String;
		public var factionIdx:int;
		public var typeArray:uint;
		public var effectFlags:Array;
		public var summonFlags:Array;
		/*---------------------------------------*/
		
		public function isType(typeID:uint):Boolean
		{
			if (typeID == CardType_None && typeArray != 0)
			{
				return false;
			}
			else
			{
				return (typeArray & typeID) == typeID;
			}
		}
		
		public function getFirstEffect():int
		{
			if (effectFlags == null || effectFlags.length == 0)
			{
				return CardEffect_None;
			}
			else
			{
				return effectFlags[0];
			}
		}
		
		public function hasEffect(effectFlag:int):Boolean
		{
			var i:int;
			
			for (i = 0; i < effectFlags.length; ++i)
			{
				if (effectFlags[i] == effectFlag)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function GetBonusValue():Number
		{
			var i:int;
			var totalBonus:Number = 0;
			var bonusDictionary:Dictionary = CardManager.getInstance().cardValues.getEffectValueDictionary();
			var effectBonus:Number;
			
			for (i = 0; i < effectFlags.length; ++i)
			{
				effectBonus = bonusDictionary[effectFlags[i]];
				
				if (effectBonus)
				{
					totalBonus += effectBonus;
				}
			}
			
			return totalBonus;
		}
		
		
		// Limits it to abilities that can be abused
		public function GetDeployBonusValue():Number
		{
			var i:int;
			var totalBonus:Number = 0;
			var bonusDictionary:Dictionary = CardManager.getInstance().cardValues.getEffectValueDictionary();
			var effectBonus:Number;
				
			if (hasEffect(CardTemplate.CardEffect_Draw))
			{
				totalBonus += bonusDictionary[CardTemplate.CardEffect_Draw];
			}
			
			if (hasEffect(CardTemplate.CardEffect_Draw2))
			{
				totalBonus += bonusDictionary[CardTemplate.CardEffect_Draw2];
			}
			
			if (hasEffect(CardTemplate.CardEffect_SummonClones))
			{
				totalBonus += bonusDictionary[CardTemplate.CardEffect_SummonClones];
			}
			
			if (hasEffect(CardTemplate.CardEffect_Nurse))
			{
				totalBonus += bonusDictionary[CardTemplate.CardEffect_Draw];
			}
			
			return totalBonus;
		}
		
		public function getFactionString():String
		{
			return getFactionStringFromId(factionIdx);
		}
		
		public static function getFactionStringFromId(factionId:int):String
		{
			switch (factionId)
			{
				case FactionId_Neutral:	
					return "Neutral";
				case FactionId_No_Mans_Land:
					return "NoMansLand";
				case FactionId_Nilfgaard:
					return "Nilfgaard";
				case FactionId_Northern_Kingdom:
					return "NorthKingdom";
				case FactionId_Scoiatael:
					return "Scoiatael";
				case FactionId_Skellige:
					return "Skellige";
			}
			
			return "None";
		}
		
		public function getPlacementType():int
		{
			return typeArray & CardType_SeigeRangedMelee;
		}
		
		public function getTypeString():String
		{
			if (isType(CardType_Row_Modifier))
			{
				if (hasEffect(CardEffect_Mushroom))
				{
					return "mushroom";
				}
				else
				{
					return "horn";
				}
			}
			else if (isType(CardType_Weather))
			{
				if (hasEffect(CardEffect_ClearSky) || hasEffect(CardEffect_Clear_Weather))
				{
					return "clearsky";
				}
				else if (hasEffect(CardEffect_Melee))
				{
					return "frost";
				}
				else if (hasEffect(CardEffect_Ranged))
				{
					if (hasEffect(CardEffect_Siege))
					{
						return "storm";
					}
					else
					{
						return "fog";
					}
				}
				else if (hasEffect(CardEffect_Siege))
				{
					return "rain";
				}
			}
			else if (isType(CardType_Spell))
			{
				if (hasEffect(CardEffect_UnsummonDummy))
				{
					return "dummy";
				}
			}
			else if (isType(CardType_Global_Effect))
			{
				if (hasEffect(CardEffect_Scorch))
				{
					return "scorch";
				}
			}
			else if (isType(CardType_Hero))
			{
				return "Hero";
			}
			
			return getPlacementTypeString();
		}
		
		public function getPlacementTypeString():String
		{
			if (isType(CardType_Creature))
			{
				if (isType(CardType_RangedMelee))
				{
					return "RangedMelee";
				}
				else if (isType(CardType_Melee))
				{
					return "Melee";
				}
				else if (isType(CardType_Ranged))
				{
					return "Ranged";
				}
				else if (isType(CardType_Siege))
				{
					return "Siege";
				}
			}
			
			return "None";
		}
		
		public function getEffectsAsPlacementType():int
		{
			var totalTypeAffected:int = CardType_None;
			
			if (hasEffect(CardEffect_Melee))
			{
				totalTypeAffected = totalTypeAffected | CardType_Melee;
			}
			
			if (hasEffect(CardEffect_Ranged))
			{
				totalTypeAffected = totalTypeAffected | CardType_Ranged;
			}
			
			if (hasEffect(CardEffect_Siege))
			{
				totalTypeAffected = totalTypeAffected | CardType_Siege;
			}
			
			return totalTypeAffected;
		}
		
		public function getEffectString():String
		{
			if (isType(CardType_Creature))
			{
				if (hasEffect(CardEffect_SummonClones))
				{
					return "summonClones";
				}
				else if (hasEffect(CardEffect_Nurse))
				{
					return "nurse";
				}
				else if (hasEffect(CardEffect_Draw2))
				{
					return "spy";
				}
				else if (hasEffect(CardEffect_SameTypeMorale))
				{
					return "stMorale";
				}
				else if (hasEffect(CardEffect_ImproveNeighbours))
				{
					return "impNeighbours";
				}
				else if (hasEffect(CardEffect_Horn))
				{
					return "horn";
				}
				else if (isType(CardType_RangedMelee))
				{
					return "agile";
				}
				else if (hasEffect(CardEffect_Scorch))
				{
					return "scorch";
				}
				else if (hasEffect(CardEffect_Mushroom))
				{
					return "mushroom";
				}
				else if (hasEffect(CardEffect_MeleeScorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_RangedScorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_Siege_Scorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_Morph))
				{
					return "morph";
				}
				else if (hasEffect(CardEffect_SuicideSummon))
				{
					return "suicide_summon";
				}
			}
			
			return "None";
		}
		
		public function getCreatureType():int
		{
			return typeArray & CardType_SeigeRangedMelee;
		}
		
		public function get tooltipIcon():String
		{
			if (isType(CardType_Row_Modifier))
			{
				if (hasEffect(CardEffect_Mushroom))
				{
					return "mushroom";
				}
				else
				{
					return "horn";
				}
			}
			else if (isType(CardType_Weather))
			{
				if (hasEffect(CardEffect_ClearSky) || hasEffect(CardEffect_Clear_Weather))
				{
					return "clearsky";
				}
				else if (hasEffect(CardEffect_Melee))
				{
					return "frost";
				}
				else if (hasEffect(CardEffect_Ranged))
				{
					if (hasEffect(CardEffect_Siege))
					{
						return "storm";
					}
					else
					{
						return "fog";
					}
				}
				else if (hasEffect(CardEffect_Siege))
				{
					return "rain";
				}
			}
			else if (isType(CardType_Spell))
			{
				if (hasEffect(CardEffect_UnsummonDummy))
				{
					return "dummy";
				}
			}
			else if (isType(CardType_Global_Effect))
			{
				if (hasEffect(CardEffect_Scorch))
				{
					return "scorch";
				}
			}
			else if (isType(CardType_Creature))
			{
				if (hasEffect(CardEffect_SummonClones))
				{
					return "summonClones";
				}
				else if (hasEffect(CardEffect_Nurse))
				{
					return "nurse";
				}
				else if (hasEffect(CardEffect_Draw2))
				{
					return "spy";
				}
				else if (hasEffect(CardEffect_SameTypeMorale))
				{
					return "stMorale";
				}
				else if (hasEffect(CardEffect_ImproveNeighbours))
				{
					return "impNeighbours";
				}
				else if (hasEffect(CardEffect_Horn))
				{
					return "horn";
				}
				else if (isType(CardType_RangedMelee))
				{
					return "agile";
				}
				else if (hasEffect(CardEffect_MeleeScorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_RangedScorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_Siege_Scorch))
				{
					return "spe_scorch";
				}
				else if (hasEffect(CardEffect_Mushroom))
				{
					return "mushroom";
				}
				else if (hasEffect(CardEffect_Morph))
				{
					return "morph";
				}
				else if (hasEffect(CardEffect_Scorch))
				{
					return "scorch";
				}
				else if (hasEffect(CardEffect_SuicideSummon))
				{
					return "suicide_summon";
				}
			}
			
			return "None";
		}
		
		public function get tooltipString():String
		{
			if (isType(CardType_Row_Modifier))
			{
				if (hasEffect(CardEffect_Mushroom))
				{
					return "gwint_card_tooltip_mushroom";
				}
				else
				{
					return "gwint_card_tooltip_horn";
				}
			}
			else if (isType(CardType_Weather))
			{
				if (hasEffect(CardEffect_ClearSky) || hasEffect(CardEffect_Clear_Weather))
				{
					return "gwint_card_tooltip_clearsky";
				}
				else if (hasEffect(CardEffect_Melee))
				{
					return "gwint_card_tooltip_frost";
				}
				else if (hasEffect(CardEffect_Ranged))
				{
					if (hasEffect(CardEffect_Siege))
					{
						return "gwint_card_tooltip_skel_rain";
					}
					else
					{
						return "gwint_card_tooltip_fog";
					}
				}
				else if (hasEffect(CardEffect_Siege))
				{
					return "gwint_card_tooltip_rain";
				}
			}
			else if (isType(CardType_Spell))
			{
				if (hasEffect(CardEffect_UnsummonDummy))
				{
					return "gwint_card_tooltip_dummy";
				}
			}
			else if (isType(CardType_Global_Effect))
			{
				if (hasEffect(CardEffect_Scorch))
				{
					return "gwint_card_tooltip_scorch";
				}
			}
			else if (isType(CardType_Creature))
			{
				if (hasEffect(CardEffect_SummonClones))
				{
					if (index == 502)
					{
						return "gwint_card_tooltip_summon_sm";
					}
					if ((index == 26) || (index == 27))
					{
						return "gwint_card_tooltip_summon_roach";
					}
					return "gwint_card_tooltip_summon_clones";
				}
				else if (hasEffect(CardEffect_SuicideSummon))
				{
					return "gwint_card_tooltip_suicide_summon";
				}
				else if (hasEffect(CardEffect_Nurse))
				{
					return "gwint_card_tooltip_nurse";
				}
				else if (hasEffect(CardEffect_Draw2))
				{
					return "gwint_card_tooltip_spy";
				}
				else if (hasEffect(CardEffect_SameTypeMorale))
				{
					return "gwint_card_tooltip_same_type_morale";
				}
				else if (hasEffect(CardEffect_ImproveNeighbours))
				{
					return "gwint_card_tooltip_improve_neightbours";
				}
				else if (hasEffect(CardEffect_Horn))
				{
					return "gwint_card_tooltip_horn";
				}
				else if (isType(CardType_RangedMelee))
				{
					return "gwint_card_tooltip_agile";
				}
				else if (hasEffect(CardEffect_MeleeScorch))
				{
					return "gwint_card_villen_melee_scorch";
				}
				else if (hasEffect(CardEffect_RangedScorch))
				{
					return "gwint_card_ranged_scorch";
				}
				else if (hasEffect(CardEffect_Siege_Scorch))
				{
					return "gwint_card_siege_scorch";
				}
				else if (hasEffect(CardEffect_Scorch))
				{
					return "gwint_card_tooltip_scorch";
				}
				else if (hasEffect(CardEffect_Mushroom))
				{
					return "gwint_card_tooltip_mushroom";
				}
				else if (hasEffect(CardEffect_Morph))
				{
					return "gwint_card_tooltip_morph";
				}
				else if (isType(CardType_Hero))
				{
					return "gwint_card_tooltip_hero";
				}
			}
			else if (isType(CardType_None))
			{
				switch (getFirstEffect())
				{
				case CardTemplate.CardEffect_Clear_Weather:
					return "gwint_card_tooltip_ldr_clear_weather";
				case CardTemplate.CardEffect_Pick_Fog:
					return "gwint_card_tooltip_ldr_pick_fog";
				case CardTemplate.CardEffect_Siege_Horn:
					return "gwint_card_tooltip_ldr_siege_horn";
				case CardTemplate.CardEffect_Siege_Scorch:
					return "gwint_card_tooltip_ldr_siege_scorch";
				case CardTemplate.CardEffect_Pick_Frost:
					return "gwint_card_tooltip_ldr_pick_frost";
				case CardTemplate.CardEffect_Range_Horn:
					return "gwint_card_tooltip_ldr_range_horn";
				case CardTemplate.CardEffect_11th_card:
					return "gwint_card_tooltip_ldr_eleventh_card";
				case CardTemplate.CardEffect_MeleeScorch:
					return "gwint_card_tooltip_ldr_melee_scorch";
				case CardTemplate.CardEffect_Pick_Rain:
					return "gwint_card_tooltip_ldr_pick_rain";
				case CardTemplate.CardEffect_View_3_Enemy:
					return "gwint_card_tooltip_ldr_view_enemy";
				case CardTemplate.CardEffect_Resurect_Enemy:
					return "gwint_card_tooltip_ldr_resurect_enemy";
				case CardTemplate.CardEffect_Counter_King:
					return "gwint_card_tooltip_ldr_counter_king";
				case CardTemplate.CardEffect_Bin2_Pick1:
					return "gwint_card_tooltip_ldr_bin_pick";
				case CardTemplate.CardEffect_Pick_Weather:
					return "gwint_card_tooltip_ldr_pick_weather";
				case CardTemplate.CardEffect_Resurect:
					return "gwint_card_tooltip_ldr_resurect";
				case CardTemplate.CardEffect_Melee_Horn:
					return "gwint_card_tooltip_ldr_melee_horn";
				case CardTemplate.CardEffect_AgileReposition:
					return "gwint_card_tooltip_ldr_agile_reposition";
				case CardTemplate.CardEffect_RandomRessurect:
					return "gwint_card_tooltip_ldr_random_ressurect";
				case CardTemplate.CardEffect_DoubleSpy:
					return "gwint_card_tooltip_ldr_double_spy";
				case CardTemplate.CardEffect_RangedScorch:
					return "gwint_card_tooltip_ldr_ranged_scorch";
				case CardTemplate.CardEffect_WeatherResistant:
					return "gwint_card_tooltip_ldr_weather_resistant";
				case CardTemplate.CardEffect_GraveyardShuffle:
					return "gwint_card_tooltip_ldr_graveyard_shuffle";
				}
			}
			
			return "";
		}
		
		public function toString():String
		{
			return "[Gwint CardTemplate] index:" + index + ", title:" + title + ", imageLoc:" + imageLoc + ", power:" + power + ", facionIdx:" + factionIdx + ", type:" + typeArray + ", effectString: " + getEffectString();
		}
	}
	
}
