package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.FeedbackDropdownMenuListItem;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.controls.W3UILoader;
	
	public class IconDropdownMenuListItem extends FeedbackDropdownMenuListItem
	{
		public var mcIconLoader      : W3UILoader;
		
		public function IconDropdownMenuListItem()
		{
			super();
			
			if (mcIconLoader) 
			{ 
				mcIconLoader.fallbackIconPath = "icons/monsters/ICO_MonsterDefault.png"; 
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override public function setData( data : Object ) : void
		{
            super.setData(data);
			
			if ( data )
			{
				var dataArray : Array = data as Array;
				
				if ( dataArray )
				{
					if( dataArray[0].dropDownIcon && mcIconLoader )
					{
						mcIconLoader.source = "img://" + dataArray[0].dropDownIcon;//icons/monsters/ICO_MonsterDefault.png";
					}
				}
			}
        }
	}
}