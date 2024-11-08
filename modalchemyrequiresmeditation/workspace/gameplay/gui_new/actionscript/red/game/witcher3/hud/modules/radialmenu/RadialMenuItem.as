/***********************************************************************/
/** Action Script file
/***********************************************************************/
/** Copyright © 2012 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.modules.radialmenu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.core.UIComponent
	import scaleform.clik.controls.UILoader;
	import flash.display.MovieClip;
	import red.game.witcher3.utils.motion.TweenEx;
	import flash.filters.ColorMatrixFilter;
	import red.game.witcher3.utils.CommonUtils;

	public class RadialMenuItem extends UIComponent
	{		
		public var mcIcon			: MovieClip;
		//public var mcButton			: InputFeedbackButton;

		protected var _iconPath				: String = "";
		protected var _itemName				: String = "";
		protected var _itemCategory			: String = "";
		protected var _itemDescription		: String = "";
		protected var _radialName			: String = "";
		protected var _isDesaturated		: Boolean = false;
		protected var bItemField 			: Boolean = false;
		
		public  var tfSignLabel				: TextField;
		public  var tfItemName				: TextField;
		public 	var mcSelection				: MovieClip;
		public  var mcItemQuality			: MovieClip;
		
		
		protected var _isSelected:Boolean;
		protected var _glowFilter:GlowFilter;
		protected static const OVER_GLOW_COLOR:Number = 0xaf9b70;
		protected static const OVER_GLOW_BLUR:Number = 20;
		protected static const OVER_GLOW_STRENGHT:Number = .75;
		protected static const OVER_GLOW_ALPHA:Number = .6;
		
		public function RadialMenuItem()
		{
			super();
			
			if (mcSelection)
			{
				mcSelection.visible = false;
			}
			
			_isSelected = false;
		}

		protected override function configUI():void
		{
			super.configUI();
			
		}

		private function updateIcon():void
		{
			if (mcIcon)
			{
				mcIcon.gotoAndStop(_radialName);
			}
		}

		public function setRadialItemName(value : String):void
		{
			_radialName = value;
			updateIcon();
			setSignLabel();
		}
		
		
		var otherTextFormat: TextFormat;
		var lTextFormat : TextFormat;
		private function setSignLabel():void
		{
			const ICON_Y_CENTER = 0;
			const ICON_Y_TOP = -14.5;
			const ICON_Y_OFFSET = -26;
			const TF_Y_OFFSET = -6.85;
			const TF_Y_TOP = 11.35;
			
			lTextFormat = new TextFormat("$NormalFont", 21);
			otherTextFormat = new TextFormat("$NormalFont", 17);
			
			lTextFormat.align = TextFormatAlign.CENTER;
			lTextFormat.font = "$NormalFont";
			otherTextFormat.align = TextFormatAlign.CENTER;
			otherTextFormat.font = "$NormalFont";
			otherTextFormat.color = 0xFFFFFF;
			
			if ( tfSignLabel )
			{
				trace("GFX >>>>>>>>>>>>>>CoreComponent._gameLanguage>>>>>>>> " +  CoreComponent._gameLanguage );
				tfSignLabel.htmlText =  "[[" + _radialName + "]]";
				tfSignLabel.htmlText = CommonUtils.toUpperCaseSafe( tfSignLabel.htmlText );
				if ( CoreComponent._gameLanguage == "JP" || CoreComponent._gameLanguage == "KR" || CoreComponent._gameLanguage == "ZH"  || CoreComponent._gameLanguage == "AR")
				{
					//tfSignLabel.text = "";
					mcIcon.y = ICON_Y_OFFSET;
					mcIcon.scaleX = mcIcon.scaleY = 0.7;
					tfSignLabel.y = TF_Y_OFFSET;
					tfSignLabel.embedFonts = true;
					tfSignLabel.defaultTextFormat = otherTextFormat;
					tfSignLabel.setTextFormat(otherTextFormat);
				}
				else
				{
					mcIcon.y = ICON_Y_TOP;
					mcIcon.scaleX = mcIcon.scaleY = 1;
					tfSignLabel.y = TF_Y_TOP;
					tfSignLabel.embedFonts = true;
					tfSignLabel.defaultTextFormat = lTextFormat;
					tfSignLabel.setTextFormat(lTextFormat);
				}
				
			}
		}
		
		public function getIsSelected():Boolean
		{
			return _isSelected;
		}
		
		public function setItemName():void
		{
			if ( tfItemName )
			{
				tfItemName.htmlText = _itemName;
				//tfItemName.htmlText = CommonUtils.toUpperCaseSafe(tfItemName.htmlText);
			}
		}
		
		public function getRadialItemName() : String
		{
			return _radialName;
		}
		
		public function SetSelected():void
		{
			if (mcSelection)
			{
				// #Y tmp test tween
				GTweener.removeTweens( mcSelection );
				GTweener.to( mcSelection, .5, { scaleX:1, scaleY:1, alpha:1 }, { ease:Exponential.easeOut }  );
				
				mcSelection.visible = true;
			}
			
			_isSelected = true;
		}
		
		public function SetDeselected():void
		{
			if (mcSelection)
			{
				// #Y tmp test tween
				GTweener.removeTweens( mcSelection );
				GTweener.to( mcSelection, .5, { scaleX:1.1, scaleY:1.1, alpha:0 }, { ease:Exponential.easeOut }  );
				
				//mcSelection.visible = false;
			}
			
			_isSelected = false;
		}
		
		private function handleHidden(gt:GTween):void
		{
			mcSelection.visible = false;
			mcSelection.alpha = 1;
			
			if (mcSelection)
			{
				mcSelection.scaleX = mcSelection.scaleY = 1.1;
			}
		}
		
		protected const DESATURATION_DELAY:Number = 1;
		private var _desaturationDelayTimer:Timer;
		
		public function SetDesatureted( value : Boolean ):void
		{
			_isDesaturated = value;
			removeDesaturationTimer();
			
			if ( value )
			{
				_desaturationDelayTimer = new Timer(DESATURATION_DELAY);
				_desaturationDelayTimer.addEventListener(TimerEvent.TIMER, applyDesaturationFilter, false, 0, true);
				_desaturationDelayTimer.start();
			}
			else
			{
				//mcIcon.filters = [];
				filters = [];
			}
		}
		
		protected function removeDesaturationTimer():void
		{
			if (_desaturationDelayTimer)
			{
				_desaturationDelayTimer.removeEventListener(TimerEvent.TIMER, applyDesaturationFilter, false);
				_desaturationDelayTimer.stop();
				_desaturationDelayTimer = null;
			}
		}
		
		protected function applyDesaturationFilter( timerEvent : Event = null ):void
		{
			var desFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
			//mcIcon.filters = [desFilter];
			filters = [desFilter];
			removeDesaturationTimer();
		}
		
		public function IsDesatureted( ): Boolean // WS
		{
			return _isDesaturated;
		}
		
		public function SetIcon( iconPath : String, itemName : String, itemCategory : String, itemDescription : String , itemQuality : int):void // WS
		{
			if (mcIcon)
			{
				var curLoader:W3UILoader;
				var filterArray:Array = [];
				
				_glowFilter = new GlowFilter(OVER_GLOW_COLOR, OVER_GLOW_ALPHA, OVER_GLOW_BLUR, OVER_GLOW_BLUR, OVER_GLOW_STRENGHT, BitmapFilterQuality.HIGH);
				filterArray.push(_glowFilter);
	
				if ( itemCategory != "crossbow" )
				{
					mcIcon.gotoAndStop("iconLoader");
					curLoader = mcIcon.mcLoader;
					
				}
				else
				{
					mcIcon.gotoAndStop("iconLoaderLarge");
					curLoader = mcIcon.mcLoaderLarge;
				}
				
				if ( mcItemQuality )
				{
					mcItemQuality.gotoAndStop ( itemQuality );
				}
				
				curLoader.fallbackIconPath = "img://" + GetDefaultFallbackIconFromType(itemCategory);
				
				if ( iconPath != "" )
				{
					curLoader.source = "img://" + iconPath;
				}
				else
				{
					curLoader.source = "";
				}
				
				curLoader.filters = filterArray;
			}
			
			_iconPath = iconPath;
			_itemName = itemName;
			_itemCategory = itemCategory;
			_itemDescription = itemDescription;
			bItemField = true;
			
			setItemName();
		}

		public function GetIconPath() : String
		{
			return _iconPath;
		}

		public function GetItemName() : String
		{
			if (!IsItemField())
			{
				return _radialName; // #B shuld be localized name for signs :)
			}
			return _itemName;
		}

		public function GetItemCategory() : String
		{
			return _itemCategory;
		}

		public function GetItemDescription() : String
		{
			if (IsItemField())
			{
				return _itemDescription;
			}
			else
			{
				return "[[" + _radialName + "_description]]";
			}
		}

		public function IsItemField() : Boolean
		{
			return bItemField;
		}

		public function SetAsItemField( value : Boolean ) : void
		{
			bItemField = value;
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
			return "";
		}
	}
}
