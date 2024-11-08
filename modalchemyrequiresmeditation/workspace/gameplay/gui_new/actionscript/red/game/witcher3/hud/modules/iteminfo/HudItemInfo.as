package red.game.witcher3.hud.modules.iteminfo
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.managers.InputDelegate;

	public class HudItemInfo extends UIComponent
	{
		public var mcIconLoader:W3UILoader;
		public var textField : TextField;
		public var tfAmmo : TextField;
		public var mcButton : InputFeedbackButton;
		public var mcError:MovieClip;
		public var mcTextBackground:MovieClip;
		public var mcDefaultIcon:MovieClip;
		//public var mcAmmoBackground: MovieClip;
		
		private var _IconName : String;
		private var _ItemCategory : String;
		public var defaultIconName : String = "potion1";
		private var _initialBackgroundWidth : Number;
		private var _minimalSize : Number = 0;		

		public function HudItemInfo()
		{
			super();
			
			if (mcButton)
			{
				mcButton.visible = false;
				mcButton.clickable = false;
			}
		}

		override protected function configUI():void
		{
			super.configUI();
			
			if (mcTextBackground)
			{
				_initialBackgroundWidth = mcTextBackground.width;
			}
			if (mcDefaultIcon)
			{
				mcDefaultIcon.gotoAndStop(defaultIconName);
			}
			ItemAmmo = "";
		}

		[Inspectable(type = "Number", defaultValue = "0")]
		public function get minimalSize( ) : Number
		{
			return _minimalSize;
		}
		public function set minimalSize( value : Number ) : void
		{
			_minimalSize = value;
		}
		
		protected var _showButtonHint:Boolean = false;
		public function get showButtonHint():Boolean { return _showButtonHint }
		public function set showButtonHint(value:Boolean):void
		{
			_showButtonHint = value;
			mcButton.visible = _showButtonHint;
		}
		
		override public function toString() : String
		{
			return this.name;
		}

		private function updateIcon():void
		{
			if ( _IconName && _IconName != ""  && _IconName != "icons/items/None_64x64.dds"  )
			{
				if (mcIconLoader) { mcIconLoader.source =  "img://" + _IconName; }
				if (mcTextBackground) { mcTextBackground.visible = true; }
				if (mcDefaultIcon) { mcDefaultIcon.visible = false; }
				//this.visible = true;
			}
			else
			{
				if (mcIconLoader) { mcIconLoader.source = ""; }
				if (mcTextBackground) { mcTextBackground.visible = false; }
				if (mcDefaultIcon) { mcDefaultIcon.visible = true; }
				//this.visible = false;
			}
		}

		public function get IconName( ) : String { return _IconName}
		public function set IconName( val : String ) : void
		{
			if ( _IconName != val )
			{
				_IconName = val;
				updateIcon();
			}
		}

		public function set ItemName( val : String ) : void
		{
			textField.htmlText = val;
			//var sizeX : Number = textField.textWidth + textField.x; // 320 is maximal
			//mcTextBackground.x = Math.max( Math.min( sizeX - mcTextBackground.width + 24, _initialBackgroundX), _minimalSize - mcTextBackground.width + _initialBackgroundX - 24) + 12;
			if (mcTextBackground)
			{
				//mcTextBackground.width = Math.max( textField.textWidth + 52 , _minimalSize);
				mcTextBackground.width = mcTextBackground.x - textField.x + textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			}
		}

		public function set ItemAmmo( val : String ) : void
		{
			tfAmmo.htmlText = val;
			
		}

		public function set ItemCategory( val : String ) : void
		{
			if ( _ItemCategory != val )
			{
				_ItemCategory = val;
				mcIconLoader.fallbackIconPath = GetDefaultFallbackIconFromType(_ItemCategory);
			}
		}

		public function setItemButtons( btn : int, pcBtn ) : void
		{
			var inputDelegate : InputDelegate;
			var keyName : String;

			inputDelegate = InputDelegate.getInstance();
			switch( btn )
			{
				case -10 : // #B double dpad hax
					keyName = "double_dpad_up";
					break;
				case 0 :
					mcButton.visible = false;
					return;
				default :
					keyName = inputDelegate.inputToNav( "key", btn );
			}
			
			mcButton.visible = showButtonHint;
			mcButton.clickable = false;
			mcButton.setDataFromStage(keyName, pcBtn);
			mcButton.validateNow();
			mcButton.x = mcIconLoader.x - mcButton.getViewWidth();
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
				case "crossbow":
					return "icons/inventory/crabspidershell_64x64.dds";
			}
			return "icons/inventory/raspberryjuice_64x64.dds";
		}

	}
}
