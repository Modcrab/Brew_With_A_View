/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.modules
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.tooltips.TooltipPrimaryStat;
	import scaleform.gfx.Extensions;
	import red.core.CoreComponent;
	import red.game.witcher3.utils.CommonUtils;

	public class ItemTooltipModule extends CoreMenuModule
	{
		protected static const PRIM_BLOCK_PADDING:Number = 10;
		protected static const LIST_BLOCK_PADDING:Number = 12;
		protected static const LEVEL_BLOCK_PADDING:Number = 10;
		protected static const WEIGHT_BLOCK_PADDING:Number = 15;
		protected static const STATS_BLOCK_PADDING:Number = 8;
		protected static const HEADER_DESCR_PADDING:Number = 20;
		
		protected static const BLOCK_PADDING:Number = 8;
		protected static const BLOCK_PADDING_SMALL:Number = 3;
		
		protected static const DESCRIPTION_PADDING:Number = 8;
		protected static const DELIMITER_PADDING:Number = 9;
		protected static const ICON_PADDING:Number = 0;
		public var moduleMerchantInfo: MovieClip;
		
		protected var _tooltipInfoDataProvider:String = CommonConstants.INVALID_STRING_PARAM;
		[Inspectable(defaultValue=CommonConstants.INVALID_STRING_PARAM)]
		public function get tooltipInfoDataProvider():String { return _tooltipInfoDataProvider; }
		public function set tooltipInfoDataProvider(value:String):void
		{
			_tooltipInfoDataProvider = value;
		}
		
		public var mcHeaderColor		: MovieClip;
		public var txtItemName			: TextField;
		public var txtItemDescription	: TextField;
		public var txtItemRarity		: TextField;
		public var txtItemType			: TextField;
		
		public var txtCraftsmanReqirementsLabel	:TextField;
		public var txtCraftsmanReqirementsValue	:TextField;
		public var txtReqirementsLabel			:TextField;
		
		public var mcWeightIcon	: MovieClip;
		public var txtWeight	: TextField;
		
		public var mcSocketsIcon : MovieClip;
		public var txtSockets	 : TextField;
		
		public var tfSetBonusDescription : TextField;
		public var tfSetBonusDescription2 : TextField;
		public var mcSetBonusDescription : MovieClip;
		
		public var mcSetAttributeList : RenderersList;
		public var mcAttributesList	  : RenderersList;
		public var mcPrimaryStat	  : TooltipPrimaryStat;
		
		
		private var _textValue : String;
		
		public function ItemTooltipModule()
		{
			mcAttributesList.alignment = TextFormatAlign.RIGHT;
			
			if (mcSetAttributeList)
			{
				mcSetAttributeList.itemPadding = 0;
				//mcSetAttributeList.isHorizontal = true;
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return false;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (_tooltipInfoDataProvider != CommonConstants.INVALID_STRING_PARAM)
			{
				dispatchEvent( new GameEvent(GameEvent.REGISTER, _tooltipInfoDataProvider, [setTooltipInfo]));
			}
			
			active = false;
		}
		
		public function setItemColorQuality(value : int)
		{
			if (mcHeaderColor)
			{
				if (!isNaN(value) && value != 0)
				{
					mcHeaderColor.gotoAndStop(value);
				}
				else
				{
					mcHeaderColor.gotoAndStop(1);
				}
				
			}
		}
		protected function setTooltipInfo(data:Object):void
		{
			// #J Normally i'd check if variables are assigned (!= null), but truth is this logic assumes they are all there, so not doing this here
			
			if (!data)
			{
				trace("GFX ERROR undefined item's data");
				this.visible = false;
				return;
			}
			
			if ( tfSetBonusDescription && tfSetBonusDescription2 )
			{
				const padding_SetBonusDescription = 5;
				const padding_SetBonusBackground = 20;
				
				if ( data.SetBonusDescription )
				{
					_textValue = data.SetBonusDescription;
					if (CoreComponent.isArabicAligmentMode)
					{
						tfSetBonusDescription.htmlText = "<p align=\"right\">" + _textValue + "</p>";

					}
					else
					{
						tfSetBonusDescription.htmlText = data.SetBonusDescription;
					}
					tfSetBonusDescription.height =  tfSetBonusDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;

					_textValue = data.SetBonusDescription2;
					if (CoreComponent.isArabicAligmentMode)
					{
						tfSetBonusDescription2.htmlText = "<p align=\"right\">" + _textValue + "</p>";

					}
					else
					{
						tfSetBonusDescription2.htmlText = data.SetBonusDescription2;
					}

					tfSetBonusDescription2.height =  tfSetBonusDescription2.textHeight + CommonConstants.SAFE_TEXT_PADDING;
					tfSetBonusDescription2.y = tfSetBonusDescription.y + tfSetBonusDescription.height + padding_SetBonusDescription ;
					
					
					mcSetBonusDescription.height = tfSetBonusDescription.height + tfSetBonusDescription2.height + padding_SetBonusBackground;
					
					tfSetBonusDescription.visible = true;
					tfSetBonusDescription2.visible = true;
					mcSetBonusDescription.visible = true;
				}
				else
				{
					tfSetBonusDescription.visible = false;
					tfSetBonusDescription2.visible = false;
					mcSetBonusDescription.visible = false;
				}
			}

			
			var curY:Number;
			
			if (moduleMerchantInfo && moduleMerchantInfo.visible == true)
			{
				curY = moduleMerchantInfo.y + moduleMerchantInfo.height;
				mcHeaderColor.y = curY;
				curY +=  BLOCK_PADDING;
			}
			else
			{
				curY = mcHeaderColor.y;
				curY +=  BLOCK_PADDING;
			}
			
			active = true;
			//Merchant info
			
			// Title
			_textValue = data.itemName;
			if (CoreComponent.isArabicAligmentMode)
			{
				txtItemName.htmlText = "<p align=\"right\">" + _textValue + "</p>";
			}
			else
			{
				txtItemName.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
				
			}
			
			txtItemName.y = curY;
			txtItemName.height = txtItemName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			curY += txtItemName.textHeight + BLOCK_PADDING;
			
			// Type
			if (data.type != "")
			{
				txtItemType.visible = true;
				txtItemType.htmlText = addArabicWrapper(data.type);
				txtItemType.htmlText = txtItemType.htmlText.toUpperCase();
				txtItemType.y = curY;
				curY += txtItemType.textHeight + BLOCK_PADDING;
			}
			else
			{
				txtItemType.visible = false;
			}
			
			// Primary stat block
			if (mcPrimaryStat)
			{
				if (data.PrimaryStatValue > 0)
				{
					mcPrimaryStat.y = curY;
					mcPrimaryStat.setValue(data.PrimaryStatValue, data.PrimaryStatLabel, data.PrimaryStatDiff, data.PrimaryStatDelta, data.PrimaryStatDiffStr);
					curY += (mcPrimaryStat.actualHeight - PRIM_BLOCK_PADDING);
					mcPrimaryStat.visible = true;
					
				if (CoreComponent.isArabicAligmentMode)
				{
					mcPrimaryStat.x = 490 - mcPrimaryStat.actualWidth;
				}
					curY += BLOCK_PADDING;
				}
				else
				{
					mcPrimaryStat.visible = false;
				}
			}
			
			//Header
			if (mcPrimaryStat.visible)
			{
				mcHeaderColor.height = txtItemName.textHeight + txtItemType.textHeight + mcPrimaryStat.actualHeight  + HEADER_DESCR_PADDING;
			}
			else
			{
				mcHeaderColor.height = txtItemName.textHeight + txtItemType.textHeight + HEADER_DESCR_PADDING + BLOCK_PADDING;
			}
			
			curY = mcHeaderColor.y + mcHeaderColor.height + DESCRIPTION_PADDING;
			
			// Description
			if (data.itemDescription != "")
			{
				//curY += DESCRIPTION_PADDING ;
				txtItemDescription.y = curY;
				txtItemDescription.visible = true;
				txtItemDescription.htmlText = addArabicWrapper(data.itemDescription);
				txtItemDescription.height = txtItemDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				curY += ( txtItemDescription.height + DESCRIPTION_PADDING );
			}
			else
			{
				txtItemDescription.visible = false;
				
			}
			
			curY += BLOCK_PADDING;
			
			// Attributes /as gfx /
			if (mcAttributesList)
			{
				var attributesListData:Array = data.attributesList as Array;
				if (attributesListData && attributesListData.length > 0)
				{
					mcAttributesList.y = curY;
					mcAttributesList.visible = true;
					mcAttributesList.dataList = data.attributesList;
					mcAttributesList.validateNow();
					curY += ( mcAttributesList.actualHeight - LIST_BLOCK_PADDING);
				}
				else
				{
					mcAttributesList.visible = false;
				}
			}
			
			var isWeightOrSocketInfoExist:Boolean = false;
			
			// Rarity
			if (data.rarity != "")
			{
				curY += BLOCK_PADDING_SMALL;
				
				txtItemRarity.visible = true;
				txtItemRarity.htmlText = addArabicWrapper(data.rarity);
				txtItemRarity.htmlText = txtItemRarity.htmlText.toUpperCase();
				txtItemRarity.y = curY;
				curY += (txtItemRarity.textHeight + BLOCK_PADDING);
			}
			else
			{
				curY += BLOCK_PADDING;
				txtItemRarity.visible = false;
			}
			
			// Weight
			if (txtWeight && mcWeightIcon)
			{
				if (data.weight != "" && data.weight)
				{
					txtWeight.visible = true;
					mcWeightIcon.visible = true;
					_textValue = data.weight;
					if (CoreComponent.isArabicAligmentMode)
					{
						txtWeight.htmlText = "<p align=\"right\">" + _textValue + "</p>";
						mcWeightIcon.x = 468;
						txtWeight.x = mcWeightIcon.x - txtWeight.width - mcWeightIcon.width/2;
						//MOVE THE SOCKET GRAPHIC
					}
					else
					{
						txtWeight.htmlText = _textValue;
					}
					
					txtWeight.y = curY +  ICON_PADDING;
					mcWeightIcon.y = curY;
					
					curY += (mcWeightIcon.height + WEIGHT_BLOCK_PADDING);
					
					isWeightOrSocketInfoExist = true;
				}
				else
				{
					mcWeightIcon.visible = false;
					txtWeight.visible = false;
				}
			}
			
			// Sockets
			if (txtSockets && mcSocketsIcon)
			{
				if (data.enhancementSlots)
				{
					_textValue = data.enhancementSlots;
					
					if (CoreComponent.isArabicAligmentMode)
					{
						txtSockets.htmlText = "<p align=\"right\">" + _textValue + "</p>";
						mcSocketsIcon.x = 475.2;
						txtSockets.x = mcSocketsIcon.x - txtSockets.width - mcSocketsIcon.width;
						//MOVE THE SOCKET GRAPHIC
					}
					else
					{
						txtSockets.htmlText = _textValue;
					}
					txtSockets.visible = true;
					mcSocketsIcon.visible = true;
					
					txtSockets.y = curY +  ICON_PADDING;
					mcSocketsIcon.y = curY;
					
					curY += (mcSocketsIcon.height + WEIGHT_BLOCK_PADDING);
					isWeightOrSocketInfoExist = true;
				}
				else
				{
					txtSockets.visible = false;
					mcSocketsIcon.visible = false;
				}
			}
			
			//isWeightOrSocketInfoExist = false; // TEMP, remove after socketsCount implementation
			
			if (isWeightOrSocketInfoExist)
			{
				curY += DELIMITER_PADDING;
			}
	
			
			if (txtReqirementsLabel)
			{
				if (data.requiredLevel)
				{
					txtReqirementsLabel.y = curY;
					_textValue = data.requiredLevel;
					if (CoreComponent.isArabicAligmentMode)
					{
						txtReqirementsLabel.htmlText = "<p align=\"right\">" + _textValue + "</p>";
					}
					else
					{
						txtReqirementsLabel.htmlText = _textValue;
					}
					
					txtReqirementsLabel.visible = true;
					curY += (txtReqirementsLabel.textHeight + LEVEL_BLOCK_PADDING);

				}
				else
				{
					txtReqirementsLabel.visible = false;
				}
			}
		
			
			if (txtCraftsmanReqirementsLabel)
			{
				txtCraftsmanReqirementsLabel.text = "[[panel_shop_crating_required_crafter]]";
				_textValue = txtCraftsmanReqirementsLabel.text;
				
				if (CoreComponent.isArabicAligmentMode)
				{
					txtCraftsmanReqirementsLabel.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				else
				{
					txtCraftsmanReqirementsLabel.htmlText = _textValue;
				}
				
				txtCraftsmanReqirementsLabel.y = curY;
				curY += txtCraftsmanReqirementsLabel.textHeight + BLOCK_PADDING_SMALL;
			}
			
			if (txtCraftsmanReqirementsValue)
			{
				txtCraftsmanReqirementsValue.y = curY;
				_textValue = data.crafterRequirements;
				if (CoreComponent.isArabicAligmentMode)
				{
					txtCraftsmanReqirementsValue.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				else
				{
					txtCraftsmanReqirementsValue.htmlText = _textValue;
				}
				
				curY += txtCraftsmanReqirementsValue.textHeight;

			}
			
			
		}
		
		private function addArabicWrapper(value:String):String
		{
			if ( CoreComponent.isArabicAligmentMode )
			{
				return "<p align=\"right\">" + value + "</p>";
			}
			else
			{
				return value;
			}
		}
		
	}
}
