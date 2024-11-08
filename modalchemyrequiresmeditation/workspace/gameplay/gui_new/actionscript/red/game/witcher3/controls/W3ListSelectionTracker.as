/***********************************************************************
/** List Selection Tracker
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	public class W3ListSelectionTracker extends UIComponent
	{
		protected static const ITEM_SIZE:Number = 6;
		protected static const ITEM_PADDING:Number = 2.5;
		
		public var mcSelectionTracker1:MovieClip;
		public var mcSelectionTracker2:MovieClip;
		public var mcSelectionTracker3:MovieClip;
		public var mcSelectionTracker4:MovieClip;
		public var mcSelectionTracker5:MovieClip;
		public var mcSelectionTracker6:MovieClip;
		public var mcSelectionTracker7:MovieClip;
		public var mcSelectionTracker8:MovieClip;
		public var mcSelectionTracker9:MovieClip;
		public var mcSelectionTracker10:MovieClip;
		public var mcSelectionTracker11:MovieClip;
		public var mcSelectionTracker12:MovieClip;
		public var mcSelectionTracker13:MovieClip;
		public var mcSelectionTracker14:MovieClip;
		public var mcSelectionTracker15:MovieClip;
		public var mcSelectionTracker16:MovieClip;
		public var mcSelectionTracker17:MovieClip;
		public var mcSelectionTracker18:MovieClip;
		public var mcSelectionTracker19:MovieClip;
		public var mcSelectionTracker20:MovieClip;
		
		protected var _indicatorsList:Vector.<MovieClip>;
		protected var _visibleWidth:Number;
		
		override protected function configUI():void
		{
			super.configUI();
			
			setupIndicatorsList();
		}
		
		protected function setupIndicatorsList():void
		{
			_indicatorsList = new Vector.<MovieClip>();
			_indicatorsList.push(mcSelectionTracker1);
			_indicatorsList.push(mcSelectionTracker2);
			_indicatorsList.push(mcSelectionTracker3);
			_indicatorsList.push(mcSelectionTracker4);
			_indicatorsList.push(mcSelectionTracker5);
			_indicatorsList.push(mcSelectionTracker6);
			_indicatorsList.push(mcSelectionTracker7);
			_indicatorsList.push(mcSelectionTracker8);
			_indicatorsList.push(mcSelectionTracker9);
			_indicatorsList.push(mcSelectionTracker10);
			_indicatorsList.push(mcSelectionTracker11);
			_indicatorsList.push(mcSelectionTracker12);
			_indicatorsList.push(mcSelectionTracker13);
			_indicatorsList.push(mcSelectionTracker14);
			_indicatorsList.push(mcSelectionTracker15);
			_indicatorsList.push(mcSelectionTracker16);
			_indicatorsList.push(mcSelectionTracker17);
			_indicatorsList.push(mcSelectionTracker18);
			_indicatorsList.push(mcSelectionTracker19);
			_indicatorsList.push(mcSelectionTracker20);
		}
		
		public function set numElements(value:int):void
		{
			var i:int;
			
			_visibleWidth = ITEM_SIZE * value + ITEM_PADDING * (value - 1);
			for (i = 0; i < _indicatorsList.length; ++i)
			{
				if (i < value)
				{
					if (i == _selectedIndex)
					{
						_indicatorsList[i].gotoAndStop("Active");
					}
					else
					{
						_indicatorsList[i].gotoAndStop("Inactive");
					}
				}
				else
				{
					_indicatorsList[i].gotoAndStop("Hidden");
				}
			}
		}
		
		public function getVisibleWidth():Number
		{
			return _visibleWidth;
		}
		
		protected var _selectedIndex:int = -1;
		public function set selectedIndex(value:int):void
		{
			if (value != _selectedIndex)
			{
				if (_selectedIndex != -1)
				{
					_indicatorsList[_selectedIndex].gotoAndStop("Inactive");
				}
				
				_selectedIndex = value;
				
				if (_selectedIndex != -1)
				{
					_indicatorsList[_selectedIndex].gotoAndStop("Active");
				}
			}
		}
	}
}
