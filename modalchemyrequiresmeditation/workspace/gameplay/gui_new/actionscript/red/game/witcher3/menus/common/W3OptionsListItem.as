/***********************************************************************
/** Right click menu list item renderer
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.core.events.GameEvent;
	import flash.events.MouseEvent;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.constants.InventoryActionType;
	
	public class W3OptionsListItem extends ListItemRenderer
	{
		var inventoryActionType : int;
		
		public function W3OptionsListItem()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			//addEventListener(MouseEvent.CLICK, handleOptionChoosen, false, 0, true);
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}
			label = data.name;
			inventoryActionType = data.actionType;
		}
		
		override protected function updateAfterStateChange():void
		{
		}
		
		
		protected function handleOptionChoosen( event:MouseEvent ):void
		{
			//trace("INVENTORY handleOptionChoosen options.menu.item itemQuantity ?? ");
			//dispatchEvent( new GameEvent(GameEvent.CALL, "OnRightMenuOptionChoosen", [index,-1,])); // @FIXME BIDON // itemId, itemQuantity, index
			//dispatchEvent( new GameEvent( GameEvent.PASSINPUT, 'quantity.popup', ['OnRightMenuOptionChoosen', index, event.renderer.data.quantity ] ));
			//dispatchEvent( new GridEvent( GridEvent.HIDE_OPTIONSMENU, true, false, index, -1, -1, this, null ));
        }
	}
}
