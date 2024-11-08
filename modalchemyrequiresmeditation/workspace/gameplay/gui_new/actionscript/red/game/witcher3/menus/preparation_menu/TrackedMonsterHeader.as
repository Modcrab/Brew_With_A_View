package red.game.witcher3.menus.preparation_menu
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.controls.InvisibleComponent;

	/**
	 * Monster info with description, recomended potions, etc
	 * @author Getsevich Yaroslav
	 */
	public class TrackedMonsterHeader extends UIComponent
	{
		public var txtMonsterSource:TextField;
		public var txtMonsterName:TextField;

		public var mcImageLoaderPos:InvisibleComponent;

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
				txtMonsterName.visible = false;
			}
			else
			{
				txtMonsterName.visible = true;
				txtMonsterName.text = data.monsterName;
			}

			txtMonsterSource.text = data.trackTypeStr;

			setupIconImage(data.monsterIconPath);
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
			addChild(_imageLoader);
			_imageLoader.x = mcImageLoaderPos.x;
			_imageLoader.y = mcImageLoaderPos.y;
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