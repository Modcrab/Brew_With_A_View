package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import red.game.witcher3.events.GridEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.ListEvent;
	import flash.events.Event;

	import red.game.witcher3.controls.W3UILoader;
	import red.core.CoreComponent;

	public class RecipeIconItemRenderer extends IconItemRenderer
	{
		public static const NoException:int = 0;
		
		public static const PINNED_EVENT:String = "PinChangedEvent";

		// Alchemy
		public static const MissingIngredient:int = 1;
		public static const NotEnoughIngredients:int = 2;
		public static const NoRecipe:int = 3;
		public static const CannotCookMore:int = 4;
		public static const CookNotAllowed:int = 5;

		// Schematics (#J different but too busy to take time to refactor at the moment)
		public static const ECE_TooLowCraftsmanLevel:int = 1;
		public static const ECE_MissingIngredient:int = 2;
		public static const ECE_TooFewIngredients:int = 3;
		public static const ECE_WrongCraftsmanType:int = 4;
		public static const ECE_NotEnoughMoney:int = 5;
		public static const ECE_UnknownSchematic:int = 6;
		public static const ECE_CookNotAllowed:int = 7;

		public var mcCraftingAnimation	: MovieClip;
		public var mcPinnedOverlay		: MovieClip;
		public var mcItemQuality		: MovieClip;
		public var txtGuide				: MovieClip;
		public var tfItemLevel			: TextField;
		
		protected static var _currentPinnedTag:uint;
		public static function setCurrentPinnedTag(stage:Stage, value:uint):void
		{
			_currentPinnedTag = value;
			stage.dispatchEvent(new Event(PINNED_EVENT));
		}

		public function RecipeIconItemRenderer()
		{
			super();
			skipTextCentering = false;
			canBePressed = false;
			
			if (mcPinnedOverlay)
			{
				mcPinnedOverlay.visible = false;
			}
		}

		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener(PINNED_EVENT, onPinnedRecipeChanged, false, 0, true);
		}

		override public function setData( data:Object ):void
		{
			super.setData(data);

			// #J If data is set while already selected, we need to send the tooltip manually as the normal selection logic that sends the tooltip won't be called (since it won't if theres no data set at the time of selection).
			if (selected)
			{
				fireShowTooltipEvent();
			}

			if (tfSecondLine)
			{
				
				if (data.cantCookReason )
				{
					tfSecondLine.htmlText = data.cantCookReason;
					//tfSecondLine.visible = data.cantCookReason != "";
					if ( CoreComponent.isArabicAligmentMode )
					{
						tfSecondLine.htmlText = "<p align=\"right\">" + data.cantCookReason+"</p>";
					}
				}
				else if ( data.canCookStatus == NoException )
				{
					if ( CoreComponent.isArabicAligmentMode )
					{
						var tempValue:String;
						tfSecondLine.text = "[[gui_panel_filter_has_ingredients]]";
						tempValue = tfSecondLine.text;
						tfSecondLine.htmlText = "<p align=\"right\">" + tempValue +"</p>";
					}
					else
					{
						tfSecondLine.htmlText = "[[gui_panel_filter_has_ingredients]]";
					}
				}
			}
			
			if (mcItemQuality)
			{
				mcItemQuality.gotoAndStop(data.rarity);
			}
			if (tfItemLevel)
			{
				if ( data && data.itemLevel )
				{
					tfItemLevel.visible = true;
					tfItemLevel.htmlText = data.itemLevel;
				}
				else
				{
					tfItemLevel.visible = false;
				}
			}
		
			updatePinnedIcon();
		}
		
		protected function onPinnedRecipeChanged(event:Event):void
		{
			updatePinnedIcon();
		}
		
		public function updatePinnedIcon():void
		{
			if (mcPinnedOverlay)
			{
				if (data && data.tag == RecipeIconItemRenderer._currentPinnedTag)
				{
					mcPinnedOverlay.visible = true;
				}
				else
				{
					mcPinnedOverlay.visible = false;
				}
			}
		}

		override protected function updateText():void
		{
			super.updateText();

            if (_label != null && textField != null)
			{
				if (data.isSchematic)
				{
					//
					updateTextColorSchematic();
				}
				else
				{
					updateTextColorRecipe();
				}
            }
			if (tfSecondLine)
			{
				if (tfSecondLine.text == "" && txtGuide)
				{
					textField.y = txtGuide.y + txtGuide.height / 2 - textField.textHeight / 2 ;
				
				}
				else
				{
					textField.y = 9;
				}
			}
			
        }

		protected function updateTextColorSchematic() : void
		{
			if (tfSecondLine)
			{
				if (data.canCookStatus == NoException)
				{
					tfSecondLine.textColor = 0x3FA524;//green
					if (selected)
					{
						//textField.textColor = 0x52C01D;
					}
					else
					{
						//textField.textColor = 0x3FA524;
					}
				}
				else if (data.canCookStatus == ECE_TooLowCraftsmanLevel || data.canCookStatus == ECE_WrongCraftsmanType || data.canCookStatus == ECE_UnknownSchematic)
				{
					tfSecondLine.textColor = 0x666666;//gray
				}
				else
				{
					tfSecondLine.textColor = 0xDD0000;//red
				}
			}
		}
		
	

		protected function updateTextColorRecipe() : void
		{
			if (tfSecondLine)
			{
				if (data.canCookStatus == NoException)
				{
					tfSecondLine.textColor = 0x3FA524;//green
					/*
					if (selected)
					{
						textField.textColor = 0x52C01D;
					}
					else
					{
						textField.textColor = 0x3FA524;
					}
					*/
				}
				else if (data.canCookStatus == CannotCookMore)
				{
					tfSecondLine.textColor = 0x666666;//gray
				}
				else
				{
					tfSecondLine.textColor = 0xDD0000;//red
				}
			}
		}

		override public function handleEntryPress() : void
		{
			// #J Override to remove base class behavior
		}

		override public function handleInput(event:InputEvent):void
		{
			// #J Override to remove base class behavior
		}

		public function fireShowTooltipEvent():void
		{
			var displayEvent:GridEvent;
			displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, null);
			displayEvent.tooltipContentRef = "ItemTooltipRef";
			displayEvent.tooltipDataSource = "OnShowCraftedItemTooltip";
			displayEvent.tooltipCustomArgs = [ data.tag ];
			dispatchEvent(displayEvent);
		}
	}

}
