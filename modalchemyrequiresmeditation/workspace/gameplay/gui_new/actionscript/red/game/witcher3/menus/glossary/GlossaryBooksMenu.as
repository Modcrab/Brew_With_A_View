package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.game.witcher3.menus.common.TextAreaModule;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	/**
	 * New way to display books
	 * red.game.witcher3.menus.glossary.GlossaryBooksMenu
	 * @author Getsevich Yaroslav
	 */
	public class GlossaryBooksMenu extends CoreMenu
	{
		public var mcMainListModule	  : DropdownListModuleBase;
		public var mcTextAreaModule	  : TextAreaModuleCustomInput;
		public var mcModuleEntryImage : GlossaryTextureSubListModule; // ??
		public var mcImageAnchor      : MovieClip;
		
		protected var _imageLoader    : UILoader;
		
		Extensions.enabled = true;
		Extensions.noInvisibleAdvance = true;
		
		public function GlossaryBooksMenu()
		{
			super();
			
			mcMainListModule.selectModuleOnClick = true;
			mcMainListModule.menuName = menuName;
			mcMainListModule.sortFunc = sortGroupListFunction;
			mcMainListModule.mcDropDownList.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 0 , true );
			
			W3DropdownMenuListItem.staticSortedFunction = sortListFunction;
		}
		
		override protected function get menuName():String {	return "GlossaryBooksMenu";	}
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			focused = 1;
			
			mcTextAreaModule.visible = false;
			
			currentModuleIdx = 0;
			mcModuleEntryImage.visible = false;
			mcModuleEntryImage.enabled = false;
		}
		
		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			
			//mcTextAreaModule.visible = value;
			//mcTextAreaModule.enabled = value;
		}
		
		public function handleSelectChange(event:ListEvent):void
		{
			var itemRdr:IconItemRenderer = event.itemRenderer as IconItemRenderer;
			
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
				_imageLoader = null;
			}
				
			if (itemRdr)
			{
				var bookText:String = CommonUtils.fixFontStyleTags(itemRdr.data.text);
				
				mcTextAreaModule.SetText(bookText);
				mcTextAreaModule.SetTitle(itemRdr.data.label);
				mcTextAreaModule.visible = true;
				
				if (itemRdr.data.isPainting)
				{
					_imageLoader = new UILoader();
					_imageLoader.source = itemRdr.data.imagePath;
					_imageLoader.x = mcImageAnchor.x;
					_imageLoader.y = mcImageAnchor.y;
					addChild(_imageLoader);
				}
				
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnReadBook", [itemRdr.data.itemId] ) );
			}
			else
			{
				mcTextAreaModule.visible = false;
			}
		}
		
		public function sortGroupListFunction(targetArray:Array):void
		{
			targetArray.sortOn( "sortIdx" );
		}
		
		public function sortListFunction(targetArray:Array):void
		{
			targetArray.sortOn( [ "isNew", "sortIdx" ], Array.DESCENDING );
		}
		
		override public function handleInput( event : InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}
			for each ( var handler:UIComponent in actualModules )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
			super.handleInput( event );
		}
		
	}
}
