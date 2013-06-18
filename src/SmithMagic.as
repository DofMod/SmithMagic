package
{
	import d2api.JobsApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.Skill;
	import d2hooks.ExchangeLeave;
	import d2hooks.ExchangeStartOkCraft;
	import d2hooks.ExchangeStartOkMultiCraft;
	import enum.effectIdEnum;
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
			runesWeight[effectIdEnum.INITIATIVE] = 0.1;
			
			runesWeight[effectIdEnum.LIFE] = 0.25;
			runesWeight[effectIdEnum.VITALITY] = 0.25;
			runesWeight[effectIdEnum.PODS] = 0.25;

			runesWeight[effectIdEnum.STRENGTH] = 1;
			runesWeight[effectIdEnum.INTELLIGENCE] = 1;
			runesWeight[effectIdEnum.LUCK] = 1;
			runesWeight[effectIdEnum.AGILITY] = 1;
			
			runesWeight[effectIdEnum.DAMAGE_PERCENT] = 2;
			runesWeight[effectIdEnum.DAMAGE_PERCENT_TRAP] = 2;
			runesWeight[effectIdEnum.RESISTANCE_AIR] = 2;
			runesWeight[effectIdEnum.RESISTANCE_WATER] = 2;
			runesWeight[effectIdEnum.RESISTANCE_FIRE] = 2;
			runesWeight[effectIdEnum.RESISTANCE_NEUTRAL] = 2;
			runesWeight[effectIdEnum.RESISTANCE_EARTH] = 2;
			runesWeight[effectIdEnum.RESISTANCE_PUSH] = 2;
			runesWeight[effectIdEnum.RESISTANCE_CRITICAL] = 2;
			
			runesWeight[effectIdEnum.WISDOM] = 3;
			runesWeight[effectIdEnum.PROSPECTION] = 3;
			
			runesWeight[effectIdEnum.TACKLE] = 4;
			runesWeight[effectIdEnum.ESCAPE] = 4;
			
			runesWeight[effectIdEnum.DAMAGE_NEUTRAL] = 5;
			runesWeight[effectIdEnum.DAMAGE_FIRE] = 5;
			runesWeight[effectIdEnum.DAMAGE_AIR] = 5;
			runesWeight[effectIdEnum.DAMAGE_EARTH] = 5;
			runesWeight[effectIdEnum.DAMAGE_WATER] = 5;
			runesWeight[effectIdEnum.DAMAGE_PUSH] = 5;
			runesWeight[effectIdEnum.HUNTER] = 5;

			runesWeight[effectIdEnum.RESISTANCE_PERCENT_AIR] = 6;
			runesWeight[effectIdEnum.RESISTANCE_PERCENT_WATER] = 6;
			runesWeight[effectIdEnum.RESISTANCE_PERCENT_FIRE] = 6;
			runesWeight[effectIdEnum.RESISTANCE_PERCENT_NEUTRAL] = 6;
			runesWeight[effectIdEnum.RESISTANCE_PERCENT_EARTH] = 6;
			
			runesWeight[effectIdEnum.DODGE_AP] = 7;
			runesWeight[effectIdEnum.DODGE_MP] = 7;
			
			runesWeight[effectIdEnum.WITHDRAW_AP] = 7;
			runesWeight[effectIdEnum.WITHDRAW_MP] = 7;
			
			runesWeight[effectIdEnum.DAMAGE_TRAP] = 15;
			
			runesWeight[effectIdEnum.CARE] = 20;
			runesWeight[effectIdEnum.DAMAGE] = 20;
			
			runesWeight[effectIdEnum.CRITICAL] = 30;
			runesWeight[effectIdEnum.INVOCATION] = 30;
			runesWeight[effectIdEnum.RETURN_DAMAGE] = 30;
			
			runesWeight[effectIdEnum.PO] = 51;
			runesWeight[effectIdEnum.MP] = 90;
			runesWeight[effectIdEnum.AP] = 100;
			
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