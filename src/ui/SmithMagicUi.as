package ui 
{
	import d2actions.ExchangeObjectMove;
	import d2actions.ExchangeObjectUseInWorkshop;
	import d2api.DataApi;
	import d2api.JobsApi;
	import d2api.PlayedCharacterApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Grid;
	import d2components.Label;
	import d2components.Slot;
	import d2data.EffectInstanceDice;
	import d2data.EffectInstanceInteger;
	import d2data.Item;
	import d2data.ItemWrapper;
	import d2enums.ChatActivableChannelsEnum;
	import d2enums.StatesEnum;
	import d2hooks.BagListUpdate;
	import d2hooks.DropEnd;
	import d2hooks.DropStart;
	import d2hooks.ExchangeCraftResult;
	import d2hooks.ExchangeObjectAdded;
	import d2hooks.ExchangeObjectModified;
	import d2hooks.ExchangeObjectRemoved;
	import d2hooks.MouseCtrlDoubleClick;
	import d2hooks.ObjectModified;
	import d2hooks.TextInformation;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ExiTeD, Relena
	 */
	
	public class SmithMagicUi 
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Variables Constantes
		public static const SIGNATURE_RUNE_ID:int = 7508;
		public static const SMITHMAGIC_RUNE_ID:int = 78;
		public static const SMITHMAGIC_POTION_ID:int = 26;
		public static const SKILL_TYPE_AMULET:int = 169;
		public static const SKILL_TYPE_RING:int = 168;
		public static const SKILL_TYPE_BELT:int = 164;
		public static const SKILL_TYPE_BOOTS:int = 163;
		public static const SKILL_TYPE_HAT:int = 166;
		public static const SKILL_TYPE_CLOAK:int = 165;
		public static const SKILL_TYPE_BAG:int = 167;
		
		// Variables Les Globales
		public var _skill:Object;
		public var _isCrafter:Boolean = false;
		public var _inCooperatingMode:Boolean;
		public var _runeWeight:Number = 0;
		public var _wellModification:Boolean = false;
		public var _waitingObject:ItemWrapper;
		public var _dataOfEffectButtons:Dictionary = new Dictionary(false);
		public var _dataOfAvailableRuneSlots:Dictionary = new Dictionary(false);
		public var _bagItems:Array = null;
		
		public var _bubbleGreyUri:Object;
		public var _bubbleGreenUri:Object;
		public var _bubbleOrangeUri:Object;
		public var _bubbleRedUri:Object;
		public var _bubbleBlueUri:Object;
		
		// Utilisation du modCommon pour l'inputBox du puits
		[Module(name="Ankama_Common")]
		public var modCommon:Object;
		
		// Déclaration des API dont on veut se servir dans cette classe
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var dataApi:DataApi;
		public var jobsApi:JobsApi;
		public var storageApi:StorageApi;
		public var playerApi:PlayedCharacterApi;
		
		// Les boutons de fermeture et reouverture de l'interface
		public var btn_close:ButtonContainer;
		public var btn_open:ButtonContainer;
		public var btn_open_cooperative:ButtonContainer;
		public var btn_wellInput:ButtonContainer;
		
		// Les Labels de l'interface
		public var lbl_level:Label;
		public var lbl_name:Label;
		public var lbl_rune_effect:Label;
		public var lbl_rune_name:Label;
		public var lbl_rune_weight:Label;
		public var lbl_result:Label;
		public var lbl_well:Label;
		
		// Les Container de l'interface
		public var ctr_concealable:GraphicContainer;
		
		// Les 3 Slots de l'interface
		public var slot_item:Slot;
		public var slot_rune:Slot;
		public var slot_signature:Slot;
		
		// La Grid de l'interface
		public var effectsGrid:Grid;
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
		//::///////////////////////////////////////////////////////////
		
		public function main(parameterList:Object):void
		{
			_bubbleGreyUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_0"));
			_bubbleGreenUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_3"));
			_bubbleOrangeUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_2"));		
			_bubbleRedUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_6"));
			_bubbleBlueUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_7"));
			
			// On récupère l'id du métier de forgemagie argument du hook de la classe principale
			_skill = jobsApi.getSkillFromId(parameterList.skillId as uint);
			_inCooperatingMode = SmithMagic.inCooperatingMode;
			_isCrafter = (parameterList.crafterInfos === undefined || parameterList.crafterInfos.id == playerApi.getPlayedCharacterInfo().id);
			
			// On enregistre les 3 slots de l'atelier
			addHooksToSlot(slot_item);
			addHooksToSlot(slot_rune);
			addHooksToSlot(slot_signature);
			
			// On vide la Grid
			updateItem(null);
			
			// On fixe la valeur du puits
			setWell(SmithMagic.well);
			
			slot_item.dropValidator = dropValidator;
			slot_rune.dropValidator = dropValidator;
			slot_signature.dropValidator = dropValidator;
			slot_item.processDrop = processDrop;
			slot_rune.processDrop = processDrop;
			slot_signature.processDrop = processDrop;
			
			sysApi.addHook(ObjectModified, onObjectModified);
			sysApi.addHook(ExchangeObjectAdded, onExchangeObjectAdded);
			sysApi.addHook(ExchangeObjectRemoved, onExchangeObjectRemoved);
			sysApi.addHook(ExchangeObjectModified, onExchangeObjectModified);
			sysApi.addHook(MouseCtrlDoubleClick, onMouseCtrlDoubleClick);
			sysApi.addHook(DropStart, onDropStart);
			sysApi.addHook(DropEnd, onDropEnd);
			sysApi.addHook(ExchangeCraftResult, onExchangeCraftResult);
			sysApi.addHook(TextInformation, onTextInformation);
			sysApi.addHook(BagListUpdate, onBagListUpdate);
			
			uiApi.addComponentHook(btn_close, "onRelease");
			uiApi.addComponentHook(btn_open, "onRelease");
			uiApi.addComponentHook(btn_open_cooperative, "onRelease");
			uiApi.addComponentHook(btn_wellInput, "onRelease");
			
			displayOpenButton(_inCooperatingMode);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//::///////////////////////////////////////////////////////////	
		
		public function onTextInformation(text:String, channelId:int, param3:Number = 0, param4:Boolean = false):void
		{
			if (channelId != ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO)
			{
				return;
			}
			
			// Is the well value modified ?
			_wellModification = (text.indexOf("reliquat") != -1);
			
			lbl_result.text = "Résultat : ";
		}
		
		public function onExchangeCraftResult(resultId:int, item:ItemWrapper):void
		{
			
			var oldItem:ItemWrapper = slot_item.data;
			var effects:Dictionary = new Dictionary();
			
			// On parcours les jets de l'item avant le passage de la rune
			for each (var oldEffect:Object in oldItem.effects)
			{
				if (oldEffect is EffectInstanceInteger)
				{
					effects[oldEffect.effectId] = ({oldValue : (getSigneBonus(oldEffect) * oldEffect.value), newValue : false, id : getIdEffectMalusToBonus(oldEffect.effectId) });
				}
			}
			
			// On parcours les jets de l'item après le passage de la rune
			for each (var newEffect:Object in item.effects)
			{
				if (newEffect is EffectInstanceInteger)
				{
					if (effects[newEffect.effectId])
					{
						effects[newEffect.effectId].newValue = getSigneBonus(newEffect) * newEffect.value;
					}
					else
					{
						effects[newEffect.effectId] = ({oldValue : false, newValue : (getSigneBonus(newEffect) * newEffect.value), id : getIdEffectMalusToBonus(newEffect.effectId)});
					}
				}
			}
			
			var weightGains:Number = 0;
			var weightLosses:Number = 0;
			
			for each (var effect:Object in effects)
			{
				if (effect.oldValue != effect.newValue)
				{
					//sysApi.log(2, "Effect : " + effect.name);
					//sysApi.log(2, "OldValue : " + effect.oldValue + " | newValue : " + effect.newValue);
				}
				
				if (effect.oldValue == false && effect.newValue != false)
				{
					weightGains += (effect.newValue * SmithMagic.runesWeight[effect.id]);
				}
				else if (effect.newValue == false && effect.oldValue != false)
				{
					weightLosses += (effect.oldValue * SmithMagic.runesWeight[effect.id]);
				}
				else if (effect.oldValue < effect.newValue)
				{
					weightGains += ((effect.newValue - effect.oldValue) * SmithMagic.runesWeight[effect.id]);
				}
				else if (effect.oldValue > effect.newValue)
				{
					weightLosses += ((effect.oldValue - effect.newValue) * SmithMagic.runesWeight[effect.id]);
				}
			}
			
			sysApi.log(2, "Rune weight : " +  _runeWeight);
			sysApi.log(2, "Weight losses : " +  weightLosses);
			sysApi.log(2, "Weight gains : " +  weightGains);
			
			if (_wellModification == true)
			{
				setWell(SmithMagic.well + weightLosses - _runeWeight);
			}
		}
		
		/**
		 * An object in the exchange has been modified.
		 * 
		 * @param	item
		 */
		public function onExchangeObjectModified(item:ItemWrapper):void
		{
			// The number of runes in the exchange has been modified
			if (slot_rune.data && slot_rune.data.objectUID == item.objectUID)
			{
				slot_rune.data = item;
				
				updateRune(slot_rune.data);
				updateItem(slot_item.data); // Update the list of runes
			}
			else if (slot_item.data && slot_item.data.objectUID == item.objectUID)
			{
				slot_item.data = item;
				
				updateItem(slot_item.data);
			}
			else
			{
				sysApi.log(2, "Unknow modified item ? (" + item + ")");
			}
		}
		
		/**
		 * An object has been modified.
		 * 
		 * @param	item
		 */
		public function onObjectModified(item:ItemWrapper):void
		{
			// Forgeable item modified
			if (slot_item.data && slot_item.data.objectUID == item.objectUID)
			{
				slot_item.data = item;
				
				updateItem(slot_item.data);
			}
		}			
		
		/**
		 * An object has been added in the exchange.
		 * 
		 * @param	item
		 */
		public function onExchangeObjectAdded(item:ItemWrapper):void
		{
			if (item.typeId == SMITHMAGIC_RUNE_ID || item.typeId == SMITHMAGIC_POTION_ID)
			{
				slot_rune.data = item;
				
				updateRune(slot_rune.data);
				updateItem(slot_item.data); // Update the list of runes
			}
			else if (item.id == SIGNATURE_RUNE_ID)
			{
				slot_signature.data = item;
			}
			else if (item.isEquipment)
			{
				slot_item.data = item;
				
				updateItem(slot_item.data);
			}
			else
			{
				sysApi.log(2, "Unknow exchange added item type : " + item);
			}
		}
		
		/**
		 * An object has been removed in the exchange.
		 * 
		 * @param	itemUid
		 */
		public function onExchangeObjectRemoved(itemUid:uint):void
		{
			if (slot_rune.data && slot_rune.data.objectUID == itemUid)
			{
				slot_rune.data = null;
				
				updateRune(null);
				updateItem(slot_item.data); // Update the list of runes
			}
			else if (slot_signature.data && slot_signature.data.objectUID == itemUid)
			{
				slot_signature.data = null;
			}
			else if (slot_item.data && slot_item.data.objectUID == itemUid)
			{
				slot_item.data = null;
				
				updateItem(null);
			}
			else
			{
				sysApi.log(2, "Unknow exchange item removed: " + itemUid);
			}
		}
		
		/**
		 * Track the bag item list.
		 * 
		 * @param	items	The list of items in the bag.
		 * @param	modifiedByOwner	Is this update due to the owner ? (TODO : cofirmation ?)
		 */
		public function onBagListUpdate(items:Object, modifiedByOwner:Boolean):void
		{
			// Here we only want le item list send by the owned, not the actual bag item list.
			if (modifiedByOwner)
			{
				_bagItems = new Array();
				
				for each (var item:ItemWrapper in items)
				{
					_bagItems.push(item);
				}
			}
		}
		
		/**
		 * On double click with Ctrl key pressed.
		 * 
		 * @param	target
		 */
		public function onMouseCtrlDoubleClick(target:Object):void
		{
			switch (target)
			{
				case slot_rune:
					if (slot_rune.data != null)
					{
						unfillSlot(slot_rune);
					}
					
					break;
				default:
					if (_dataOfAvailableRuneSlots[target] != null)
					{
						fillSlot(slot_rune, _dataOfAvailableRuneSlots[target], _dataOfAvailableRuneSlots[target].quantity);
					}
			}
		}		
		
		/**
		 * On double click.
		 * 
		 * @param	target
		 */
		public function onDoubleClick(target:Object):void
		{
			switch (target)
			{
				case slot_item:
				case slot_rune:
				case slot_signature:
					if (target.data)
					{
						unfillSlot(target as Slot, 1);
					}
					
					break;
				default:
					if (_dataOfAvailableRuneSlots[target] != null)
					{
						fillSlot(slot_rune, _dataOfAvailableRuneSlots[target], 1);
					}
			}
		}
		
		/**
		 * On mouse rollout.
		 * 
		 * @param	target
		 */
		public function onRollOut(target:Object):void
		{
			uiApi.hideTooltip();
		}
		
		/**
		 * On mouse rollover.
		 * 
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			switch (target)
			{
				case slot_rune:
				case slot_signature:
				case slot_item:
					if (target.data)
					{
						uiApi.showTooltip(target.data.name, target);
					}
					
					break;
				default:
					var data:Object;
					var toolTip:Object;
					var effectWeight:Number;
					
					if (target.name.search("btn_jet") != -1 && _dataOfEffectButtons[target] !== null)
					{
						data = _dataOfEffectButtons[target].effect as EffectInstanceInteger;
						effectWeight = data.value * SmithMagic.runesWeight[getIdEffectMalusToBonus(data.effectId)];
						
						toolTip = uiApi.textTooltipInfo("Poids de l'effet : " + effectWeight);
						uiApi.showTooltip(toolTip, target, false, "standard", 7, 1, 3);
					}
					else if (target.name.search("slot_") != -1 && _dataOfAvailableRuneSlots[target] !== null)
					{
						data = _dataOfAvailableRuneSlots[target] as ItemWrapper;
						effectWeight = SmithMagic.runesWeight[data.effects[0].effectId] * data.effects[0].parameter0;
						
						toolTip = uiApi.textTooltipInfo(data.name + ", +" + data.effects[0].description + "\nPoids de la rune : " + effectWeight + "\nProbabilité : " + 50 + "%");
						uiApi.showTooltip(toolTip, target, false, "standard", 7, 1, 3);
					}
					else if (target.name.search("tx_bulle") != -1)
					{
						if (target.uri.toString() == _bubbleGreyUri.toString())
						{
							toolTip = uiApi.textTooltipInfo("Jet inférieur au jet min");
						}
						else if (target.uri.toString() == _bubbleGreenUri.toString())
						{
							toolTip = uiApi.textTooltipInfo("Jet moyen");
						}
						else if (target.uri.toString() == _bubbleOrangeUri.toString())
						{
							toolTip = uiApi.textTooltipInfo("Bon jet (>80% du jet max)");
						}
						else if (target.uri.toString() == _bubbleRedUri.toString())
						{
							toolTip = uiApi.textTooltipInfo("Jet overmax");
						}
						else if (target.uri.toString() == _bubbleBlueUri.toString())
						{
							toolTip = uiApi.textTooltipInfo("Jet éxotique");
						}
						else
						{
							break;
						}
						
						uiApi.showTooltip(toolTip, target, false, "standard", 7, 1, 3);
					}
			}
		}
		
		/**
		 * On mouse release.
		 * 
		 * @param	target
		 */
		public function onRelease(target:Object):void
		{
			switch (target)
			{	
				case btn_close:
					ctr_concealable.visible = false;
					
					break;
				
				case btn_open:
				case btn_open_cooperative:
					ctr_concealable.visible = true;
					
					break;
				
				case btn_wellInput:
					modCommon.openInputPopup("Réglage manuel du puits", "Entrez la valeur souhaitée", onValidWellValue, null, SmithMagic.well, "0-9.", 5);
					
					break;
			}
		}
		
		/**
		 * On drag & drop start.
		 * 
		 * @param	target
		 */
		public function onDropStart(target:Object):void
		{
			for each (var slot:Slot in [slot_item, slot_rune, slot_signature])
			{
				if (isValidSlot(slot, target.data))
				{
					slot.selected = true;
				}
			}
		}
		
		/**
		 * On drag & drop end.
		 * 
		 * @param	target
		 */
		public function onDropEnd(target:Object):void
		{
			for each (var slot:Object in [slot_item, slot_rune, slot_signature])
			{
				slot.selected = false;
			}
		}
		
		/**
		 * Effects grid values manager.
		 * 
		 * @param	data
		 * @param	componentsRef
		 * @param	selected
		 */
		public function updateGrid(data:*, componentsRef:*, selected:Boolean):void
		{
			_dataOfEffectButtons[componentsRef.btn_jet] = data;
			_dataOfAvailableRuneSlots[componentsRef.slot_pa] = null;
			_dataOfAvailableRuneSlots[componentsRef.slot_ra] = null;
			_dataOfAvailableRuneSlots[componentsRef.slot_simple] = null;
			
			if (data == null)
			{
				componentsRef.ctr_jet.visible = false;
				
				return;
			}
			
			uiApi.addComponentHook(componentsRef.btn_jet, "onRollOver");
			uiApi.addComponentHook(componentsRef.btn_jet, "onRollOut");
			
			uiApi.addComponentHook(componentsRef.tx_bulle, "onRollOver");
			uiApi.addComponentHook(componentsRef.tx_bulle, "onRollOut");
			
			var effect:EffectInstanceInteger = data.effect as EffectInstanceInteger;
			var isNull:Boolean = data.isNull as Boolean;
			var signeBonus:int = 0;
			
			// On initialise l'état sur la bulle verte (entre le jet min et 80% du jet)
			componentsRef.tx_bulle.uri = _bubbleGreenUri;
			
			// On initialise les labels min et max et actuel
			componentsRef.lbl_jetMin.text = "";
			componentsRef.lbl_jetMax.text = "";
			componentsRef.lbl_jet.text = effect.description;
			
			// On affecte le style css en fonction du type de jet (malus, bonus ou pas de signe)
			if (effect.description.charAt(0) == "-")
			{
				componentsRef.lbl_jet.cssClass = "malus";
				signeBonus = -1;
			}
			else
			{
				componentsRef.lbl_jet.cssClass = "bonus";
				signeBonus = 1;
			}
			
			if (isNull)
			{
				componentsRef.lbl_jet.cssClass = "normal";
			}
			
			var isExotic:Boolean = true;
			
			// On parcours les effets possible de l'objet
			for each (var effectDice:EffectInstanceDice in slot_item.data.possibleEffects)
			{
				if (effectDice.effectId == effect.effectId)
				{
					isExotic = false;
					
					var jetMin:int;
					var jetMax:int;
					var jetActuel:int = signeBonus * effect.value;
					
					if (signeBonus == 1)
					{
						jetMin = signeBonus * effectDice.diceNum;
						jetMax = signeBonus * effectDice.diceSide;
						
						if (effectDice.diceSide == 0)
						{
							jetMax = jetMin;
						}
					}
					else
					{
						jetMin = signeBonus * effectDice.diceSide;
						jetMax = signeBonus * effectDice.diceNum;
						
						if (effectDice.diceSide == 0)
						{
							jetMin = jetMax;
						}
					}
					
					// On affecte le jet max et min aux labels de la grid
					componentsRef.lbl_jetMin.text = jetMin;
					componentsRef.lbl_jetMax.text = jetMax;
			
					// On change l'état de la bulle si le jet est overmax
					if (jetActuel > jetMax)
					{
						componentsRef.tx_bulle.uri = _bubbleRedUri;
					}
					// On change l'état de la bulle si le jet est sous le jet max
					else if (jetActuel < jetMin)
					{
						componentsRef.tx_bulle.uri = _bubbleGreyUri;
					}
					// On change l'état de la bulle entre 80 et 100% de la fourchette du jet
					else if ((jetActuel == jetMax) || (((jetActuel - jetMin) / (jetMax - jetMin))  >= 0.8))
					{
						componentsRef.tx_bulle.uri = _bubbleOrangeUri;
					}
					
					break;
				}
			}
			
			if (isExotic)
			{
				componentsRef.lbl_jet.cssClass = "exotic";
				componentsRef.tx_bulle.uri = _bubbleBlueUri;
			}
			
			// On enregistre les slots rune simple/pa/ra
			addHooksToSlot(componentsRef.slot_simple);
			addHooksToSlot(componentsRef.slot_pa);
			addHooksToSlot(componentsRef.slot_ra);
			
			// Par défaut les slots de runes sont invisibles
			componentsRef.slot_simple.visible = false;
			componentsRef.slot_pa.visible = false;
			componentsRef.slot_ra.visible = false;
			
			//var t0:int = getTimer();
			for each (var item:ItemWrapper in storageApi.getViewContent("storageResources"))
			{
				//sysApi.log(16, "item.name : " + item.name);
				if (item.typeId == SMITHMAGIC_RUNE_ID)
				{
					for each (var effet:EffectInstanceInteger in item.effects)
					{
						if (effet.effectId == getIdEffectMalusToBonus(effect.effectId))
						{
							//sysApi.log(16, "effect.description : " + effet.description);
							if (item.name.search("Rune Pa") != -1)
							{
								_dataOfAvailableRuneSlots[componentsRef.slot_pa] = item;
								componentsRef.slot_pa.data = item;
								componentsRef.slot_pa.visible = true;
							}
							else if (item.name.search("Rune Ra") != -1)
							{
								_dataOfAvailableRuneSlots[componentsRef.slot_ra] = item;
								componentsRef.slot_ra.data = item;
								componentsRef.slot_ra.visible = true;
							}
							else
							{
								_dataOfAvailableRuneSlots[componentsRef.slot_simple] = item;
								componentsRef.slot_simple.data = item;
								componentsRef.slot_simple.visible = true;										
							}
						}
					}
				}
			}
			//sysApi.log(16, "temps :" +  (getTimer() - t0) + "ms");
			
			// Gestion de la selection de la ligne
			componentsRef.btn_jet.selected	= selected;
			componentsRef.btn_jet.state = selected ? StatesEnum.STATE_SELECTED:StatesEnum.STATE_NORMAL;
			
			// On affiche la ligne du jet
			componentsRef.ctr_jet.visible = true;
		}
				
		//::///////////////////////////////////////////////////////////
		//::// Méthodes Privées
		//::///////////////////////////////////////////////////////////
		
		private function displayOpenButton(inCooperativeMode:Boolean):void
		{
			btn_open.visible = !inCooperativeMode;
			btn_open_cooperative.visible = inCooperativeMode;
		}
		
		private function getSigneBonus(effect:Object):int
		{
			// On affecte le style css en fonction du type de jet (malus, bonus ou pas de signe)
			if (effect.description.charAt(0) == "-")
			{
				return -1;
			}
			else
			{
				return 1;
			}
		}
		
		/**
		 * Update the fields relative to the selectioned rune.
		 * 
		 * @param	rune	The selectioned rune. Null to reset de default
		 * 					fields values.
		 */
		private function updateRune(rune:ItemWrapper):void
		{
			if (rune == null)
			{
				lbl_rune_name.text = "";
				lbl_rune_effect.text = "";
				lbl_rune_weight.text = "";
				
				return;
			}
			
			var effect:Object = rune.effects[0];
			
			lbl_rune_name.text = rune.name;
			lbl_rune_effect.text = "+" + effect.description;
			
			if (SmithMagic.runesWeight[effect.effectId])
			{
				_runeWeight = SmithMagic.runesWeight[effect.effectId] * effect.value;
				
				lbl_rune_weight.text = "Poids : " + _runeWeight;
			}
			else
			{
				_runeWeight = 0;
				
				lbl_rune_weight.text = "Poids : Inconnu";
			}
		}
		
		/**
		 * Update the fields relative to the selectioned forgeable item.
		 * 
		 * @param	item	The selectioned item. Null to reset the default
		 * 					fields values.
		 */
		private function updateItem(item:ItemWrapper):void
		{
			if (item == null)
			{
				lbl_level.text = "";
				lbl_name.text = "";
				
				effectsGrid.dataProvider = new Array();
				
				return;
			}
			
			lbl_level.text = String("Niv. " + item.level);
			lbl_name.text = item.name;
			
			var effect:Object;
			var forgeableEffectList:Array = new Array();
			var presentEffectList:Dictionary = new Dictionary();
			
			for each (effect in item.effects)
			{
				// Exclude damages effects (EffectInstanceMinMax) and Signature/Hunter mark/follower bonus (EffectInstanceString)
				if (effect is EffectInstanceInteger)
				{
					forgeableEffectList.push({effect : effect, isNull : false});
					presentEffectList[effect.effectId] = true;
				}
			}
			
			for each (effect in item.possibleEffects)
			{
				if (effect is EffectInstanceInteger && !(presentEffectList[effect.effectId]))
				{
					forgeableEffectList.push({effect : effect, isNull : true});
				}
			}
			
			effectsGrid.dataProvider = forgeableEffectList;
		}
		
		/**
		 * Callback called when the user valid the new well value.
		 * 
		 * @param	string	The new well value.
		 */
		private function onValidWellValue(string:String):void
		{
			setWell(Number(string));
		}
		
		/**
		 * Update the well value and relative fields.
		 * 
		 * @param	well	The new well value.
		 */
		private function setWell(well:Number):void
		{
			SmithMagic.well = well;
			
			lbl_well.text = "Puits : " + well;
		}
		
		/**
		 * Add basics hook listener to a slot.
		 * 
		 * @param	slot	A slot.
		 */
		private function addHooksToSlot(slot:Slot):void
		{
			uiApi.addComponentHook(slot, "onRollOver");
			uiApi.addComponentHook(slot, "onRollOut");
			uiApi.addComponentHook(slot, "onDoubleClick");
		}
		
		private function isValidSlot(slot:Slot, itemWp:ItemWrapper):Boolean
		{
			if (!_skill)
			{
				return false;
			}
			
			var item:Item = dataApi.getItem(itemWp.objectGID);
			
			switch (slot)
			{
				case slot_item:
					if (_skill.modifiableItemType != item.typeId)
					{
						return false;
					}
					
					return true;
				case slot_rune:
					if ((((!(_skill.isForgemagus)) || (!(item.typeId == SMITHMAGIC_RUNE_ID)))) && (!(item.typeId == SMITHMAGIC_POTION_ID)))
					{
						return false;
					}
					
					return true;
				case slot_signature:
					if (!(item.id == SIGNATURE_RUNE_ID))
					{
						return false;
					}
					
					return true;
			}
			
			return false;
		}
		
		private function dropValidator(target:Object, data:Object, source:Object):Boolean
		{
			if (data is ItemWrapper && target is Slot)
			{
				return isValidSlot(target as Slot, data as ItemWrapper);
			}
			
			return false;
		}
		
		private function processDrop(target:Object, data:Object, source:Object):void
		{
			if (!(data is ItemWrapper) || !(target is Slot))
			{
				return;
			}
			
			var item:ItemWrapper = data as ItemWrapper;
			var slot:Slot = target as Slot;
			
			switch (slot)
			{
				case slot_item:
				case slot_signature:
					fillSlot(slot, item, 1);
					
					break;
				case slot_rune:
					if (int(item.info1) > 1)
					{
						_waitingObject = item;
						modCommon.openQuantityPopup(1, item.quantity, item.quantity, onValidQtyDropToSlot);
					}
					else
					{
						fillSlot(slot_rune, item, 1);
					}
					
					break;
			}
		}
		
		/**
		 * Return the slot's item in the right inventory.
		 * 
		 * @param	slot	The slot to empty.
		 * @param	quantity	The quantity to return. If  -1, empty the slot.
		 */
		private function unfillSlot(slot:Slot, quantity:int = -1):void
		{
			if (quantity == -1)
			{
				quantity = slot.data.quantity;
			}
			
			if (isItemFromBag(slot.data))
			{
				sysApi.sendAction(new ExchangeObjectUseInWorkshop(slot.data.objectUID, -(quantity)));
			}
			else
			{
				sysApi.sendAction(new ExchangeObjectMove(slot.data.objectUID, -(quantity)));
			}
		}
		
		/**
		 * Find the the right slot associed with the item to exchange, then add
		 * this item to the exchange.
		 * 
		 * @param	item	The item to exchange.
		 * @param	quantity	The quantity to exchange. If -1, select the
		 * 				maxium quantity. (1 for the equipment and the signature
		 * 				rune, all for the others runes).
		 */
		private function fillDefaultSlot(item:ItemWrapper, quantity:int = -1):void
		{
			for each (var slot:Slot in [slot_item, slot_rune, slot_signature])
			{
				if (dropValidator(slot, item, null))
				{
					if (quantity == -1)
					{
						switch (slot)
						{
							case slot_item:
							case slot_signature:
								quantity = 1;
								
								break;
							case slot_rune:
								quantity = item.quantity;
								
								break;
						}
					}
					
					fillSlot(slot, item, quantity);
					
					return;
				}
			}
		}
		
		/**
		 * Tell the client to add the item to the exchange.
		 * 
		 * @param	slot	The destination slot of the item.
		 * @param	item	The item to exchange.
		 * @param	quantity	The quantity to exchange.
		 */
		private function fillSlot(slot:Slot, item:ItemWrapper, quantity:int):void
		{
			if ((slot.data != null) && ((slot == slot_item) || (slot == slot_signature) || ((slot == slot_rune) && (slot.data.objectGID != item.objectGID))))
			{
				unfillSlot(slot, -1);
			}
			
			sysApi.sendAction(new ExchangeObjectMove(item.objectUID, quantity));
		}
		
		/**
		 * Test if the item belong to the cooperative smithMagic bag.
		 * 
		 * @param	itemSought	The sought item
		 * 
		 * @return True if the item belong to the bag, else False.
		 */
		private function isItemFromBag(itemSought:ItemWrapper):Boolean
		{
			if (_bagItems)
			{
				for each (var item:ItemWrapper in _bagItems)
				{
					if (item.objectUID == itemSought.objectUID)
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		private function onValidQtyDropToSlot(quantity:Number):void
		{
			fillDefaultSlot(_waitingObject, quantity);
		}
		
		private function getIdEffectMalusToBonus(id:uint):uint
		{
			switch (id)
			{
				case 145: // + Dommage
					id = 112;
					break;
				case 423: // + Dommage Terre
					id = 422;
					break;
				case 431: // + Dommage Neutre
					id = 430;
					break;
				case 425: // + Dommage Feu
					id = 424;
					break;
				case 429: // + Dommage Air
					id = 428;
					break;
				case 427: // + Dommage Eau
					id = 426;
					break;
				case 157: // Force
					id = 118;
					break;
				case 155: // Intelligence
					id = 126;
					break;
				case 152: // Chance
					id = 123;
					break;
				case 154: // Agilité
					id = 119;
					break;
				case 153: // Vitalité
					id = 125;
					break;
				case 156: // Sagesse
					id = 124;
					break;
				case 175: // Initiative
					id = 174;
					break;
				case 245: // Résistance (fixe) Terre
					id = 240;
					break;
				case 248: // Résistance (fixe) Feu
					id = 243;
					break;
				case 249: // Résistance (fixe) Neutre
					id = 244;
					break;
				case 247: // Résistance (fixe) Air
					id = 242;
					break;
				case 246: // Résistance (fixe) Eau
					id = 241;
					break;
				case 215: // Résistance (%) Terre
					id = 210;
					break;
				case 218: // Résistance (%) Feu
					id = 213;
					break;
				case 219: // Résistance (%) Neutre
					id = 214;
					break;
				case 217: // Résistance (%) Air
					id = 212;
					break;
				case 216: // Résistance (%) Eau
					id = 211;
					break;
				case 421: // Résitance Critiques
					id = 420;
					break;
				case 417: // Résistance Poussée
					id = 416;
					break;
				case 162: // Esquive PA
					id = 160;
					break;
				case 163: // Esquive PM
					id = 161;
					break;
				case 159: // Pods
					id = 158;
					break;
				case 177: // Prospection
					id = 176;
					break;
				case 186: // % Dommages
					id = 138;
					break;
				//case 226: // % Dommages Piège
					//id = 226;
					//break;
				//case 225: // + Dommages Pièges
					//id = 225;
					//break;
				case 755: // Tacle
					id = 753;
					break;
				case 754: // Fuite
					id = 752;
					break;
				case 411: // Retrait PA
					id = 410;
					break;
				case 413: // Retrait PM
					id = 412;
					break;
				case 179: // Soin
					id = 178;
					break;
				case 171: // CC
					id = 115;
					break;
				//case 182: // Créature invocable
					//id = 182;
					//break;
				//case 220: // Renvois de dommage
					//id = 220;
					//break;
				case 116: // Portée
					id = 117;
					break;
				case 168: // PA
					id = 111;
					break;
				case 169: // PM
					id = 128;
					break;
			}
			
			return id;
		}
	}	
}