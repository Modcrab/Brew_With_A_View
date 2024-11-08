package red.game.witcher3.menus.overlay 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.UILoader;
	
	/**
	 * red.game.witcher3.menus.overlay.PaintingPopup
	 * @author Getsevich Yaroslav
	 */
	public class PaintingPopup extends BasePopup
	{
		public var txtTitle:TextField;
		public var txtDescription:TextField;
		
		private var _imageLoader:UILoader;
		
		public function PaintingPopup()
		{
			_fixedPosition = true;
		}
		
		override protected function populateData():void 
		{
			super.populateData();
			
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			
			// ???
			//txtTitle.htmlText = _data.TextTitle;
			//txtDescription.htmlText = _data.TextContent;
			
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
			
			_imageLoader = new UILoader();
			_imageLoader.source = _data.ImagePath;			
			_imageLoader.addEventListener(Event.COMPLETE, handleIconLoaded, false, 0, true);
			_imageLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadIOError, false, 0, true );
			addChild(_imageLoader);
			
			visible = false;
		}
		
		private function handleIconLoaded(event:Event):void
		{
			const BLOCK_PADDING = 5;
			
			_imageLoader.x = - _imageLoader.actualWidth / 2;
			_imageLoader.y = txtTitle.y + txtTitle.textHeight + BLOCK_PADDING;
			
			if (txtDescription.text)
			{
				txtDescription.visible = true;
				txtDescription.y = _imageLoader.y + _imageLoader.height + BLOCK_PADDING;
				mcInpuFeedback.y = txtDescription.y + txtDescription.textHeight + BLOCK_PADDING;
			}
			else
			{
				txtDescription.visible = false;
				mcInpuFeedback.y = _imageLoader.y + _imageLoader.actualHeight + BLOCK_PADDING;
			}
			
			var visibleRect:Rectangle = CommonUtils.getScreenRect();
			x = visibleRect.x + visibleRect.width / 2;  //- actualWidth / 2;
			y = visibleRect.y + visibleRect.height / 2 - actualHeight / 2;				
			visible = true;
		}
		
		private function handleLoadIOError(event:Event):void
		{
			// TODO:
		}
		
	}

}
