package red.game.witcher3.hud.modules.lootpopup
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.menus.common.ColorSprite;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.controls.BaseListItem;

	public class HudLootItemsListItem extends BaseListItem
	{

	//{region Private variables
	// ------------------------------------------------

	private var bTakeAllItem : Boolean = false;

	//{region Private constants
	// ------------------------------------------------
	private static const TEXT_PADDING:Number = 4;
	private static const READ_BOOK_ALPHA:Number = .3;

	//{region Art clips
	// ------------------------------------------------

	public var tfType : TextField;
	public var tfQuantity : TextField;
	public var mcFrame : MovieClip;
	public var mcIconLoader : W3UILoader;
	public var mcColorBackground : ColorSprite;
	public var genStatsList : RenderersList;
	
	public var mcQuestIndicator : MovieClip;

	//{region Initialization
	// ------------------------------------------------

		public function HudLootItemsListItem()
		{
			super();
			tfType.text = "";
			tfQuantity.text = "";
			textField.text = "";
		}

	//{region Overrides
	// ------------------------------------------------

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.

		}

		override protected function configUI():void
		{
			super.configUI();
		}

		public function setStateOver()
		{
			this.setState("over");
		}

		override public function setData( data:Object ):void
		{
			if (data)
			{
				if ( data.label && data.label != "" )
				{
					super.setData( data );
				}
				if ( data.quantity && tfQuantity && data.quantity > 1 )
				{
					tfQuantity.text = "x" + data.quantity;
				}
				else
				{
					tfQuantity.text = "";
				}
				if( data.iconPath && mcIconLoader )
				{
					if ( data.iconPath != "" )
					{
						mcIconLoader.source = "img://" + data.iconPath;
					}
					else
					{
						mcIconLoader.source = "";
					}
				}
				if (mcIconLoader)
				{
					mcIconLoader.alpha = data.isRead ? READ_BOOK_ALPHA : 1;
				}
				if (mcQuestIndicator)
				{
					if (data.isQuestItem)
					{
						mcQuestIndicator.visible = true;
						mcQuestIndicator.gotoAndStop(data.questTag);
					}
					else
					{
						mcQuestIndicator.visible = false;
					}
				}
				if (mcColorBackground && data.quality)
				{
					mcColorBackground.visible = true;
					mcColorBackground.colorBlind = CoreComponent.isColorBlindMode;
					mcColorBackground.setByItemQuality(_data.quality);
				}
				else
				{
					mcColorBackground.visible = false;
				}
				if (genStatsList && data.genericStats)
				{
					genStatsList.dataList = data.genericStats;
					genStatsList.validateNow();
				}
				
				updateTypeText();
			}
			else
			{
				visible = false;
			}
		}
		
		override protected function updateText():void
		{
			const SINGLE_LINE_TF1 = 30;
			const SINGLE_LINE_TF2 = 47;
			const DOUBLE_LINE_TF1 = 17;
			const DOUBLE_LINE_TF1_LARGE = 6;
			const DOUBLE_LINE_TF2 = 53;
			const DOUBLE_LINE_TF2_LARGE = 58;
			const ARAB_TEXT_LIMIT = 34;
			const NO_TYPE		  = 30;
			
			super.updateText();
			updateTypeText();
			
			textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			// #Y textField.numLines returns incorrect value for arabic :E
			if ((textField.numLines > 1 && !CoreComponent.isArabicAligmentMode) || (CoreComponent.isArabicAligmentMode && textField.height > ARAB_TEXT_LIMIT))
			{
				textField.y = DOUBLE_LINE_TF1_LARGE;
				tfType.y = DOUBLE_LINE_TF2_LARGE;
			}
			else
			{
				if (data && data.itemType)
				{
					textField.y = DOUBLE_LINE_TF1;
					tfType.y = SINGLE_LINE_TF2;
				}
				else
				{
					textField.y = SINGLE_LINE_TF1;
					tfType.y = SINGLE_LINE_TF2;
				}
			}
		}
		
		protected function updateTypeText():void
		{
			if (data && data.itemType)
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					tfType.htmlText = "<p align=\"right\">" + data.itemType + "</p>";
				}
				else
				{
					tfType.htmlText = data.itemType;
				}
			}
			else
			{
				tfType.htmlText = "";
			}
		}

	}
}
