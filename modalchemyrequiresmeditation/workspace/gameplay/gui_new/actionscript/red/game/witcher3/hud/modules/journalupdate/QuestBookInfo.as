package red.game.witcher3.hud.modules.journalupdate
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.hud.modules.journalupdate.QuestBookInfo
	 * for HudModuleJournalUpdate.as
	 * @author Getsevich Yaroslav
	 */
	public class QuestBookInfo extends UIComponent
	{
		private const BORDER_PADDING:Number = 20;
		private const BLOCK_PADDING:Number = 10;
		private const ICON_SIZE:Number = 64;
		
		public var mcBackground : MovieClip;
		public var tfItemName   : TextField;
		public var btnActivate  : InputFeedbackButton;
		
		private var _imageLoader : UILoader;
		private var _data        : Object;
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			populateData();
		}
		
		private function populateData():void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				_imageLoader = null;
			}
			
			btnActivate.clickable = false;
			btnActivate.label = _data.buttonLabel;
			btnActivate.setDataFromStage(_data.gpadCode, _data.keyCode);
			
			_imageLoader = new UILoader();
			_imageLoader.source = _data.iconPath;
			_imageLoader.x = BORDER_PADDING;
			_imageLoader.y = BORDER_PADDING;
			_imageLoader.width = _imageLoader.height = ICON_SIZE;
			addChild(_imageLoader);
			
			tfItemName.text = _data.itemName;
			tfItemName.width = tfItemName.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfItemName.x = _imageLoader.x + ICON_SIZE + BLOCK_PADDING;
			tfItemName.y = BORDER_PADDING;
			
			btnActivate.x = _imageLoader.x + ICON_SIZE + BLOCK_PADDING;
			
			mcBackground.width = Math.max( tfItemName.x + tfItemName.width, btnActivate.x + btnActivate.getViewWidth() ) + BORDER_PADDING;
			mcBackground.height = ICON_SIZE + BLOCK_PADDING * 2 + BORDER_PADDING;
		}
		
	}

}
