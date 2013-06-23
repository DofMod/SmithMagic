package enum
{
	
	/**
	 * ...
	 * @author Relena
	 */
	public class EffectIdEnum
	{
		public static const LIFE:int = 110; // Old effect
		
		public static const AP:int = 111;
		public static const DAMAGE:int = 112;
		public static const CRITICAL:int = 115;
		public static const NEGATIVE_PO:int = 116;
		public static const PO:int = 117;
		public static const STRENGTH:int = 118;
		public static const AGILITY:int = 119;
		public static const LUCK:int = 123;
		public static const WISDOM:int = 124;
		public static const VITALITY:int = 125;
		public static const INTELLIGENCE:int = 126;
		public static const MP:int = 128;
		public static const DAMAGE_PERCENT:int = 138;
		
		public static const NEGATIVE_DAMAGE:int = 145;
		public static const NEGATIVE_LUCK:int = 152;
		public static const NEGATIVE_VITALITY:int = 153;
		public static const NEGATIVE_AGILITY:int = 154;
		public static const NEGATIVE_INTELLIGENCE:int = 155;
		public static const NEGATIVE_WISDOM:int = 156;
		public static const NEGATIVE_STRENGTH:int = 157;
		
		public static const PODS:int = 158;
		public static const NEGATIVE_PODS:int = 159;
		public static const DODGE_AP:int = 160;
		public static const DODGE_MP:int = 161;
		public static const NEGATIVE_DODGE_AP:int = 162;
		public static const NEGATIVE_DODGE_MP:int = 163;
		public static const NEGATIVE_AP:int = 168;
		public static const NEGATIVE_MP:int = 169;
		public static const NEGATIVE_CRITICAL:int = 171;
		public static const INITIATIVE:int = 174;
		public static const NEGATIVE_INITIATIVE:int = 175;
		public static const PROSPECTION:int = 176;
		public static const NEGATIVE_PROSPECTION:int = 177;
		public static const CARE:int = 178;
		public static const NEGATIVE_CARE:int = 179;
		public static const INVOCATION:int = 182;
		public static const NEGATIVE_DAMAGE_PERCENT:int = 186;
		
		public static const RESISTANCE_PERCENT_EARTH:int = 210;
		public static const RESISTANCE_PERCENT_WATER:int = 211;
		public static const RESISTANCE_PERCENT_AIR:int = 212;
		public static const RESISTANCE_PERCENT_FIRE:int = 213;
		public static const RESISTANCE_PERCENT_NEUTRAL:int = 214;
		public static const NEGATIVE_RESISTANCE_PERCENT_EARTH:int = 215;
		public static const NEGATIVE_RESISTANCE_PERCENT_WATER:int = 216;
		public static const NEGATIVE_RESISTANCE_PERCENT_AIR:int = 217;
		public static const NEGATIVE_RESISTANCE_PERCENT_FIRE:int = 218;
		public static const NEGATIVE_RESISTANCE_PERCENT_NEUTRAL:int = 219;
		
		public static const RETURN_DAMAGE:int = 220;
		public static const DAMAGE_TRAP:int = 225;
		public static const DAMAGE_PERCENT_TRAP:int = 226;
		
		public static const RESISTANCE_EARTH:int = 240;
		public static const RESISTANCE_WATER:int = 241;
		public static const RESISTANCE_AIR:int = 242;
		public static const RESISTANCE_FIRE:int = 243;
		public static const RESISTANCE_NEUTRAL:int = 244;
		public static const NEGATIVE_RESISTANCE_EARTH:int = 245;
		public static const NEGATIVE_RESISTANCE_WATER:int = 246;
		public static const NEGATIVE_RESISTANCE_AIR:int = 247;
		public static const NEGATIVE_RESISTANCE_FIRE:int = 248;
		public static const NEGATIVE_RESISTANCE_NEUTRAL:int = 249;
		
		public static const WITHDRAW_AP:int = 410;
		public static const NEGATIVE_WITHDRAW_AP:int = 411;
		public static const WITHDRAW_MP:int = 412;
		public static const NEGATIVE_WITHDRAW_MP:int = 413;
		public static const DAMAGE_PUSH:int = 414;
		public static const RESISTANCE_PUSH:int = 416;
		public static const NEGATIVE_RESISTANCE_PUSH:int = 417;
		public static const RESISTANCE_CRITICAL:int = 420;
		public static const NEGATIVE_RESISTANCE_CRITICAL:int = 421;
		
		public static const DAMAGE_EARTH:int = 422;
		public static const NEGATIVE_DAMAGE_EARTH:int = 423;
		public static const DAMAGE_FIRE:int = 424;
		public static const NEGATIVE_DAMAGE_FIRE:int = 425;
		public static const DAMAGE_WATER:int = 426;
		public static const NEGATIVE_DAMAGE_WATER:int = 427;
		public static const DAMAGE_AIR:int = 428;
		public static const NEGATIVE_DAMAGE_AIR:int = 429;
		public static const DAMAGE_NEUTRAL:int = 430;
		public static const NEGATIVE_DAMAGE_NEUTRAL:int = 431;
		
		public static const ESCAPE:int = 752;
		public static const TACKLE:int = 753;
		public static const NEGATIVE_ESCAPE:int = 754;
		public static const NEGATIVE_TACKLE:int = 755;
		public static const HUNTER:int = 795;
		
		/**
		 * Converte malus effect id to the coesponding bonus effect id.
		 * 
		 * @param	id	Identifier of the malus effect.
		 * 
		 * @return	The identifier of the bonus effect.
		 */
		public static function getEffectIdFromMalusToBonus(effectId:int):int
		{
			switch (effectId)
			{
				case EffectIdEnum.NEGATIVE_DAMAGE:
					return EffectIdEnum.DAMAGE;
				case EffectIdEnum.NEGATIVE_DAMAGE_EARTH:
					return EffectIdEnum.DAMAGE_EARTH;
				case EffectIdEnum.NEGATIVE_DAMAGE_NEUTRAL:
					return EffectIdEnum.DAMAGE_NEUTRAL;
				case EffectIdEnum.NEGATIVE_DAMAGE_FIRE:
					return EffectIdEnum.DAMAGE_FIRE;
				case EffectIdEnum.NEGATIVE_DAMAGE_AIR:
					return EffectIdEnum.DAMAGE_AIR;
				case EffectIdEnum.NEGATIVE_DAMAGE_WATER:
					return EffectIdEnum.DAMAGE_WATER;
				case EffectIdEnum.NEGATIVE_STRENGTH:
					return EffectIdEnum.STRENGTH;
				case EffectIdEnum.NEGATIVE_INTELLIGENCE:
					return EffectIdEnum.INTELLIGENCE;
				case EffectIdEnum.NEGATIVE_LUCK:
					return EffectIdEnum.LUCK;
				case EffectIdEnum.NEGATIVE_AGILITY:
					return EffectIdEnum.AGILITY;
				case EffectIdEnum.NEGATIVE_VITALITY:
					return EffectIdEnum.VITALITY;
				case EffectIdEnum.NEGATIVE_WISDOM:
					return EffectIdEnum.WISDOM;
				case EffectIdEnum.NEGATIVE_INITIATIVE:
					return EffectIdEnum.INITIATIVE;
				case EffectIdEnum.NEGATIVE_RESISTANCE_EARTH:
					return EffectIdEnum.RESISTANCE_EARTH;
				case EffectIdEnum.NEGATIVE_RESISTANCE_FIRE:
					return EffectIdEnum.RESISTANCE_FIRE;
				case EffectIdEnum.NEGATIVE_RESISTANCE_NEUTRAL:
					return EffectIdEnum.RESISTANCE_NEUTRAL;
				case EffectIdEnum.NEGATIVE_RESISTANCE_AIR:
					return EffectIdEnum.RESISTANCE_AIR;
				case EffectIdEnum.NEGATIVE_RESISTANCE_WATER:
					return EffectIdEnum.RESISTANCE_WATER;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_EARTH:
					return EffectIdEnum.RESISTANCE_PERCENT_EARTH;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_FIRE:
					return EffectIdEnum.RESISTANCE_PERCENT_FIRE;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_NEUTRAL:
					return EffectIdEnum.RESISTANCE_PERCENT_NEUTRAL;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_AIR:
					return EffectIdEnum.RESISTANCE_PERCENT_AIR;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_WATER:
					return EffectIdEnum.RESISTANCE_PERCENT_WATER;
				case EffectIdEnum.NEGATIVE_RESISTANCE_CRITICAL:
					return EffectIdEnum.RESISTANCE_CRITICAL;
				case EffectIdEnum.NEGATIVE_RESISTANCE_PUSH:
					return EffectIdEnum.RESISTANCE_PUSH;
				case EffectIdEnum.NEGATIVE_DODGE_AP:
					return EffectIdEnum.DODGE_AP;
				case EffectIdEnum.NEGATIVE_DODGE_MP:
					return EffectIdEnum.DODGE_MP;
				case EffectIdEnum.NEGATIVE_PODS:
					return EffectIdEnum.PODS;
				case EffectIdEnum.NEGATIVE_PROSPECTION:
					return EffectIdEnum.PROSPECTION;
				case EffectIdEnum.NEGATIVE_DAMAGE_PERCENT:
					return EffectIdEnum.DAMAGE_PERCENT;
				case EffectIdEnum.NEGATIVE_TACKLE:
					return EffectIdEnum.TACKLE;
				case EffectIdEnum.NEGATIVE_ESCAPE:
					return EffectIdEnum.ESCAPE;
				case EffectIdEnum.NEGATIVE_WITHDRAW_AP:
					return EffectIdEnum.WITHDRAW_AP;
				case EffectIdEnum.NEGATIVE_WITHDRAW_MP:
					return EffectIdEnum.WITHDRAW_MP;
				case EffectIdEnum.NEGATIVE_CARE:
					return EffectIdEnum.CARE;
				case EffectIdEnum.NEGATIVE_CRITICAL:
					return EffectIdEnum.CRITICAL;
				case EffectIdEnum.NEGATIVE_PO:
					return EffectIdEnum.PO;
				case EffectIdEnum.NEGATIVE_AP:
					return EffectIdEnum.AP;
				case EffectIdEnum.NEGATIVE_MP:
					return EffectIdEnum.MP;
			}
			
			return effectId;
		}
		
		/**
		 * Test if an effect is negative.
		 * 
		 * @param	id	Identifier of the effect.
		 * 
		 * @return	True or False.
		 */
		public static function isEffectNegative(effectId:int):Boolean
		{
			switch (effectId)
			{
				case EffectIdEnum.NEGATIVE_DAMAGE:
				case EffectIdEnum.NEGATIVE_DAMAGE_EARTH:
				case EffectIdEnum.NEGATIVE_DAMAGE_NEUTRAL:
				case EffectIdEnum.NEGATIVE_DAMAGE_FIRE:
				case EffectIdEnum.NEGATIVE_DAMAGE_AIR:
				case EffectIdEnum.NEGATIVE_DAMAGE_WATER:
				case EffectIdEnum.NEGATIVE_STRENGTH:
				case EffectIdEnum.NEGATIVE_INTELLIGENCE:
				case EffectIdEnum.NEGATIVE_LUCK:
				case EffectIdEnum.NEGATIVE_AGILITY:
				case EffectIdEnum.NEGATIVE_VITALITY:
				case EffectIdEnum.NEGATIVE_WISDOM:
				case EffectIdEnum.NEGATIVE_INITIATIVE:
				case EffectIdEnum.NEGATIVE_RESISTANCE_EARTH:
				case EffectIdEnum.NEGATIVE_RESISTANCE_FIRE:
				case EffectIdEnum.NEGATIVE_RESISTANCE_NEUTRAL:
				case EffectIdEnum.NEGATIVE_RESISTANCE_AIR:
				case EffectIdEnum.NEGATIVE_RESISTANCE_WATER:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_EARTH:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_FIRE:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_NEUTRAL:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_AIR:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PERCENT_WATER:
				case EffectIdEnum.NEGATIVE_RESISTANCE_CRITICAL:
				case EffectIdEnum.NEGATIVE_RESISTANCE_PUSH:
				case EffectIdEnum.NEGATIVE_DODGE_AP:
				case EffectIdEnum.NEGATIVE_DODGE_MP:
				case EffectIdEnum.NEGATIVE_PODS:
				case EffectIdEnum.NEGATIVE_PROSPECTION:
				case EffectIdEnum.NEGATIVE_DAMAGE_PERCENT:
				case EffectIdEnum.NEGATIVE_TACKLE:
				case EffectIdEnum.NEGATIVE_ESCAPE:
				case EffectIdEnum.NEGATIVE_WITHDRAW_AP:
				case EffectIdEnum.NEGATIVE_WITHDRAW_MP:
				case EffectIdEnum.NEGATIVE_CARE:
				case EffectIdEnum.NEGATIVE_CRITICAL:
				case EffectIdEnum.NEGATIVE_PO:
				case EffectIdEnum.NEGATIVE_AP:
				case EffectIdEnum.NEGATIVE_MP:
					return true;
			}
			
			return false;
		}
		
		/**
		 * Test if an effect is positive.
		 * 
		 * @param	effectId	Identifier of the effect.
		 * 
		 * @return	True of False.
		 */
		public static function isEffectPositive(effectId:int):Boolean
		{
			switch (effectId)
			{
				case EffectIdEnum.LIFE:
				case EffectIdEnum.AP:
				case EffectIdEnum.DAMAGE:
				case EffectIdEnum.CRITICAL:
				case EffectIdEnum.PO:
				case EffectIdEnum.STRENGTH:
				case EffectIdEnum.AGILITY:
				case EffectIdEnum.LUCK:
				case EffectIdEnum.WISDOM:
				case EffectIdEnum.VITALITY:
				case EffectIdEnum.INTELLIGENCE:
				case EffectIdEnum.MP:
				case EffectIdEnum.DAMAGE_PERCENT:
				case EffectIdEnum.PODS:
				case EffectIdEnum.DODGE_AP:
				case EffectIdEnum.DODGE_MP:
				case EffectIdEnum.INITIATIVE:
				case EffectIdEnum.PROSPECTION:
				case EffectIdEnum.CARE:
				case EffectIdEnum.INVOCATION:
				case EffectIdEnum.RESISTANCE_PERCENT_EARTH:
				case EffectIdEnum.RESISTANCE_PERCENT_WATER:
				case EffectIdEnum.RESISTANCE_PERCENT_AIR:
				case EffectIdEnum.RESISTANCE_PERCENT_FIRE:
				case EffectIdEnum.RESISTANCE_PERCENT_NEUTRAL:
				case EffectIdEnum.RETURN_DAMAGE:
				case EffectIdEnum.DAMAGE_TRAP:
				case EffectIdEnum.DAMAGE_PERCENT_TRAP:
				case EffectIdEnum.RESISTANCE_EARTH:
				case EffectIdEnum.RESISTANCE_WATER:
				case EffectIdEnum.RESISTANCE_AIR:
				case EffectIdEnum.RESISTANCE_FIRE:
				case EffectIdEnum.RESISTANCE_NEUTRAL:
				case EffectIdEnum.WITHDRAW_AP:
				case EffectIdEnum.WITHDRAW_MP:
				case EffectIdEnum.DAMAGE_PUSH:
				case EffectIdEnum.RESISTANCE_PUSH:
				case EffectIdEnum.RESISTANCE_CRITICAL:
				case EffectIdEnum.DAMAGE_EARTH:
				case EffectIdEnum.DAMAGE_FIRE:
				case EffectIdEnum.DAMAGE_WATER:
				case EffectIdEnum.DAMAGE_AIR:
				case EffectIdEnum.DAMAGE_NEUTRAL:
				case EffectIdEnum.ESCAPE:
				case EffectIdEnum.TACKLE:
				case EffectIdEnum.HUNTER:
					return true;
			}
			
			return false;
		}
		
		/**
		 * Test if the effect is forgeable.
		 * 
		 * @param	effectId	Identifier of the effect.
		 * 
		 * @return	True or False.
		 */
		public static function isForgeableEffect(effectId:int):Boolean
		{
			return isEffectPositive(effectId) || isEffectNegative(effectId);
		}
	}
}