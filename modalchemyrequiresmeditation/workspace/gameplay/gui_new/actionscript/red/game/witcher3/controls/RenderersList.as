package red.game.witcher3.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.engine.TabAlignment;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	import red.game.witcher3.tooltips.TooltipPropRenderer;
	import red.game.witcher3.tooltips.TooltipStatRenderer;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Simple renderers list without scrolling and other stuff
	 * red.game.witcher3.controls.RenderersList
	 * @author Yaroslav Getsevich
	 */
	public class RenderersList extends UIComponent
	{
		protected var _itemRendererName:String;
		protected var _dataList:Array;
		protected var _itemPadding:Number;
		protected var _isHorizontal:Boolean;
		protected var _alignment:String;
		protected var _straightenColumn:Boolean;
		
		protected var _itemRendererRef:Class;
		protected var _renderers:Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>;
		protected var _canvas:Sprite;
		public var _thisWidth : Number;
		
		public function RenderersList()
		{
			_dataList = [];
			_canvas = new Sprite();
			addChild(_canvas);
		}
		
        public function get straightenColumn():Boolean { return _straightenColumn; }
        public function set straightenColumn(value:Boolean):void
		{
			_straightenColumn = value;
			invalidateData();
		}
		
		// only for !_isHorizontal; use const from TextFormatAlign class
		[Inspectable(name = "alignment", type = "list", enumeration = "center, left, right", defaultValue="left")]
        public function get alignment():String { return _alignment; }
        public function set alignment(value:String):void
		{
			_alignment = value;
			invalidateData();
		}
		
		[Inspectable(name = "isHorizontal")]
        public function get isHorizontal():Boolean { return _isHorizontal; }
        public function set isHorizontal(value:Boolean):void
		{
			_isHorizontal = value;
			invalidateData();
		}
		
        [Inspectable(name = "itemRenderer")]
        public function get itemRendererName():String { return _itemRendererName; }
        public function set itemRendererName(value:String):void
		{
            var classRef:Class = getDefinitionByName(value) as Class;
            if (classRef != null)
			{
				_itemRendererName = value;
                _itemRendererRef = classRef;
				invalidateData();
            }
			else
			{
                trace("Error: " + this + ", The class " + value + " cannot be found in your library. Please ensure it is there.");
            }
        }
		
		[Inspectable(name = "itemPadding", defaultValue = "0")]
		public function get itemPadding():Number { return _itemPadding }
		public function set itemPadding(value:Number):void
		{
			_itemPadding = value;
			invalidateData();
		}
		
		public function get dataList():Array { return _dataList }
		public function set dataList(value:Array):void
		{
			while (_renderers.length) _canvas.removeChild(_renderers.pop());
			if (value)
			{
				_dataList = value;
				invalidateData()
			}
		}
		
		public function getRenderersCount():int
		{
			return _renderers.length;
		}
		
		override protected function draw():void
		{
			super.draw();
			if (isInvalid(InvalidationType.DATA))
			{
				populateData();
			}
		}
		
		protected function populateData():void
		{
			var itemWidth:Number = 0;
			var itemHeight:Number = 0;
			var curWidth:Number = 0;
			var curHeight:Number = 0;
			var maxValueWidth:Number = 0;
			var newItem:IListItemRenderer;
			
			while (_renderers.length) _canvas.removeChild(_renderers.pop());
			
			for each (var curItemData:Object in _dataList)
			{
				var attrRenderer:TooltipStatRenderer;
				
				newItem = new _itemRendererRef() as IListItemRenderer;
				newItem.setData(curItemData);
				_canvas.addChild(newItem as DisplayObject);
				newItem.validateNow();
				
				var newItemComponent:BaseListItem = newItem as BaseListItem;
				if (newItemComponent)
				{
					itemWidth = newItemComponent.getRendererWidth();
					itemHeight = newItemComponent.getRendererHeight();
				}
				else
				{
					itemWidth = newItem.width;
					itemHeight = newItem.height;
				}
				
				if (_isHorizontal)
				{
					newItem.x = curWidth;
					curWidth += (itemWidth + _itemPadding);
				}
				else
				{
					var tooltipProps:BaseListItem = newItem as BaseListItem;
					
					if (_alignment == TextFormatAlign.CENTER)
					{
						newItem.x = - newItem.width / 2;
					}
					else
					if (_alignment == TextFormatAlign.RIGHT)
					{
						newItem.x = tooltipProps ? - tooltipProps.getRendererWidth() : - newItem.width;
					}
					else
					{
						newItem.x = 0;
					}
					
					attrRenderer = newItem as TooltipStatRenderer;
					if (attrRenderer)
					{
						var valueText:TextField = attrRenderer.tfStatValue;
						
						if (valueText && valueText.textWidth > maxValueWidth)
						{
							maxValueWidth = (valueText.x + valueText.textWidth);
						}
					}
					
					newItem.y = curHeight;
					curHeight += ( itemHeight + _itemPadding );
				}
				
				_renderers.push(newItem);
				
			}
			_thisWidth = _canvas.width;
			if (!_isHorizontal && _straightenColumn)
			{
				var rdrCount:int = _renderers.length;
				
				for (var j:int = 0; j < rdrCount; j++ )
				{
					attrRenderer = _renderers[j] as TooltipStatRenderer;
					if (attrRenderer)
					{
						attrRenderer.columnPadding = maxValueWidth;
					}
				}
				
				// in case of multiline renderes
				curHeight = 0;
				for (var i:int = 0; i < rdrCount; i++)
				{
					newItem = _renderers[i];
					if (newItem)
					{
						newItem.y = curHeight;
						curHeight += newItem.height + _itemPadding;
					}
				}
			}
			
		}
	}
}
