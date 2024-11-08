/***********************************************************************
/** Inventory Player statistic module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.InteractiveObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import red.core.CoreMenuModule;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.controls.W3ScrollingCategorizedList;
	import red.game.witcher3.menus.common.W3StatsListItem;
	import red.game.witcher3.menus.common.W3StatisticsListItem;
	import scaleform.clik.data.DataProvider;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	import flash.text.TextField;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.gfx.FocusManager;
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	
	public class PlayerStatsModule extends CoreMenuModule
	{
		public var mcStatsList : W3ScrollingList; 
		public var mcStatsListItem1 : W3StatisticsListItem;
		public var mcStatsListItem2 : W3StatisticsListItem;
		public var mcStatsListItem3 : W3StatisticsListItem;
		public var mcStatsListItem4 : W3StatisticsListItem;
		public var mcStatsListItem5 : W3StatisticsListItem;
		public var mcStatsListItem6 : W3StatisticsListItem;
		public var mcStatsListItem7 : W3StatisticsListItem;
		public var mcStatsListItem8 : W3StatisticsListItem;
		public var mcStatsListItem9 : W3StatisticsListItem;
		public var mcStatsListItem10 : W3StatisticsListItem;
		
		public var tfCurrentState : TextField;
		protected var _moduleDisplayName : String = "";
		
		public function PlayerStatsModule()
		{
			dataBindingKey = "inventory.stats";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "playerstats.stats", [handleStatsUpdate]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "playerstats.stats.name", [handleModuleNameSet]));
			mcStatsList.addEventListener( ListEvent.INDEX_CHANGE, handleIndexChange, false, 0, true );
			mcStatsList.addEventListener( ListEvent.ITEM_ROLL_OVER, handleItemRollOver, false, 0, true);
			mcStatsList.addEventListener( ListEvent.ITEM_ROLL_OUT, handleItemRollOut, false, 0, true);
			_inputHandlers.push(mcStatsList);
		}	
		
		private function handleStatsUpdate( gameData:Object, index:int ):void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array
				mcStatsList.dataProvider = new DataProvider( dataArray );
				mcStatsList.invalidate();
				
				mcStatsList.selectedIndex = 0;
				mcStatsList.invalidateSelectedIndex();
				mcStatsList.validateNow();
				mcStatsList.ShowRenderers(true);
				/*
				if( mcStatsList.selectedIndex == -1 )
				{
					mcStatsList.selectedIndex = 0;
					mcStatsList.invalidateSelectedIndex();
				}
				*/
				handleDataChanged();
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return false;
		}
			
		protected function handleModuleNameSet(  name : String ):void
		{
			if (tfCurrentState)
			{
				_moduleDisplayName = name;
				tfCurrentState.htmlText = name;
			}
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			mcStatsList.focused = value;
			if (tfCurrentState)
			{
				tfCurrentState.htmlText = _moduleDisplayName;
			}
			setCurrentItemContext(mcStatsList.selectedIndex);
			
			if (!focused)
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnStatisticsLostFocus', [] ));
			}
		}
		
		const tooltipOffset:Number = 600; // ?
		protected function handleItemRollOver(event:ListEvent):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			if (!isGamepad)
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, -1, -1, -1, null, null);
				var curRenderer:W3StatisticsListItem = event.itemRenderer as W3StatisticsListItem;
				var itemRendererLoc:Point = localToGlobal(new Point(curRenderer.x, curRenderer.y));
				itemRendererLoc.x -= tooltipOffset;
				
				displayEvent.tooltipCustomArgs = [event.itemData.id];
				displayEvent.isMouseTooltip = !isGamepad;
				displayEvent.anchorRect = new Rectangle(itemRendererLoc.x, itemRendererLoc.y, 0, 0);
				displayEvent.tooltipDataSource = "OnShowStatTooltip";
				//displayEvent.tooltipMouseContentRef = "PlayerStatisticsTooltipRef_Mouse";
				dispatchEvent(displayEvent);
			}
		}
		
		protected function handleItemRollOut(event:ListEvent):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			if (!isGamepad)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, -1, -1, -1, null, null);
				dispatchEvent(hideEvent);
			}
		}
		
		protected function handleIndexChange(event:ListEvent):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			if (isGamepad)
			{
				updateContext(event.itemData.id);
			}
		}
		
		protected function setCurrentItemContext(itemIdx:int):void
		{
			var curStatRenderer:W3StatisticsListItem =  mcStatsList.getRendererAt(itemIdx) as W3StatisticsListItem;
			if (curStatRenderer)
			{
				updateContext(curStatRenderer.GetId())
			}
		}
		
		// #Y remove?
		protected function updateContext(statId:uint):void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, 'OnSelectPlayerStat', [statId]));
		}
	}
}
