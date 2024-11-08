package red.game.witcher3.menus.common_menu
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Sub tab
	 * @author Getsevich Yaroslav
	 */
	public class MenuTabSubContainer extends MenuTabsContainer
	{
		protected static const TABS_POSITION_Y:Number = 64;
		protected static const NAV_BUTTONS_PADDING:Number = 60;
		protected static const TEXT_POS:Number = 250;
		protected static const TAB_PADDING:Number = 35;
		protected static const TAB_SIZE:Number = 64;
		protected static const RENDERER_CLASS:String = "SubMenuTabRef";
		
		protected var _canvas:Sprite;
		protected var _parentId:int;
		protected var _renderersCreated:Boolean;
		
		//public var tfTitle:TextField;
		public var navButtonLB:Sprite;
		public var navButtonRB:Sprite;
		
		public function MenuTabSubContainer()
		{
			_renderersCreated = false;
			_canvas = new Sprite();
			addChild(_canvas);
			navButtonLB.visible = false;
			navButtonRB.visible = false;
		}
		
		public function get parentId():int { return _parentId }
		public function set parentId(value:int):void
		{
			_parentId = value;
		}
		
		override protected function populateData():void
		{
			if (!_renderersCreated) createRenderers();
			super.populateData();
			
			_canvas.y = TABS_POSITION_Y;
			navButtonLB.visible = true;
			navButtonRB.visible = true;
			
			//navButtonRB.x = tfTitle.x + tfTitle.textWidth + NAV_BUTTONS_PADDING;
			//navButtonLB.x = _canvas.x - navButtonLB.width - NAV_BUTTONS_PADDING;
		}
		
		override protected function onIndexChanged():void
		{
			super.onIndexChanged();
			if (_selectedIndex > -1)
			{
				//tfTitle.text = _itemsList[_selectedIndex].label;
				//navButtonRB.x = tfTitle.x + tfTitle.textWidth + NAV_BUTTONS_PADDING;
			}
		}
		
		// use only dynamically created renderers
		override protected function initItems():void { };		
		
		protected function createRenderers():void
		{
			var rendererRef:Class = getDefinitionByName(RENDERER_CLASS) as Class;
			var len:int = _data.length;
			var curPos:Number = 0;
			
			for (var i:int = 0; i < len; i++)
			{
				var newRenderer:MenuTab = new rendererRef() as MenuTab;
				_canvas.addChild(newRenderer);				
				setupItem(newRenderer);
				newRenderer.validateNow();
				_itemsList.push(newRenderer);
				newRenderer.y = curPos;
				curPos += (TAB_PADDING + TAB_SIZE);
			}
			_renderersCreated = true;
			navButtonLB.y = _canvas.y + curPos + NAV_BUTTONS_PADDING;
		}
		
		// ignore
		override protected function updatePositions():void { }
	}

}
