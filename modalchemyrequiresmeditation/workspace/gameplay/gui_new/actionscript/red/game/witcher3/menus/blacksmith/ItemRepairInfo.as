package red.game.witcher3.menus.blacksmith 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.constants.NavigationCode;
	
	/**
	 * Display info and repair cost for selected item
	 * @author Getsevich Yaroslav
	 */
	public class ItemRepairInfo extends BlacksmithItemPanel
	{
		public var txtDurabilityLabel:TextField;
		public var txtDurabilityValue:TextField;
		public var btnRepairAll : InputFeedbackButton;
		
		public function ItemRepairInfo()
		{			
			txtDurabilityLabel.text = "[[panel_inventory_tooltip_durability]]";
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			
			btnRepairAll.label = "[[repair_equipped_items]]";
			btnRepairAll.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.SPACE);
			btnRepairAll.visible = false;
			btnRepairAll.validateNow();
			btnRepairAll.addEventListener(MouseEvent.CLICK, handleRepairClick, false, 0, true);
		}
		
		override protected function updateData():void 
		{
			super.updateData();
			
			trace("GFX updateData ", _data.durability);
			
			if (_data.durability)
			{
				txtDurabilityLabel.visible = true;
				txtDurabilityValue.text = Math.round( _data.durability ) + " %";
				txtDurabilityValue.visible = true;
			}
		}
		
		override protected function cleanupView():void 
		{
			super.cleanupView();
			txtDurabilityValue.text = "";
			txtDurabilityValue.visible = false;
			txtDurabilityLabel.visible = false;
		}
		
		private function handleRepairClick(event:Event):void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, 'OnRepairAllItems'));
		}
		
	}
}
