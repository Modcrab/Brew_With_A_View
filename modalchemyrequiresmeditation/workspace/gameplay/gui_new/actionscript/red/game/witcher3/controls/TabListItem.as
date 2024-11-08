/*******red\game\witcher3\controls**************************************
/** LIST ITEM FOR TABS, USED FOR INVENTORY GRID & ...
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.ListItemRenderer;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import flash.events.MouseEvent;
	import red.game.witcher3.menus.common.TabListItemIconsContainer;
	import flash.events.Event;
	
	public class TabListItem extends BaseListItem
	{
		public var mcIcon : MovieClip;
		public var mcBck : MovieClip;
		
		public function TabListItem()
		{
			super();
		}
		
		public function GetLocKey():String
		{
			return (data && data.locKey) ? data.locKey : "";
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if (! data )
			{
				return;
			}
			if ( data.enabled != null )
			{
				enabled =  data.enabled;
			}
			if ( mcIcon && data.icon )
			{
				mcIcon.gotoAndStop( data.icon );
			}
		}
		
		public function getIconData():String
		{
			if (data && data.icon)
			{
				return data.icon;
			}
			else
			{
				return "";
			}
		}
		
		public function setIsOpen(value:Boolean):void {}
		
		override protected function updateAfterStateChange():void
		{
			if (mcIcon)
			{
				stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
				if (data)
				{
					mcIcon.gotoAndStop( data.icon );
				}
			}
		}
		
		override public function gotoAndPlay (frame:Object, scene:String = null) : void //#B fastest approach
		{
			super.gotoAndStop(frame, scene);
		}
		
		public function GetCurrentWidth() : Number
		{
			return width + textField.textWidth;
		}
		
		override public function handleInput(event:InputEvent):void
		{}
	}
}
