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
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;

	public class DistanceInfo extends UIComponent
	{
		public var mcBackground : MovieClip;
		public var mcLevelIndicator : MovieClip;
		public var mcFootsteps : MovieClip;
		public var mcIcon : MovieClip;
		public var tfDistance : TextField;

		private var _initialBackgroundX : Number;
		private var _initialIconX : Number;
		private var _initialLevelIndicatorX : Number;
		private var _minimalSize : Number = 0;
		
		private var _currDistance : int = -1;
		private var _currText : String;
		private var _currLevelIndicator : int = -1;

		private const LEVEL_BELOW		= 1;
		private const LEVEL_THE_SAME	= 2;
		private const LEVEL_ABOVE		= 3;
		
		public function DistanceInfo()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			
			_initialBackgroundX     = mcBackground.x;
			_initialIconX           = mcIcon.x;
			_initialLevelIndicatorX = mcLevelIndicator.x;
		}
		
		public function Update( distance : Number, mapPinZ : Number, playerZ : Number, threshold : Number )
		{
			if ( _currDistance != int( distance ) )
			{
				_currDistance = int( distance );
				
				if ( _currDistance >= 0 )
				{
					visible = true;
	
					var updatedIndicator = UpdateLevelIndicator( mapPinZ, playerZ, threshold );
					var updatedText      = UpdateText();
					if ( updatedIndicator || updatedText )  
					{
						UpdateLayout();
					}
				}
				else
				{
					visible = false;
				}
			}
			else
			{
				if ( _currDistance >= 0 )
				{
					if ( UpdateLevelIndicator( mapPinZ, playerZ, threshold ) )
					{
						UpdateLayout();
					}
				}
			}
		}
		
		private function UpdateLevelIndicator( mapPinZ : Number, playerZ : Number, threshold : Number ) : Boolean
		{
			if ( mcLevelIndicator )
			{
				var levelIndicator : int;
				if      ( playerZ > mapPinZ + threshold )	levelIndicator = LEVEL_BELOW;
				else if ( playerZ < mapPinZ - threshold )	levelIndicator = LEVEL_ABOVE;
				else										levelIndicator = LEVEL_THE_SAME;

				if ( _currLevelIndicator != levelIndicator )
				{
					_currLevelIndicator = levelIndicator;
					mcLevelIndicator.gotoAndStop( _currLevelIndicator ); // frames: below, normal, above
					return true;
				}
				return false;
			}
			return false;
		}
		
		private function UpdateText() : Boolean
		{
			if ( _currDistance < 10 )
			{
				if ( _currLevelIndicator == LEVEL_BELOW )
				{
					return SetText( "[[panel_hud_below]]" );
				}
				else if ( _currLevelIndicator == LEVEL_ABOVE )
				{
					return SetText( "[[panel_hud_above]]" );
				}
				else
				{
					return SetText( "[[panel_hud_nearby]]" );
				}
			}
			else
			{
				return SetText( _currDistance.toString(), true, false );
			}
			return false;
		}

		private function SetText( text : String, showFoolsteps : Boolean = false, convertToUppercase : Boolean = true ) : Boolean
		{
			if ( tfDistance )
			{
				if ( _currText == text )
				{
					return false;
				}
				_currText = text;

				tfDistance.htmlText = text;
				if ( convertToUppercase )
				{
					tfDistance.htmlText = CommonUtils.toUpperCaseSafe( tfDistance.htmlText );
				}
			
				if ( showFoolsteps && !mcFootsteps.visible)
				{
					mcFootsteps.visible = true;
				}
				else if (!showFoolsteps && mcFootsteps.visible)
				{
					mcFootsteps.visible = false;
				}

				return true;
			}
			return false;
		}
		
		private function UpdateLayout()
		{
			if ( tfDistance )
			{
				var currTextWidth : Number = tfDistance.textWidth;

				mcLevelIndicator.x = _initialLevelIndicatorX - currTextWidth;
				mcIcon.x           = _initialIconX           - currTextWidth;
				mcBackground.x     = _initialBackgroundX     - currTextWidth;

				if ( _currLevelIndicator != LEVEL_THE_SAME )
				{
					mcIcon.x           -= mcLevelIndicator.width;
					mcBackground.x     -= mcLevelIndicator.width;
				}
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
