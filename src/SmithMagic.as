package
{
	import d2api.JobsApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.Skill;
	import d2hooks.ExchangeLeave;
	import d2hooks.ExchangeStartOkCraft;
	import d2hooks.ExchangeStartOkMultiCraft;
	import enum.EffectIdEnum;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import ui.SmithMagicUi;
	
	/**
	 * Main module class (Entry point).
	 * 
	 * @author ExiTeD, Relena
	 */
	
	public class SmithMagic extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Include ui source files
		private var includes:Array = [SmithMagicUi];
		
		// Some constants
		private static const uiName:String = "smithmagic";
		private static const uiInstanceName:String = "exited_smithmagic";
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var jobsApi:JobsApi;
		
		// Some globals
		public static var well:Number = 0;
		public static var skill:Skill = null;
		public static var runesWeight:Dictionary = new Dictionary();
		public static var inCooperatingMode:Boolean;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			runesWeight[EffectIdEnum.INITIATIVE] = 0.1;
			
			runesWeight[EffectIdEnum.LIFE] = 0.25;
			runesWeight[EffectIdEnum.VITALITY] = 0.25;
			runesWeight[EffectIdEnum.PODS] = 0.25;

			runesWeight[EffectIdEnum.STRENGTH] = 1;
			runesWeight[EffectIdEnum.INTELLIGENCE] = 1;
			runesWeight[EffectIdEnum.LUCK] = 1;
			runesWeight[EffectIdEnum.AGILITY] = 1;
			
			runesWeight[EffectIdEnum.DAMAGE_PERCENT] = 2;
			runesWeight[EffectIdEnum.DAMAGE_PERCENT_TRAP] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_AIR] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_WATER] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_FIRE] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_NEUTRAL] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_EARTH] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_PUSH] = 2;
			runesWeight[EffectIdEnum.RESISTANCE_CRITICAL] = 2;
			
			runesWeight[EffectIdEnum.WISDOM] = 3;
			runesWeight[EffectIdEnum.PROSPECTION] = 3;
			
			runesWeight[EffectIdEnum.TACKLE] = 4;
			runesWeight[EffectIdEnum.ESCAPE] = 4;
			
			runesWeight[EffectIdEnum.DAMAGE_NEUTRAL] = 5;
			runesWeight[EffectIdEnum.DAMAGE_FIRE] = 5;
			runesWeight[EffectIdEnum.DAMAGE_AIR] = 5;
			runesWeight[EffectIdEnum.DAMAGE_EARTH] = 5;
			runesWeight[EffectIdEnum.DAMAGE_WATER] = 5;
			runesWeight[EffectIdEnum.DAMAGE_PUSH] = 5;
			runesWeight[EffectIdEnum.HUNTER] = 5;

			runesWeight[EffectIdEnum.RESISTANCE_PERCENT_AIR] = 6;
			runesWeight[EffectIdEnum.RESISTANCE_PERCENT_WATER] = 6;
			runesWeight[EffectIdEnum.RESISTANCE_PERCENT_FIRE] = 6;
			runesWeight[EffectIdEnum.RESISTANCE_PERCENT_NEUTRAL] = 6;
			runesWeight[EffectIdEnum.RESISTANCE_PERCENT_EARTH] = 6;
			
			runesWeight[EffectIdEnum.DODGE_AP] = 7;
			runesWeight[EffectIdEnum.DODGE_MP] = 7;
			
			runesWeight[EffectIdEnum.WITHDRAW_AP] = 7;
			runesWeight[EffectIdEnum.WITHDRAW_MP] = 7;
			
			runesWeight[EffectIdEnum.DAMAGE_TRAP] = 15;
			
			runesWeight[EffectIdEnum.CARE] = 20;
			runesWeight[EffectIdEnum.DAMAGE] = 20;
			
			runesWeight[EffectIdEnum.CRITICAL] = 30;
			runesWeight[EffectIdEnum.INVOCATION] = 30;
			runesWeight[EffectIdEnum.RETURN_DAMAGE] = 30;
			
			runesWeight[EffectIdEnum.PO] = 51;
			runesWeight[EffectIdEnum.MP] = 90;
			runesWeight[EffectIdEnum.AP] = 100;
			
			sysApi.addHook(ExchangeStartOkCraft, onExchangeStartOkCraft);
			sysApi.addHook(ExchangeStartOkMultiCraft, onExchangeStartOkMultiCraft);
			sysApi.addHook(ExchangeLeave, onExchangeLeave);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//:://////////////////////////////////////////////////////////
		
		/**
		 * Callback called when a craft start.
		 * 
		 * @param	recipes	The recipes list.
		 * @param	skillId	The skill identifier.
		 * @param	nbCases	The maximum number of case that may be used.
		 */
		private function onExchangeStartOkCraft(recipes:Object, skillId:uint, nbCases:uint):void
		{
			skill = jobsApi.getSkillFromId(skillId as uint) as Skill;
			if (!skill || !skill.isForgemagus)
			{
				return;
			}
			
			inCooperatingMode = false;
			uiApi.loadUi(uiName, uiInstanceName, {skillId:skillId, recipes:recipes, nbCase:nbCases});
		}
		
		/**
		 * Callback called when a cooperative craft start.
		 * 
		 * @param	skillId	The skill identifier.
		 * @param	recipes	The recipes list.
		 * @param	nbCase	The maximum number of case that amy by used.
		 * @param	crafterInfos	The crafter informations.
		 * @param	curtomerInfos	The customer informations.
		 */
		private function onExchangeStartOkMultiCraft(skillId:int, recipes:Object, nbCase:uint, crafterInfos:Object, customerInfos:Object):void
		{
			skill = jobsApi.getSkillFromId(skillId as uint) as Skill;
			if (!skill || !skill.isForgemagus)
			{
				return;
			}
			
			inCooperatingMode = true;
			uiApi.loadUi(uiName, uiInstanceName, {skillId:skillId, recipes:recipes, nbCase:nbCase, crafterInfos:crafterInfos, customerInfos:customerInfos});
		}
		
		/**
		 * Callback called when a we leave an exchange.
		 * 
		 * @param	success	Is the exchange successful.
		 */
		private function onExchangeLeave(success:Boolean):void
		{
			if (uiApi.getUi(uiInstanceName))
			{
				uiApi.unloadUi(uiInstanceName);
			}
		}
	}
}