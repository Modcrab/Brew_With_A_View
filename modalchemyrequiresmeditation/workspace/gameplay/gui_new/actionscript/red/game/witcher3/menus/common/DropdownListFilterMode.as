/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import scaleform.clik.core.UIComponent;
	public class DropdownListFilterMode extends CheckboxListMode
	{
		override protected function configUI():void
		{
			super.configUI();
			
			mcTitle.text = "[[gui_panel_filter_by]]";
			
			var defaultData : Array;
			defaultData = [{ key:"HasIngredients", label:"[[gui_panel_filter_has_ingredients]]", isChecked:true },
						   { key:"MissingIngredients", label:"[[gui_panel_filter_elements_missing]]", isChecked:true },
						   { key:"AlreadyCrafted", label:"[[gui_panel_filter_already_crafted]]", isChecked:true } ];
			setData(defaultData);
		}
	}
}