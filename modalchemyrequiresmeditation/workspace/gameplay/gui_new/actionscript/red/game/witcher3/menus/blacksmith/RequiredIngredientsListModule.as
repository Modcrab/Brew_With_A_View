package red.game.witcher3.menus.blacksmith 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.CoreComponent;
	import red.core.CoreMenuModule;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.inventory_menu.PinnedCraftingItemInfo;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * #for EnchantingMenu
	 * red.game.witcher3.menus.blacksmith.RequiredIngredientsListModule 
	 * Required Ingredients
	 * @author Getsevich Yaroslav
	 */
	public class RequiredIngredientsListModule extends CoreMenuModule
	{
		private const RENDERER_CLASS_NAME:String = "IngredientRef";
		private const BLOCK_PADDING:Number = 5;
		private const ROW_PADDING:Number = 20;
		
		public var mcListAnchor:MovieClip;
		//public var mcDelimiter:MovieClip;
		
		public var tfName:TextField;
		public var tfType:TextField;
		public var tfDescription:TextField;
		public var tfLevel:TextField;
		public var tfIngredientsTitle:TextField;
		public var tfHint:TextField;
		private var _textValue : String ;
		private var _canvas:Sprite;
		private var _ingredientsList:Vector.<PinnedCraftingItemInfo>;
		private var _data:Object;
		
		public function RequiredIngredientsListModule()
		{
			_ingredientsList = new Vector.<PinnedCraftingItemInfo>;
			_canvas = new Sprite();
			_canvas.x = mcListAnchor.x;
			_canvas.y = mcListAnchor.y;
			
			addChild(_canvas);
			
			
			visible = false;
		}
		
		public function get data():Object { return _data };
		public function set data(value:Object):void 
		{
			_data = value;
			populateData();
		}
		
		protected function populateData():void
		{
			if (data)
			{
				var curHeight:Number = 0;
				
				
				cleanupContent();
				
				_textValue = _data.localizedName;
				tfName.htmlText = _textValue;
				tfName.htmlText = CommonUtils.toUpperCaseSafe(_textValue);
				if (CoreComponent.isArabicAligmentMode)
				{
					tfName.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				_textValue = _data.type ? "[[panel_enchanting_filter_runeword]]" : "[[panel_enchanting_filter_glyphword ]]";
				tfType.htmlText = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfType.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				
				_textValue = _data.description;
				tfDescription.htmlText = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfDescription.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				_textValue = _data.levelName;
				tfLevel.text = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfLevel.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				
				_textValue  = "[[panel_alchemy_required_ingridients]]";
				tfIngredientsTitle.htmlText = _textValue;
				tfIngredientsTitle.htmlText = CommonUtils.toUpperCaseSafe(_textValue);
				if (CoreComponent.isArabicAligmentMode)
				{
					tfIngredientsTitle.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				
				_textValue = "[[panel_enchanting_message_warning  ]]";
				tfHint.htmlText = _textValue;
				if (CoreComponent.isArabicAligmentMode)
				{
					tfHint.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				
				
				
				tfDescription.height = tfDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				curHeight = tfDescription.y + tfDescription.height + BLOCK_PADDING;
				
				//mcDelimiter.y = curHeight;
				curHeight +=  ROW_PADDING;
				
				tfIngredientsTitle.y = curHeight;
				curHeight += tfIngredientsTitle.textHeight + ROW_PADDING;
				
				_canvas.y = curHeight + BLOCK_PADDING;
				
				if (data.ingredientsList)
				{
					var itemsCount:uint = data.ingredientsList.length;
					var classRef:Class = getDefinitionByName(RENDERER_CLASS_NAME) as Class;
					
					for (var i:int = 0; i < itemsCount; i++)
					{
						var newItem:PinnedCraftingItemInfo = new classRef() as PinnedCraftingItemInfo;
						
						newItem.y = _canvas.height;
						_canvas.addChild(newItem);
						newItem.validateNow();
						newItem.setItemData(data.ingredientsList[i]);
						
						_ingredientsList.push(newItem);
					}
					
					curHeight += _canvas.height + BLOCK_PADDING;
					tfHint.y = curHeight;
				}
				visible = true;
			}
			else
			{
				visible = false;
			}
		}
		
		protected function cleanupContent():void
		{
			while (_ingredientsList.length)
			{
				_canvas.removeChild(_ingredientsList.pop());
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return false;
		}
		
	}
}
