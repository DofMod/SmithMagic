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
		public static var poidsUnitaireEffect:Dictionary = new Dictionary();
		public static var _coop:Boolean;
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			poidsUnitaireEffect[118] = 1; // Force
			poidsUnitaireEffect[126] = 1; // Intell
			poidsUnitaireEffect[123] = 1; // Chance
			poidsUnitaireEffect[119] = 1; // Agilité
			poidsUnitaireEffect[124] = 3; // Sagesse
			poidsUnitaireEffect[125] = 0.25; // Vitalité
			poidsUnitaireEffect[174] = 0.1; // Initiative
			poidsUnitaireEffect[242] = 2; // Res +Air
			poidsUnitaireEffect[241] = 2; // Res +Eau
			poidsUnitaireEffect[243] = 2; // Res +Feu
			poidsUnitaireEffect[244] = 2; // Res +Neutre
			poidsUnitaireEffect[240] = 2; // Res +Terre
			poidsUnitaireEffect[212] = 6; // Res %Air
			poidsUnitaireEffect[211] = 6; // Res %Eau
			poidsUnitaireEffect[213] = 6; // Res %Feu
			poidsUnitaireEffect[214] = 6; // Res %Neutre
			poidsUnitaireEffect[210] = 6; // Res %Terre
			poidsUnitaireEffect[416] = 2; // Res poussé
			poidsUnitaireEffect[420] = 2; // Res critique
			poidsUnitaireEffect[160] = 7; // Esquive PA
			poidsUnitaireEffect[161] = 7; // Esquive PM
			poidsUnitaireEffect[176] = 3; // Prospection
			poidsUnitaireEffect[138] = 2; // % Dom
			poidsUnitaireEffect[226] = 2; // % Dom Pièges
			poidsUnitaireEffect[225] = 15; // + Dom Pièges
			poidsUnitaireEffect[753] = 4; // Tacle
			poidsUnitaireEffect[752] = 4; // Fuite
			poidsUnitaireEffect[410] = 7; // Retrait PA
			poidsUnitaireEffect[412] = 7; // Retrait PM
			poidsUnitaireEffect[178] = 20; // Soins
			poidsUnitaireEffect[115] = 30; // CC
			poidsUnitaireEffect[182] = 30; // Créa
			poidsUnitaireEffect[220] = 30; // Renvoie dom
			poidsUnitaireEffect[117] = 51; // PO
			poidsUnitaireEffect[111] = 100; // PA
			poidsUnitaireEffect[128] = 90; // PM
			poidsUnitaireEffect[112] = 20; // + Dom
			poidsUnitaireEffect[430] = 5; // + Dom Neutre
			poidsUnitaireEffect[424] = 5; // + Dom Feu
			poidsUnitaireEffect[428] = 5; // + Dom Air
			poidsUnitaireEffect[422] = 5; // + Dom Terre
			poidsUnitaireEffect[426] = 5; // + Dom Eau
			poidsUnitaireEffect[414] = 5; // + Dom Poussée
			poidsUnitaireEffect[158] = 0.25; // PODS
			poidsUnitaireEffect[795] = 5; // Arme de chasse
			poidsUnitaireEffect[110] = 0.25; // ANCIEN EFFET +VIE
			
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