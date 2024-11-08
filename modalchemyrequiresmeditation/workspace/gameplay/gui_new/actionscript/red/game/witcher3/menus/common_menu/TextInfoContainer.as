/***********************************************************************
/** MenuHub - Skills Items Container
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;

	public class TextInfoContainer extends UIComponent
	{
		public var mcTextInfoItem1 : TextInfoItem;
		public var mcTextInfoItem2 : TextInfoItem;
		public var mcTextInfoItem3 : TextInfoItem;

		override protected function configUI():void
		{
			super.configUI();
			mcTextInfoItem1.visible = false;
			mcTextInfoItem2.visible = false;
			mcTextInfoItem3.visible = false;
		}

		public function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray : Array = gameData as Array;
			var mcTextInfoItem : TextInfoItem;

			for ( var i : int = 0; i < dataArray.length; i++ )
			{
				mcTextInfoItem = GetTextInfoById( i );
				mcTextInfoItem.SetEntryTopText( dataArray[i].topText );
				mcTextInfoItem.SetEntryBottomText( dataArray[i].bottomText );
				mcTextInfoItem.visible = true;
			}
			for ( i = dataArray.length; i < 3; i++ )
			{
				mcTextInfoItem = GetTextInfoById( i );
				mcTextInfoItem.visible = false;
			}
		}

		public function GetTextInfoById( id : int ) : TextInfoItem
		{
			if ( id == 0 )
			{
				return mcTextInfoItem1;
			}
			else if ( id == 1 )
			{
				return mcTextInfoItem2;
			}
			else if ( id == 2 )
			{
				return mcTextInfoItem3;
			}
			return null;
		}

		public function IsAnyItemToDisplay() : Boolean
		{
			return mcTextInfoItem1.visible || mcTextInfoItem2.visible || mcTextInfoItem3.visible;
		}
	}
}
