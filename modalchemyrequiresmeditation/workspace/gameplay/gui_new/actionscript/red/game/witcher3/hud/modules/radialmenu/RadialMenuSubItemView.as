package red.game.witcher3.hud.modules.radialmenu
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * [HUD] radial menu center
	 * red.game.witcher3.hud.modules.radialmenu.RadialMenuSubItemView
	 * @author Getsevich Yaroslav
	 */
	public class RadialMenuSubItemView extends UIComponent
	{
		public var tfItemName 	 : TextField;
		public var tfItemCounter : TextField;
		
		private var _imageLoader : UILoader;
		private var _itemName	 : String;
		private var _iconPath	 : String;
		private var _count		 : int;
		private var _idx		 : int;
		
		protected var _glowFilter:GlowFilter;
		protected static const OVER_GLOW_COLOR:Number = 0xaf9b70;
		protected static const OVER_GLOW_BLUR:Number = 20;
		protected static const OVER_GLOW_STRENGHT:Number = .75;
		protected static const OVER_GLOW_ALPHA:Number = .6;
		
		public function RadialMenuSubItemView()
		{
			visible = false;
		}
		
		public function setData( itemName:String, iconPath:String, idx:int = -1, count:int = -1 ):void
		{
			visible = false; // show only after image loaded
			
			trace("GFX setData ", itemName, iconPath, idx, count);
			
			_itemName = itemName;
			_iconPath = iconPath;
			_count = count;
			_idx = idx;
			
			if ( _imageLoader )
			{
				_imageLoader.unload();
				_imageLoader.removeEventListener( Event.COMPLETE, handleImageLoaded, false );
				_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, handleLoadIOError, false );
				removeChild( _imageLoader );
			}
			
			if ( _iconPath )
			{
				_imageLoader = new UILoader();
				_imageLoader.source = _iconPath;
				_imageLoader.addEventListener( Event.COMPLETE, handleImageLoaded, false, 0, true );
				_imageLoader.addEventListener( IOErrorEvent.IO_ERROR, handleLoadIOError, false, 0, true );
				addChild(_imageLoader);
			}
			else
			{
				handleLoadIOError();
			}
			

			tfItemName.htmlText = _itemName;
			tfItemName.height = tfItemName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			if (idx >= 0 && count > 1 )
			{
				const text_padding = 5;
				
				tfItemCounter.text =   " < " + idx + "/" + _count + " > ";
				tfItemCounter.visible = true;
				tfItemCounter.y = tfItemName.y + tfItemName.height - text_padding;
			}
			else
			{
				tfItemCounter.visible = false;
			}
			
			/*
			if (_imageLoader )
			{
				var filterArray:Array = [];
				_glowFilter = new GlowFilter( OVER_GLOW_COLOR, OVER_GLOW_ALPHA, OVER_GLOW_BLUR, OVER_GLOW_BLUR, OVER_GLOW_STRENGHT, BitmapFilterQuality.HIGH );
				filterArray.push( _glowFilter );
				_imageLoader.filters = filterArray;
			}
			*/
		}
		
		public function cleanup():void
		{
			// just hide it for now
			visible = false;
		}
		
		private function handleImageLoaded(event:Event):void
		{
			visible = true;
			
			_imageLoader.x = - _imageLoader.actualWidth / 2;
			_imageLoader.y = - _imageLoader.actualHeight / 2;
			
			tfItemName.y = _imageLoader.y + _imageLoader.height - 5;
			tfItemName.x = - tfItemName.width / 2;
		}
		
		private function handleLoadIOError(event:Event = null):void
		{
			visible = true;
			
			if ( _imageLoader )
			{
				_imageLoader.unload();
				_imageLoader.removeEventListener( Event.COMPLETE, handleImageLoaded, false );
				_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, handleLoadIOError, false );
				removeChild( _imageLoader );
			}
			
			tfItemName.y = 0;
			tfItemName.x = - tfItemName.width / 2;
		}
		
	}

}
