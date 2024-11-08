package red.game.witcher3.menus.common 
{
	
	/**
	 * package red.game.witcher3.menus.common.DropdownEnchantmentsFilterMode
	 * @author Getsevich Yaroslav
	 */
	public class DropdownEnchantmentsFilterMode extends CheckboxListMode
	{
		override protected function configUI():void
		{
			super.configUI();
			
			mcTitle.text = "[[gui_panel_filter_by]]";
			
			var defaultData : Array;
			defaultData = [{ key:"HasIngredients", label:"[[gui_panel_filter_has_ingredients]]", isChecked:true },
						   { key:"MissingIngredients", label:"[[gui_panel_filter_elements_missing]]", isChecked:true },
						   
						   { key:"Level1", label:"[[panel_enchanting_filter_level_1_enchant]]", isChecked:true }, 
						   { key:"Level2", label:"[[panel_enchanting_filter_level_2_enchant]]", isChecked:true },
						   { key:"Level3", label:"[[panel_enchanting_filter_level_3_enchant]]", isChecked:true } ];
			
			setData(defaultData);
		}
	}

}
