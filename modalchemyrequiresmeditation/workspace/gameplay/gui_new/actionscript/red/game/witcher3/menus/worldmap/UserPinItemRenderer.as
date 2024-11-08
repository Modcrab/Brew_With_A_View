package red.game.witcher3.menus.worldmap 
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	
	/**
	 * ...
	 * red.game.witcher3.menus.worldmap.UserPinItemRenderer
	 * @author Pawel
	 */
	public class UserPinItemRenderer extends BaseListItem
	{
		public var mcIcon:MovieClip;
		
		override  public function setData(data:Object):void
		{
			super.setData(data);

			if (mcIcon && data)
			{
				mcIcon.gotoAndStop( data.pinId );
			}
		}
		
	}

}