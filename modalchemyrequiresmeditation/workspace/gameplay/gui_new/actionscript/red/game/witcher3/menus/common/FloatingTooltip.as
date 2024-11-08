/***********************************************************************
/** Floating tooltip, curently used in inventory only
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.core.CoreComponent;
	import scaleform.clik.data.DataProvider;

	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.controls.W3TextArea;

	public class FloatingTooltip extends UIComponent // #B obsolete
	{
		public var mcComparisionAnchor:MovieClip;
		
		public var tfItemName	: TextField;
		public var tfItemTitle	: TextField;
		public var tfItemRarity	: TextField;
		public var tfItemType	: TextField;
		
		public var mcIconLoader:W3UILoader;
		
		public var mcPriceIcon		: MovieClip;
		public var mcWeightIcon		: MovieClip;
		public var mcDurabilityIcon	: MovieClip;

		public var tfPriceValue		: TextField;
		public var tfWeightValue	: TextField;
		public var tfDurabilityValue: TextField;
		
		public var mcStatsList 		: W3ScrollingList;
		public var mcStatsListItem1 : W3StatsListItem;
		public var mcStatsListItem2 : W3StatsListItem;
		public var mcStatsListItem3 : W3StatsListItem;
		public var mcStatsListItem4 : W3StatsListItem;
		public var mcStatsListItem5 : W3StatsListItem;
		public var mcStatsListItem6 : W3StatsListItem;
		public var mcStatsListItem7 : W3StatsListItem;
		public var mcStatsListItem8 : W3StatsListItem;
		public var mcStatsListItem9 : W3StatsListItem;

		public var mcTextDescription : W3TextArea;
		
		public var bindingName : String = "tooltip";

		protected var _iconPath : String;
		protected var _itemCategory : String;
		protected var currentItemId:*;
		
		public function FloatingTooltip()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			mouseEnabled = mouseChildren = false; //#B to avoid flickering
			visible = false;
			focusable = false;

			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".name", [SetName]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".title", [SetTitle]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".stats", [handleTooltipStatsUpdate]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".price", [SetPrice]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".rarity", [SetRarity]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".durability", [SetDurability]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".weight", [SetWeight]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".icon", [SetIcon]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".category", [SetItemCategory]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".type", [SetItemType]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, bindingName + ".description", [SetDescription]));
			
			dispatchEvent( new GameEvent(GameEvent.CALL, 'OnTooltipLoaded'));
		}
		
		public function Initialize() : void
		{
			
		}
		
		[Inspectable(defaultValue="tooltip")]
		public function get BindingName() : String
		{
			return bindingName;
		}
		public function set BindingName( value:String ) : void
		{
			bindingName = value;
		}
		
		override public function toString() : String
		{
			return "[W3 Upgradepopup: ]";
		}
		
		public function SetName( value : String ) : void
		{
			tfItemName.htmlText = value;
		}

		public function SetTitle( value : String ) : void
		{
			if ( tfItemTitle )
			{
				tfItemTitle.htmlText = value;
			}
		}
		
		public function SetDescription( value : String) : void
		{
			var position:int = mcStatsList.dataProvider.length;
		
			//we currently have 9 mcStatsListItem mc's and the textfield is going to use one of them for x,y positioning
			if (position < 0 || position > mcStatsList.TotalRenderers)
			{
				trace("INVENTORY FloatingTooltip.as: position index out of bounds! Shadi Dadenji");
				mcTextDescription.textField.htmlText = "FloatingTooltip: position index out of bounds! Shadi Dadenji";
				return;
			}
			
			var mcRenderer:MovieClip = mcStatsList.getRendererAt(position) as MovieClip;
			
			//position the textfield at the next empty statsList Object (hence: nStatsSize + 1)
			mcTextDescription.x = mcRenderer.x;
			mcTextDescription.y = mcRenderer.y;
			mcTextDescription.textField.htmlText = value;
		}

		public function SetPrice( value : String ) : void
		{
			tfPriceValue.htmlText = value;
			
			if (value == "")
			{
				//item is priceless. hide the property
				if (mcPriceIcon)
					mcPriceIcon.visible = false;
			}
			else
			{
				if (mcPriceIcon)
					mcPriceIcon.visible = true;
			}
		}
	
		
		public function SetWeight( value : String ) : void
		{
			tfWeightValue.htmlText = value;
			
			if (value == "")
			{
				//item is weightless. hide the property and call Stephen Hawking
				if (mcWeightIcon)
					mcWeightIcon.visible = false;
			}
			else
			{
				if (mcWeightIcon)
					mcWeightIcon.visible = true;
			}
		}

		public function SetDurability( value : String ) : void
		{
			//need to change color of text dynamically based on range @SD
			tfDurabilityValue.htmlText = value + "%";
			
			if (value == "")
			{
				if (mcDurabilityIcon)
				{
					mcDurabilityIcon.visible = false;
					tfDurabilityValue.htmlText = "";
				}
			}
			else
			{
				if (mcDurabilityIcon)
					mcDurabilityIcon.visible = true;
			}
		}
		
		public function SetRarity( value : String ) : void
		{
			tfItemRarity.htmlText = value;
		}
		
		public function SetIcon( value : String ) : void
		{
			if ( mcIconLoader )
			{
				if (_iconPath != value || _iconPath == "" )
				{
					_iconPath = value;
					//trace("INVENTORY _iconPath "+_iconPath,"for",this.index);
					if (_iconPath != "" )
					{
						mcIconLoader.source = "img://" + _iconPath;
					}
					else
					{
						mcIconLoader.source = "";
					}
				}
			}
		}
		
		public function SetItemCategory( value : String ) : void
		{
			tfItemTitle.htmlText = value;
				
			if ( mcIconLoader )
			{
				_itemCategory = value;
				mcIconLoader.fallbackIconPath = GetDefaultFallbackIconFromType(_itemCategory);
			}
		}
		
		public function SetItemType( value : String ) : void
		{
			tfItemType.htmlText = value;
		}
		
		
		private function handleTooltipStatsUpdate( gameData:Object, index:int ):void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array
				mcStatsList.dataProvider = new DataProvider( dataArray );
				mcStatsList.invalidate();
				mcStatsList.validateNow();
				mcStatsList.ShowRenderers(true);
			}
		}
		
		protected function GetDefaultFallbackIconFromType( itemType : String ) : String
		{
			switch(itemType)
			{
				case "additional_alchemy_ingredient" :
					return "icons/inventory/Tw2_rune_earth.png";
				case "alchemy_recipe" :
					return "icons/inventory/candlemakersbill_64x64.dds";
				case "armor" :
					return "icons/inventory/armor-01.png";
				case "book" :
					return "icons/inventory/bookofdragons_64x64.dds";
				case "boots" :
					return "icons/inventory/boots-01.png";
				case "crafting_ingredient" :
					return "icons/inventory/Tw2_rune_moon.png";
				case "crafting_schematic" :
					return "icons/inventory/filippasnotes_64x64.dds";
				case "edibles" :
					return "icons/inventory/Tw2_ingredient_cortinarius.png";
				case "gloves" :
					return "icons/inventory/gauntlet-01.png";
				case "herb" :
					return "icons/inventory/Tw2_ingredient_balisse.png";
				case "junk" :
				case "misc" :
					return "icons/inventory/Tw2_trap_nekker_small.png";
				case "key" :
					return "icons/inventory/baltimoreskey_64x64.dds";
				case "oil" :
					return "icons/inventory/Tw2_oil_Brown.png";
				case "pants" :
					return "icons/inventory/trousers-01.png";
				case "petard" :
					return "icons/inventory/bomb-01.png";
				case "potion" :
					return "icons/inventory/gauntlet-01.png";
				case "trophy" :
					return "icons/inventory/trophy-01.png";
				case "steelsword" :
					return "icons/inventory/sword-01-B.png";
				case "silversword" :
					return "icons/inventory/sword-02-B.png";
				case "lure" :
					return "icons/inventory/Tw2_lure_trinket.png";
				case "trap" :
					return "icons/inventory/Tw2_trap_talgarwinter_small.png";
				case "bolt" :
					return "icons/inventory/crabspidershell_64x64.dds";
			}
			return "icons/inventory/raspberryjuice_64x64.dds";
		}
	}
}