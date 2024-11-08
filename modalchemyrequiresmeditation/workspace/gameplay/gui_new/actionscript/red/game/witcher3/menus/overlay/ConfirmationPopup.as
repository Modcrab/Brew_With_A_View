package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.constants.CommonConstants;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class ConfirmationPopup extends BasePopup
	{
		private static const HEIGHT_PADDING: Number = 10;
		private static const INPUT_PADDING: Number = 10;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
		
		public var txtMessage:TextField;
		public var txtTitle:TextField;
		public var textBorder:MovieClip;
		private var curHeight:Number;
		public var mcHeader: MovieClip;
		public var mcInputBackground: MovieClip;
		public var mcBackground: MovieClip;
		
		override protected function populateData():void
		{
			super.populateData();
			
			txtMessage.htmlText = _data.TextContent;
			txtMessage.height = txtMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _data.TextTitle );
			if (txtTitle.text == "")
			{
				txtMessage.y = 16.85;
				mcHeader.visible = false;
			}
			curHeight = txtMessage.y + txtMessage.textHeight + HEIGHT_PADDING;
			mcBackground.height = curHeight + FINAL_HEIGHT_PADDING;
			mcInputBackground.y  = mcBackground.height - mcInputBackground.height / 2;
			mcInpuFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			mcInputBackground.x = mcBackground.width / 2;
			mcInputBackground.width = mcInpuFeedback.buttonsContainer.width + INPUT_PADDING;
		}
	}

}