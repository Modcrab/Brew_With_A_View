/***********************************************************************
/** Journal tabs module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.journal
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.TabListItem;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.managers.InputManager;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.menus.common.JournalRewardModule;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.UILoader;

	public class QuestSubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var mcList : W3ScrollingList;
		public var mcListItem1 : ObjectiveItemRenderer;
		public var mcListItem2 : ObjectiveItemRenderer;
		public var mcListItem3 : ObjectiveItemRenderer;
		public var mcListItem4 : ObjectiveItemRenderer;
		public var mcListItem5 : ObjectiveItemRenderer;
		public var mcListItem6 : ObjectiveItemRenderer;
		public var mcListItem7 : ObjectiveItemRenderer;
		public var mcListItem8 : ObjectiveItemRenderer;
		public var mcListItem9 : ObjectiveItemRenderer;
		public var mcListItem10 : ObjectiveItemRenderer;

		
	

		public var mcScrollbar : ScrollBar;

		//public var tfQuest: TextField;
		public var tfObjectives : TextField;

		public var mcObjectivesBackground : MovieClip;
	

		public var mcExpansionIcon1 : UILoader;
		public var mcExpansionIcon2 : UILoader;
		public var mcExpIconAnchor : MovieClip;
		
		private var _expansionIcon : int;

		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/

		protected var _trackInputFeedback:int = -1;

		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

		public function QuestSubListModule()
		{
			super();
		}

		override public function hasSelectableItems():Boolean
		{
			if (mcListItem1 == null || !mcListItem1.hasData())
			{
				return super.hasSelectableItems();
			}

			return true;
		}

		protected override function configUI():void
		{
			//_inputHandlers.push(mcList);
			super.configUI();
			selectRewardsOnFocus = false;
			this.focusable = true;
			mcList.focusable = false;
			enabled = true;
			Init();
		}

		protected function Init() : void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			mcList.addEventListener( ListEvent.INDEX_CHANGE, OnListItemClick, false, 0, true ); // #B maybe shuld be Event change ?
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + '.questname', [handleQuestNameSet]));

			stage.addEventListener( W3ScrollingList.REPOSITION, repositionRenderers, false, 0, true);

			//mcList.selectedIndex = 0;
			//tfObjectives.htmlText = "[[panel_journal_quest_objectives]]";
			tfObjectives.htmlText = "";
			//tfObjectives.htmlText = CommonUtils.toUpperCaseSafe(tfObjectives.htmlText);
		}

		override public function toString() : String
		{
			return "[W3 QuestSubListModule]"
		}

		public function LoadExpansionTexture( epIndex : int, texture : String )
		{
			if ( epIndex == 1 )
			{
				mcExpansionIcon1 = new UILoader();
				mcExpansionIcon1.scaleX = 0.7;
				mcExpansionIcon1.scaleY = 0.7;
				mcExpansionIcon1.source = texture;
				mcExpansionIcon1.visible = false;
				addChild( mcExpansionIcon1 );
				
				mcExpansionIcon1.x = mcExpIconAnchor.x;
				mcExpansionIcon1.y = mcExpIconAnchor.y;
			}
			else if ( epIndex == 2 )
			{
				mcExpansionIcon2 = new UILoader();
				mcExpansionIcon2.scaleX = 0.7;
				mcExpansionIcon2.scaleY = 0.7;
				mcExpansionIcon2.source = texture;
				mcExpansionIcon2.visible = false;
				addChild( mcExpansionIcon2 );
				
				mcExpansionIcon2.x = mcExpIconAnchor.x;
				mcExpansionIcon2.y = mcExpIconAnchor.y;
			}
		}
		
		public function updateExpansionIcon( epIndex : int )
		{
			_expansionIcon = epIndex;
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/

		private function OnListItemClick( event:ListEvent ):void
		{
			/*mcList.selectedIndex = event.index;
			var mcListItem : ObjectiveItemRenderer = mcList.getRendererAt(mcList.selectedIndex) as ObjectiveItemRenderer;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnObjectiveSelected', [mcListItem.data.tag]) );*/
			mcList.validateNow();
			repositionRenderers();
		}
		
		override protected function handleSlotClick(event:ListEvent):void
		{
			// don't want this behavior from base module implementation
		}

		protected function objectiveSorter( a, b ):int
		{
			if (a.status != b.status)
			{
				// JS_Active = 1
				if (a.status == 1)
				{
					return -1;
				}
				else if (b.status == 1)
				{
					return 1;
				}
			}
			
			if (a.phaseIndex != b.phaseIndex)
			{
				return a.phaseIndex - b.phaseIndex;
			}

			return a.objectiveIndex - b.objectiveIndex;
		}

		protected function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;

			dataArray.sort(objectiveSorter);
			insertOrDelimiter( dataArray );

			if( dataArray.length == 0 )
			{
				tfObjectives.visible = false;
			}
			else
			{
				tfObjectives.visible = true;
			}

			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcList.dataProvider = new DataProvider(dataArray);
				}
			}
			else if (gameData)
			{
				mcList.dataProvider = new DataProvider(dataArray);
				/*if ( dataArray.length < 1 )
				{
					tfObjectives.visible = false;
				}
				else
				{
					tfObjectives.visible = true;
				}*/
			}

			mcList.ShowRenderers(true);
			mcList.selectedIndex = 0;
			mcRewards.SetSelectedIndex( -1 );

			mcList.validateNow();

			if (!focused && mcList.selectedIndex != -1)
			{
				var renderer:ObjectiveItemRenderer = mcList.getSelectedRenderer() as ObjectiveItemRenderer;
				if (renderer) renderer.selectionGlowEnabled = false;
			}

			repositionRenderers();
			
			var lastIndex:int =  Math.min(mcList.dataProvider.length, mcList.getRenderers().length) - 1;
			var lastRenderer : ObjectiveItemRenderer = mcList.getRendererAt(lastIndex) as ObjectiveItemRenderer;
			
			trace("Minimap --------------- lastIndex ", lastIndex, mcList.dataProvider.length, mcList.getRenderers().length );
			trace("Minimap --------------- lastRenderer", lastRenderer);
			
			if ( lastRenderer )
			{
				mcObjectivesBackground.height = lastRenderer.y + lastRenderer.actualHeight + 30 - mcObjectivesBackground.y;
			}
			else
			{
				mcObjectivesBackground.height = 0;
			}
			
			handleDataChanged();
			/*var renderer : ObjectiveItemRenderer = mcList.getRendererAt(0) as ObjectiveItemRenderer;
			if (renderer)
			{
				renderer.SetIsNew(false);
			}*/

			switch ( _expansionIcon )
			{
				case 0:
					if ( mcExpansionIcon1)
						mcExpansionIcon1.visible = false;
					if ( mcExpansionIcon2 )
						mcExpansionIcon2.visible = false;
					break;
				case 1:
					if ( mcExpansionIcon1)
						mcExpansionIcon1.visible = true;
					if ( mcExpansionIcon2 )
						mcExpansionIcon2.visible = false;
					break;
				case 2:
					if ( mcExpansionIcon1)
						mcExpansionIcon1.visible = false;
					if ( mcExpansionIcon2 )
						mcExpansionIcon2.visible = true;
					break;
			}
			if ( mcExpansionIcon1 )
				mcExpansionIcon1.y = lastRenderer.y + lastRenderer.height ;
			if ( mcExpansionIcon2 )
				mcExpansionIcon2.y = lastRenderer.y + lastRenderer.height  -  mcExpansionIcon2.height/2;
		}

		public function repositionRenderers():void
		{
			var i :int;
			var curObjective : ObjectiveItemRenderer;
			var NextPosY : Number = mcList.y;
			
			trace("GFX ----------------- Renderers being repositioned ---------------------- ");

			for ( i = 0; i < mcList.numRenderers; ++i)
			{
				curObjective = mcList.getRenderers()[i] as ObjectiveItemRenderer;
				curObjective.validateNow();

				if (curObjective)
				{
					curObjective.y = NextPosY;
					NextPosY += curObjective.textField.textHeight + 15;
				}
			}
			mcScrollbar.height = NextPosY - mcScrollbar.y - 5;
		}

		protected function handleQuestNameSet(  name : String ):void
		{
			/*if (tfQuest)
			{
				tfQuest.htmlText = name;
			}*/
		}

		private function updateInputFeedback():void
		{
			var renderer:ObjectiveItemRenderer;
			renderer = mcList.getSelectedRenderer() as ObjectiveItemRenderer;
			
			var shouldShow:Boolean = _focused > 0 && renderer && renderer.data && !renderer.data.tracked && renderer.data.status == 1;
			
			if (shouldShow && _trackInputFeedback < 0)
			{
				_trackInputFeedback = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_journal_track");
				InputFeedbackManager.updateButtons(this);
			}
			else if (!shouldShow && _trackInputFeedback >= 0)
			{
				InputFeedbackManager.removeButton(this, _trackInputFeedback);
				InputFeedbackManager.updateButtons(this);
				_trackInputFeedback = -1;
			}
		}

		override public function set focused(value:Number):void
		{
			mcList.focused = 0;
			mcRewards.focused = 0;

            if (value == _focused || !_focusable)
			{
				return;
			}

			super.focused = value;

			updateInputFeedback();

			var rewardRenderer:SlotBase;
			if ( value )
			{
				if ( mcList.selectedIndex == -1 && mcRewards.mcRewardGrid.selectedIndex == -1 )
				{
					if (  mcList.dataProvider.length > 0 )
					{
						mcList.selectedIndex = 0;
						mcRewards.SetSelectedIndex(-1);
					}
					else if( mcRewards.mcRewardGrid.data.length > 0 )
					{
						mcRewards.SetSelectedIndex(0);
						mcRewards.FindSelectedIndex();
						mcList.selectedIndex = - 1;
					}
				}
			}
			
			setActiveSelectionEnabled(value != 0 && !_lastMoveWasMouse);
		}
		
		override protected function handleControllerChanged(event:Event):void
		{
			super.handleControllerChanged(event);
		}
		
		protected var _lastMoveWasMouse:Boolean = false;
		public function updateLastMoveWasMouseNavigation(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			setActiveSelectionEnabled(focused != 0 && !_lastMoveWasMouse);
		}
		
		public function setActiveSelectionEnabled(value:Boolean)
		{
			mcRewards.activeSelectionVisible = value;
			
			var renderer:ObjectiveItemRenderer;
			for (var i:int = 0; i < mcList.getRenderers().length; ++i)
			{
				renderer = mcList.getRendererAt(i) as ObjectiveItemRenderer;
				if (renderer) renderer.selectionGlowEnabled = value;
			}
		}

		override public function handleInput( event:InputEvent ):void // #B fix it !!!
		{
			if ( event.handled || !_focused )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if ( keyPress )
			{
				trace("JOURNAL");
				switch (details.navEquivalent)
				{
					/* case NavigationCode.GAMEPAD_A:
						if (selected)
						{

							event.handled = true;
						}*/
					case NavigationCode.UP:
						if ( mcRewards.GetSelectedIndex() > -1 )
						{
							//trace("GFX JOURNAL ************************ ");
							//trace("GFX JOURNAL handleInput UP mcRewards.GetSelectedIndex() > -1 opt1 "+mcRewards.GetSelectedIndex());
							//trace("GFX JOURNAL ************************ ");
							mcRewards.SetSelectedIndex(-1);
							event.handled = true;
							mcList.selectedIndex = mcList.dataProvider.length - 1;
						}
						else if ( mcList.selectedIndex == 0 && details.value != InputValue.KEY_HOLD ) //#J Added in a check for Key_Hold to stop the wrap when pressing and holidng
						{
							//trace("GFX JOURNAL ************************ ");
							//trace("GFX JOURNAL UP mcList.selectedIndex == 0 opt2 "+mcList.selectedIndex+" mcRewards.HasItems() "+mcRewards.HasItems());
							//trace("GFX JOURNAL ************************ ");
							if ( mcRewards.HasItems() )
							{
								mcRewards.SetSelectedIndex(0);
								mcRewards.FindSelectedIndex();
								event.handled = true;
								mcList.selectedIndex = - 1;
							}
						}
						break;
					case NavigationCode.DOWN:
						if ( mcRewards.GetSelectedIndex() > -1 && details.value != InputValue.KEY_HOLD) //#J Added in a check for Key_Hold to stop the wrap when pressing and holidng
						{
							//trace("GFX JOURNAL ************************ ");
							//trace("GFX JOURNAL DOWN mcRewards.GetSelectedIndex() > -1 opt3 "+mcRewards.GetSelectedIndex());
							//trace("GFX JOURNAL ************************ ");
							mcRewards.SetSelectedIndex(-1);
							event.handled = true;
							mcList.selectedIndex = 0;
						}
						else if ( mcList.selectedIndex == mcList.dataProvider.length - 1 )
						{
							//trace("GFX JOURNAL ************************ ");
							//trace("GFX JOURNAL DOWN  mcList.selectedIndex == mcList.dataProvider.length - 1 opt4 "+mcList.selectedIndex +" mcRewards.HasItems() "+mcRewards.HasItems());
							//trace("GFX JOURNAL ************************ ");
							if ( mcRewards.HasItems() )
							{
								mcList.selectedIndex = - 1;
								mcRewards.SetSelectedIndex(0);
								mcRewards.FindSelectedIndex();
								event.handled = true;
							}
						}
						break;
					default:
						break;
				}

				if ( !event.handled )
				{
					if( mcRewards.GetSelectedIndex() > -1 )
					{
						//trace("GFX JOURNAL ************************ ");
						//trace("GFX JOURNAL DOWN/UP mcRewards.GetSelectedIndex() > -1 opt5 "+mcRewards.GetSelectedIndex());
						//trace("GFX JOURNAL ************************ ");
						mcRewards.handleInput(event);
					}
					else if ( mcList.selectedIndex > -1 )
					{
						//trace("GFX JOURNAL ************************ ");
						//trace("GFX JOURNAL DOWN/UP mcList.selectedIndex > -1 opt6 "+mcList.selectedIndex );
						//trace("GFX JOURNAL ************************ ");
						mcList.handleInput(event);
					}
				}
				updateInputFeedback();
			}
		}
		
		private function insertOrDelimiter( dataArray:Array )
		{
			var i : int;
			var prevMutuallyExclusive : Boolean = false;
			
			if ( dataArray == null )
			{
				return;
			}

			/*
			trace( "Minimap2 =======================" );
			for ( i = 0; i < dataArray.length; ++i )
			{
				trace( "Minimap2 [" + i + "] [" + dataArray[ i ].isMutuallyExclusive + "] [" + dataArray[ i ].label + "]" );
			}
			*/

			for ( i = 0; i < dataArray.length; ++i )
			{
				if ( prevMutuallyExclusive )
				{
					if ( isActiveAndMutuallyExclusive( dataArray[ i ] ) )
					{
						// put delimiter
						var delimiter : Object = new Object();
						
						// just for compatibility
						delimiter["tag"] = 0;
						delimiter["isNew"] = false;
						delimiter["tracked"] = false;
						delimiter["isLegend"] = false;
						delimiter["status"] = ObjectiveItemRenderer.DELIMITER_STATUS;
						delimiter["label"] = "[[hud_questracker_or]]";
						delimiter["phaseIndex"] = 0;
						delimiter["objectiveIndex"] = 0;
						delimiter["isMutuallyExclusive"] = false;
						
						/*
						l_questObjectiveDataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_objectiveTag) ); //#B change to cguid				
						l_questObjectiveDataFlashObject.SetMemberFlashBool( "isNew", l_objectiveIsNew );
						l_questObjectiveDataFlashObject.SetMemberFlashBool( "tracked", l_objectiveIsTracked );
						l_questObjectiveDataFlashObject.SetMemberFlashBool( "isLegend", false );
						l_questObjectiveDataFlashObject.SetMemberFlashInt( "status", l_objectiveStatus );
						l_questObjectiveDataFlashObject.SetMemberFlashString(  "label", l_objectiveTitle + l_objectiveProgress );
						l_questObjectiveDataFlashObject.SetMemberFlashInt( "phaseIndex", 1 );
						l_questObjectiveDataFlashObject.SetMemberFlashInt( "objectiveIndex", l_objectiveOrder );
						l_questObjectiveDataFlashObject.SetMemberFlashBool( "isMutuallyExclusive", l_objective.IsMutuallyExclusive() );
						*/
						
						dataArray.splice( i, 0, delimiter );
					}
				}
				prevMutuallyExclusive = isActiveAndMutuallyExclusive( dataArray[ i ] );
			}
			
			/*
			trace( "Minimap2 =======================" );
			for ( i = 0; i < dataArray.length; ++i )
			{
				trace( "Minimap2 [" + i + "] [" + dataArray[ i ].isMutuallyExclusive + "] [" + dataArray[ i ].label + "]" );
			}
			*/

		}
		
		private function isActiveAndMutuallyExclusive( object : Object ) : Boolean
		{
			return object.isMutuallyExclusive && object.status == 1
		}
	}
}
