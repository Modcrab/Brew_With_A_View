/***********************************************************************
/** Inventory Player statistic module
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.menus.mainmenu.IngameMenu;
	import red.game.witcher3.menus.overlay.BasePopup;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.ScrollBar
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	
	// #J Started as a module but changed to popup and don't have time to clean it properly. Sorry for confusion.
	public class PlayerFullStatsModule extends BasePopup
	{
		public var txtTitle:TextField;
		public var txtMagicTitle:TextField;
		public var txtDamageTitle:TextField;
		public var txtResistanceTitle:TextField;
		
		private var statDictionary:Dictionary;
		
		public var mcList:W3ScrollingList;
		public var mcAdaptiveStatsListItem1:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem2:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem3:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem4:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem5:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem6:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem7:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem8:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem9:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem10:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem11:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem12:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem13:AdaptiveStatsListItem;
		public var mcAdaptiveStatsListItem14:AdaptiveStatsListItem;
		
		public var mcScrollbar:ScrollBar;
		
		protected function get popupName():String
		{
			return "CharacterStatsPopup";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			alpha = 0;
			visible = false;
			
			SetupStatDictionary();
			
			if (_data != null)
			{
				show();
			}
			
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll, true, 0, true);
			
			this.focused = 1;
		}
		
		public override function set data(value:Object):void
		{
			_data = value;
			
			if (statDictionary != null)
			{
				show();
			}
		}
		
		public function show():void
		{
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
			
			fillStatsData(_data.stats as Array);
			
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
		}
		
		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { } );
			}
		}
		
		protected function SetupStatDictionary():void
		{
			statDictionary = new Dictionary();
			
			var i:int;
			var currentChild:W3StatisticsListItem;
			
			for (i = 0; i < numChildren; ++i)
			{
				currentChild = getChildAt(i) as W3StatisticsListItem;
				
				if (currentChild && currentChild.statID != "")
				{
					statDictionary[currentChild.statID] = currentChild;
				}
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			if (keyPress)
			{
				switch (details.navEquivalent)
				{
				case NavigationCode.DOWN:
				case NavigationCode.RIGHT_STICK_DOWN:
					{
						++mcScrollbar.position;
					}
					break;
				case NavigationCode.UP:
				case NavigationCode.RIGHT_STICK_UP:
					{
						--mcScrollbar.position;
					}
					break;
				}
			}
		}
		
		protected function onScroll( event : MouseEvent ) : void
		{
			if ( event.delta > 0 )
			{
				--mcScrollbar.position;
			}
			else
			{
				++mcScrollbar.position;
			}
			event.stopImmediatePropagation();
		}
		
		protected function fillStatsData(statsInfo:Array):void
		{
			if (!statsInfo)
			{
				throw new Error("GFX - Invalid data array sent to popup");
			}
			
			for each(var curItem:W3StatisticsListItem in statDictionary)
			{
				curItem.visible = false;
			}
			
			var i:int;
			var currentData:Object;
			var currentStatsItem:W3StatisticsListItem;
			
			for (i = 0; i < statsInfo.length; )
			{
				currentData = statsInfo[i];
				currentStatsItem = statDictionary[currentData.tag];
				
				if (currentStatsItem != null)
				{
					currentStatsItem.visible = true;
					currentStatsItem.setData(currentData);
					statsInfo.splice(i, 1);
				}
				else
				{
					++i;
				}
			}
			
			mcList.dataProvider = new DataProvider(statsInfo);
		}
	}
}