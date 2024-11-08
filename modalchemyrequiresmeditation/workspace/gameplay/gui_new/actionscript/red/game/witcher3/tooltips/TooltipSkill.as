package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.W3UILoaderPaperdollSlot;
	import red.game.witcher3.interfaces.IAnchorable;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	// #B not use align in Arabic
	/**
	 * Skill tooltip
	 * @author Yaroslav Getsevich
	 */
	public class TooltipSkill extends TooltipBase implements IAnchorable
	{
		private static const TEXT_PADDING:Number = 5;
		private static const TEXT_BIG_PADDING:Number = 15;
		private static const BLOCK_PADDING:Number = 8;
		
		public var mcBackground:MovieClip;
		public var mcHeaderBackground:MovieClip;
		public var mcShadow:MovieClip;
		
		public var tfSkillName:TextField;
		public var tfSkillLevel:TextField;
		public var tfCurrentLevelDescription:TextField;
		public var tfNextLevelDescription:TextField;
		public var txfRequiredPoints:TextField;
		public var tfType:TextField;
		
		private var _textValue:String;

		public function TooltipSkill()
		{
			super();
			
			visible = false;
			tfSkillName.text = "";
			tfSkillLevel.text = "";
			tfCurrentLevelDescription.text = "";
			tfNextLevelDescription.text = "";
		}
		
		override protected function populateData():void
		{
			super.populateData();
			
			if (!data) return;
			
			// HEADER: first line
			_textValue = _data.skillName;
			tfSkillName.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
			if (CoreComponent.isArabicAligmentMode)
			{
				tfSkillName.htmlText = "<p align=\"right\">" + _textValue + "</p>";
			}
		
			if (_data.skillSubCategory && _data.skillSubCategory != "")
			{
				_textValue = _data.skillSubCategory;
				tfType.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
				if (CoreComponent.isArabicAligmentMode)
				{
					tfType.htmlText = "<p align=\"left\">" + _textValue + "</p>";
				}
				tfType.visible = true;
			}
			else
			{
				tfType.visible = false;
			}
			
			// HEADER: second line
			
			if (_data.isCoreSkill)
			{
				_textValue = _data.skillLevelString;
				tfSkillLevel.htmlText = _textValue;
				tfSkillLevel.visible = true;
			}
			else
			if (_data.skillLevelString != "")
			{
				tfSkillLevel.htmlText = "[[panel_character_tooltip_skills_level]]";
				tfSkillLevel.htmlText = CommonUtils.toUpperCaseSafe(tfSkillLevel.htmlText);
				tfSkillLevel.htmlText = tfSkillLevel.htmlText + ("<font color = '#FFFFFF'>" + _data.skillLevelString + "</font>");
				tfSkillLevel.width = tfSkillLevel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				tfSkillLevel.visible = true;
			}
			else
			{
				tfSkillLevel.text = "";
				tfSkillLevel.visible = false;
			}
			
			var pointsColor:String;
			
			pointsColor = "#FFFFFF";
			if (_data.level < _data.maxLevel)
			{
				if (!_data.hasEnoughPoints)
				{
					pointsColor = "#EE0404";
				}
				else if (_data.curSkillPoints > 0)
				{
					pointsColor = "#93FF93";
				}
			}
			
			if (_data.requiredPointsSpent >= 0)
			{
				txfRequiredPoints.htmlText =  "[[panel_character_tooltip_skills_req_points]]";
				_textValue = txfRequiredPoints.htmlText;
				_textValue = _textValue + " " + _data.requiredPointsSpent;
				txfRequiredPoints.htmlText = _textValue;
				_textValue = txfRequiredPoints.htmlText;
				txfRequiredPoints.visible = true;
			}
			else
			{
				txfRequiredPoints.text = "";
				txfRequiredPoints.visible = false;
			}
			
			const INIT_TEXT_POS:Number = 85;
			var curHeight:Number = INIT_TEXT_POS;
			
			if (_data.currentLevelDescription)
			{
				tfCurrentLevelDescription.y = curHeight;
				_textValue = _data.currentLevelDescription;
				tfCurrentLevelDescription.htmlText = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfCurrentLevelDescription.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				tfCurrentLevelDescription.height = tfCurrentLevelDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				curHeight += tfCurrentLevelDescription.height + TEXT_PADDING;
			}
			if (_data.nextLevelDescription)
			{
				tfNextLevelDescription.y = curHeight;
				_textValue = _data.nextLevelDescription;
				tfNextLevelDescription.htmlText = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfNextLevelDescription.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				tfNextLevelDescription.height = tfNextLevelDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				curHeight += tfNextLevelDescription.height + TEXT_PADDING;
			}
			
			mcBackground.gotoAndStop("solid");
			mcShadow.height = mcBackground.height = curHeight;
			
			visible = true;
		}
		
		override protected function updatePosition():void
		{
			var resultPoint:Point = new Point();
			
			if (_anchorRect)
			{
				this.x = _anchorRect.x + _anchorRect.width;
				this.y = _anchorRect.y + _anchorRect.height;
				
				resultPoint.x = this.x;
				resultPoint.y = this.y;
			}
			
			var actualVisibleRect:Rectangle = mcBackground.getRect(parent);
			var screenHeight:Number = 1080; // #Y Hardcode, flash document's height
			var screenWidth:Number = 1920; // #Y Hardcode, flash document's width
			var bottomEdge:Number = actualVisibleRect.y + actualVisibleRect.height;
			var rightEdge:Number = actualVisibleRect.x + actualVisibleRect.width;
			
			// apply safe area if not PC
			if (InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_PC)
			{
				screenHeight *= 0.95;
				screenWidth *= 0.95;
			}
			
			trace("GFX updatePosition _anchorRect ", _anchorRect, "; bottomEdge: ", bottomEdge, "; screenHeight ", screenHeight);
			trace("GFX actualVisibleRect ", actualVisibleRect );
			
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
			
			x = resultPoint.x;
			y = resultPoint.y;
		}
		
		override public function set backgroundVisibility(value:Boolean):void
		{
			super.backgroundVisibility = value;
			if (mcBackground)
			{
				mcBackground.gotoAndStop(_backgroundVisibility ? "solid" : "transparent");
			}
		}

	}

}
