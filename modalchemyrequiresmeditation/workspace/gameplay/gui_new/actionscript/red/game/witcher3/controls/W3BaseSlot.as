/***********************************************************************
/** Base slot for inventory, containers, alchemy, paperdoll, shops etc
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	import red.game.witcher3.data.GridData;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	//import witcher3.managers.W3DragManager;
	
	//import flash.events.MouseEvent;
	
	public class W3BaseSlot extends ListItemRenderer
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var mcLoader:W3UILoader;

		/********************************************************************************************************************
			PUBLIC CONSTANTS
		/ ******************************************************************************************************************/

		public static const DEFAULT_GROUPNAME:String = "default";
	
		/********************************************************************************************************************
			COMPONENT PROPERTIES
		/ ******************************************************************************************************************/
	
		protected var _iconPath : String;
		protected var gridData:GridData;

		/********************************************************************************************************************
			HACKS
		/ ******************************************************************************************************************/
		
		public function getGridData() : GridData // #B move it to better place
		{
			return gridData;
		}
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function W3BaseSlot()
		{
			super();
			mouseChildren = tabChildren = false;
			//tfQuantity.autoSize = TextFieldAutoSize.RIGHT;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			mcLoader.maintainAspectRatio = false;
		}
		
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/
			
		public function get IconPath():String
		{
			return _iconPath;
		}
		
		public function set IconPath( value:String ):void
		{
			if (_iconPath != value || _iconPath == "" )
			{
				_iconPath = value;
				if (_iconPath != "" )
				{
					mcLoader.source = "img://" + _iconPath;
				}
				else
				{
					mcLoader.fallbackIconPath = "";
					mcLoader.source = "";
				}
			}
		}
		
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
	
        override public function setListData(listData:ListData):void
		{
			gridData = listData as GridData;
			if ( gridData )
			{
				IconPath = gridData.iconPath;
			}
			else
			{
				IconPath = "";
				ResetIcons();
			}
			update();
		}
		
		// FIXME: Maybe update should be part of data or gridData...
		override public function setData( data:Object ):void
		{
			super.setData( data );
			update();
		}
		
		override protected function updateAfterStateChange():void
		{
			super.updateAfterStateChange();
			update();
		}

		override protected function initialize():void // #B ?????????????
		{
			super.initialize();
			toggle = true;
			allowDeselect = false;
			if ( _group == null )
			{
                groupName = DEFAULT_GROUPNAME; // #B?
            }
		}
		
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}
		
		override public function toString():String
		{
			return "[W3 BaseSlot: iconPath " + _iconPath + ", index " + _index + "]";
		}
					
		/********************************************************************************************************************
			UPDATES & CALLBACKS
		/ ******************************************************************************************************************/
		
		protected function update():void
		{
			// #B update icon ?
		}
		
		protected function ResetIcons() : void
		{
		}
		
		override public function setSize(width:Number, height:Number):void {
			trace("INVENTORY setSize ",this);
        }
	}
}