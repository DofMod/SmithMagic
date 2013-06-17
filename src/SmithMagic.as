package
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2hooks.ExchangeLeave;
	import d2hooks.ExchangeStartOkCraft;
	import d2hooks.ExchangeStartOkMultiCraft;
	import enum.effectIdEnum;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import ui.SmithMagicUi;
	
	/**
	 * ...
	 * @author ExiTeD, Relena
	 */
	
	public class SmithMagic extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		private var includes:Array = [SmithMagicUi];
		
		private static const uiName:String = "smithmagic";
		private static const uiInstanceName:String = "exited_smithmagic";
		
		// Déclaration des API dont on veut se servir dans cette classe.
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		
		// Déclaration des variables
		public static var well:Number = 0;
		public static var runesWeight:Dictionary = new Dictionary();
		public static var inCooperatingMode:Boolean;
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
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
			
			// Durant la session de jeu, à chaque fois que l'un d'eux sera envoyé par dofus,
			sysApi.addHook(ExchangeStartOkCraft, onExchangeStartOkCraft);
			sysApi.addHook(ExchangeStartOkMultiCraft, onExchangeStartOkMultiCraft);
			sysApi.addHook(ExchangeLeave, onExchangeLeave);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//:://////////////////////////////////////////////////////////
		
		private function onExchangeStartOkCraft(recettes:Object, skillId:uint, nbCases:uint):void
		{
			inCooperatingMode = false;
			uiApi.loadUi(uiName, uiInstanceName, skillId);
		}
		
		private function onExchangeStartOkMultiCraft(skillId:int, recettes:Object, arg2:int, arg3:Object, arg4:Object):void
		{
			inCooperatingMode = true;
			uiApi.loadUi(uiName, uiInstanceName, skillId);
		}
		
		private function onExchangeLeave(param1:Boolean):void
		{
			if (uiApi.getUi(uiInstanceName))
			{
				uiApi.unloadUi(uiInstanceName);
			}
		}
	}
}