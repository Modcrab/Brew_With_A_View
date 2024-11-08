package red.game.witcher3.menus.overlay
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.controls.W3TextArea;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import scaleform.clik.events.InputEvent;
	import red.game.witcher3.utils.CommonUtils;
	
	
	/**
	 * Book popup. Display book's text in the inventory.
	 * @author Getsevich Yaroslav
	 */
	public class BookPopup extends BasePopup
	{
		const ANIM_OFFSET:Number = 100;
		const ANIM_DURATION:Number = .5;
		const BTN_DISABLED_ALPHA:Number = .3;
		
		public var txtMessage:W3TextArea;
		public var txtTitle:TextField;
		public var txtCounter:TextField;
		public var btnPrior:ConditionalButton;
		public var btnNext:ConditionalButton;
		public var mcBooksList:W3ScrollingList;
		public var mcBookBackground:MovieClip;
		
		public var mcBookRenderer1:BookItemRenderer;
		public var mcBookRenderer2:BookItemRenderer;
		public var mcBookRenderer3:BookItemRenderer;
		public var mcBookRenderer4:BookItemRenderer;
		public var mcBookRenderer5:BookItemRenderer;
		public var mcBookRenderer6:BookItemRenderer;
		
		protected var _imageLoader:UILoader;
		
		protected var _selectedBookId:int = 0;
		protected var _booksCount:int = 0;
		protected var _booksList:Array;
		protected var _title:String;
		protected var _isFirstInit:Boolean = true;
		
		protected var _renderersCanvas:Sprite;
		
		override protected function configUI():void
		{
			super.configUI();
			
			_isFirstInit = true;
			tabChildren = false;
			
			mcBooksList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
			btnPrior.addEventListener(MouseEvent.CLICK, handlePriorClick, false, 0, true);
			btnNext.addEventListener(MouseEvent.CLICK, handleNextClick, false, 0, true);
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 1000, true);
		}
		
		override protected function populateData():void
		{
			super.populateData();
			removeEventListener( Event.ENTER_FRAME, validateDataPopulation, false );
			addEventListener( Event.ENTER_FRAME, validateDataPopulation, false, 0, true);
		}
		
		protected function validateDataPopulation( event : Event = null ):void
		{
			removeEventListener( Event.ENTER_FRAME, validateDataPopulation, false );
			
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			txtMessage.focused = 1;
			
			_booksList = _data.newBooksList as Array;
			
			if (_booksList && _booksList.length > 0 )
			{
				_booksList.sortOn("isQuestItem", Array.DESCENDING);
				
				var curBookData:Object = { };
				
				if (_data.iconPath)
				{
					curBookData.itemId = _data.itemId;
					curBookData.iconPath = _data.iconPath;
					curBookData.isNewItem = _data.isNewItem;
					curBookData.isQuestItem = _data.isQuestItem;
					curBookData.TextTitle = _data.TextTitle;
					curBookData.TextContent = _data.TextContent;
					curBookData.isNewItem = _data.isNewItem;
					curBookData.questTag = _data.questTag;
					
					_booksList.unshift( curBookData );
				}
			}
			
			if (_booksList && _booksList.length)
			{
				_booksCount = _booksList.length;
				
				mcBooksList.dataProvider = new DataProvider( _booksList );
				mcBooksList.selectedIndex = 0;
				
				txtCounter.visible = true;
				txtCounter.text = "0/" + _booksCount;
				
				if (_booksCount < 6)
				{
					var rdrList:Vector.<IListItemRenderer> = mcBooksList.getRenderers();
					
					_renderersCanvas = new Sprite();
					addChild(_renderersCanvas);
					
					var i:int = 0;
					
					while ( i < _booksCount && i < rdrList.length)
					{
						var curItem:BookItemRenderer = rdrList[i] as BookItemRenderer;
						
						if (curItem)
						{
							_renderersCanvas.addChild( curItem );
						}
						
						i++
					}
					
					var item_offset : Number = mcBookRenderer1.x;
					var tr:Rectangle = _renderersCanvas.getBounds(this);
					
					_renderersCanvas.x = mcBookBackground.x + ( mcBookBackground.width - _renderersCanvas.width ) / 2 - item_offset;
					
					const BTN_PADDING_RIGHT = 20;
					
					if ( _booksCount > 1 )
					{
						btnPrior.x = _renderersCanvas.x + item_offset - BTN_PADDING_RIGHT;
						btnNext.x = _renderersCanvas.x + _renderersCanvas.width + item_offset + BTN_PADDING_RIGHT;
					}
					else
					{
						btnPrior.alpha = 0;
						btnNext.alpha = 0;
					}
				}
				
				populateSingleBookData( _booksList[0], false );
			}
			else
			{
				_booksCount = 0;
				btnPrior.alpha = 0;
				btnNext.alpha = 0;
				txtCounter.visible = false;
				
				if (_data.iconPath)
				{
					_imageLoader = new UILoader();
					_imageLoader.source = _data.iconPath;
					_imageLoader.x = mcBooksList.x + ( mcBooksList.width - 64 ) / 2;
					_imageLoader.y = mcBooksList.y;
					
					addChild(_imageLoader);
				}
				
				populateSingleBookData( _data, false );
			}
		}
		
		protected function populateSingleBookData(bookData:Object, isPrior:Boolean = false):void
		{
			trace("GFX populateSingleBookData ", bookData.TextTitle, bookData.iconPath);
			
			if ( CoreComponent.isArabicAligmentMode )
			{
				txtMessage.htmlText = "<p align=\"right\">" + bookData.TextContent +"</p>";
			}
			else
			{
				txtMessage.htmlText = bookData.TextContent;
			}
			
			_title =  bookData.TextTitle;
			
			GTweener.removeTweens(txtTitle);
			GTweener.removeTweens(txtMessage);
			
			if (!_isFirstInit)
			{
				GTweener.to(txtTitle, ANIM_DURATION / 2, { alpha:0 }, { ease : Sine.easeIn, onComplete : onTitleHidden } );
				GTweener.to(txtMessage, ANIM_DURATION / 2, { alpha:0 }, { ease : Sine.easeIn, onComplete : onTitleHidden } );
			}
			else
			{
				_isFirstInit = false;
				txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _title );
				txtTitle.alpha = 1;
			}
			
			trace("GFX ----------------- OnBookRead ", bookData.itemId, "; ", bookData.TextTitle);
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnBookRead", [ uint( bookData.itemId ) ] ) );
		}
		
		private function handleIndexChanged( event : ListEvent ):void
		{
			if (event.itemData)
			{
				event.itemData.isNewItem = false;
				populateSingleBookData( event.itemData );
			}
			
			if (event.itemRenderer)
			{
				event.itemRenderer["mcNewIcon"].visible = false;
			}
			
			txtCounter.text = (event.index + 1) + "/" + _booksCount;
			
			btnPrior.alpha = event.index  > 0 ? 1 : BTN_DISABLED_ALPHA;
			btnNext.alpha = event.index < _booksCount - 1 ? 1 : BTN_DISABLED_ALPHA;
		}
		
		private function onTitleHidden(tw:GTween):void
		{
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _title );
			GTweener.to(txtTitle, ANIM_DURATION / 2, { alpha:1 }, { ease : Sine.easeOut } );
			GTweener.to(txtMessage, ANIM_DURATION / 2, { alpha:1 }, { ease : Sine.easeOut } );
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			
			if (_booksCount < 1 || event.handled || details.value == InputValue.KEY_UP)
			{
				// ignore
				return;
			}
			
			switch( details.navEquivalent )
			{
				case NavigationCode.LEFT:
					selectPriorBook();
					event.handled = true;
					break;
					
				case NavigationCode.RIGHT:
					selectNextBook();
					event.handled = true;
					break;
			}
			
			if ( !event.handled )
			{
				switch( details.code )
				{
					case KeyCode.A:
						selectPriorBook();
						event.handled = true;
						break;
						
					case KeyCode.D:
						selectNextBook();
						event.handled = true;
						break;
				}
			}
			
		}
		
		private function handleNextClick(event:MouseEvent):void
		{
			selectNextBook();
		}
		
		private function handlePriorClick(event:MouseEvent):void
		{
			selectPriorBook();
		}
		
		private function selectNextBook():void
		{
			if ( mcBooksList.selectedIndex < _booksCount - 1 )
			{
				mcBooksList.selectedIndex++;
			}
		}
		
		private function selectPriorBook():void
		{
			if ( mcBooksList.selectedIndex > 0 )
			{
				mcBooksList.selectedIndex--;
			}
		}
		
	}
}
