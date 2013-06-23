package ui 
{
	import d2actions.ExchangeObjectMove;
	import d2actions.ExchangeObjectUseInWorkshop;
	import d2api.ContextMenuApi;
	import d2api.DataApi;
	import d2api.PlayedCharacterApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Grid;
	import d2components.Label;
	import d2components.Slot;
	import d2data.ContextMenuData;
	import d2data.EffectInstance;
	import d2data.EffectInstanceDice;
	import d2data.EffectInstanceInteger;
	import d2data.Item;
	import d2data.ItemWrapper;
	import d2enums.ChatActivableChannelsEnum;
	import d2enums.LocationEnum;
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
	import enum.EffectIdEnum;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * Main ui class.
	 * 
	 * @author ExiTeD, Relena
	 */
	
	public class SmithMagicUi 
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Les constantes
		private static const SIGNATURE_RUNE_ID:int = 7508;
		private static const SMITHMAGIC_RUNE_ID:int = 78;
		private static const SMITHMAGIC_POTION_ID:int = 26;
		private static const SKILL_TYPE_AMULET:int = 169;
		private static const SKILL_TYPE_RING:int = 168;
		private static const SKILL_TYPE_BELT:int = 164;
		private static const SKILL_TYPE_BOOTS:int = 163;
		private static const SKILL_TYPE_HAT:int = 166;
		private static const SKILL_TYPE_CLOAK:int = 165;
		private static const SKILL_TYPE_BAG:int = 167;
		
		// Les variables globales
		private var _isCrafter:Boolean = false;
		private var _inCooperatingMode:Boolean;
		private var _runeWeight:Number = 0;
		private var _wellModification:Boolean = false;
		private var _waitingObject:ItemWrapper;
		private var _dataOfEffectButtons:Dictionary = new Dictionary(false);
		private var _dataOfAvailableRuneSlots:Dictionary = new Dictionary(false);
		private var _bagItems:Array = null;
		
		private var _bubbleGreyUri:Object;
		private var _bubbleGreenUri:Object;
		private var _bubbleOrangeUri:Object;
		private var _bubbleRedUri:Object;
		private var _bubbleBlueUri:Object;
		
		// Utilisation du modCommon pour l'inputBox du puits
		[Module(name="Ankama_Common")]
		public var modCommon:Object;
		
		// Utilisation du modContextMenu pour les menus contextuel
		[Module (name="Ankama_ContextMenu")]
		public var modContextMenu : Object;
		
		// Déclaration des API dont on veut se servir dans cette classe
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var dataApi:DataApi;
		public var storageApi:StorageApi;
		public var playerApi:PlayedCharacterApi;
		public var menuApi:ContextMenuApi;
		
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
		public var lbl_min:Label;
		public var lbl_max:Label;
		public var lbl_effect:Label;
		public var lbl_rune_ba:Label;
		public var lbl_rune_pa:Label;
		public var lbl_rune_ra:Label;
		
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
			
			_inCooperatingMode = SmithMagic.inCooperatingMode;
			_isCrafter = (parameterList.crafterInfos === undefined || parameterList.crafterInfos.id == playerApi.getPlayedCharacterInfo().id);
			
			for each (var slot:Slot in [slot_item, slot_rune, slot_signature])
			{
				addHooksToSlot(slot);
				
				if (_isCrafter)
				{
					slot.dropValidator = dropValidator;
					slot.processDrop = processDrop;
				}
				else
				{
					slot.allowDrag = false;
					slot.softDisabled = true;
					slot.highlightTexture = null;
					slot.selectedTexture = null;
					slot.acceptDragTexture = null;
					slot.refuseDragTexture = null;
				}
			}
			
			slot_item.emptyTexture = uiApi.createUri(uiApi.me().getConstant("assets") + pictoNameFromSkillId(SmithMagic.skill.id));
			slot_item.refresh();
			
			updateItem(null);
			
			setWell(SmithMagic.well);
			
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
			
			uiApi.addComponentHook(btn_open, "onRollOver");
			uiApi.addComponentHook(btn_open, "onRollOut");
			uiApi.addComponentHook(btn_open_cooperative, "onRollOver");
			uiApi.addComponentHook(btn_open_cooperative, "onRollOut");
			
			uiApi.addComponentHook(lbl_min, "onRollOver");
			uiApi.addComponentHook(lbl_min, "onRollOut");
			uiApi.addComponentHook(lbl_max, "onRollOver");
			uiApi.addComponentHook(lbl_max, "onRollOut");
			uiApi.addComponentHook(lbl_effect, "onRollOver");
			uiApi.addComponentHook(lbl_effect, "onRollOut");
			uiApi.addComponentHook(lbl_rune_ba, "onRollOver");
			uiApi.addComponentHook(lbl_rune_ba, "onRollOut");
			uiApi.addComponentHook(lbl_rune_pa, "onRollOver");
			uiApi.addComponentHook(lbl_rune_pa, "onRollOut");
			uiApi.addComponentHook(lbl_rune_ra, "onRollOver");
			uiApi.addComponentHook(lbl_rune_ra, "onRollOut");
			
			displayOpenButton(_inCooperatingMode);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////	
		
		/**
		 * Callback called we recieve chat message.
		 * 
		 * @param	text	Content of the message.
		 * @param	channelId	Id of this message's channel.
		 * @param	timestamp	The message reception date.
		 * @param	saveMessage	Do we need to save the message now ? (false = already done).
		 */
		public function onTextInformation(text:String, channelId:int, timestamp:Number = 0, saveMessage:Boolean = false):void
		{
			if (channelId != ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO)
			{
				return;
			}
			
			// Is the well value modified ?
			_wellModification = (text.indexOf("reliquat") != -1);
			
			lbl_result.text = "Résultat : ";
		}
		
		/**
		 * Callback called when we get the result of a craft.
		 * 
		 * @param	resultId	Is the craft successful ?
		 * @param	item	The result item.
		 */
		public function onExchangeCraftResult(resultId:int, item:ItemWrapper):void
		{
			if (item == null)
			{
				return;
			}
			
			var oldItem:ItemWrapper = slot_item.data;
			var effects:Dictionary = new Dictionary();
			var oldValue:int;
			var newValue:int;
			var effectIdBonus:int;
			
			// On parcours les jets de l'item avant le passage de la rune
			for each (var oldEffect:Object in oldItem.effects)
			{
				if (oldEffect is EffectInstanceInteger)
				{
					oldValue = (EffectIdEnum.isEffectNegative(oldEffect.effectId) ? -1 : 1) * oldEffect.value;
					effectIdBonus =  EffectIdEnum.getEffectIdFromMalusToBonus(oldEffect.effectId);
					
					effects[oldEffect.effectId] = ({oldValue : oldValue, newValue : false, id : effectIdBonus});
				}
			}
			
			// On parcours les jets de l'item après le passage de la rune
			for each (var newEffect:Object in item.effects)
			{
				if (newEffect is EffectInstanceInteger)
				{
					if (effects[newEffect.effectId])
					{
						effects[newEffect.effectId].newValue = (EffectIdEnum.isEffectNegative(newEffect.effectId) ? -1 : 1) * newEffect.value;
					}
					else
					{
						newValue = (EffectIdEnum.isEffectNegative(newEffect.effectId) ? -1 : 1) * newEffect.value;
						effectIdBonus = EffectIdEnum.getEffectIdFromMalusToBonus(newEffect.effectId);
						
						effects[newEffect.effectId] = ({oldValue : false, newValue : newValue, id : effectIdBonus});
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
			
			//sysApi.log(2, "Rune weight : " +  _runeWeight);
			//sysApi.log(2, "Weight losses : " +  weightLosses);
			//sysApi.log(2, "Weight gains : " +  weightGains);
			
			if (_wellModification == true)
			{
				//setWell(SmithMagic.well + weightLosses - _runeWeight);
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
		 * @param	modifiedByRemotePlayer	Is this update due to the remove player ?
		 */
		public function onBagListUpdate(items:Object, modifiedByRemotePlayer:Boolean):void
		{
			// Here we only want le item list send by the remote player, not the actual bag item list.
			if (modifiedByRemotePlayer)
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
				case lbl_min:
					uiApi.showTooltip("Effets minimums", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case lbl_max:
					uiApi.showTooltip("Effets maximum", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case lbl_effect:
					uiApi.showTooltip("Effets actuels", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case lbl_rune_ba:
					uiApi.showTooltip("Runes de base", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case lbl_rune_pa:
					uiApi.showTooltip("Runes PA", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case lbl_rune_ra:
					uiApi.showTooltip("Runes RA", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				case btn_open:
				case btn_open_cooperative:
					uiApi.showTooltip("Mode avancé", target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					
					break;
				default:
					var data:Object;
					var toolTip:Object;
					var effectWeight:Number;
					
					if (target.name.search("btn_jet") != -1 && _dataOfEffectButtons[target] !== null)
					{
						data = _dataOfEffectButtons[target] as EffectInstanceInteger;
						effectWeight = data.value * SmithMagic.runesWeight[EffectIdEnum.getEffectIdFromMalusToBonus(data.effectId)];
						
						toolTip = uiApi.textTooltipInfo("Poids de l'effet : " + effectWeight);
						uiApi.showTooltip(toolTip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
					}
					else if (target.name.search("slot_") != -1 && _dataOfAvailableRuneSlots[target] !== null)
					{
						data = _dataOfAvailableRuneSlots[target] as ItemWrapper;
						effectWeight = SmithMagic.runesWeight[data.effects[0].effectId] * data.effects[0].parameter0;
						
						toolTip = uiApi.textTooltipInfo(data.name + ", +" + data.effects[0].description + "\nPoids de la rune : " + effectWeight + "\nProbabilité : " + 50 + "%");
						uiApi.showTooltip(toolTip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
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
						
						uiApi.showTooltip(toolTip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3);
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
		 * On mouse right click.
		 * 
		 * @param	target
		 */
		public function onRightClick(target:Object):void
		{
			if (target.data)
			{
				var menu:ContextMenuData = menuApi.create(target.data);
				if (menu.content.length > 0)
				{
					modContextMenu.createContextMenu(menu);
				}
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
		 * @param	effect
		 * @param	componentsRef
		 * @param	selected
		 */
		public function updateGrid(effect:EffectInstanceInteger, componentsRef:*, selected:Boolean):void
		{
			// Reset globals data tracker
			_dataOfEffectButtons[componentsRef.btn_jet] = effect;
			_dataOfAvailableRuneSlots[componentsRef.slot_pa] = null;
			_dataOfAvailableRuneSlots[componentsRef.slot_ra] = null;
			_dataOfAvailableRuneSlots[componentsRef.slot_simple] = null;
			
			// If empty line
			if (effect == null)
			{
				componentsRef.ctr_jet.visible = false;
				
				return;
			}
			
			// Find the associated effect dice (jet min, jet max)
			var effectDice:EffectInstanceDice = null;
			var effectIsExotique:Boolean = true;
			
			var bonusEffectId:int = EffectIdEnum.getEffectIdFromMalusToBonus(effect.effectId);
			for each (effectDice in slot_item.data.possibleEffects)
			{
				if (EffectIdEnum.getEffectIdFromMalusToBonus(effectDice.effectId) == bonusEffectId)
				{
					effectIsExotique = false;
					
					break;
				}
			}
			
			if (effectIsExotique)
			{
				componentsRef.lbl_jetMin.text = "";
				componentsRef.lbl_jetMax.text = "";
				componentsRef.lbl_jet.text = effect.description;
				
				componentsRef.lbl_jet.cssClass = "exotic";
				
				componentsRef.tx_bulle.uri = _bubbleBlueUri;
			}
			else
			{
				var jetMin:int;
				var jetMax:int;
				var jetValue:int;
				
				var isEffectNegative:Boolean = EffectIdEnum.isEffectNegative(effect.effectId);
				var isEffectDiceNegative:Boolean = EffectIdEnum.isEffectNegative(effectDice.effectId);
				
				// Get and set jet min & jet max & description.
				if (isEffectDiceNegative)
				{
					jetMax = -(effectDice.diceNum);
					jetMin = (effectDice.diceSide) ? -(effectDice.diceSide) : jetMax;
				}
				else
				{
					jetMin = effectDice.diceNum;
					jetMax = (effectDice.diceSide) ? effectDice.diceSide : jetMin;
				}
				
				componentsRef.lbl_jetMin.text = jetMin;
				componentsRef.lbl_jetMax.text = jetMax;
				componentsRef.lbl_jet.text = effect.description;
				
				// Get actual jet + Set the effect style
				if (effect.value == 0)
				{
					componentsRef.lbl_jet.cssClass = "normal";
					
					jetValue = 0;
				}
				else if (isEffectNegative != isEffectDiceNegative)
				{
					componentsRef.lbl_jet.cssClass = "overmax";
					
					jetValue = effect.value;
				}
				else if (isEffectNegative)
				{
					componentsRef.lbl_jet.cssClass = "malus";
					
					jetValue = -(effect.value);
				}
				else
				{
					componentsRef.lbl_jet.cssClass = "bonus";
					
					jetValue = effect.value;
				}
				
				// Select the right bubble color
				if (jetValue < jetMin || jetValue == 0)
				{
					componentsRef.tx_bulle.uri = _bubbleGreyUri;
				}
				else if (jetValue > jetMax)
				{
					componentsRef.tx_bulle.uri = _bubbleRedUri;
				}
				else if ((jetValue == jetMax) || (((jetValue - jetMin) / (jetMax - jetMin))  >= 0.8))
				{
					componentsRef.tx_bulle.uri = _bubbleOrangeUri;
				}
				else
				{
					componentsRef.tx_bulle.uri = _bubbleGreenUri;
				}
			}
			
			// Find the runes associated to the effect
			componentsRef.slot_simple.visible = false;
			componentsRef.slot_pa.visible = false;
			componentsRef.slot_ra.visible = false;
			
			for each (var item:ItemWrapper in storageApi.getViewContent("storageResources"))
			{
				if (item.typeId != SMITHMAGIC_RUNE_ID || item.effects[0].effectId != effect.effectId)
				{
					continue;
				}
				
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
			
			addHooksToSlot(componentsRef.slot_simple);
			addHooksToSlot(componentsRef.slot_pa);
			addHooksToSlot(componentsRef.slot_ra);
			
			uiApi.addComponentHook(componentsRef.btn_jet, "onRollOver");
			uiApi.addComponentHook(componentsRef.btn_jet, "onRollOut");
			
			uiApi.addComponentHook(componentsRef.tx_bulle, "onRollOver");
			uiApi.addComponentHook(componentsRef.tx_bulle, "onRollOut");
			
			// Gestion of the selection
			componentsRef.btn_jet.selected	= selected;
			componentsRef.btn_jet.state = selected ? StatesEnum.STATE_SELECTED : StatesEnum.STATE_NORMAL;
			
			// Display line
			componentsRef.ctr_jet.visible = true;
		}
				
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Display the right open button.
		 * 
		 * @param	inCooperativeMode	Are we in cooperative mode ?
		 */
		private function displayOpenButton(inCooperativeMode:Boolean):void
		{
			btn_open.visible = !inCooperativeMode;
			btn_open_cooperative.visible = inCooperativeMode;
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
			
			var effect:EffectInstance;
			var forgeableEffectList:Array = new Array();
			var presentEffectList:Dictionary = new Dictionary();
			
			for each (effect in item.effects)
			{
				// Exclude damages effects (EffectInstanceMinMax) and Signature/Hunter mark/follower bonus (EffectInstanceString)
				if (effect is EffectInstanceInteger)
				{
					forgeableEffectList.push(effect);
					presentEffectList[EffectIdEnum.getEffectIdFromMalusToBonus(effect.effectId)] = true;
				}
			}
			
			for each (effect in item.possibleEffects)
			{
				if (effect is EffectInstanceInteger && !(presentEffectList[EffectIdEnum.getEffectIdFromMalusToBonus(effect.effectId)]))
				{
					forgeableEffectList.push(effect);
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
			uiApi.addComponentHook(slot, "onRightClick");
		}
		
		/**
		 * Test if the item is valid for the slot.
		 * 
		 * @param	slot	The destination slot to test.
		 * @param	itemWp	The item to put in the slot.
		 * 
		 * @return	True of False.
		 */
		private function isValidSlot(slot:Slot, item:ItemWrapper):Boolean
		{
			if (!SmithMagic.skill)
			{
				return false;
			}
			
			switch (slot)
			{
				case slot_item:
					if (SmithMagic.skill.modifiableItemType != item.typeId)
					{
						return false;
					}
					
					return true;
				case slot_rune:
					if (item.typeId != SMITHMAGIC_RUNE_ID && item.typeId != SMITHMAGIC_POTION_ID)
					{
						return false;
					}
					
					return true;
				case slot_signature:
					if (item.id != SIGNATURE_RUNE_ID)
					{
						return false;
					}
					
					return true;
			}
			
			return false;
		}
		
		/**
		 * Slot drop validator callback. Test if item is valid for the slot.
		 * 
		 * @param	target	The target slot.
		 * @param	data	The item to drop on the slot.
		 * @param	source	?
		 * 
		 * @return	True of False.
		 */
		private function dropValidator(target:Object, data:Object, source:Object):Boolean
		{
			if (data is ItemWrapper && target is Slot)
			{
				return isValidSlot(target as Slot, data as ItemWrapper);
			}
			
			return false;
		}
		
		/**
		 * Slot drop process callback. Fill the slot with the item.
		 * 
		 * @param	target	The target slot.
		 * @param	data	The item to drop on the slot.
		 * @param	source	?
		 */
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
					if (item.quantity > 1)
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
			
			if (isItemFromBag(item))
			{
				sysApi.sendAction(new ExchangeObjectUseInWorkshop(item.objectUID, quantity));
			}
			else
			{
				sysApi.sendAction(new ExchangeObjectMove(item.objectUID, quantity));
			}
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
		
		/**
		 * Callback called when we valid the quantity selector popup.
		 * 
		 * @param	quantity	The nex quantity of item so add.
		 */
		private function onValidQtyDropToSlot(quantity:Number):void
		{
			fillDefaultSlot(_waitingObject, quantity);
		}
		
		/**
		 * Return the skill pictorgram URI  string.
		 * 
		 * @param	skillId	Index of the skill.
		 * 
		 * @return	The skill pictogram URI string
		 */
		private function pictoNameFromSkillId(skillId:int):String
		{
			switch(skillId)
			{
				case SKILL_TYPE_AMULET:
				{
					return "tx_slotItem0";
				}
				case SKILL_TYPE_RING:
				{
					return "tx_slotItem2";
				}
				case SKILL_TYPE_BELT:
				{
					return "tx_slotItem3";
				}
				case SKILL_TYPE_BOOTS:
				{
					return "tx_slotItem5";
				}
				case SKILL_TYPE_HAT:
				{
					return "tx_slotItem6";
				}
				case SKILL_TYPE_CLOAK:
				case SKILL_TYPE_BAG:
				{
					return "tx_slotItem7";
				}
				default:
				{
					return "tx_slotItem1";
					break;
				}
			}
		}
	}	
}