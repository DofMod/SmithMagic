package
{
	import d2api.DataApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.EffectInstanceDice;
	import d2data.Item;
	import d2hooks.ExchangeLeave;
	import d2hooks.ExchangeStartOkCraft;
	import d2hooks.ExchangeStartOkMultiCraft;
	import d2hooks.StorageModChanged;
	import d2hooks.UiLoaded;
	import enum.effectIdEnum;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ExiTeD, Relena
	 */
	
	public class SmithMagic extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		import ui.SmithMagicUi;
		protected var smithMagicUi:SmithMagicUi;
		
		private static const uiName:String = "smithmagic";
		private static const uiInstanceName:String = "exited_smithmagic";
		
		// Déclaration des API dont on veut se servir dans cette classe.
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var dataApi:DataApi;
		
		// Déclaration des variables
		public static var puits:Number = 0;
		public static var allRune:Dictionary = new Dictionary();
		public static var runeWeight:Dictionary = new Dictionary();
		public static var _coop:Boolean;
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			runeWeight[effectIdEnum.INITIATIVE] = 0.1;
			
			runeWeight[effectIdEnum.LIFE] = 0.25;
			runeWeight[effectIdEnum.VITALITY] = 0.25;
			runeWeight[effectIdEnum.PODS] = 0.25;

			runeWeight[effectIdEnum.STRENGTH] = 1;
			runeWeight[effectIdEnum.INTELLIGENCE] = 1;
			runeWeight[effectIdEnum.LUCK] = 1;
			runeWeight[effectIdEnum.AGILITY] = 1;
			
			runeWeight[effectIdEnum.DAMAGE_PERCENT] = 2;
			runeWeight[effectIdEnum.DAMAGE_PERCENT_TRAP] = 2;
			runeWeight[effectIdEnum.RESISTANCE_AIR] = 2;
			runeWeight[effectIdEnum.RESISTANCE_WATER] = 2;
			runeWeight[effectIdEnum.RESISTANCE_FIRE] = 2;
			runeWeight[effectIdEnum.RESISTANCE_NEUTRAL] = 2;
			runeWeight[effectIdEnum.RESISTANCE_EARTH] = 2;
			runeWeight[effectIdEnum.RESISTANCE_PUSH] = 2;
			runeWeight[effectIdEnum.RESISTANCE_CRITICAL] = 2;
			
			runeWeight[effectIdEnum.WISDOM] = 3;
			runeWeight[effectIdEnum.PROSPECTION] = 3;
			
			runeWeight[effectIdEnum.TACKLE] = 4;
			runeWeight[effectIdEnum.ESCAPE] = 4;
			
			runeWeight[effectIdEnum.DAMAGE_NEUTRAL] = 5;
			runeWeight[effectIdEnum.DAMAGE_FIRE] = 5;
			runeWeight[effectIdEnum.DAMAGE_AIR] = 5;
			runeWeight[effectIdEnum.DAMAGE_EARTH] = 5;
			runeWeight[effectIdEnum.DAMAGE_WATER] = 5;
			runeWeight[effectIdEnum.DAMAGE_PUSH] = 5;
			runeWeight[effectIdEnum.HUNTER] = 5;

			runeWeight[effectIdEnum.RESISTANCE_PERCENT_AIR] = 6;
			runeWeight[effectIdEnum.RESISTANCE_PERCENT_WATER] = 6;
			runeWeight[effectIdEnum.RESISTANCE_PERCENT_FIRE] = 6;
			runeWeight[effectIdEnum.RESISTANCE_PERCENT_NEUTRAL] = 6;
			runeWeight[effectIdEnum.RESISTANCE_PERCENT_EARTH] = 6;
			
			runeWeight[effectIdEnum.DODGE_AP] = 7;
			runeWeight[effectIdEnum.DODGE_MP] = 7;
			
			runeWeight[effectIdEnum.WITHDRAW_AP] = 7;
			runeWeight[effectIdEnum.WITHDRAW_MP] = 7;
			
			runeWeight[effectIdEnum.DAMAGE_TRAP] = 15;
			
			runeWeight[effectIdEnum.CARE] = 20;
			runeWeight[effectIdEnum.DAMAGE] = 20;
			
			runeWeight[effectIdEnum.CRITICAL] = 30;
			runeWeight[effectIdEnum.INVOCATION] = 30;
			runeWeight[effectIdEnum.RETURN_DAMAGE] = 30;
			
			runeWeight[effectIdEnum.PO] = 51;
			runeWeight[effectIdEnum.MP] = 90;
			runeWeight[effectIdEnum.AP] = 100;
			
			// Durant la session de jeu, à chaque fois que l'un d'eux sera envoyé par dofus,
			//sysApi.addHook(StorageModChanged, onStorageModChanged);
			sysApi.addHook(ExchangeStartOkCraft, onExchangeStartOkCraft);
			sysApi.addHook(ExchangeStartOkMultiCraft, onExchangeStartOkMultiCraft);
			sysApi.addHook(ExchangeLeave, onExchangeLeave);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//:://////////////////////////////////////////////////////////
		
		private function onStorageModChanged(mode:int):void
		{
			if (mode == 0)
			{
				uiApi.unloadUi(uiInstanceName);
			}
		}
		
		private function onExchangeStartOkCraft(recettes:Object, skillId:uint, nbCases:uint):void
		{
			_coop = false;
			uiApi.loadUi(uiName, uiInstanceName, skillId);
		}
		
		private function onExchangeStartOkMultiCraft(skillId:int, recettes:Object, arg2:int, arg3:Object, arg4:Object):void
		{
			_coop = true;
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