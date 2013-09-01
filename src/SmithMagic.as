package
{
	import d2api.FileApi;
	import d2api.JobsApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.Skill;
	import d2hooks.ExchangeLeave;
	import d2hooks.ExchangeStartOkCraft;
	import d2hooks.ExchangeStartOkMultiCraft;
	import flash.display.Sprite;
	import managers.LangManager;
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
		public var fileApi:FileApi;
		
		// Some globals
		private var _langManager:LangManager;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			_langManager = new LangManager(sysApi, fileApi, sysApi.getCurrentLanguage());
			
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
			var skill:Skill = jobsApi.getSkillFromId(skillId) as Skill;
			if (!skill || !skill.isForgemagus)
			{
				return;
			}
			
			var params:Object = {};
			params.skill = skill;
			params.inCooperatingMode = false;
			params.langManager = _langManager;
			
			uiApi.loadUi(uiName, uiInstanceName, params);
		}
		
		/**
		 * Callback called when a cooperative craft start.
		 * 
		 * @param	skillId	The skill identifier.
		 * @param	recipes	The recipes list.
		 * @param	nbCases	The maximum number of case that amy by used.
		 * @param	crafterInfos	The crafter informations.
		 * @param	curtomerInfos	The customer informations.
		 */
		private function onExchangeStartOkMultiCraft(skillId:int, recipes:Object, nbCases:uint, crafterInfos:Object, customerInfos:Object):void
		{
			var skill:Skill = jobsApi.getSkillFromId(skillId) as Skill;
			if (!skill || !skill.isForgemagus)
			{
				return;
			}
			
			var params:Object = {};
			params.skill = skill;
			params.crafterInfos = crafterInfos;
			params.customerInfos = customerInfos;
			params.inCooperatingMode = true;
			params.langManager = _langManager;
			
			uiApi.loadUi(uiName, uiInstanceName, params);
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