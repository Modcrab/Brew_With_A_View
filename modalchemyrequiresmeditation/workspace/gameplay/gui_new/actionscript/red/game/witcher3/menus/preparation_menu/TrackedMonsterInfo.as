package red.game.witcher3.menus.preparation_menu
{
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.InvisibleComponent;
	import scaleform.clik.controls.ScrollBar;

	/**
	 * Monster info with description, recomended potions, etc
	 * @author Getsevich Yaroslav
	 */
	public class TrackedMonsterInfo extends UIComponent
	{
		public var mcScrollbar:ScrollBar;
		public var txtDescription:W3TextArea;
		public var mcBgImageGuide:InvisibleComponent;

		protected var _imageLoader:W3UILoaderSlot;

		override protected function configUI():void
		{
			super.configUI();

		}

		public function setupMonsterInfo(data:Object):void
		{
			if (!data)
				return;

			if (data.trackType == 0)
			{
				visible = false;
				unloadIcon();
			}
			else
			{
				visible = true;
				setupIconImage("textures/journal/bestiary/" + data.bgImgPath);
				txtDescription.htmlText = data.txtDesc;
			}
		}

		protected function setupIconImage(iconPath:String):void
		{
			unloadIcon();

			_imageLoader = new W3UILoaderSlot();
			_imageLoader.maintainAspectRatio = false;
			_imageLoader.autoSize = false;
			_imageLoader.addEventListener(Event.COMPLETE, handleIconLoaded, false, 0, true);
			_imageLoader.source = "img://" + iconPath;
			_imageLoader.mouseChildren = false;
			_imageLoader.mouseEnabled = false;
			addChildAt(_imageLoader, this.numChildren);
			_imageLoader.x = mcBgImageGuide.x;
			_imageLoader.y = mcBgImageGuide.y;

			// force the text and scrollbar to the front
			addChild(mcScrollbar);
			addChild(txtDescription);
		}

		protected function unloadIcon():void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				_imageLoader.removeEventListener(Event.COMPLETE, handleIconLoaded);
				removeChild(_imageLoader);
				_imageLoader = null;
			}
		}

		protected function handleIconLoaded(event:Event):void
		{
			var image:Bitmap = Bitmap(event.target.content);
			if (image)
			{
				image.smoothing = true;
				image.pixelSnapping = PixelSnapping.NEVER;
			}
		}
	}

}