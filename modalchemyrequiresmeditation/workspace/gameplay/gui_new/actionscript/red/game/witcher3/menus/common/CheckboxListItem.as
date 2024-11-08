/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.core.UIComponent;
	
	public class CheckboxListItem extends BaseListItem
	{
		public var mcCheckbox : MovieClip;
		
		protected var _isChecked:Boolean = false;
		public function get isChecked() : Boolean
		{
			return _isChecked;
		}
		public function set isChecked(value:Boolean):void
		{
			if (_isChecked == value)
			{
				return;
			}
			
			_isChecked = value;
			
			updateCheckbox();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			updateCheckbox();
		}
		
		protected function updateCheckbox():void
		{
			if (mcCheckbox)
			{
				if (_isChecked)
				{
					mcCheckbox.gotoAndStop("on");
				}
				else
				{
					mcCheckbox.gotoAndStop("off");
				}
			}
		}
		
		protected var _groupID:String = "";
		public function get groupID():String { return _groupID }
		public function set groupID( value:String ):void { _groupID = value; }
		
		protected var _dataKey:String = "";
		public function get dataKey():String { return _dataKey }
		public function set dataKey( value:String ):void { _dataKey = value; }
		
		override public function setData( data:Object ):void
		{
			super.setData(data);
			
			if (data)
			{
				isChecked = data.isChecked;
				dataKey = data.key;
				
				if (data.hasOwnProperty("groupId") && data.groupId != "")
				{
					groupID = data.groupId;
				}
				else
				{
					groupID = "";
				}
			}
		}
	}
}