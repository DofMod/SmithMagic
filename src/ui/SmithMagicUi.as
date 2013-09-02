package ui 
{
	import d2actions.ExchangeObjectMove;
	import d2actions.ExchangeObjectUseInWorkshop;
	import d2api.ContextMenuApi;
	import d2api.PlayedCharacterApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Grid;
	import d2components.Label;
	import d2components.Slot;
	import d2components.Texture;
	import d2data.ContextMenuData;
	import d2data.EffectInstance;
	import d2data.EffectInstanceDice;
	import d2data.EffectInstanceInteger;
	import d2data.ItemWrapper;
	import d2data.Skill;
	import d2enums.ChatActivableChannelsEnum;
	import d2enums.ComponentHookList;
	import d2enums.CraftResultEnum;
	import d2enums.LocationEnum;
	import d2hooks.BagListUpdate;
	import d2hooks.DropEnd;
	import d2hooks.DropStart;
	import d2hooks.ExchangeCraftResult;
	import d2hooks.ExchangeMultiCraftCrafterCanUseHisRessources;
	import d2hooks.ExchangeObjectAdded;
	import d2hooks.ExchangeObjectModified;
	import d2hooks.ExchangeObjectRemoved;
	import d2hooks.MouseCtrlDoubleClick;
	import d2hooks.ObjectModified;
	import d2hooks.TextInformation;
	import enums.ItemIdEnum;
	import enums.ItemTypeIdEnum;
	import enums.LangEnum;
	import enums.SkillIdEnum;
	import flash.utils.Dictionary;
	import managers.LangManager;
	import utils.EffectIdUtils;
	import utils.SmithmagicUtils;
	
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
		
		// Les variables globales
		private var _well:int = 0;
		private var _isCrafter:Boolean = false;
		private var _inCooperatingMode:Boolean;
		private var _runeWeight:Number = 0;
		private var _waitingObject:ItemWrapper = null;
		private var _modifiedEffects:Dictionary = new Dictionary(false);
		private var _crafterCanUseHisRessources:Boolean = false;
		private var _itemsFromBag:Array = null;
		private var _itemsInBag:Array = null;
		private var _skill:Skill = null;
		private var _langManager:LangManager = null;
		
		private var _bubbleGreyUri:Object;
		private var _bubbleGreenUri:Object;
		private var _bubbleOrangeUri:Object;
		private var _bubbleRedUri:Object;
		private var _bubbleBlueUri:Object;
		
		private var _associatedRuneBgColor:int;
		
		// Utilisation du modCommon pour l'inputBox du puits
		[Module(name="Ankama_Common")]
		public var modCommon:Object;
		
		// Utilisation du modContextMenu pour les menus contextuel
		[Module (name="Ankama_ContextMenu")]
		public var modContextMenu : Object;
		
		// Déclaration des API dont on veut se servir dans cette classe
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var storageApi:StorageApi;
		public var playerApi:PlayedCharacterApi;
		public var menuApi:ContextMenuApi;
		
		// Les boutons de fermeture et reouverture de l'interface
		public var btn_close:ButtonContainer;
		public var btn_option:ButtonContainer;
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
		
		// The textures of the interface
		public var tx_failure_fg:Texture;
		public var tx_failure_bg:Texture;
		public var tx_success_fg:Texture;
		public var tx_success_bg:Texture;
		
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
			
			_associatedRuneBgColor = uiApi.me().getConstant("colors_grid_over");
			
			_langManager = parameterList.langManager;
			_skill = parameterList.skill;
			_inCooperatingMode = parameterList.inCooperatingMode;
			_isCrafter = (parameterList.crafterInfos === undefined || parameterList.crafterInfos.id == playerApi.getPlayedCharacterInfo().id);
			
			initLabels();
			
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
			
			slot_item.emptyTexture = uiApi.createUri(uiApi.me().getConstant("assets") + pictoNameFromSkillId(_skill.id));
			slot_item.refresh();
			
			displayResultIcon(-1);
			
			updateItem(null);
			
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
			
			if (_inCooperatingMode)
			{
				sysApi.addHook(ExchangeMultiCraftCrafterCanUseHisRessources, onExchangeMultiCraftCrafterCanUseHisRessources);
			}
			
			uiApi.addComponentHook(btn_wellInput, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_option, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_option, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_ROLL_OUT);			
			uiApi.addComponentHook(btn_open, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_open, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_open, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(btn_open_cooperative, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_open_cooperative, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_open_cooperative, ComponentHookList.ON_ROLL_OUT);
			
			uiApi.addComponentHook(lbl_min, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_min, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(lbl_max, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_max, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(lbl_effect, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_effect, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(lbl_rune_ba, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_rune_ba, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(lbl_rune_pa, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_rune_pa, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(lbl_rune_ra, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(lbl_rune_ra, ComponentHookList.ON_ROLL_OUT);
			
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
			
			lbl_result.text = _langManager.getText(LangEnum.RESULT, "");
		}
		
		/**
		 * Callback called when we get the result of a craft.
		 * 
		 * @param	resultId	Identifier of the craft result (d2enum.CraftResultEnum).
		 * @param	item	The result item.
		 */
		public function onExchangeCraftResult(resultId:int, item:ItemWrapper):void
		{
			if (item == null)
			{
				return;
			}
			
			displayResultIcon(resultId);
			
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
					oldValue = (EffectIdUtils.isEffectNegative(oldEffect.effectId) ? -1 : 1) * oldEffect.value;
					effectIdBonus =  EffectIdUtils.getEffectIdFromMalusToBonus(oldEffect.effectId);
					
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
						effects[newEffect.effectId].newValue = (EffectIdUtils.isEffectNegative(newEffect.effectId) ? -1 : 1) * newEffect.value;
					}
					else
					{
						newValue = (EffectIdUtils.isEffectNegative(newEffect.effectId) ? -1 : 1) * newEffect.value;
						effectIdBonus = EffectIdUtils.getEffectIdFromMalusToBonus(newEffect.effectId);
						
						effects[newEffect.effectId] = ({oldValue : false, newValue : newValue, id : effectIdBonus});
					}
				}
			}
			
			_modifiedEffects = new Dictionary();
			
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
					weightGains += (effect.newValue * SmithmagicUtils.getEffectWeight(effect.id));
					
					_modifiedEffects[effect.id] = effect.newValue;
				}
				else if (effect.newValue == false && effect.oldValue != false)
				{
					weightLosses += (effect.oldValue * SmithmagicUtils.getEffectWeight(effect.id));
					
					_modifiedEffects[effect.id] = -effect.oldValue;
				}
				else if (effect.oldValue < effect.newValue)
				{
					weightGains += ((effect.newValue - effect.oldValue) * SmithmagicUtils.getEffectWeight(effect.id));
					
					_modifiedEffects[effect.id] = effect.newValue - effect.oldValue;
				}
				else if (effect.oldValue > effect.newValue)
				{
					weightLosses += ((effect.oldValue - effect.newValue) * SmithmagicUtils.getEffectWeight(effect.id));
					
					_modifiedEffects[effect.id] = effect.newValue - effect.oldValue;
				}
			}
			
			//sysApi.log(2, "Rune weight : " +  _runeWeight);
			//sysApi.log(2, "Weight losses : " +  weightLosses);
			//sysApi.log(2, "Weight gains : " +  weightGains);
			
			if (resultId == CraftResultEnum.CRAFT_FAILED || resultId == CraftResultEnum.CRAFT_NEUTRAL)
			{
				//setWell(SmithMagic.well + weightLosses - _runeWeight);
			}
		}
		
		/**
		 * This callback is called when the client allow/disallow the craft to
		 * use his ressources.
		 * 
		 * @param	allowed	Is the crafter is allowed to use his own ressources.
		 */
		public function onExchangeMultiCraftCrafterCanUseHisRessources(allowed:Boolean):void
		{
			_crafterCanUseHisRessources = allowed;
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
			
			displayResultIcon(-1);
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
			if (item.typeId == ItemTypeIdEnum.SMITHMAGIC_RUNE || item.typeId == ItemTypeIdEnum.SMITHMAGIC_POTION)
			{
				slot_rune.data = item;
				
				updateRune(slot_rune.data);
				updateItem(slot_item.data); // Update the list of runes
			}
			else if (item.id == ItemIdEnum.RUNE_SIGNATURE)
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
			
			displayResultIcon(-1);
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
			
			displayResultIcon(-1);
		}
		
		/**
		 * Track the bag item list.
		 * 
		 * @param	items	The list of items in the bag.
		 * @param	modifiedByRemotePlayer	Is this update due to the remove player ?
		 */
		public function onBagListUpdate(items:Object, modifiedByRemotePlayer:Boolean):void
		{
			_itemsInBag = new Array();
			
			for each (var item:ItemWrapper in items)
			{
				_itemsInBag.push(item);
			}
			
			// Here we only want le item list send by the remote player, not the actual bag item list.
			if (modifiedByRemotePlayer)
			{
				_itemsFromBag = _itemsInBag;
			}
			
			updateItem(slot_item.data); // Update runes list
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
					if (target.name.search("slot_") != -1)
					{
						var runeSlot:Slot = target as Slot;
						if (!runeSlot&& !runeSlot.value)
						{
							return;
						}
						
						fillSlot(slot_rune, runeSlot.value, runeSlot.value.quantity);
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
					if (target.name.search("slot_") != -1)
					{
						var runeSlot:Slot = target as Slot;
						if (!runeSlot&& !runeSlot.value)
						{
							return;
						}
						
						fillSlot(slot_rune, runeSlot.value, 1);
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
						uiApi.showTooltip(uiApi.textTooltipInfo(target.data.name), target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3, null, null, null, "TextInfo");
					}
					
					break;
				case lbl_min:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_MIN_EFFECTS), target);
					
					break;
				case lbl_max:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_MAX_EFFECTS), target);
					
					break;
				case lbl_effect:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_ACTUAL_EFFECTS), target);
					
					break;
				case lbl_rune_ba:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_RUNE_SIMPLE), target);
					
					break;
				case lbl_rune_pa:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_RUNE_PA), target);
					
					break;
				case lbl_rune_ra:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_RUNE_RA), target);
					
					break;
				case btn_open:
				case btn_open_cooperative:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_AVANCED_MODE), target);
					
					break;
				case btn_close:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_BASIC_MODE), target);
					
					break;
				case btn_option:
					showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_OPTIONS), target);
					
					break;
				default:
					var data:Object;
					var effectWeight:Number;
					
					if (target.name.search("btn_jet") != -1)
					{
						var buttonEffect:ButtonContainer = target as ButtonContainer;
						if (!buttonEffect && !buttonEffect.value)
						{
							return;
						}
						
						data = buttonEffect.value as EffectInstanceInteger;
						effectWeight = data.value * SmithmagicUtils.getEffectWeight(EffectIdUtils.getEffectIdFromMalusToBonus(data.effectId));
						
						showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_WEIGHT, effectWeight), target);
					}
					else if (target.name.search("slot_") != -1)
					{
						var runeSlot:Slot = target as Slot;
						if (!runeSlot&& !runeSlot.value)
						{
							return;
						}
						
						data = runeSlot.value as ItemWrapper;
						effectWeight = SmithmagicUtils.getEffectWeight(data.effects[0].effectId) * data.effects[0].parameter0;
						
						showDefaultTextTooltip(_langManager.getText(LangEnum.TOOLTIP_RUNE, data.name, data.effects[0].description, effectWeight), target);
					}
					else if (target.name.search("tx_bulle") != -1)
					{
						var text:String;
						if (target.uri.toString() == _bubbleGreyUri.toString())
						{
							text = _langManager.getText(LangEnum.TOOLTIP_BAD)
						}
						else if (target.uri.toString() == _bubbleGreenUri.toString())
						{
							text = _langManager.getText(LangEnum.TOOLTIP_NORMAL)
						}
						else if (target.uri.toString() == _bubbleOrangeUri.toString())
						{
							text = _langManager.getText(LangEnum.TOOLTIP_GOOD)
						}
						else if (target.uri.toString() == _bubbleRedUri.toString())
						{
							text = _langManager.getText(LangEnum.TOOLTIP_OVERMAX)
						}
						else if (target.uri.toString() == _bubbleBlueUri.toString())
						{
							text = _langManager.getText(LangEnum.TOOLTIP_EXOTIC)
						}
						else
						{
							break;
						}
						
						showDefaultTextTooltip(text, target);
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
					modCommon.openInputPopup(_langManager.getText(LangEnum.POPUP_WELL_TITLE), _langManager.getText(LangEnum.POPUP_WELL_MESSAGE), onValidWellValue, null, _well, "0-9.", 5);
					
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
			componentsRef.btn_jet.value = effect;
			componentsRef.slot_pa.value = null;
			componentsRef.slot_ra.value = null;
			componentsRef.slot_simple.value = null;
			
			// If empty line
			if (effect == null)
			{
				componentsRef.ctr_jet.visible = false;
				
				return;
			}
			
			// Find the associated effect dice (jet min, jet max)
			var effectDice:EffectInstanceDice = null;
			var effectIsExotique:Boolean = true;
			
			var bonusEffectId:int = EffectIdUtils.getEffectIdFromMalusToBonus(effect.effectId);
			for each (effectDice in slot_item.data.possibleEffects)
			{
				if (EffectIdUtils.getEffectIdFromMalusToBonus(effectDice.effectId) == bonusEffectId)
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
				
				var isEffectNegative:Boolean = EffectIdUtils.isEffectNegative(effect.effectId);
				var isEffectDiceNegative:Boolean = EffectIdUtils.isEffectNegative(effectDice.effectId);
				
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
			
			componentsRef.lbl_jetModification.text = "";
			for (var modifiedEffectBonusId:String in _modifiedEffects)
			{
				if (int(modifiedEffectBonusId) == bonusEffectId)
				{
					componentsRef.lbl_jetModification.text = _modifiedEffects[modifiedEffectBonusId];
					
					if (_modifiedEffects[modifiedEffectBonusId] > 0)
					{
						componentsRef.lbl_jetModification.cssClass = "augmentation";
					}
					else
					{
						componentsRef.lbl_jetModification.cssClass = "diminution";
					}
					
					break;
				}
			}
			
			// Find the runes associated to the effect
			componentsRef.slot_simple.visible = false;
			componentsRef.slot_pa.visible = false;
			componentsRef.slot_ra.visible = false;
			
			for each (var items:Object in [(_inCooperatingMode && (!_isCrafter || !_crafterCanUseHisRessources)) ? null : storageApi.getViewContent("storageResources"), _itemsInBag])
			{
				for each (var item:ItemWrapper in items)
				{
					if (item.typeId != ItemTypeIdEnum.SMITHMAGIC_RUNE || item.effects[0].effectId != bonusEffectId)
					{
						continue;
					}
					
					var runeSubtype:int = SmithmagicUtils.getRuneSubtype(item.id);
					if (runeSubtype == 2)
					{
						componentsRef.slot_pa.value = item;
						componentsRef.slot_pa.data = item;
						componentsRef.slot_pa.visible = true;
					}
					else if (runeSubtype == 3)
					{
						componentsRef.slot_ra.value = item;
						componentsRef.slot_ra.data = item;
						componentsRef.slot_ra.visible = true;
					}
					else
					{
						componentsRef.slot_simple.value = item;
						componentsRef.slot_simple.data = item;
						componentsRef.slot_simple.visible = true;										
					}
				}
			}
			
			addHooksToSlot(componentsRef.slot_simple);
			addHooksToSlot(componentsRef.slot_pa);
			addHooksToSlot(componentsRef.slot_ra);
			
			uiApi.addComponentHook(componentsRef.btn_jet, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(componentsRef.btn_jet, ComponentHookList.ON_ROLL_OUT);
			
			uiApi.addComponentHook(componentsRef.tx_bulle, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(componentsRef.tx_bulle, ComponentHookList.ON_ROLL_OUT);
			
			// Highlight the effect modified with the rune in slot_rune
			if (slot_rune.data && slot_rune.data.effects[0].effectId == bonusEffectId)
			{
				componentsRef.btn_jet.bgColor =  _associatedRuneBgColor;
			}
			else
			{
				componentsRef.btn_jet.bgColor =  -1;
			}
			
			// Display line
			componentsRef.ctr_jet.visible = true;
		}
				
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Init UI labels.
		 */
		private function initLabels():void
		{
			lbl_well.text = _langManager.getText(LangEnum.WELL, 0);
			lbl_result.text = _langManager.getText(LangEnum.RESULT, "");
			lbl_min.text = _langManager.getText(LangEnum.SHORTCUT_MINIMUM);
			lbl_max.text = _langManager.getText(LangEnum.SHORTCUT_MAXIMUM);
			lbl_effect.text = _langManager.getText(LangEnum.CHARACTERISTIC);
			lbl_rune_ba.text = _langManager.getText(LangEnum.SHORTCUT_RUNE_SIMPLE);
			lbl_rune_pa.text = _langManager.getText(LangEnum.SHORTCUT_RUNE_PA);
			lbl_rune_ra.text = _langManager.getText(LangEnum.SHORTCUT_RUNE_RA);
		}
		
		/**
		 * Display the right texture according to the craft result.
		 * 
		 * @param	result
		 */
		private function displayResultIcon(result:int = -1):void
		{
			switch (result)
			{
				case CraftResultEnum.CRAFT_SUCCESS:
					tx_failure_bg.visible = false;
					tx_failure_fg.visible = false;
					tx_success_bg.visible = true;
					tx_success_fg.visible = true;
					
					break;
				case CraftResultEnum.CRAFT_NEUTRAL:
					tx_failure_bg.visible = false;
					tx_failure_fg.visible = false;
					tx_success_bg.visible = true;
					tx_success_fg.visible = false;
					
					break;
				case CraftResultEnum.CRAFT_FAILED:
					tx_failure_bg.visible = true;
					tx_failure_fg.visible = true;
					tx_success_bg.visible = false;
					tx_success_fg.visible = false;
					
					break;
				default:
					tx_failure_bg.visible = false;
					tx_failure_fg.visible = false;
					tx_success_bg.visible = false;
					tx_success_fg.visible = false;
			}
		}
		
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
			
			if (SmithmagicUtils.getEffectWeight(effect.effectId))
			{
				_runeWeight = SmithmagicUtils.getEffectWeight(effect.effectId) * effect.value;
				
				lbl_rune_weight.text = _langManager.getText(LangEnum.WEIGHT, _runeWeight);
			}
			else
			{
				_runeWeight = 0;
				
				lbl_rune_weight.text = _langManager.getText(LangEnum.UNKNOW_WEIGHT);
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
			
			lbl_level.text = _langManager.getText(LangEnum.LEVEL, item.level);
			lbl_name.text = item.name;
			
			var effect:EffectInstance;
			var forgeableEffectList:Array = new Array();
			var presentEffectList:Dictionary = new Dictionary();
			
			for each (effect in item.effects)
			{
				if (EffectIdUtils.isForgeableEffect(effect.effectId))
				{
					forgeableEffectList.push(effect);
					presentEffectList[EffectIdUtils.getEffectIdFromMalusToBonus(effect.effectId)] = true;
				}
			}
			
			for each (effect in item.possibleEffects)
			{
				if (EffectIdUtils.isForgeableEffect(effect.effectId) && !(presentEffectList[EffectIdUtils.getEffectIdFromMalusToBonus(effect.effectId)]))
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
			_well = well;
			
			lbl_well.text = _langManager.getText(LangEnum.WELL, _well);
		}
		
		/**
		 * Add basics hook listener to a slot.
		 * 
		 * @param	slot	A slot.
		 */
		private function addHooksToSlot(slot:Slot):void
		{
			uiApi.addComponentHook(slot, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(slot, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(slot, ComponentHookList.ON_DOUBLE_CLICK);
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
			switch (slot)
			{
				case slot_item:
					if (_skill.modifiableItemType != item.typeId)
					{
						return false;
					}
					
					return true;
				case slot_rune:
					if (item.typeId != ItemTypeIdEnum.SMITHMAGIC_RUNE && item.typeId != ItemTypeIdEnum.SMITHMAGIC_POTION)
					{
						return false;
					}
					
					return true;
				case slot_signature:
					if (item.id != ItemIdEnum.RUNE_SIGNATURE)
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
			if (_itemsFromBag)
			{
				for each (var item:ItemWrapper in _itemsFromBag)
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
				case SkillIdEnum.MAGE_AN_AMULET:
				{
					return "tx_slotItem0";
				}
				case SkillIdEnum.MAGE_A_RING:
				{
					return "tx_slotItem2";
				}
				case SkillIdEnum.MAGE_A_BELT:
				{
					return "tx_slotItem3";
				}
				case SkillIdEnum.MAGE_BOOTS:
				{
					return "tx_slotItem5";
				}
				case SkillIdEnum.MAGE_A_HAT:
				{
					return "tx_slotItem6";
				}
				case SkillIdEnum.MAGE_A_CAPE:
				case SkillIdEnum.MAGE_A_BAG:
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
		
		/**
		 * Display tooltip
		 */
		private function showDefaultTextTooltip(text:String, target:*):void
		{
			uiApi.showTooltip(uiApi.textTooltipInfo(text), target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3, null, null, null, "TextInfo");
		}
	}	
}