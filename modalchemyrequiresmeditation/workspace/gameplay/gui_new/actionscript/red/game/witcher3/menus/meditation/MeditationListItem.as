/***********************************************************************
/** MEDITATION LIST ITEM RENDERER
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	
	public class MeditationListItem extends BaseListItem
	{
		public var mcIcon : MovieClip;
		public var _iconName : String;
		public var _subPanelName : uint;
		
		public function MeditationListItem()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		
		override public function setData( data:Object ):void
		{
			if (! data )
			{
				return;
			}
			_iconName = data.iconName;
			_subPanelName = data.subPanelName;
			super.setData( data );
		}
		
		
		override protected function update()
		{
			updateIcon();
		}
		
		private function updateIcon()
		{
			if (mcIcon)
			{
				mcIcon.gotoAndStop(_iconName);
			}
		}
	}
}
