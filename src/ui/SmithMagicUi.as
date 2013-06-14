package ui 
{
	import d2actions.ExchangeObjectMove;
	import d2api.DataApi;
	import d2api.JobsApi;
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
	import d2enums.StatesEnum;
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
		public var _inCooperatingMode:Boolean;
		public var _poidsRune:Number = 0;
		public var _signeReliquat:int;
		public var _waitingObject:Object;		
		public var _btnRef:Dictionary = new Dictionary(false);
		public var _runeRef:Dictionary = new Dictionary(false);
		
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
		
		// Les boutons de fermeture et reouverture de l'interface
		public var btn_close:ButtonContainer;
		public var btn_open:ButtonContainer;
		public var btn_input:ButtonContainer;
		
		// Les Labels de l'interface
		public var lbl_level:Label;
		public var lbl_name:Label;
		public var lbl_rune_effect:Label;
		public var lbl_rune_name:Label;
		public var lbl_rune_poids:Label;
		public var lbl_resultat:Label;
		public var lbl_puits:Label;
		
		// Les Container de l'interface
		public var ctr_concealable:GraphicContainer;
		public var ctr_topbar:GraphicContainer;
				
		// Les 3 Slots de l'interface
		public var slot_item:Slot;
		public var slot_rune:Slot;
		public var slot_signature:Slot;
		
		// La Grid de l'interface
		public var maGrid:Grid;
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
		//::///////////////////////////////////////////////////////////		
		
		public function main(skillId:Object):void
		{
			_bubbleGreyUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_0"));
			_bubbleGreenUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_3"));
			_bubbleOrangeUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_2"));			
			_bubbleRedUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_6"));
			_bubbleBlueUri = uiApi.createUri((uiApi.me().getConstant("assets") + "state_7"));
			
			// On récupère l'id du métier de forgemagie argument du hook de la classe principale
			_skill = jobsApi.getSkillFromId(skillId as uint);
			_inCooperatingMode = SmithMagic.inCooperatingMode;
			
			// On enregistre les 3 slots de l'atelier
			addHooksToSlot(slot_item);
			addHooksToSlot(slot_rune);
			addHooksToSlot(slot_signature);
			
			// On vide la Grid
			updateItem(null);
			
			// On fixe la valeur du puits
			setPuits(SmithMagic.well);
			
			lbl_rune_name.colorText = 0x7F0000;
			lbl_puits.colorText = 0x004A7F;
					
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
			
			uiApi.addComponentHook(btn_close, "onRelease");
			uiApi.addComponentHook(btn_open, "onRelease");
			uiApi.addComponentHook(btn_input, "onRelease");
		}
						
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//::///////////////////////////////////////////////////////////	
		
		public function onTextInformation(text:String, channelId:int):void
		{
			// Si le message ne vient pas du cannal information
			if (channelId != 10)
			{
				return;
			}
			
			// On définit le signe du reliquat
			if (text.indexOf("-reliquat") != -1)
				_signeReliquat = -1;
			else if (text.indexOf("+reliquat") != -1)
				_signeReliquat = 1;
			else 
				_signeReliquat = 0;

			var resultat:String = "";
			
			// Mise à jour du résultat
			lbl_resultat.text = "Résultat : " + resultat;
		}		
		
		public function onExchangeCraftResult(resultId:int, item:ItemWrapper):void
		{
			
			var oldItem:ItemWrapper = slot_item.data;
			var dicoEffect:Dictionary = new Dictionary();
			
			// On parcours les jets de l'item avant le passage de la rune
			for each (var oldEffect:Object in oldItem.effects)
			{
				if (oldEffect is EffectInstanceInteger)
				{
					dicoEffect[oldEffect.effectId] = ({name : oldEffect.description, old : (getSigneBonus(oldEffect) * oldEffect.value), neww : false, id : getIdEffectMalusToBonus(oldEffect.effectId) });
				}
			}
			
			// On parcours les jets de l'item après le passage de la rune
			for each (var newEffect:Object in item.effects)
			{
				if (newEffect is EffectInstanceInteger)
				{
					if (dicoEffect[newEffect.effectId])
					{
						dicoEffect[newEffect.effectId].neww = getSigneBonus(newEffect) * newEffect.value;
					}
					else
					{
						dicoEffect[newEffect.effectId] = ({name : newEffect.description, old : false, neww : (getSigneBonus(newEffect) * newEffect.value), id : getIdEffectMalusToBonus(newEffect.effectId)});
					}
				}
			}
			
			var poidsGains:Number = 0;
			var poidsPertes:Number = 0;
			
			for each (var effect:Object in dicoEffect)
			{
				//sysApi.log(2, " effect : " + effect.name);
				//sysApi.log(8, "old : " + effect.old + " | new : " + effect.neww);
				
				// Si l'effet à Diminué
				if (effect.old > effect.neww)
				{
					poidsPertes += ((effect.old - effect.neww) * SmithMagic.runesWeight[effect.id])
				}
				// Si l'effet à Augmenté
				else if (effect.old < effect.neww)
				{
					poidsGains += ((effect.neww - effect.old) * SmithMagic.runesWeight[effect.id])
				}
				// Si l'effet vient d'être ajouté à l'objet
				else if (effect.old == false && effect.neww != false)
				{
					poidsGains += (effect.neww * SmithMagic.runesWeight[effect.id])
				}
				// Si l'effet vient d'être supprimé de l'objet
				else if (effect.neww == false && effect.old != false)
				{
					poidsPertes += (effect.old * SmithMagic.runesWeight[effect.id])
				}
			}
			
			var poidsRune:Number = _poidsRune;
			
			sysApi.log(16, "poidsRune : " +  poidsRune);
			sysApi.log(16, "poidsPertes : " +  poidsPertes);
			sysApi.log(16, "poidsGains : " +  poidsGains);
						
			if (poidsGains > 0 && poidsGains < poidsRune)
			{
				poidsRune = poidsGains;
			}
			
			// Si le reliquat varie
			if (_signeReliquat != 0)
			{
				if (poidsRune > poidsPertes)
				{
					// Ici on inverse les deux car sinon le résultat est négatif
					if (SmithMagic.well >= (poidsRune - poidsPertes))
					{
						//sysApi.log(1, "On doit perdre du puits et il est suffisant");
						setPuits(SmithMagic.well + poidsPertes - poidsRune);
					}
					else
					{
						//sysApi.log(1, "On doit perdre du puits mais il est insuffisant");
						setPuits(0);
					}
				}
				else if (poidsRune < poidsPertes)
				{
					//sysApi.log(1, "On a trop perdu");
					setPuits(SmithMagic.well + poidsPertes - poidsRune);
				}
				else
				{
					//sysApi.log(1, "On a perdu autant qu'on a gagné");
				}
			}
		}
		
		public function onExchangeObjectModified(item:ItemWrapper):void
		{
			// Permet de mettre à jour la quantité des runes ou des potions présentent dans le slot de l'atelier
			// Et également la quantité de runes dans la grid
			if (item.typeId == SMITHMAGIC_RUNE_ID || item.typeId == SMITHMAGIC_POTION_ID)
			{
				slot_rune.data = item;
				updateRune(slot_rune.data);
				updateItem(slot_item.data);
			}
		}
		
		public function onObjectModified(item:ItemWrapper):void
		{
			// Permet de mettre à jour l'objet dans notre atelier à chaque fois qu'un objet y est placé ou qu'une rune est passée
			if (item.isEquipment)
			{
				slot_item.data = item;
				updateItem(slot_item.data);
			}
		}			
		
		public function onExchangeObjectAdded(item:ItemWrapper):void
		{
			// Si l'item est dans la catégorie Runes de Forgemagie ou Potions de Forgemagie
			if (item.typeId == SMITHMAGIC_RUNE_ID || item.typeId == SMITHMAGIC_POTION_ID)
			{
				slot_rune.data = item;
				updateRune(slot_rune.data);
				updateItem(slot_item.data);
			}
			// Si l'item est une rune de signature
			else if (item.id == SIGNATURE_RUNE_ID)
			{
				slot_signature.data = item;
			}
			// Sinon si c'est autre chose (donc un objet)
			else
			{
				lbl_level.text = String("Niv. " + item.level);
				lbl_name.text = item.name;
				slot_item.data = item;
				updateItem(slot_item.data);
			}	
		}
		
		public function onExchangeObjectRemoved(itemUid:uint):void
		{
			var item:Object;
			
			if (_inCooperatingMode)
			{
				item = dataApi.getItem(itemUid) as Item;
			}
			else
			{
				item = dataApi.getItemFromUId(itemUid) as ItemWrapper;
			}
			
			// Si l'item est dans la catégorie Runes de Forgemagie ou Potions de Forgemagie
			if (item.typeId == SMITHMAGIC_RUNE_ID || item.typeId == SMITHMAGIC_POTION_ID)
			{
				slot_rune.data = null;
				updateRune(null);
				updateItem(slot_item.data);
			}
			// Si l'item est une rune de signature
			else if (item.id == SIGNATURE_RUNE_ID)
			{
				slot_signature.data = null;
			}
			// Sinon si c'est autre chose (donc un objet)
			else
			{
				lbl_level.text = "";
				lbl_name.text = "";
				slot_item.data = null;
				updateItem(null);
			}		
		}
		
		public function onMouseCtrlDoubleClick(target:Object):void
		{
			switch (target)
			{
				case slot_rune:
					// Permet de vider toutes les runes de notre atelier
					if (target.data)
					{
						sysApi.sendAction(new ExchangeObjectMove(target.data.objectUID, -(target.data.quantity)));
					}
					
					break;
				default:
					if (_runeRef[target] != null)
					{
						var data:ItemWrapper = _runeRef[target];

						// Permet de vider le slot si on souhaite ajouter un type de rune qui n'est pas déjà dans le slot
						if (slot_rune.data != null && slot_rune.data.name != data.name)
						{
							sysApi.sendAction(new ExchangeObjectMove(slot_rune.data.objectUID, -(slot_rune.data.quantity)));
						}
						
						// Si la rune cliqué n'est pas déjà celle dans le slot
						if (slot_rune.data != data)
						{
							sysApi.sendAction(new ExchangeObjectMove(data.objectUID, data.quantity));
						}
					}
			}
		}		
		
		public function onDoubleClick(target:Object):void
		{
			switch (target)
			{
				// Permet de retirer une seule rune d'un des 3 slots de notre atelier
				case slot_item:
				case slot_rune:
				case slot_signature:
					if (target.data)
					{
						sysApi.sendAction(new ExchangeObjectMove(target.data.objectUID, -1));
					}
					
					break;
				default:
					if (_runeRef[target] != null)
					{
						var data:ItemWrapper = _runeRef[target];

						// Permet de vider le slot si on souhaite ajouter un type de rune qui n'est pas déjà dans le slot
						if (slot_rune.data != null && slot_rune.data.name != data.name)
						{
							sysApi.sendAction(new ExchangeObjectMove(slot_rune.data.objectUID, -(slot_rune.data.quantity)));
						}
						
						// Si la rune cliqué n'est pas déjà celle dans le slot
						if (slot_rune.data != data)
						{
							sysApi.sendAction(new ExchangeObjectMove(data.objectUID, 1));
						}
					}
			}
		}
		
		public function onRollOut(target:Object):void
		{
			uiApi.hideTooltip();
		}
		
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
					//sysApi.log(8, "target.name : " + target.name);
					var data:Object;
					var toolTip:Object;
					var effectWeight:Number;
					
					// Le Cas du Rollover sur un jet, data de type EffectInstanceInteger
					if (_btnRef[target] !== null && target.name.search("btn_jet") != -1 && _btnRef[target].effect is EffectInstanceInteger)
					{
						data = _btnRef[target].effect as EffectInstanceInteger;
						effectWeight = data.value * SmithMagic.runesWeight[getIdEffectMalusToBonus(data.effectId)];
						
						toolTip = uiApi.textTooltipInfo("Poids de l'effet : " + effectWeight);
						uiApi.showTooltip(toolTip, target, false, "standard", 7, 1, 3);
					}
					// Si les infos existent on affiche la tooltip
					else if (_runeRef[target] !== null && target.name.search("slot_") != -1)
					{
						data = _runeRef[target] as ItemWrapper;
						effectWeight = SmithMagic.runesWeight[data.effects[0].effectId] * data.effects[0].parameter0;
						
						toolTip = uiApi.textTooltipInfo(data.name + ", + " + data.effects[0].description + "\nPoid de la rune : " + effectWeight + "\nProbabilité : " + 50 + "%");
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
		
		public function onRelease(target:Object):void
		{
			switch (target)
			{
				// Quand on clique sur agrandir l'interface
				case slot_item:
					updateItem(slot_item.data);
					updateRune(slot_rune.data);
					
					break;
				
				// Masquage de l'interface et affichage du bouton de réouverture
				case btn_close:
					ctr_concealable.visible = false;
					btn_open.visible = true;
					
					break;
				
				// Affichage de l'interface et masquage de ce bouton
				case btn_open:
					ctr_concealable.visible = true;
					btn_open.visible = false;
					
					break;
				
				// Quand on clique sur la texture de l'input on affiche un popup qui demande la valeur du puits
				case btn_input:
					modCommon.openInputPopup("Réglage manuel du puits", "Entrez la valeur souhaitée", onValidQuantity, null, SmithMagic.well, "0-9.", 5);
					
					break;
			}
		}					
	   
		public function onDropStart(target:Object):void
		{
			for each (var slot:Object in [slot_item, slot_rune, slot_signature])
			{
				if (isValidSlot(slot, target.data))
				{
					slot.selected = true;
				}
			}
		}
		
		public function onDropEnd(target:Object):void
		{
			for each (var slot:Object in [slot_item, slot_rune, slot_signature])
			{
				slot.selected = false;
			}
		}
		
		public function updateGrid(data:*, componentsRef:*, selected:Boolean):void
		{
			_btnRef[componentsRef.btn_jet] = data;
			_runeRef[componentsRef.slot_pa] = null;
			_runeRef[componentsRef.slot_ra] = null;
			_runeRef[componentsRef.slot_simple] = null;
			
			if (data !== null)
			{
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
				componentsRef.lb_jetmin.text = "-";			
				componentsRef.lb_jetmax.text = "-";	
				componentsRef.lb_jet.text = effect.description;
				
				// On affecte le style css en fonction du type de jet (malus, bonus ou pas de signe)
				if (effect.description.charAt(0) == "-")
				{
					componentsRef.lb_jet.cssClass = "malus";
					signeBonus = -1;
				}
				else
				{
					if (effect.description.charAt(0) == "+")
					{
						componentsRef.lb_jet.cssClass = "bonus";
						signeBonus = 1;
					}
					else
					{
						componentsRef.lb_jet.cssClass = "normal";
						signeBonus = 1;
					}
				}
				
				if (isNull)
				{
					componentsRef.lb_jet.cssClass = "bold";
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
						componentsRef.lb_jetmin.text = jetMin;
						componentsRef.lb_jetmax.text = jetMax;
				
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
						else if ((((jetActuel - jetMin) * 100) / (jetMax - jetMin))  >= 80)
						{
							componentsRef.tx_bulle.uri = _bubbleOrangeUri;
						}
					}
				}
				
				// Si le jet est exotique
				if (isExotic)
				{
					componentsRef.lb_jet.cssClass = "exotic"; 
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
									_runeRef[componentsRef.slot_pa] = item;
									componentsRef.slot_pa.data = item;
									componentsRef.slot_pa.visible = true;
								}
								else if (item.name.search("Rune Ra") != -1)
								{
									_runeRef[componentsRef.slot_ra] = item;
									componentsRef.slot_ra.data = item;
									componentsRef.slot_ra.visible = true;
								}
								else
								{
									_runeRef[componentsRef.slot_simple] = item;
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
			else
			{
				// On cache la ligne du jet
				componentsRef.ctr_jet.visible = false;
			}
		}
				
		//::///////////////////////////////////////////////////////////
		//::// Méthodes Privées
		//::///////////////////////////////////////////////////////////
		
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
		
		private function updateRune(item:ItemWrapper):void
		{
			// Permet d'effacer les labels quand on retire la rune du slot
			if (item == null)
			{
				lbl_rune_name.text = "";
				lbl_rune_effect.text = "";
				lbl_rune_poids.text = "";
				
				return;
			}
			
			// On met à jour le nom de la rune
			lbl_rune_name.text = item.name;
			
			// On met à jour l'unique effet de la rune
			for each (var effect:EffectInstanceInteger in item.effects)
			{
				lbl_rune_effect.text = effect.description;
				
				// On stock ces valeurs pour calculer le poids de la rune
				var effectId:int = effect.effectId;
				var effectValue:int = effect.value;
			}
			
			// On met à jour le poids de la rune
			if (SmithMagic.runesWeight[effectId])
			{
				_poidsRune = effectValue * SmithMagic.runesWeight[effectId];
				lbl_rune_poids.text = "Poids : " + _poidsRune;
			}
			else
			{
				lbl_rune_poids.text = "Aucun effet visible";
				//sysApi.log(8, "effet inconnu, ID : " + effectId);
			}
		}
		
		private function updateItem(item:ItemWrapper):void
		{
			var tabEffect:Array = new Array();
			var visibleEffect:Dictionary = new Dictionary();
			
			// Permet d'effacer la grid quand on pass null en argument
			if (item == null)
			{
				maGrid.dataProvider = tabEffect;
				
				return;
			}
			
			// On parcours les jets actuel de l'objetEnCours pour les stocker dans un tableau
			for each (var effect:Object in item.effects)
			{
				// Si c'est un jet normal sinon c'est ( EffectInstanceMinMax = DMG DE CAC) ou (EffectInstanceString = Signature)
				if (effect is EffectInstanceInteger)
				{
					tabEffect.push({ effect : effect, isNull : false});
					visibleEffect[effect.effectId] = true;
				}
			}
			
			// On parcours les jets actuel de l'objetEnCours pour les stocker dans un tableau
			for each (var possibleEffect:Object in item.possibleEffects)
			{
				// Si c'est un jet normal sinon c'est ( EffectInstanceMinMax = DMG DE CAC ) ou (EffectInstanceString = Signature)
				if (possibleEffect is EffectInstanceInteger && (visibleEffect[possibleEffect.effectId] != true))
				{
					tabEffect.push({ effect : possibleEffect, isNull : true});
				}
			}			
			
			maGrid.dataProvider = tabEffect;
		}	
		
		private function onValidQuantity(string:String):void
		{
			setPuits(Number(string));
		}
		
		private function setPuits(puits:Number):void
		{
			// Mise à jour de la variable puits et du label puits
			SmithMagic.well = puits;
			lbl_puits.text = "Puits : " + puits;
		}
		
		private function addHooksToSlot(slot:Slot):void
		{
			uiApi.addComponentHook(slot, "onRollOver");
			uiApi.addComponentHook(slot, "onRollOut");
			uiApi.addComponentHook(slot, "onDoubleClick");
			uiApi.addComponentHook(slot, "onRelease");
		}
		
		private function isValidSlot(slot:Object, itemWp:Object):Boolean
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
			return isValidSlot(target, data);
		}
		
		private function processDrop(target:Object, data:Object, source:Object):void
		{
			// Si le slot est valide
			if (dropValidator(target, data, source))
			{
				switch (target)
				{
					case slot_item:
					case slot_signature:
						fillSlot(target, data, 1);
						
						break;
					case slot_rune:
						if (data.info1 > 1)
						{
							_waitingObject = data;
							modCommon.openQuantityPopup(1, data.quantity, data.quantity, onValidQtyDropToSlot);
						}
						else
						{
							fillSlot(slot_rune, data, 1);
						}
						
						break;
				}
			}
		}
		
		private function unfillSlot(target:Object, qty:int = -1):void
		{
			if (qty == -1)
			{
				qty = target.data.quantity;
			}
			
			sysApi.sendAction(new ExchangeObjectMove(target.data.objectUID, -(qty)));
		}
		
		private function fillDefaultSlot(data:Object, qty:int = -1):void
		{
			var _local3:Object;
			for each (_local3 in [slot_item, slot_rune, slot_signature])
			{
				if (dropValidator(_local3, data, null))
				{
					if (qty == -1)
					{
						switch (_local3)
						{
							case slot_item:
							case slot_signature:
								qty = 1;
								
								break;
							case slot_rune:
								qty = data.quantity;
								
								break;
						}
					}
					
					fillSlot(_local3, data, qty);
					
					return;
				}
			}
		}
		
		private function fillSlot(target:Object, data:Object, qty:int):void
		{
			if (((!((target.data == null))) && ((((((target == slot_item)) || ((target == slot_signature)))) || ((((target == slot_rune)) && (!((target.data.objectGID == data.objectGID)))))))))
			{
				unfillSlot(target, -1);
			}
			
			sysApi.sendAction(new ExchangeObjectMove(data.objectUID, qty));
		}
		
		private function onValidQtyDropToSlot(qty:Number):void
		{
			fillDefaultSlot(_waitingObject, qty);
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