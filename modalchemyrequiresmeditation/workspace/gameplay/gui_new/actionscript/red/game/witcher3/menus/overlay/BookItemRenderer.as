package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.UILoader;
	
	/*
	 * For book popup
	 * red.game.witcher3.menus.overlay.BookItemRenderer
	*/
	
	public class BookItemRenderer extends ListItemRenderer
	{
		public var mcNewIcon   : MovieClip;
		public var mcQuest     : MovieClip;
		public var mcSelection : MovieClip;
		
		protected var _imageLoader : UILoader;
		
		public function BookItemRenderer()
		{
			mcSelection.visible = false;
			mcNewIcon.visible = false;
			mcQuest.visible = false;
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			mcSelection.visible = selected;
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			
			if ( !data )
			{
				visible = false;
				return;
			}
			
			visible = true;
			
			if (_imageLoader)
			{
				_imageLoader.y = -10;
				_imageLoader.unload();
				removeChild(_imageLoader);
				_imageLoader = null;
			}
			
			if (data.iconPath)
			{
				_imageLoader = new UILoader();
				_imageLoader.source = data.iconPath;
				addChild(_imageLoader);
			}
			
			if (data.isQuestItem)
			{
				mcQuest.visible = true;
				mcQuest.gotoAndStop(data.questTag);
			}
			else
			{
				mcQuest.visible = false;
			}
			
			
			mcNewIcon.visible = data.isNewItem;
			
			addChild( mcQuest );
			addChild( mcNewIcon );
		}
		
	}

}
