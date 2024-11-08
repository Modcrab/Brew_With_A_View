package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.hud.modules.wolfHead.W3StatIndicator;
	import scaleform.clik.motion.Tween;

	public class HudModuleCompanion extends HudModuleBase
	{
		public var textField : TextField;
		public var mcLoader : W3UILoader;
		public var mcHealthBar 	: W3StatIndicator;

		public var textField2 : TextField;
		public var mcLoader2 : W3UILoader;
		public var mcHealthBar2 	: W3StatIndicator;
		public var mcGraphicPortrait2 	: MovieClip;

		public function HudModuleCompanion()
		{
			super();
		}

		override public function get moduleName():String
		{
			return "CompanionModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setVitality( _Percentage : Number )
		{
			if ( mcHealthBar )
			{
				mcHealthBar.value = _Percentage * 100;
			}
		}

		public function setName( value : String )
		{
			textField.htmlText = value;
		}

		public function setPortrait( value : String )
		{
			// #Y Cut first '\', if it exist, to prevent conflict with prefix 'img://'
			// TODO: Implement it to all UI Loaders
			if (value.charAt(0) == '\\')
			{
				value = value.slice(1, value.length);
			}

			mcLoader.source = "img://" + value;
		}

		public function setVitality2( _Percentage : Number )
		{
			if ( mcHealthBar2 )
			{
				mcHealthBar2.value = _Percentage * 100;
			}
		}

		public function setName2( value : String )
		{
			textField2.htmlText = value;
		}

		public function setPortrait2( value : String )
		{
			if ( value == "" )
			{
				gotoAndStop("one");
				return;
			}
			else
			{
				gotoAndStop("two");
				mcLoader2 = this.getChildByName("mcLoader2") as W3UILoader;
				textField2 = this.getChildByName("textField2") as TextField;
				mcHealthBar2 = this.getChildByName("mcHealthBar2") as W3StatIndicator;
			}

			// #Y Cut first '\', if it exist, to prevent conflict with prefix 'img://'
			// TODO: Implement it to all UI Loaders
			if (value.charAt(0) == '\\')
			{
				value = value.slice(1, value.length);
			}

			mcLoader2.source = "img://" + value;
		}
	}
}
