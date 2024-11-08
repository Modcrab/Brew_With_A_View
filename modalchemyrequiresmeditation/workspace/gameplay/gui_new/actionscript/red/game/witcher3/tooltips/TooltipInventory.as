package red.game.witcher3.tooltips
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	/**
	 * Tooltip for inventory item
	 * Control scheme [GAMEPAD]
	 * Used in InventoryMenu and RepairMenu
	 * red.game.witcher3.tooltips.TooltipInventory
	 * @author Yaroslav Getsevich
	 */
	public class TooltipInventory extends TooltipBase
	{
		public static var ingnoreSafeRect:Boolean = false;
		
		protected const BACKGROUND_PADDING:Number = 5;
		protected const SOCKETS_BLOCK_PADDING:Number = 0;
		protected const EQUIPPED_TOOLTIP_PADDING_X:Number = 15;
		protected const EQUIPPED_TOOLTIP_PADDING_Y:Number = 40;
		protected const LIST_OFFSET:Number = 10;
		protected const ENCHANT_ICON_PADDING:Number = -4;
		protected const BLOCK_PADDING:Number = 5;
		protected const AR_BLOCK_PADDING:Number = 35;
		protected const LIST_PADDING:Number = 15;
		protected const BOTTOM_SMALL_PADDING:Number = 2;
	
		
		protected const CONTENT_RIGHT_EDGE_POS:Number = 470;
		
		public var tfEquippedTitle:TextField;
		public var tfItemName:TextField;
		public var tfItemRarity:TextField;
		public var tfItemType:TextField;
		public var tfDescription:TextField;
		public var tfRequiredLevel:TextField;
		public var tfWarningMessage:TextField;
		public var tfEnchantmentInfo:TextField;
		public var tfEnchantedName:TextField;
		public var tfCharges:TextField;
		public var tfSetCounter:TextField;
		
		public var mcAttributeList:RenderersList; // damage, crit chance, etc
		public var mcPropertyList:RenderersList;  // price, weight, etc
		public var mcSocketList:RenderersList;
		public var mcSetAttributeList:RenderersList;
		
		public var btnCompareHint:InputFeedbackButton;
		public var mcEnchantmentIcon:MovieClip;
		public var mcPrimaryStat:TooltipPrimaryStat;
		public var mcOilInfo1:MovieClip;
		public var mcOilInfo2:MovieClip;
		public var mcOilInfo3:MovieClip;
		public var mcBackground:MovieClip;
		public var mcHeaderBackground:MovieClip;
		public var mcWarningBackground:MovieClip;
		public var mcEnchantedTypeIcon:MovieClip;
		public var mcShadow:MovieClip;
		private var _textValue : String;
		
		protected var _invalidateData:Boolean;
		protected var _comparisonTooltip:TooltipInventory;
		protected var _comparisonMode:Boolean;
		
		protected var _comparisonTooltipRef:String = "ItemTooltipRef";
		
		protected var _availableNameWidthConst:Number;
		
		public function TooltipInventory()
		{
			visible = false;
			
			mcPropertyList.isHorizontal = true;
			mcPropertyList.alignment = TextFormatAlign.LEFT;
			mcSocketList.isHorizontal = false;
			mcPropertyList.itemPadding = 0;
			mcAttributeList.itemPadding = 0;
			
			if (mcSetAttributeList)
			{
				mcSetAttributeList.itemPadding = 0;
			}
			
			mcAttributeList.straightenColumn = true;
			mcSocketList.straightenColumn = true;
			
			_availableNameWidthConst = 326;
			
			// #Y TEMP, PROTO
			_comparisonTooltipRef = "ItemTooltipRef_mouse";
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			
			_invalidateData = true;
			
			if (_data && _data.equippedItemData)
			{
				var stats:Array = _data.StatsList as Array;
				var equippedStats:Array = _data.equippedItemData.StatsList as Array;
				var countStats:int = stats.length;
				var equippedCountStats:int = equippedStats.length;
				var curEquippedStat:Object;
				
				for (var i:int = 0; i < countStats; i++)
				{
					var hasSameStat:Boolean = false;
					var curStat:Object = stats[i];
					
					for (var j:int = 0; j < equippedCountStats; j++)
					{
						curEquippedStat = equippedStats[j];
						
						if (curStat.id == curEquippedStat.id)
						{
							var diff:Number = curEquippedStat.floatValue - curStat.floatValue;
							
							curEquippedStat.diff = diff;
							curStat.diff = -diff;
							
							hasSameStat = true;
							break;
						}
					}
					
					if (!hasSameStat)
					{
						curStat.diff = curStat.floatValue;
					}
				}
				
				for (var k:int = 0; k < equippedCountStats; k++)
				{
					curEquippedStat = equippedStats[k];
					
					if (isNaN(curEquippedStat.diff))
					{
						curEquippedStat.diff = curEquippedStat.floatValue;
					}
				}
			}
			
		}
		
		override public function set backgroundVisibility(value:Boolean):void
		{
			super.backgroundVisibility = value;
			if (mcBackground)
			{
				mcBackground.gotoAndStop(_backgroundVisibility ? "solid" : "transparent");
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			if (!Extensions.isScaleform)
			{
				applyDebugData();
			}
			if (CoreComponent.isArabicAligmentMode)
			{
				mcAttributeList.itemRendererName = "AttributeRenderer_mouse_ar";
			}
		}
		
		override protected function populateData():void
		{
			super.populateData();
			if (!_data) return;
			populateItemData();
			visible = true;
			
		}
		
		protected var _strikethroughCanvas:Sprite;
		protected var backgroundAdditionalHeight:Number = 0;
		
		public function updateStats():void
		{
			populateItemData(true);
		}
		
		protected function populateItemData(statUpdateOnly:Boolean = false):void
		{
			var currentHeight:Number = 0;
			
			const PC_TITLE_HEIGHT = 15;
			const EQUIPPED_TITLE_HEIGHT = 31;
			const WARNING_TITLE_HEIGHT = 25;
			
			const ITEM_NAME_PADDING = 1;
			const PRIMARY_STAT_BLOCK_PADDING = 3;
			const DEFAULT_BLOCK_PADDING = 8;
			
			// title
			
			mcWarningBackground.visible = false;
			
			if (_data.EquippedTitle)
			{
				applyTextValue(tfEquippedTitle, _data.EquippedTitle, true, true);
				if (tfWarningMessage) tfWarningMessage.visible = false;
				
				mcBackground.y = -EQUIPPED_TITLE_HEIGHT;
				backgroundAdditionalHeight = EQUIPPED_TITLE_HEIGHT + EQUIPPED_TOOLTIP_PADDING_X;
				mcWarningBackground.visible = true;
				mcWarningBackground.gotoAndStop("equip");
			}
			else
			{
				if (tfEquippedTitle) tfEquippedTitle.visible = false;
				applyTextValue(tfWarningMessage, _data.WarningMessage, false, true);
				
				if (tfWarningMessage.visible)
				{
					mcWarningBackground.gotoAndStop("warning");
					mcWarningBackground.visible = true;
					mcBackground.y = -WARNING_TITLE_HEIGHT;
					backgroundAdditionalHeight = WARNING_TITLE_HEIGHT;// + EQUIPPED_TOOLTIP_PADDING_X;
				}
			}
			
			if (mcShadow)
			{
				mcShadow.y = mcBackground.y;
			}
			
			// --- HEADER ---
			
			// item name
			applyTextValue(tfItemName, _data.ItemName, true, true);
			
			//tfItemName.width = CONTENT_RIGHT_EDGE_POS;
			tfItemName.height = tfItemName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			cutTextFieldContent(tfItemName, 2);
			
			currentHeight += (tfItemName.height + ITEM_NAME_PADDING);
			
			// item type
			if (_data.hasEnchantedType)
			{
				tfItemType.text = _data.ItemType;
				_textValue = tfItemType.text;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfItemType.htmlText = "<p align=\"right\">" + _textValue+ "</p>";
				}
				else
				{
					tfItemType.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
				}
			}
			else
			{
				tfItemType.text = _data.ItemType;
				_textValue = tfItemType.text;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfItemType.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				else
				{
					tfItemType.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
					
				}
			}
			if (tfItemType)
			{
				tfItemType.y = currentHeight;
				//tfItemType.width = tfItemType.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				tfItemType.textColor = 0xc8c7c7;
				
				if (mcEnchantedTypeIcon)
				{
					if (_data.hasEnchantedType)
					{
						if (CoreComponent.isArabicAligmentMode)
						{
							mcEnchantedTypeIcon.visible = true;
							mcEnchantedTypeIcon.x = tfItemType.x + tfItemType.width - tfItemType.textWidth - mcEnchantedTypeIcon.width;
							
						}
						else
						{
							mcEnchantedTypeIcon.visible = true;
							mcEnchantedTypeIcon.x = tfItemType.x - mcEnchantedTypeIcon.width - ENCHANT_ICON_PADDING;
						}
							
							tfItemType.textColor = 0xF68104;
						
					}
					else
					{
						mcEnchantedTypeIcon.visible = false;
					}
				}
				
				currentHeight += tfItemType.textHeight + PRIMARY_STAT_BLOCK_PADDING;
			}
			else
			{
				if (mcEnchantedTypeIcon)
				{
					mcEnchantedTypeIcon.visible = false;
				}
			}
			
			if (tfCharges)
			{
				if (_data.charges)
				{
					tfCharges.htmlText = _data.charges;
					tfCharges.visible = true;
				}
				else
				{
					tfCharges.visible = false;
				}
				
				tfCharges.y = tfItemType ? tfItemType.y : tfItemName.y;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfCharges.x = tfItemType.x - tfItemType.textWidth -  ENCHANT_ICON_PADDING;//+ tfItemType.width - tfItemType.textWidth - ENCHANT_ICON_PADDING;
				}
			}
			
			// primary stat
			if (_data.PrimaryStatValue > 0)
			{
				mcPrimaryStat.y = currentHeight;
				mcPrimaryStat.setValue(data.PrimaryStatValue, data.PrimaryStatLabel, data.PrimaryStatDiff, _data.PrimaryStatDelta, data.PrimaryStatDiffStr, data.PrimaryStatDurabilityPenalty);
				mcPrimaryStat.visible = true;
				currentHeight += mcPrimaryStat.tfLabel.height + DEFAULT_BLOCK_PADDING;
				if (CoreComponent.isArabicAligmentMode)
				{
					mcPrimaryStat.x = 451 - mcPrimaryStat.thisWidth;
				}
				else
				{
					mcPrimaryStat.x = 8.3;
				}
				
			}
			else
			{
				mcPrimaryStat.visible = false;
				currentHeight += DEFAULT_BLOCK_PADDING;
			}
			
			mcHeaderBackground.height = currentHeight;
			currentHeight += PRIMARY_STAT_BLOCK_PADDING;
			setHeaderColor(_data.ItemRarityIdx);
			
			
			// -- LISTS ---
			
			// full stats list
			var statsData:Array = _data.StatsList as Array;
			if (mcAttributeList && statsData && statsData.length)
			{
				mcAttributeList.y = currentHeight;
				mcAttributeList.dataList = statsData;
				mcAttributeList.validateNow();
				mcAttributeList.visible = true;
				currentHeight = mcAttributeList.y + mcAttributeList.actualHeight;//BLOCK_PADDING;
			}
			else
			{
				mcAttributeList.visible = false;
			}
			
			// sockets list
			var socketsList:Array = _data.SocketsList as Array;
			if (mcSocketList && socketsList && socketsList.length && !_data.appliedEnchantmentInfo)
			{
				mcSocketList.y = currentHeight;
				mcSocketList.dataList = socketsList;
				mcSocketList.validateNow();
				mcSocketList.visible = true;
				currentHeight += (mcSocketList.actualHeight + BLOCK_PADDING);
			}
			else
			{
				mcSocketList.visible = false;
			}
			
			// enchantment
			
			if (mcEnchantmentIcon && tfEnchantmentInfo)
			{
				if (_data.appliedEnchantmentInfo)
				{
					tfEnchantmentInfo.htmlText = _data.appliedEnchantmentInfo;
					tfEnchantmentInfo.height = tfEnchantmentInfo.textHeight + CommonConstants.SAFE_TEXT_PADDING;
					
					if (tfEnchantmentInfo.textHeight > mcEnchantmentIcon.height)
					{
						tfEnchantmentInfo.y = currentHeight;
						mcEnchantmentIcon.y = tfEnchantmentInfo.y + tfEnchantmentInfo.height / 2;
					}
					else
					{
						mcEnchantmentIcon.y = currentHeight + mcEnchantmentIcon.height / 2;
						tfEnchantmentInfo.y = mcEnchantmentIcon.y - tfEnchantmentInfo.textHeight / 2;
					}
					
					currentHeight += (Math.max(tfEnchantmentInfo.textHeight, mcEnchantmentIcon.height) + BLOCK_PADDING);
				}
				else
				{
					tfEnchantmentInfo.visible = false;
					mcEnchantmentIcon.visible = false;
				}
				
			}
			
			// applied oil (only for swords)
			
			currentHeight = displayOil( mcOilInfo1, _data.appliedOilInfo1, currentHeight );
			currentHeight = displayOil( mcOilInfo2, _data.appliedOilInfo2, currentHeight );
			currentHeight = displayOil( mcOilInfo3, _data.appliedOilInfo3, currentHeight );
			
			
			// description (ignored for swords / armor)
			applyTextValue(tfDescription, _data.Description, false, true);
			if (tfDescription)
			{
				if (_data.Description)
				{
					tfDescription.y = currentHeight;
					currentHeight += tfDescription.height;
				}
				else
				{
					tfDescription.visible = false;
				}
			}
			
			// Rarity
			//applyTextValue(tfItemRarity, _data.ItemRarity, true);
			_textValue = _data.ItemRarity;
			if (CoreComponent.isArabicAligmentMode)
			{
				tfItemRarity.htmlText = "<p align=\"right\">" + _textValue + "</p>";
			}
			else
			{
				tfItemRarity.htmlText = _textValue;
			}
			
			if (tfItemRarity)
			{
				if (!CoreComponent.isArabicAligmentMode)
				{
					tfItemRarity.width = tfItemRarity.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				}
				tfItemRarity.y = currentHeight;
				currentHeight += (tfItemRarity.textHeight + BLOCK_PADDING);
				
			}
			
			// SET
			
			if (tfSetCounter)
			{
				if (_data.SetCounter)
				{
					tfSetCounter.htmlText = _data.SetCounter;
					tfSetCounter.visible = true;
					
					if (tfItemRarity)
					{
						if (!CoreComponent.isArabicAligmentMode)
						{
							tfSetCounter.x = tfItemRarity.x + tfItemRarity.textWidth + BLOCK_PADDING;
						}
						else
						{
							tfSetCounter.x = tfItemRarity.x + tfItemRarity.width - tfItemRarity.textWidth - AR_BLOCK_PADDING;
						}
						tfSetCounter.y = tfItemRarity.y;
					}
					else
					{
						tfSetCounter.visible = false;
					}
				}
				else
				{
					tfSetCounter.visible = false;
				}
			}
			
			var setStatsList:Array = _data.SetStatsList as Array;
			if (mcSetAttributeList && setStatsList && setStatsList.length)
			{
				mcSetAttributeList.y = currentHeight;
				mcSetAttributeList.dataList = setStatsList;
				mcSetAttributeList.validateNow();
				mcSetAttributeList.visible = true;
				currentHeight = mcSetAttributeList.y + mcSetAttributeList.actualHeight;//BLOCK_PADDING;
			}
			else
			{
				mcSetAttributeList.visible = false;
			}
			
			
			// Required Level
			if (tfRequiredLevel)
			{
				if (_data.RequiredLevel)
				{
					tfRequiredLevel.y = currentHeight;
					//applyTextValue(tfRequiredLevel, _data.RequiredLevel, false);
					
					_textValue = _data.RequiredLevel;
					if (CoreComponent.isArabicAligmentMode)
					{
						tfRequiredLevel.htmlText = "<p align=\"right\">" + _textValue + "</p>";
					}
					else
					{
						tfRequiredLevel.htmlText = _textValue;
					}
					currentHeight += tfRequiredLevel.height + BOTTOM_SMALL_PADDING;
					tfRequiredLevel.visible = true;
				}
				else
				{
					tfRequiredLevel.visible = false;
				}
			}
			
			// properties (price, weight, etc)
			if (mcPropertyList)
			{
				
				mcPropertyList.dataList = _data.PropertiesList as Array;
				mcPropertyList.validateNow();
				mcPropertyList.y = currentHeight;
				currentHeight += (mcPropertyList.actualHeight + BOTTOM_SMALL_PADDING);
				
				if (CoreComponent.isArabicAligmentMode)
				{
					mcPropertyList.x = mcBackground.x + mcBackground.width - mcPropertyList._thisWidth - LIST_OFFSET;
				}
				else
				{
					mcPropertyList.x = 7.85;
				}
			}
			
			if (btnCompareHint)
			{
				if (_data.equippedItemData && !InputManager.getInstance().isGamepad())
				{
					const BUTTON_PADDING:Number = 30;
					
					btnCompareHint.clickable = false;
					btnCompareHint.setDataFromStage("", KeyCode.SHIFT);
					btnCompareHint.label = "[[panel_common_compare]]";
					btnCompareHint.visible = true;
					btnCompareHint.addHoldPrefix = true;
					btnCompareHint.validateNow();
					btnCompareHint.y = currentHeight + BUTTON_PADDING;
					
					currentHeight += BUTTON_PADDING * 2;
				}
				else
				{
					btnCompareHint.visible = false;
				}
			}
			
			mcBackground.height = currentHeight + backgroundAdditionalHeight;
			
			if (mcShadow)
			{
				mcShadow.height = mcBackground.height;
			}
			
			if (_data.equippedItemData && !statUpdateOnly)
			{
				createComparisonTooltip(_data.equippedItemData);
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
				addEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate, false, 0, true);
			}
		}
		
		private function displayOil( oilContainer:MovieClip, oilDescription:String, currentHeight:Number ):Number
		{
			if (oilContainer)
			{
				if (oilDescription)
				{
					var tfOilData:TextField = oilContainer["txtOilInfo"];
					var oilIcon:MovieClip = oilContainer["mcOilIcon"];
					
					if (tfOilData)
					{
						_textValue = oilDescription;
						if (CoreComponent.isArabicAligmentMode)
						{
							tfOilData.x = -1.5;
							oilIcon.x = tfOilData.x + tfOilData.width + oilIcon.width/2 ;
							tfOilData.htmlText = "<p align=\"right\">" + _textValue + "</p>";
						}
						else
						{
							tfOilData.htmlText = _textValue;
						}
						
						tfOilData.height = tfOilData.textHeight + CommonConstants.SAFE_TEXT_PADDING;
						oilContainer.y = currentHeight;
						oilContainer.visible = true;
						currentHeight +=  (oilContainer.height + BLOCK_PADDING);
					}
					else
					{
						oilContainer.visible = false;
					}
				}
				else
				{
					oilContainer.visible = false;
				}
			}
			return currentHeight;
		}
		
		private function setHeaderColor(value:int):void
		{
			switch(value)
			{
				case 1:
					mcHeaderBackground.gotoAndStop("gray");
					break;
				case 2:
					mcHeaderBackground.gotoAndStop("blue");
					break;
				case 3:
					mcHeaderBackground.gotoAndStop("yellow");
					break;
				case 4:
					mcHeaderBackground.gotoAndStop("orange");
					break;
				case 5:
					mcHeaderBackground.gotoAndStop("green");
					break;
			}
		}
		
		// for plain text only! doesn't work with HTML
		protected function cutTextFieldContent(textField:TextField, maxLines:Number):void
		{
			if (textField.numLines > maxLines && !((textField.numLines - 1) == maxLines && CommonUtils.strTrim(textField.getLineText(textField.numLines)) == ""))
			{
				var lineLength:int = textField.getLineLength(maxLines - 1);
				var lineOffset:int = textField.getLineOffset(maxLines - 1);
				var lastCharIdx:int = lineOffset + lineLength - 2;
				while (textField.text.charAt(lastCharIdx) == " " && lastCharIdx > 0) lastCharIdx--; // remove spacebars
				
				var newText:String = textField.text.substr(0, lastCharIdx) + "…";
				
				textField.text = newText;
			}
		}
		
		public function showEquippedTooltip(value:Boolean):void
		{
			_comparisonMode = value;
			
			if (_comparisonTooltip)
			{
				if (value)
				{
					addChild(_comparisonTooltip);
					
					// #Y CHECK
					if (!CoreComponent.isArabicAligmentMode)
					{
						TooltipStatRenderer.showComparison = true;
					}
					else
					{
						TooltipStatRenderer_ar.showComparison = true;
					}
					updateStats();
					_comparisonTooltip.updateStats();
				}
				else
				{
					removeChild(_comparisonTooltip);
					
					// #Y CHECK
					if (!CoreComponent.isArabicAligmentMode)
					{
						TooltipStatRenderer.showComparison = false;
					}
					else
					{
						TooltipStatRenderer_ar.showComparison = false;
					}
					updateStats();
				}
					
				_comparisonTooltip.visible = value;
				
				removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
				addEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate, false, 0, true);
			}
		}

		/* DBG
		override public function set y(value:Number):void
		{
			super.y = value;
			var er:Error = new Error();
			trace("GFX ===== SET Y  ", y, " [" + value + "] ", er.getStackTrace());
		}
		*/
		
		private var _stopSafeRectCheck:Boolean = false;
		override public function stopSafeRectCheck(value:Boolean = false):void
		{
			_stopSafeRectCheck = value;
			
			if (_stopSafeRectCheck)
			{
				removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
			}
		}
		
		override public function updateSafeRectCheck():void
		{
			removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
			addEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate, false, 0, true);
		}
		
		override public function getPositionAfterScale(emulateScale:Number = -1):Point
		{
			var resultPoint:Point = new Point(x, y);
			
			var screenHeight:Number = 1080; // #Y Hardcode, flash document's height
			var screenWidth:Number = 1920; // #Y Hardcode, flash document's width
			
			//trace("GFX -- getPositionAfterScale ", resultPoint, "; ingnoreSafeRect", ingnoreSafeRect );
			
			// check safe rect
			
			if (ingnoreSafeRect)
			{
				return resultPoint;
			}
			
			var actualVisibleRect:Rectangle = mcBackground.getRect(parent)
			
			if(_comparisonTooltip && _comparisonTooltip.visible)
			{
				var compRect:Rectangle = _comparisonTooltip.mcBackground.getRect(parent);
				
				actualVisibleRect = actualVisibleRect.union(compRect);
			}
			
			// apply safe area if not PC
			if (InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_PC)
			{
				screenHeight *= 0.95;
				screenWidth *= 0.95;
			}
			else
			{
				screenHeight -= 5;
			}
			
			//trace("GFX -- emulateScale " , emulateScale, _anchorRect );
			//trace("GFX -- 1* ", actualVisibleRect);
			
			if (emulateScale > 0)
			{
				var koef:Number = emulateScale / this.scaleX;
				
				//trace("GFX -- koef ", koef);
				
				if (koef < 1)
				{
					// reset position;
					resultPoint.x = _actualPosition.x;
					resultPoint.y = _actualPosition.y;
				}
				
				actualVisibleRect.width = actualVisibleRect.width * koef;
				actualVisibleRect.height = actualVisibleRect.height * koef;
			}
			
			//trace("GFX -- 2* ", actualVisibleRect);
			
			var bottomEdge:Number = actualVisibleRect.y + actualVisibleRect.height;
			var rightEdge:Number = actualVisibleRect.x + actualVisibleRect.width;
			var positionChanged:Boolean = false;
			
			//trace("GFX * bottomEdge ", bottomEdge, " / ", screenHeight);
			//trace("GFX * rightEdge ", rightEdge, " / ", screenWidth);
			
			if ( bottomEdge > screenHeight )
			{
				if (_anchorRect)
				{
					if ( (_anchorRect.y - actualVisibleRect.height < screenHeight) && (_anchorRect.y - actualVisibleRect.height > 0) )
					{
						resultPoint.y = _anchorRect.y - actualVisibleRect.height;
					}
					else
					{
						resultPoint.y -= (bottomEdge - screenHeight);
					}
				}
				else
				{
					resultPoint.y -= (bottomEdge - screenHeight)
				}
			}
			
			if ( rightEdge > screenWidth )
			{
				if (_anchorRect)
				{
					if ( (_anchorRect.x - actualVisibleRect.width < screenWidth ) && (_anchorRect.x - actualVisibleRect.width > 0))
					{
						resultPoint.x = _anchorRect.x - actualVisibleRect.width;
					}
					else
					{
						resultPoint.x -= (rightEdge - screenWidth);
					}
					
				}
				else
				{
					resultPoint.x -= (rightEdge - screenWidth);
				}
			}
			
			return resultPoint;
		}
		
		
		override protected function updatePosition():void
		{
			if (_stopSafeRectCheck)
			{
				return;
			}
			
			applyPositioning();
			
			x = _actualPosition.x;
			y = _actualPosition.y;
			
			updateTooltipPosition();
			
			if( _invalidateData )
			{
				_invalidateData = false;
				dispatchEvent( new Event( Event.ACTIVATE ) );
			}
		}
		
		protected function updateTooltipPosition():void
		{
			if (_stopSafeRectCheck)
			{
				return;
			}
			
			var updatedLocation:Point = getPositionAfterScale();
			
			this.x = updatedLocation.x;
			this.y = updatedLocation.y;
		}
		
		override public function get scaleX():Number { return super.actualScaleX; }
		override public function get scaleY():Number { return super.actualScaleY; }
		
		protected function createComparisonTooltip(tooltipData:Object):void
		{
			const COMP_PADDING = 0;
			
			if (_comparisonTooltip)
			{
				removeChild(_comparisonTooltip);
				_comparisonTooltip = null;
			}
			
			var ClassRef:Class = getDefinitionByName(_comparisonTooltipRef) as Class;
			_comparisonTooltip = new ClassRef() as TooltipInventory;
			
			_comparisonTooltip.isMouseTooltip = false;
			_comparisonTooltip.lockFixedPosition = true;
			_comparisonTooltip.backgroundVisibility = true;
			_comparisonTooltip.data = tooltipData;
			//addChild(_comparisonTooltip);
			_comparisonTooltip.validateNow();
			_comparisonTooltip.visible = _comparisonMode;
			
			var equippedPadding:Number = 0;
			
			if (tooltipData.EquippedTitle)
			{
				//equippedPadding = EQUIPPED_TOOLTIP_PADDING_Y;
			}
			
			_comparisonTooltip.x = mcBackground.x + mcBackground.width + EQUIPPED_TOOLTIP_PADDING_X + COMP_PADDING;
			_comparisonTooltip.y = equippedPadding;
			
			removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
			addEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate, false, 0, true);
		}
		
		protected function handleComparisonTooltipValidate(event:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, handleComparisonTooltipValidate);
			updatePosition();
			//updateTooltipPosition(); // fit safe rect
		}
		
		protected function applyDebugData():void
		{
			var testData:Object = { }
			testData.PrimaryStatLabel = "damage";
			testData.PrimaryStatValue = "10";
			testData.ItemName = "Witcher Sword";
			testData.ItemRarity = "Cool";
			testData.ItemType = "Sword";
			testData.CommonDescription = "Common Description";
			testData.UniqDescription = "Sword Description";
			testData.SocketsDescription = "ddddddddddddd";
			
			var testStatsList:Array = [];
			testStatsList.push( { type:"attack", value:"10", icon:"better" } );
			testStatsList.push( { type:"attack", value:"10", icon:"better" } );
			testStatsList.push( { type:"attack", value:"10", icon:"wayBetter" } );
			testStatsList.push( { type:"attack", value:"10", icon:"none" } );
			testData.GenericStatsList = testStatsList;
			
			var testPropList:Array = [];
			
			testPropList.push( { type:"notforsale", label:"", value:"" } );
			testPropList.push( { type:"price", label:"price", value:"100" } );
			testPropList.push( { type:"weight", label:"weight", value:"50" } );
			testPropList.push( { type:"repair", label:"repair", value:"10" } );
			testData.PropertiesList = testPropList;
			
			this.anchorRect = new Rectangle((parent["testAnchor"] as MovieClip).x, (parent["testAnchor"] as MovieClip).y, 0, 0);
			this.lockFixedPosition = true;
			this.data = testData;
		}
		
	}
}
