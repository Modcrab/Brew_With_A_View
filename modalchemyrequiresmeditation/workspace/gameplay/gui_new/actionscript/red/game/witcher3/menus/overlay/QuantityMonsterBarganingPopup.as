/***********************************************************************
/** Monster Barganing Popup
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.overlay
{
	import scaleform.clik.events.SliderEvent;
	import flash.text.TextField;
	import red.game.witcher3.hud.modules.wolfHead.W3StatIndicator;
	import flash.display.MovieClip;
	import scaleform.clik.motion.Tween;

	public class QuantityMonsterBarganingPopup extends QuantityPopup
	{
		public var tfBaseValue:TextField;
		public var tfBaseValueDescription:TextField;
		public var tfPlus:TextField;
		public var tfBonusValue:TextField;
		public var tfBonusValueDescription:TextField;
		public var tfEqual:TextField;
		public var tfFinalValue:TextField;
		public var tfFinalValueDescription:TextField;
		public var tfAngerBarLabel:TextField;
		
		public var mcAngerBar : W3StatIndicator;
		public var mcMask : MovieClip;
		public var mcBackground : MovieClip;
		
		public var mcRewordIcon1 : MovieClip;
		public var mcRewordIcon2 : MovieClip;
		public var mcRewordIcon3 : MovieClip;

		private var mcAngerBarTween		: Tween;

		private var _baseValue : int;

		public function QuantityMonsterBarganingPopup()
		{
			super();
		}

		protected override function configUI():void
		{
			super.configUI();

			tfBaseValueDescription.htmlText = "[[panel_hud_dialogue_bar_base]]";
			tfBonusValueDescription.htmlText = "[[panel_hud_dialogue_bar_bonus]]";
			tfFinalValueDescription.htmlText = "[[panel_hud_dialogue_bar_final]]";
			tfAngerBarLabel.htmlText = "[[panel_hud_dialogue_bar_label_anger]]";
			tfPlus.htmlText = "+";
			tfEqual.htmlText = "=";
		}
		
		override protected function alignControls():void
		{
			// ignore
		}

		override protected function populateData():void
		{
			super.populateData();
			
			if ( _data )
			{
				_baseValue = _data.baseValue as int;
				tfBaseValue.htmlText = _baseValue.toString();
				tfBonusValue.htmlText = (_data.currentValue - _baseValue).toString();
				tfFinalValue.htmlText = _data.currentValue.toString();
				setBarValue(_data.anger);
				mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
				
				if (!_data.ShowPrice)
				{
					tfAngerBarLabel.y = 258;
					mcAngerBar.y = 299;
				}
				else
				{
					tfAngerBarLabel.y = 294;
					mcAngerBar.y = 333;
				}
				
				if (_data.alternativeRewardType)
				{
					mcRewordIcon1.gotoAndStop("potatoes");
					mcRewordIcon2.gotoAndStop("potatoes");
					mcRewordIcon3.gotoAndStop("potatoes");
					mcPriceIcon.gotoAndStop("potatoes");
				}
			}
		}

		override protected function handlSliderChanged(event:SliderEvent):void
		{
			super.handlSliderChanged(event);
			tfBonusValue.htmlText = (_currentQuantity - _baseValue).toString();
			tfFinalValue.htmlText = _currentQuantity.toString();
		}

		public function setBarValue( _Percentage : Number ):void
		{
			mcAngerBar.value = _Percentage;
			if (mcAngerBarTween)
				mcAngerBarTween.paused = true;
			mcAngerBarTween = new Tween(500, mcAngerBar, { value: _Percentage }, { paused:false } );
		}
	}
}
