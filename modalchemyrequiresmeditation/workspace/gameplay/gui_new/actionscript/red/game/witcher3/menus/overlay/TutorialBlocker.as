package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3TextArea;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * Modal tutorial popup
	 * @author Yaroslav Getsevich
	 */
	public class TutorialBlocker extends BasePopup
	{
		public var txtTitle:TextField;
		public var txtDescription:W3TextArea;
		public var imageHolder:MovieClip;
		public var scrollBar:ScrollBar;
		protected var _imageLoader:UILoader;

		override protected function populateData():void
		{
			super.populateData();

			txtTitle.htmlText = _data.title;
			txtDescription.htmlText = _data.description;
			txtDescription.focused = 1;

			if (_imageLoader)
			{
				_imageLoader.unload();
				imageHolder.removeChild(_imageLoader);
			}
			_imageLoader = new UILoader();
			_imageLoader.source = "img://" + _data.imagePath;
			imageHolder.addChild(_imageLoader);
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
		}

	}
}
