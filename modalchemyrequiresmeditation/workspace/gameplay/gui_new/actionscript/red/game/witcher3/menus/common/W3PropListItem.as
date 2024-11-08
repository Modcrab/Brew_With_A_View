package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.BaseListItem;
	
	public class W3PropListItem extends BaseListItem
	{
		public var mcIcon:MovieClip;
		public var tfStatValue:TextField;
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}
			
			tfStatValue.htmlText = data.value;
			if (data.type)
			{
				mcIcon.gotoAndStop(data.type);
				mcIcon.visible = true;
			}
			else
			{
				mcIcon.visible = false;
			}
		}
		
	}

}
