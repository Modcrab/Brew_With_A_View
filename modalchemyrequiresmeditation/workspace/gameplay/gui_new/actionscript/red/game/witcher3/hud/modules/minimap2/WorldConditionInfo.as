/***********************************************************************
/** Wheater, time of day and monster info
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;

	public class WorldConditionInfo extends UIComponent
	{
		public var mcWeather : MovieClip;
		public var mcBackground : MovieClip;
		public var textField : TextField;

		private var _initialBackgroundX : Number;
		private var _minimalSize : Number = 0;

		public function WorldConditionInfo()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			this.visible = false;
			_initialBackgroundX = mcBackground.x;
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "hud.worldcondition.weather", [handleSetWeatherIcon]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "hud.worldcondition.text", [handleSetText]));
		}

		private function handleSetWeatherIcon( value : String )
		{
			if ( value != "" )
			{
				this.visible = true;
				if (mcWeather)
				{
					mcWeather.mcIcons.gotoAndStop(value);
				}
			}
			else
			{
				this.visible = false;
			}
		}

		private function handleSetText( value : String )
		{
			if (textField)
			{
				textField.htmlText = CommonUtils.toUpperCaseSafe(value);
				var sizeX : Number = textField.textWidth;
				mcBackground.x = Math.min( mcBackground.width - sizeX - _initialBackgroundX , Math.max( _initialBackgroundX, mcBackground.width - 20 - _minimalSize) ) + 12;
			}
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
	}
}
