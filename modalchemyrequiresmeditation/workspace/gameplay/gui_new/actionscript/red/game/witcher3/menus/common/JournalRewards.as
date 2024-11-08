/***********************************************************************
/** Journal Rewards
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.slots.SlotsListGrid;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.utils.CommonUtils;

	public class JournalRewards extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var tfRewards : TextField;
		public var tfExperience : TextField;
		public var tfExperienceValue : TextField;
		public var mcRewardGrid : SlotsListGrid;

	
		public var mcRewardsBackground : MovieClip;

		public var titleString : String = "[[panel_journal_quest_rewards]]";
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		public var dataBindingKeyReward : String = "journal.objectives.list.reward.items";
		//protected var journalRewardModule : JournalRewardModule;

		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

		public function JournalRewards()
		{
			super();
		}

		protected override function configUI():void
		{
			super.configUI();
			mouseEnabled = false;
			
			mcRewardGrid.visible = false;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKeyReward, [handleRewardDataSet]));
			//mcRewardGrid.resetRenderers();
			mcRewardGrid.addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			handleExperienceValueSet('0');
			Init();
			//journalRewardModule =
		}

		protected function Init() : void
		{
			if ( tfRewards )
			{
				tfRewards.htmlText = titleString;
				tfRewards.htmlText = CommonUtils.toUpperCaseSafe(tfRewards.htmlText);
			}
			if ( tfExperience )
			{
				tfExperience.htmlText = "[[panel_journal_quest_experience]]";
				tfExperience.htmlText = CommonUtils.toUpperCaseSafe(tfExperience.htmlText);
			}
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKeyReward+'.experience', [handleExperienceValueSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'journal.rewards.panel.visible', [handleShowRewards]));

		}

		override public function toString() : String
		{
			return "[W3 JournalRewards]"
		}

		[Inspectable(defaultValue="0")]
		public function get columns():uint { return mcRewardGrid.columns }
		public function set columns(value:uint ):void
		{
			mcRewardGrid.columns = value;
		}

		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/

		protected function handleExperienceValueSet( value : String ):void
		{
			if (tfExperienceValue)
			{
				if ( value == '0' )
				{
					tfExperienceValue.visible = false;
					tfExperience.visible = false;
					
				}
				else
				{
					tfExperienceValue.htmlText = value;
					tfExperienceValue.visible = true;
					tfExperience.visible = true;
					
				}
			}
			CalculateBackgroundHeight();
			/*if ( JournalRewardModule(parent) )
			{
				JournalRewardModule(parent).handleDataChanged();
			}*/
		}

		protected function CalculateBackgroundHeight():void
		{
			var backgroundHeight : Number = 0;
			if( mcRewardGrid.visible )
			{
				backgroundHeight += 117; //#B FIX MAGIC NUMBER
			}
			if (tfExperienceValue.visible)
			{
				backgroundHeight += 63;  //#B FIX MAGIC NUMBER
			}
			mcRewardsBackground.height = backgroundHeight;
			//tfExperience.y = tfExperienceValue.y;
		}

		protected function handleShowRewards( value : Boolean ):void
		{
			this.visible = value;

			if ( !value )
			{
				var displayEvent:GridEvent;
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
				dispatchEvent(displayEvent);
			}
		}

		protected function handleRewardDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;

			if( !dataArray || dataArray.length == 0 )
			{
				mcRewardGrid.visible = false;
				mcRewardGrid.enabled = false;
				
			}
			else
			{
				mcRewardGrid.visible = true;
				mcRewardGrid.enabled = true;
			
				handleShowRewards(true);
				
				if (gameData)
				{
					mcRewardGrid.data = dataArray;
					mcRewardGrid.validateNow();
					mcRewardGrid.selectedIndex = 0;
					
					const CENTER_POINT:Number = 268;
					const CELL_SIZE:Number = 80;
					mcRewardGrid.x = CENTER_POINT - ( mcRewardGrid.NumNonEmptyRenderers() * CELL_SIZE ) / 2;
				}
				
				updateActiveSelectionVisible();
			}
			
			for (var i : int = 0; i < mcRewardGrid.columns; i++ )
			{
				var slot : SlotBase = mcRewardGrid.getRendererAt(i) as SlotBase;
				
				slot.visible = slot.data != null;// (dataArray.length > i);
				slot.draggingEnabled = false; // #J rewards should not be draggable
			}
			CalculateBackgroundHeight();
			
			/*if ( JournalRewardModule(parent) )
			{
				JournalRewardModule(parent).handleDataChanged();
			}*/
		}
		
		public function set activeSelectionVisible(value:Boolean):void
		{
			mcRewardGrid.activeSelectionVisible = value;
			updateActiveSelectionVisible();
		}

		protected function updateActiveSelectionVisible():void
		{
			mcRewardGrid.updateActiveSelectionVisible();
		}

		protected function onGridItemChange( event : GridEvent ):void
		{
			dispatchEvent(event);
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !_focused )
			{
				return;
			}
			mcRewardGrid.handleInputNavSimple(event);
		}

		public function GetSelectedIndex() : int
		{
			return mcRewardGrid.selectedIndex;
		}

		public function SetSelectedIndex( value : int ) : void
		{
			mcRewardGrid.selectedIndex = value;
		}

		public function FindSelectedIndex() : void
		{
			mcRewardGrid.findSelection();
		}

		override public function set focused(value:Number):void
		{
			super.focused = value;
			mcRewardGrid.focused = value;

			var currentSlot:SlotBase = mcRewardGrid.getSelectedRenderer() as SlotBase;
			if (currentSlot)
			{
				currentSlot.activeSelectionEnabled = value != 0;

				if (!value)
				{
					currentSlot.hideTooltip();
				}
				else
				{
					currentSlot.showTooltip();
				}
			}
		}

		public function HasItems() : Boolean
		{
			return mcRewardGrid.visible && mcRewardGrid.NumNonEmptyRenderers() > 0;
		}
	}
}
