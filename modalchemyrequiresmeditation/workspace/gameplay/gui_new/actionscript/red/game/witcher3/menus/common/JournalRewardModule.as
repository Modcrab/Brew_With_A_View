/***********************************************************************
/** Journal tabs module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.slots.SlotBase;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.TabListItem;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.core.CoreMenuModule;
	
	public class JournalRewardModule extends CoreMenuModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var mcRewards : JournalRewards;
		public var selectRewardsOnFocus:Boolean = true;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		protected var _moduleDisplayName : String = "";
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function JournalRewardModule()
		{
			super();
			dataBindingKey = "journal.objectives.list";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			mouseEnabled = false;
			mcRewards.visible = false;
			mcRewards.mcRewardGrid.focusable = false;
			//_inputHandlers.push(mcRewards);
			//mcRewardGrid.addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
		}

		override public function toString() : String
		{
			return "[W3 JournalRewardModule]"
		}
		
		override public function hasSelectableItems():Boolean
		{
			var firstRenderer:SlotBase = mcRewards.mcRewardGrid.getRendererAt(0) as SlotBase;
			
			if (mcRewards.visible == false || firstRenderer == null || firstRenderer.data == null)
			{
				return false;
			}
			
			return true;
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
		}
		
		override public function set focused(value:Number):void
		{
            if (value == _focused || !_focusable)
			{
				return;
			}
            super.focused = value;
			
			if (selectRewardsOnFocus)
			{
				mcRewards.focused = value;
				mcRewards.mcRewardGrid.selectedIndex = 0;
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !_focused )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if ( keyPress && mcRewards.enabled)
			{
				mcRewards.handleInput(event);
			}
		}
	}
}
