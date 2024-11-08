package red.game.witcher3.hud.modules.signinfo
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InvalidationType;
	
	public class HudItemInfo extends UIComponent
	{
		public var mcIconLoader:UILoader;
		public var mcBckArrow:MovieClip;
		public var mcError:MovieClip;
		private var _IconName : String;
		
		public function HudItemInfo()
		{
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (mcBckArrow)
			{
				mcBckArrow.visible = false;
			}
		}
		
		override public function toString() : String
		{
			return this.name;
		}
		
		private function updateIcon():void
		{
			if ( _IconName && _IconName != ""  && _IconName != "icons/items/None_64x64.dds"  )
			{
				mcIconLoader.source =  "img://" + _IconName;
				this.visible = true;
			}
			else
			{
				mcIconLoader.source = "";
				this.visible = false;
			}
		}
		
		public function set IconName( val : String ) : void
		{
			if ( _IconName != val )
			{
				_IconName = val;
				updateIcon();
			}
		}
		
		public function set IconDimmed( value : Boolean ) : void
		{
			if ( value )
			{
				mcIconLoader.alpha = 0.5;
			}
			else
			{
				mcIconLoader.alpha = 1.0;
			}
		}
	}
}
