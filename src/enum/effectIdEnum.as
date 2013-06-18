package enum
{
	
	/**
	 * ...
	 * @author Relena
	 */
	public class effectIdEnum
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
		public static function getEffectIdFromMalusToBonus(id:int):int
		{
			switch (id)
			{
				case effectIdEnum.NEGATIVE_DAMAGE:
					return effectIdEnum.DAMAGE;
				case effectIdEnum.NEGATIVE_DAMAGE_EARTH:
					return effectIdEnum.DAMAGE_EARTH;
				case effectIdEnum.NEGATIVE_DAMAGE_NEUTRAL:
					return effectIdEnum.DAMAGE_NEUTRAL;
				case effectIdEnum.NEGATIVE_DAMAGE_FIRE:
					return effectIdEnum.DAMAGE_FIRE;
				case effectIdEnum.NEGATIVE_DAMAGE_AIR:
					return effectIdEnum.DAMAGE_AIR;
				case effectIdEnum.NEGATIVE_DAMAGE_WATER:
					return effectIdEnum.DAMAGE_WATER;
				case effectIdEnum.NEGATIVE_STRENGTH:
					return effectIdEnum.STRENGTH;
				case effectIdEnum.NEGATIVE_INTELLIGENCE:
					return effectIdEnum.INTELLIGENCE;
				case effectIdEnum.NEGATIVE_LUCK:
					return effectIdEnum.LUCK;
				case effectIdEnum.NEGATIVE_AGILITY:
					return effectIdEnum.AGILITY;
				case effectIdEnum.NEGATIVE_VITALITY:
					return effectIdEnum.VITALITY;
				case effectIdEnum.NEGATIVE_WISDOM:
					return effectIdEnum.WISDOM;
				case effectIdEnum.NEGATIVE_INITIATIVE:
					return effectIdEnum.INITIATIVE;
				case effectIdEnum.NEGATIVE_RESISTANCE_EARTH:
					return effectIdEnum.RESISTANCE_EARTH;
				case effectIdEnum.NEGATIVE_RESISTANCE_FIRE:
					return effectIdEnum.RESISTANCE_FIRE;
				case effectIdEnum.NEGATIVE_RESISTANCE_NEUTRAL:
					return effectIdEnum.RESISTANCE_NEUTRAL;
				case effectIdEnum.NEGATIVE_RESISTANCE_AIR:
					return effectIdEnum.RESISTANCE_AIR;
				case effectIdEnum.NEGATIVE_RESISTANCE_WATER:
					return effectIdEnum.RESISTANCE_WATER;
				case effectIdEnum.NEGATIVE_RESISTANCE_PERCENT_EARTH:
					return effectIdEnum.RESISTANCE_PERCENT_EARTH;
				case effectIdEnum.NEGATIVE_RESISTANCE_PERCENT_FIRE:
					return effectIdEnum.RESISTANCE_PERCENT_FIRE;
				case effectIdEnum.NEGATIVE_RESISTANCE_PERCENT_NEUTRAL:
					return effectIdEnum.RESISTANCE_PERCENT_NEUTRAL;
				case effectIdEnum.NEGATIVE_RESISTANCE_PERCENT_AIR:
					return effectIdEnum.RESISTANCE_PERCENT_AIR;
				case effectIdEnum.NEGATIVE_RESISTANCE_PERCENT_WATER:
					return effectIdEnum.RESISTANCE_PERCENT_WATER;
				case effectIdEnum.NEGATIVE_RESISTANCE_CRITICAL:
					return effectIdEnum.RESISTANCE_CRITICAL;
				case effectIdEnum.NEGATIVE_RESISTANCE_PUSH:
					return effectIdEnum.RESISTANCE_PUSH;
				case effectIdEnum.NEGATIVE_DODGE_AP:
					return effectIdEnum.DODGE_AP;
				case effectIdEnum.NEGATIVE_DODGE_MP:
					return effectIdEnum.DODGE_MP;
				case effectIdEnum.NEGATIVE_PODS:
					return effectIdEnum.PODS;
				case effectIdEnum.NEGATIVE_PROSPECTION:
					return effectIdEnum.PROSPECTION;
				case effectIdEnum.NEGATIVE_DAMAGE_PERCENT:
					return effectIdEnum.DAMAGE_PERCENT;
				case effectIdEnum.NEGATIVE_TACKLE:
					return effectIdEnum.TACKLE;
				case effectIdEnum.NEGATIVE_ESCAPE:
					return effectIdEnum.ESCAPE;
				case effectIdEnum.NEGATIVE_WITHDRAW_AP:
					return effectIdEnum.WITHDRAW_AP;
				case effectIdEnum.NEGATIVE_WITHDRAW_MP:
					return effectIdEnum.WITHDRAW_MP;
				case effectIdEnum.NEGATIVE_CARE:
					return effectIdEnum.CARE;
				case effectIdEnum.NEGATIVE_CRITICAL:
					return effectIdEnum.CRITICAL;
				case effectIdEnum.NEGATIVE_PO:
					return effectIdEnum.PO;
				case effectIdEnum.NEGATIVE_AP:
					return effectIdEnum.AP;
				case effectIdEnum.NEGATIVE_MP:
					return effectIdEnum.MP;
			}
			
			return id;
		}
	}
}