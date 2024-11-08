package red.game.witcher3.menus.blacksmith 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * red.game.witcher3.menus.blacksmith.ItemAddSocketInfo
	 * @author Getsevich Yaroslav
	 */
	public class ItemAddSocketInfo extends BlacksmithItemPanel
	{
		public var txtSockets:TextField;
		public var txtSocketsTitle:TextField;
		public var priceFrame:MovieClip;
		
		public function ItemAddSocketInfo()
		{
			txtSocketsTitle.text = "[[panel_socket_number_sockets]]";
			//txtSocketsTitle.text = CommonUtils.toUpperCaseSafe(txtSocketsTitle.text);
		}
		
		override public function playErrorAnimation():void
		{
			//
		}
		
		override protected function updateData():void 
		{
			super.updateData();
			
			if (_data)
			{
				txtSockets.text = _data.socketsCount + " / " + _data.socketsMaxCount;
				txtSockets.textColor = _data.disableAction ? 0x666666 : 0xE0E0DF;
				txtSocketsTitle.textColor = _data.disableAction ? 0x666666 : 0xE0E0DF;
				
				btnExecute.visible = !_data.disableAction;
				txtPriceLabel.visible = !_data.disableAction;
				txtPriceValue.visible = !_data.disableAction;
				mcCoinIcon.visible = !_data.disableAction;
				priceFrame.visible = !_data.disableAction;
			}
			
			updateSlots(_data.socketsCount, imageHolder);
		}
		
		override protected function cleanupView():void 
		{
			super.cleanupView();
			txtSockets.text = "";
		}
		
	}

}
