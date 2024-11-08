/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.controls.W3Slider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.ui.InputDetails;
	public class GammaSettingModule extends StaticOptionModule
	{
		public var txtTitle : TextField;
		public var mcSlider : W3Slider;

		private var _data:Object;

		override protected function configUI():void
		{
			super.configUI();
			focusable = false;
		}

		public function showWithData(data:Object):void
		{
			super.show();

			_data = data;

			if (data.subElements.length >= 3)
			{
				mcSlider.snapInterval = Number((data.subElements[1] - data.subElements[0]) / data.subElements[2]);
			}
			else
			{
				mcSlider.snapInterval = 1;
			}

			if (data.subElements.length >= 2)
			{
				mcSlider.maximum = Number(data.subElements[1]);
			}
			else
			{
				mcSlider.maximum = 1;
			}

			if (data.subElements.length >= 1)
			{
				mcSlider.minimum = Number(data.subElements[0]);
			}
			else
			{
				mcSlider.minimum = 0;
			}
			mcSlider.offsetLeft = 35;
			mcSlider.offsetRight = 35;
			mcSlider.snapping = true;
			mcSlider.value = Number(data.current);
			mcSlider.addEventListener( SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false);
		}

		override public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				CommonUtils.convertWASDCodeToNavEquivalent(details);
				
				if (mcSlider)
				{
					mcSlider.handleInput(event);
				}

				// #J screw it, first pass won't have apply/cancel
				/*
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);

				if ( keyUp && !event.handled )
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_A:
						{
							handleNavigateBack();
						}
						break;
					}
				}*/
			}

			super.handleInputNavigate(event);
		}

		function OnSliderValueChanged( event : SliderEvent ) : void
		{
			var sliderValue : Number;
			sliderValue = mcSlider.value;
			_data.current = sliderValue.toString();

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionValueChanged', [ _data.groupID, _data.tag, _data.current ] ) );
		}
	}
}