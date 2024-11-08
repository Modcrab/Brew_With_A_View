package red.game.witcher3.menus.photomode 
{
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ButtonBar;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	
	public class PhotomodeTabbedMenu extends UIComponent
	{
		public var m_buttonBar : ButtonBar;
		public var m_content : ScrollingList;
		
		public var m_contentItem1 : PhotomodeSliderRenderer;
		public var m_contentItem2 : PhotomodeSliderRenderer;
		public var m_contentItem3 : PhotomodeSliderRenderer;
		public var m_contentItem4 : PhotomodeSliderRenderer;
		public var m_contentItem5 : PhotomodeSliderRenderer;
		public var m_contentItem6 : PhotomodeSliderRenderer;
		
		override protected function configUI():void
		{
			super.configUI();
			
			m_content.dataProvider = new DataProvider();
			m_content.removeEventListener(InputEvent.INPUT, m_content.handleInput);	
			
			m_buttonBar.addEventListener(IndexEvent.INDEX_CHANGE, onTabChange);		
			
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		public function setTabs(data:DataProvider):void
		{
			m_buttonBar.dataProvider = data;
			m_buttonBar.selectedIndex = 0;
			m_buttonBar.validateNow();
		}
		
		private function onTabChange(event:IndexEvent):void 
		{
			if (event.data == null)
				return;
			
			var dataProvider = event.data.data as IDataProvider;
			
			if (dataProvider == null)
				return;
			
			m_content.dataProvider = dataProvider;
			m_content.selectedIndex = 0;
			m_content.validateNow();
		}
		
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			if (!keyDown)
				return;
				
			switch (details.code) 
			{
			case KeyCode.Q:
			case KeyCode.PAD_LEFT_SHOULDER:
				m_buttonBar.selectedIndex = m_buttonBar.selectedIndex == 0 ? 0 : m_buttonBar.selectedIndex - 1;
				break;
			case KeyCode.E:
			case KeyCode.PAD_RIGHT_SHOULDER:
				m_buttonBar.selectedIndex = m_buttonBar.selectedIndex == m_buttonBar.dataProvider.length - 1 ? m_buttonBar.selectedIndex : m_buttonBar.selectedIndex + 1;
				break;
			case KeyCode.PAD_DIGIT_DOWN:
				m_content.selectedIndex = m_content.selectedIndex == m_content.dataProvider.length - 1 ? m_content.selectedIndex : m_content.selectedIndex + 1;
				break;
			case KeyCode.DOWN:
				if (InputManager.getInstance().isGamepad())
					break;
				m_content.selectedIndex = m_content.selectedIndex == m_content.dataProvider.length - 1 ? m_content.selectedIndex : m_content.selectedIndex + 1;
				break;
			case KeyCode.PAD_DIGIT_UP:
				m_content.selectedIndex = m_content.selectedIndex == 0 ? 0 : m_content.selectedIndex - 1;
				break;
			case KeyCode.UP:
				if (InputManager.getInstance().isGamepad())
					break;
				m_content.selectedIndex = m_content.selectedIndex == 0 ? 0 : m_content.selectedIndex - 1;
				break;
			default:
				break;
			}
		}
	}
}