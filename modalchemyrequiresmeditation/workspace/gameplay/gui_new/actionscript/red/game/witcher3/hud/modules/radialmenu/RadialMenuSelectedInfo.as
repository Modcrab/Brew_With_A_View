package red.game.witcher3.hud.modules.radialmenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;

	public class RadialMenuSelectedInfo extends UIComponent
	{
		public var textField : TextField;
		public var tfFieldDescription : TextField;
		public var tfDescription : TextField;
		//public var mcBckArrow:MovieClip;
		private var _IconName : String;

		public var mcIcon			: MovieClip;
		private var _iconPath		: String = "";
		private var _itemName		: String = "";
		private var bItemField 		: Boolean = false;

		public function RadialMenuSelectedInfo()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent(new GameEvent(GameEvent.REGISTER,this.name+".decription",[SetItemDescription]));
		}

		override public function toString() : String
		{
			return this.name;
		}


		public function SetIcon( iconPath : String, itemName : String, itemCategory : String ):void
		{
			trace("HUD_RADIAL "+this.name+" iconPath "+iconPath+" bItemField "+bItemField);
			if (mcIcon)
			{
				if ( bItemField )
				{
					mcIcon.gotoAndStop("Slot1"); // #B doesn't matter with item is it, it need only iconLoader
					mcIcon.mcLoader.fallbackIconPath = "img://" + GetDefaultFallbackIconFromType(itemCategory);
					mcIcon.mcLoader.source = "img://" + iconPath;
					tfFieldDescription.htmlText = "[[panel_hud_radaialmenu_equipped]]";
					tfFieldDescription.htmlText = CommonUtils.toUpperCaseSafe(tfFieldDescription.htmlText);
				}
				else
				{
					mcIcon.gotoAndStop(iconPath);
					tfFieldDescription.htmlText = "[[panel_hud_radaialmenu_activesign]]";
					tfFieldDescription.htmlText = CommonUtils.toUpperCaseSafe(tfFieldDescription.htmlText);
				}

				_iconPath = iconPath;
				ItemName = itemName;
			}
		}

		public function set IconName( val : String ) : void
		{
			if ( _IconName != val )
			{
				_IconName = val;
			}
		}

		public function set ItemName( val : String ) : void
		{
			textField.htmlText = CommonUtils.toUpperCaseSafe(val);
		}

		public function SetItemDescription( val : String ) : void
		{
			tfDescription.htmlText = val;
		}

		public function IsItemField() : Boolean
		{
			return bItemField;
		}

		public function SetAsItemField( value : Boolean ) : void
		{
			bItemField = value;
			if ( value )
			{}
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
				case "crossbow" :
					return "icons/inventory/crabspidershell_64x64.dds";
			}
			return "icons/inventory/raspberryjuice_64x64.dds";
		}

	}
}