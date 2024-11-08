/***********************************************************************
/** Scrolling list with categories
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
		
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import scaleform.clik.constants.WrappingMode;
    import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.controls.ScrollIndicator;
	import flash.utils.getDefinitionByName;

	public class W3ScrollingCategorizedList extends W3ScrollingList
	{
		var categoriesNr : int = 0;
		var m_currentListHeight : Number;
		protected var CategoriesItems : Vector.<W3Label>;
		private var _LabelClass : String;
		private var _CategoryOffsetY : Number;
		
		public function W3ScrollingCategorizedList()
		{
			super();
			CategoriesItems = new Vector.<W3Label>;
		}
		
		// Protected Methods:
        override protected function configUI():void
		{
            super.configUI();
			stage.addEventListener(W3ScrollingList.REPOSITION, updatePosition, false, 0, false);
        }
		
		[Inspectable(type = "String", defaultValue = "W3CategoryLabel")]
        public function get LabelClass() : String
		{
			return _LabelClass;
		}
        public function set LabelClass( value : String ) : void
		{
			_LabelClass = value;
        }
		
		[Inspectable( defaultValue = 10)]
        public function get CategoryOffsetY() : Number
		{
			return _CategoryOffsetY;
		}
        public function set CategoryOffsetY( value : Number ) : void
		{
			_CategoryOffsetY = value;
        }
		
		override protected function updateScrollBar():void
		{
            if (_scrollBar == null) { return; }
			if ( _dataProvider.length <= _totalRenderers )
			{
				scrollBar.visible = false;
			}
			else
			{
				scrollBar.visible = true;
			}

            var max:Number = Math.max(0, _dataProvider.length - _totalRenderers);
            if (_scrollBar is ScrollIndicator) {
                var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
                scrollIndicator.setScrollProperties(_totalRenderers, 0, _dataProvider.length-_totalRenderers);
            } else {
                // Min/max
            }
            _scrollBar.position = _scrollPosition;
            _scrollBar.validateNow();
		}
			
		public function updatePosition( event : Event )
		{
			//trace("GFX ***  updatePosition event ");
			if ( !CategoriesItems || !dataProvider)
			{
				return;
			}
			var tempRenderer : BaseListItem;
			var tempY : Number = this.y;
			var currentCategory : String = "";
			var i : int;
			// #B hide all categories
			
			for ( i = 0; i < CategoriesItems.length; i++ )
			{
				CategoriesItems[i].visible = false;
			}
			
			for ( i = 0; i < dataProvider.length; i++ )
			{
				tempRenderer = getRendererAt(i) as BaseListItem;
				if ( tempRenderer )
				{
					if ( tempRenderer.data.category != currentCategory  )
					{
						currentCategory = tempRenderer.data.category;
						tempY = updateCategoryPosition( currentCategory, tempY );
					}
					tempRenderer.y = tempY;
					tempY += tempRenderer.height;
				}
			}
			if ( tempRenderer )
			{
				tempY += tempRenderer.height;
			}
			//m_currentListHeight = tempY;
			//updateScrollBar();
		}
		
		private function updateCategoryPosition( currentCategory : String , tempY : Number ) : Number
		{
			var resultY : Number;
			var i : int
			resultY = tempY;
			
			if ( currentCategory == " " || currentCategory == "" || currentCategory == "# " || currentCategory == "#"  ) // #B in case when label is empty or empty localised skip displaying title
			{
				return resultY;
			}
			
			for ( i = 0; i < CategoriesItems.length; i++ )
			{
				if( CategoriesItems[i] && CategoriesItems[i].htmlText == currentCategory )
				{
					CategoriesItems[i].y = tempY + _CategoryOffsetY;
					CategoriesItems[i].visible = true;
					resultY += CategoriesItems[i].height;
					return resultY + _CategoryOffsetY + _CategoryOffsetY;
				}
			}
			
			/*
			 * deprecated
			 * 
			var newCategoryItem : W3Label;
			var classRef : Class = getDefinitionByName( LabelClass ) as Class;

			if( classRef != null)
			{
				newCategoryItem = new classRef() as W3Label;
				newCategoryItem.x = this.x;
				newCategoryItem.y = tempY + _CategoryOffsetY;
				newCategoryItem.htmlText = currentCategory.toUpperCase();
				parent.addChild( newCategoryItem );
				CategoriesItems.push( newCategoryItem );
				resultY += newCategoryItem.height + _CategoryOffsetY + _CategoryOffsetY;
			}
			*/
			
			return resultY;
			
		}
		
		override public function toString():String
		{
			return "[W3 W3ScrollingCategorizedList "+ this.name+" ]";
		}
		
		override protected function populateData(data:Array):void
		{
			super.populateData(data);
			stage.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
		}
	}
}
