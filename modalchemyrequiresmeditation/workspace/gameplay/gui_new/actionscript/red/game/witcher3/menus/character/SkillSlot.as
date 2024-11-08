/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	
	import red.game.witcher3.data.GridData;
	import scaleform.clik.events.DragEvent;
	import scaleform.clik.constants.NavigationCode;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3BaseSlot;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	
	public class SkillSlot extends PerkSlot implements IGridItemRenderer
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
    	/********************************************************************************************************************
			COMPONENT PROIPERTIES
		/ ******************************************************************************************************************/
		
    	/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function SkillSlot()
		{
			super();
		}
		
		override protected function configUI() : void
		{
			super.configUI();
		}
		
		/********************************************************************************************************************
			SETTERS & GETTERS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
		
		override protected function updateAcquired()
		{
			if ( mcBackground )
			{
				if(data.acquired)
				{
					mcBackground.gotoAndStop('acquired');
				}
				else if(data.avialable)
				{
					mcBackground.gotoAndStop('available');
				}
				else
				{
					mcBackground.gotoAndStop('notavailable');
				}
			}
		}
		
		override public function toString():String
		{
			return "[W3 SkillSlot: " + ", index " + _index + "]";
		}

		/********************************************************************************************************************
			UPDATES & CALLBACKS
		/ ******************************************************************************************************************/
	}
}