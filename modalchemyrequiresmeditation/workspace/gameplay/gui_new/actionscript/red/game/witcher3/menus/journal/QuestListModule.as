//>---------------------------------------------------------------------------
// Module displaying the list of quest on the QuestListPanel
//----------------------------------------------------------------------------
//>---------------------------------------------------------------------------
// Copyright © 2013 CDProjektRed
// R. Pergent
//----------------------------------------------------------------------------
package  red.game.witcher3.menus.journal
{
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	
	public class QuestListModule extends DropdownListModuleBase
	{
		/********************************************************************************************************************
				Init
		/ ******************************************************************************************************************/
		
		public function QuestListModule()
		{
			super();
			_itemInputFeedbackLabel = "panel_button_journal_track";
		}

		override protected function configUI():void
		{
			super.configUI();
			//InitDebugData();
			
			mcDropDownList.restoreSelectionByTag = true;
			mcDropDownList.updateSurgicallyOnDataSet = true;
			
			stage.addEventListener( QuestItemRenderer.UNTRACK, handleUntrackItem, false, 0 , true );
		}
		
		override protected function handleValidateItemItemFeedback(event:Event):void 
		{
			super.handleValidateItemItemFeedback(event);
			
		}
		
		function InitDebugData()
		{
			//#B Hax start
			var l_dataArray : Array; // temp
			l_dataArray = new Array();
			
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Destroy the Alghul", isStory:true, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"Cook a trap", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Harvest Bazyliszek scales", isStory:false, isNew:true, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Conquer the bies 2", isStory:false, isNew:true, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Conquer the bies", isStory:false, isNew:false, isActive:true, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Find The Lair", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Find The Lair2", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"KEAR MORHEN" , dropDownLabel:"Kear Morhen", label:"Free the country", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair1", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair2", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair3", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair5", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devil Lair6", isStory:false, isNew:false, isActive:false, selected:false} );
			
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Destroy the Alghulf", isStory:true, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"Cook a trapf", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Harvest Bazyliszekf scales", isStory:false, isNew:true, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Conquer tfhe bies 2", isStory:false, isNew:true, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"NOVIGRAD" , dropDownLabel:"Novigrad", label:"Conquer thfe bies", isStory:false, isNew:false, isActive:true, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Find The fLair", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"SKELLIGE" , dropDownLabel:"Skellige", label:"Find The Laifr2", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"KEAR MORHEN" , dropDownLabel:"Kear Morhen", label:"Free thef country", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devifl Lair", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Defvil Lair1", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devfl Lair2", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devfil Lair3", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devifl Lair5", isStory:false, isNew:false, isActive:false, selected:false} );
			l_dataArray.push ( { label2:"PROLOGUE VILLAGE" , dropDownLabel:"Prologue Village", label:"The Devifl Lair6", isStory:false, isNew:false, isActive:false, selected:false} );
			
			trace("DROPDOWN "+this+" configUI ");
			handleListData(l_dataArray,-1); // #B hax end
		}
		
		public function handleUntrackItem( event : Event )
		{
			var data:Object;
			var i:int;
			
			if (currentDataArrayRef != null)
			{
				for (i = 0; i < currentDataArrayRef.length; ++i)
				{
					data = currentDataArrayRef[i];
					
					if (data && data.hasOwnProperty("tracked"))
					{
						data.tracked = false;
					}
				}
			}
		}
		
		override protected function canShowSubItemInputFeedback(curItem : W3DropdownMenuListItem ):Boolean
		{
			var currentRenderer:QuestItemRenderer = curItem.GetSubSelectedRenderer(true) as QuestItemRenderer;
			if (currentRenderer && !currentRenderer.data.tracked && currentRenderer.data.status == 1)
			{
				return true;
			}
			return false;
		}
		
		override protected function sortData(targetArray:Array):void
		{
			//targetArray.sort(sortQuestData);
		}
		
		protected function sortQuestData( a, b ):int
		{
			/*
			if (a.status != b.status)
			{
				return a.status - b.status;
			}			
			else if (a.isStory != b.isStory)
			{
				return a.isStory - b.isStory;
			}
			else if (a.tracked)
			{
				return -1;
			}
			else if (b.tracked)
			{
				return 1;
			}
			else if (a.questWorld != b.questWorld)
			{
				if (a.questWorld == a.curWorld)
				{
					return -1;
				}
				else if (b.questWorld == b.curWorld)
				{
					return 1;
				}
				else if (a.questWorld == 0)
				{
					return -1;
				}
				else if (b.questWorld == 0)
				{
					return 1;
				}
				
				return a.questWorld - b.questWorld;
			}
			*/
			
			return 0;
		}
		
		override protected function filterList( a, b ):int
		{
			var lastName	:RegExp = /\b\S+$/;
			var areaA = a.dropDownLabel.match(lastName);
			var areaB = b.dropDownLabel.match(lastName);

			if ( a.dropDownLabel != b.dropDownLabel )
			{
				if ( areaA < areaB )	return -1;
				if ( areaA > areaB )	return 1;
				return 0;
			}
			
			if ( a.isStory == true && b.isStory != true)
			{
				return -1;
			}
			else if (  a.isStory == true && b.isStory == true )
			{
				return 0;
			}
			else
			{
				return 1;
			}
		}
	}

}
