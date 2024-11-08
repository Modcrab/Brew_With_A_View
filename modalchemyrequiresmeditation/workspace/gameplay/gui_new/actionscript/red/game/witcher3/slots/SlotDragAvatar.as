package red.game.witcher3.slots
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.menus.common.ItemDataStub;
	import scaleform.clik.controls.UILoader;
	
	/**
	 * Simple avatar for slot's dragging state
	 * @author Yaroslav Getsevich
	 */
	public class SlotDragAvatar extends Sprite
	{
		private static const ACTION_ICON_PADDING_X:Number = 15;
		private static const ACTION_ICON_PADDING_Y:Number = 15;
		
		public static const ACTION_NONE:uint = 1;
		public static const ACTION_GRID_DROP:uint = 2;
		public static const ACTION_GRID_SWAP:uint = 3;
		public static const ACTION_SWAP:uint = 4;
		public static const ACTION_ENHANCE:uint = 5;
		public static const ACTION_DROP:uint = 6;
		public static const ACTION_ERROR:uint = 7;
		public static const ACTION_OIL:uint = 8;
		public static const ACTION_REPAIR:uint = 9;
		public static const ACTION_DIY:uint = 10;
		
		private var _data:*;
		private var _sourceLoader:UILoader;
		private var _imageLoader:W3UILoaderSlot;
		private var _sourceContainer:IDragTarget;
		
		private var _actionIcon:MovieClip;
		
		public function SlotDragAvatar(sourceLoader:UILoader, itemData:* = null, sourceContainer:IDragTarget = null)
		{
			super();
			
			_sourceContainer = sourceContainer;
			_data = itemData;
			_sourceLoader = sourceLoader;
			
			_imageLoader = new W3UILoaderSlot();
			_imageLoader.setOriginSource(_sourceLoader.source);
			_imageLoader.maintainAspectRatio = false;
			_imageLoader.autoSize = false;
			_imageLoader.addEventListener(Event.COMPLETE, handleImageLoader, false, 0, true);
			
			var sourceSlotLoader:W3UILoaderSlot = sourceLoader as W3UILoaderSlot;
			if (sourceSlotLoader)
			{
				_imageLoader.slotType = sourceSlotLoader.slotType;
			}
			addChild(_imageLoader);
			
			// try to load action icon
			try
			{
				var ActionIconClass:Class = getDefinitionByName("SlotAvatarIconRef") as Class;
				_actionIcon = new ActionIconClass();
				_actionIcon.gotoAndStop("none");
				addChild(_actionIcon);
			}
			catch (er:Error)
			{
				_actionIcon = null;
				trace("GFX can't load action icon: " + er.message);
			}
		}
		
		public function get data():* { return _data }
		public function set data(value:*):void
		{
			_data = value;
		}
		
		public function getSourceContainer():IDragTarget
		{
			return _sourceContainer;
		}
		
		public function setActionIcon(actionType:uint):void
		{
			if (_actionIcon)
			{
				_actionIcon.gotoAndStop(actionType)
			}
		}
		
		private function handleImageLoader(event:Event):void
		{
			var image:Bitmap = Bitmap(event.target.content);
			if (image)
			{
				image.smoothing = true;
				image.pixelSnapping = PixelSnapping.NEVER;
			}
			_imageLoader.scaleX = _sourceLoader.actualScaleX;
			_imageLoader.scaleY = _sourceLoader.actualScaleY;
			_imageLoader.x = -_imageLoader.width / 2;
			_imageLoader.y = -_imageLoader.height / 2;
			
			if (_actionIcon)
			{
				_actionIcon.x = _imageLoader.width / 2 + ACTION_ICON_PADDING_X;
				_actionIcon.y =  ACTION_ICON_PADDING_Y;
			}
		}
		
	}
}
