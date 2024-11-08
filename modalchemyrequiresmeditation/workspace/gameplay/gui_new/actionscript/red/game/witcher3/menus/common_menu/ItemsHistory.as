/***********************************************************************
/** MenuHub - Items History for inventory
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;

	public class ItemsHistory extends UIComponent
	{
		public var mcItemInfo1 : NewItemInfo;
		public var mcItemInfo2 : NewItemInfo;
		public var mcItemInfo3 : NewItemInfo;

		override protected function configUI():void
		{
			super.configUI();
			mcItemInfo1.visible = false;
			mcItemInfo1.visible = false;
			mcItemInfo1.visible = false;
		}

		public function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray : Array = gameData as Array;
			var mcItemInfo : NewItemInfo;
			trace("Bidon handleDataSet ItemsHistory");
			for ( var i : int = 0; i < dataArray.length; i++ )
			{
				trace("Bidon i show "+i);
				mcItemInfo = GetItemInfoById( i );
				mcItemInfo.SetItemIcon( dataArray[i].iconName );
				mcItemInfo.SetItemName( dataArray[i].itemName );
				mcItemInfo.SetItemType( dataArray[i].category );
				mcItemInfo.visible = true;
			}
			for ( i = dataArray.length; i < 3; i++ )
			{
				mcItemInfo = GetItemInfoById( i );
				mcItemInfo.visible = false;
				trace("Bidon i hide "+i);
			}
		}

		public function GetItemInfoById( id : int ) : NewItemInfo
		{
			if ( id == 0 )
			{
				return mcItemInfo1;
			}
			else if ( id == 1 )
			{
				return mcItemInfo2;
			}
			else if ( id == 2 )
			{
				return mcItemInfo3;
			}
			return null;
		}

		public function IsAnyItemToDisplay() : Boolean
		{
			trace("Bidon mcItemInfo1.visible "+mcItemInfo1.visible);
			trace("Bidon mcItemInfo2.visible "+mcItemInfo2.visible);
			trace("Bidon mcItemInfo3.visible "+mcItemInfo3.visible);
			return mcItemInfo1.visible || mcItemInfo2.visible || mcItemInfo3.visible;
		}
	}
}
