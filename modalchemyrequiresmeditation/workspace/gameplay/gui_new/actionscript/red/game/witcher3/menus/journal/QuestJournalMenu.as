/***********************************************************************
/** PANEL jurnal quest main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.journal
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import scaleform.clik.events.ListEvent;

	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.menus.common.TextAreaModule;
	import red.game.witcher3.menus.common.ItemDataStub;

	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class QuestJournalMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/

		public var 		mcQuestListModule					: QuestListModule;
		public var 		mcObjectiveListModule				: QuestSubListModule;
		public var 		mcTextAreaModule					: TextAreaModuleCustomInput; 
		public var		mcCurrentlyTrackedQuest				: MovieClip;
		public var 		mcCurrentlyTrackedObjective			: MovieClip;

		public var 		mcAnchor_MODULE_Tooltip				: MovieClip;

		/********************************************************************************************************************
				INIT
		/ ******************************************************************************************************************/

		public function QuestJournalMenu()
		{
			super();
			mcQuestListModule.menuName = menuName;
			SetDataBindings();
		}

		protected function SetDataBindings() : void
		{
			mcTextAreaModule.dataBindingKey = "journal.quest.description";
		}

		override protected function get menuName():String
		{
			return "JournalQuestMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			
			var titleText:TextField;
			
			if (mcCurrentlyTrackedQuest)
			{
				titleText = mcCurrentlyTrackedQuest.getChildByName("txtTitle") as TextField;
				
				if (titleText)
				{
					titleText.text = "[[panel_hub_journal_tracked]]";
				}
				
				mcCurrentlyTrackedQuest.visible = false;
			}
			
			if (mcCurrentlyTrackedObjective)
			{
				titleText = mcCurrentlyTrackedObjective.getChildByName("txtTitle") as TextField;
				
				if (titleText)
				{
					titleText.text = "[[panel_journal_current_objective]]";
				}
				
				mcCurrentlyTrackedObjective.visible = false;
			}

			//trace("DROPDOWN QuestJournalMenu# configUI start");
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			stage.invalidate();
			validateNow();

			focused = 1;
			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
			
			mcQuestListModule.addEventListener(ListEvent.INDEX_CHANGE, handleListItemChanged, false, 0, true);
		}
		
		private function handleListItemChanged(event:ListEvent):void
		{
			trace("GFX ------------------- handleListItemChanged ", event.itemData);
			
			if (event.itemData)
			{
				mcTextAreaModule.SetTitle(event.itemData.label);
				mcTextAreaModule.SetText( event.itemData.description );
				mcTextAreaModule.setDifficulty( event.itemData.reqdifficulty );
				mcTextAreaModule.setLocation( event.itemData.secondLabel );
				mcTextAreaModule.setHeaderColor(event.itemData.isStory);
				mcTextAreaModule.setCrest(event.itemData.questArea);
				mcTextAreaModule.ShowSkullIcon(event.itemData.isdeadlydifficulty);
			}
		
			
		}
		
		public function setTitle( value : String ) : void
		{
			if (mcTextAreaModule)
			{
				//mcTextAreaModule.SetTitle(value);
			}
		}
		
		public function setText( value : String  ) : void
		{
			if (mcTextAreaModule)
			{
				//mcTextAreaModule.SetText(value);
			}
		}
		
		
		public function setExpansionTexture( epIndex : int, texture : String )
		{
			mcObjectiveListModule.LoadExpansionTexture( epIndex, texture );
		}
		
		public function updateExpansionIcon( epIndex : int )
		{
			mcObjectiveListModule.updateExpansionIcon( epIndex );
		}

		/********************************************************************************************************************
				FUNCTIONS
		/ ******************************************************************************************************************/

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			for each ( var handler:UIComponent in actualModules )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B :
						hideAnimation();
						break;
				}
			}
		}
		
		public function setCurrentlyTrackedQuest(questText:String):void
		{
			if (mcCurrentlyTrackedQuest)
			{
				var textField:TextField = mcCurrentlyTrackedQuest.getChildByName("txtCurrentObjective") as TextField;
				
				if (textField)
				{
					mcCurrentlyTrackedQuest.visible = true;
					
					textField.text = questText;
				}
			}
			
			mcQuestListModule.updateItemInputFeedback();
		}
		
		public function setCurrentlyTrackedObjective(questText:String):void
		{
			if (mcCurrentlyTrackedObjective)
			{
				var textField:TextField = mcCurrentlyTrackedObjective.getChildByName("txtCurrentObjective") as TextField;
				
				if (textField)
				{
					mcCurrentlyTrackedObjective.visible = true;
					
					textField.text = questText;
				}
			}
		}

		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}

		protected function onGridItemChange( event:GridEvent ) : void
		{
			var itemDataStub:ItemDataStub = event.itemData as ItemDataStub;
			var displayEvent:GridEvent;
			if (itemDataStub)
			{
				if (itemDataStub.id)
				{
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
				else
				{
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
			}
			else
			{
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
			}
			dispatchEvent(displayEvent);
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			mcObjectiveListModule.visible = value;
			mcObjectiveListModule.enabled = value;

			mcTextAreaModule.visible = value;
			mcTextAreaModule.enabled = value;
		}
		
		override protected function onLastMoveStatusChanged()
		{
			super.onLastMoveStatusChanged();
			
			if (_lastMoveWasMouse)
			{
				currentModuleIdx = 0;
			}
			
			mcObjectiveListModule.updateLastMoveWasMouseNavigation(_lastMoveWasMouse);
		}
	}
}
