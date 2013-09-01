package managers
{
	import d2api.FileApi;
	import d2api.SystemApi;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Relena
	 */
	public class LangManager
	{
		private static const ARG_KEY:String = "#";
		
		private var _sysApi:SystemApi;
		private var _fileApi:FileApi;
		
		private var _dico:Dictionary;
		private var _init:Boolean;
		
		public function LangManager(sysApi:SystemApi, fileApi:FileApi, lang:String)
		{
			_sysApi = sysApi;
			_fileApi = fileApi;
			
			_dico = new Dictionary();
			_init = false;
			
			try
			{
				_fileApi.loadXmlFile("lang/" + lang + ".xml", loadSuccess, loadError);
			}
			catch (err:Error)
			{
				_sysApi.log(16, err.getStackTrace());
			}
		}
		
		private function loadSuccess(root:XML):void
		{
			for each (var child:XML in root.elements())
			{
				_dico[child.localName()] = child.toString();
			}
			
			_init = true;
		}
		
		private function loadError(... args):void
		{
			_sysApi.log(8, args.length);
			_sysApi.log(8, args);
			
			_init = true;
		}
		
		public function getText(key:String, ...args):String
		{
			if (!_init)
			{
				return "[NOT_INIT]";
			}
			
			var text:String = _dico[key];
			if (!text)
			{
				return "[UNKOWN_KEY_" + key + "]";
			}
			
			var splitedText:Array = text.split(ARG_KEY);
			var resultText:String = splitedText.shift();
			for (var index:int = 0; index < splitedText.length; index++)
			{
				for (var pos:int = 0; pos < splitedText[index].length; pos++)
				{
					var char:String = (splitedText[index] as String).charAt(pos);
					if (char != "0" && int(char) == 0)
					{
						break;
					}
				}
				
				if (pos == 0)
				{
					return "[ERROR_KEY_" + key + "]";
				}
				
				var indexArg:int = int(splitedText[index].substring(0, pos));
				if (indexArg > args.length)
				{
					return "[ERROR_KEY_" + key + "]";
				}
				
				resultText += args[indexArg] + splitedText[index].substring(pos);
			}
			
			return resultText;
		}
		
		public function isInit():Boolean
		{
			return _init;
		}
	}
}