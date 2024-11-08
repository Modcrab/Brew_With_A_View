/***********************************************************************
/** CHaracter Tree Grid List
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	/*import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import scaleform.clik.events.ListEvent;
	
	import flash.utils.getDefinitionByName;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.game.witcher3.data.GridData;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.SkillDataStub;
	
	import red.game.witcher3.menus.common.AbstractGridContainer;*/

	[Event(name="change", type="flash.events.Event")]
    [Event(name="itemClick", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemPress", type="scaleform.clik.events.ListEvent")]
    [Event(name = "itemDoubleClick", type = "scaleform.clik.events.ListEvent")]
	
	public class SkillTreeGrid extends CharacterTreeGrid
	{
		
		[Inspectable(name="slotRenderer", defaultValue="SkillItemRenderer")]
		override public function get slotRendererName() : String
		{
			return _slotRenderer;
		}
	}
}