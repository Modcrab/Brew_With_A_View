/***********************************************************************
/** Notice Board Item Class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.noticeboard
{

	import red.game.witcher3.controls.BaseListItem;
	import flash.display.MovieClip;
	import red.game.witcher3.slots.SlotBase;

	public class NoticeboardListItem extends SlotBase
	{
		var mcErrand : MovieClip;
		var destinationErrandOutlook : int = 2;

		public function NoticeboardListItem()
		{
			super();
			
			INDICATE_ANIM_DURATION = .7;
		}

		protected override function configUI():void
		{
			super.configUI();
		}
		
		override public function set data(value:*):void
		{
			super.data = value;

			if ( !mcErrand )
			{
				mcErrand = this.getChildByName("mcErrand") as MovieClip;
			}

			if ( data )
			{
				if ( data.tag == "" )
				{
					selectable = false;
					enabled = false;
					visible = false;
					return;
				}
				else
				{
					selectable = true;
					enabled = true;
					visible = true;
				}
				this.x += data.posX;
				this.y += data.posY;
				if ( data.isFluff )
				{
					destinationErrandOutlook =  ( index % 3 ) + 9;
					if ( mcErrand )
					{
						mcErrand.gotoAndStop(destinationErrandOutlook);
						mcStateSelectedActive.gotoAndStop(destinationErrandOutlook);
					}
					return;
				}
				else
				{
					destinationErrandOutlook = index + 1;
					if ( mcErrand )
					{
						mcErrand.gotoAndStop( destinationErrandOutlook );
						mcStateSelectedActive.gotoAndStop(destinationErrandOutlook);
					}
				}
			}
			else
			{
				selectable = false;
				enabled = false;
				visible = false;
			}
		}


		override public function set visible(value:Boolean):void
		{
            super.visible = value;
			if ( data )
			{
				trace("JOURNAL cghange visibility to " + value +" for >" + data.tag + "<");
			}
			trace("JOURNAL cghange visibility to " + value +" index "+index);
        }
	}
}
