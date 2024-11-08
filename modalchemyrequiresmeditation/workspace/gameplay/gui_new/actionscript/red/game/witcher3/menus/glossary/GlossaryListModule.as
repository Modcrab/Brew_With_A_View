package  red.game.witcher3.menus.glossary
{
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	
	public class GlossaryListModule extends DropdownListModuleBase
	{
		/********************************************************************************************************************
				Init
		/ ******************************************************************************************************************/
		
		public function GlossaryListModule()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			//InitDebugData();
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
	}

}