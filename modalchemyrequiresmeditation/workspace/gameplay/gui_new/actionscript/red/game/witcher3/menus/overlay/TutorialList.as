package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	/**
	 * Tutorial List
	 * @author Getsevich Yaroslav
	 */
	public class TutorialList extends BasePopup
	{
		protected static const VIEWER_CLASSNAME:String = "TutorialBlockerRef";
		protected static const DEFAULT_WIDTH:Number = 1060; // 620 + 440
		protected var _tutorialViewer:TutorialBlocker;
		public var tutorialList:W3ScrollingList;
		public var tlScrollbar:ScrollBar;
		public var background:MovieClip;
		
		override protected function configUI():void 
		{
			super.configUI();
			_tutorialViewer = createViewer();			
			tutorialList.addEventListener(ListEvent.INDEX_CHANGE, handleTutorialChanged, false, 0, true);
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		override protected function populateData():void
		{
			if (_data && _data.tutorialList)
			{
				tutorialList.dataProvider = new DataProvider(_data.tutorialList as Array);
				tutorialList.ShowRenderers(true);
				tutorialList.selectedIndex = 0;
				tutorialList.focused = 1;
			}
		}
		
		private function handleTutorialChanged(event:ListEvent):void
		{
			if (event.itemData && _tutorialViewer)
			{
				var currentData:Object = event.itemData;
				currentData.ButtonsList = _data.ButtonsList;
				_tutorialViewer.data = currentData;
			}
		}
		
		private function createViewer():TutorialBlocker
		{
			try
			{
				var ContentClassRef:Class = getDefinitionByName(VIEWER_CLASSNAME) as Class;
				_tutorialViewer = new ContentClassRef() as TutorialBlocker;
				_tutorialViewer.fixedPosition = true;
				_tutorialViewer.x = background.width;
				_tutorialViewer.y = background.y;
				addChild(_tutorialViewer);
				setPosition();
				tutorialList.focused = 1;
				return _tutorialViewer;
			}
			catch (er:Error)
			{
				var contentError:Error = new Error();
				contentError.message = "WARNING: Missing " + VIEWER_CLASSNAME + " definition in the MenuOverlay.fla";
				throw(contentError);
			}
			return null;
		}
		
		private function setPosition():void
		{
			var screenRect:Rectangle = CommonUtils.getScreenRect();
			x = screenRect.x + Math.round((screenRect.width - DEFAULT_WIDTH) / 2);
			y = screenRect.y + Math.round((screenRect.height - height) / 2);
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			super.handleInput(event);
			if (!event.handled)
			{
				tutorialList.handleInput(event);
			}
		}
		
	}

}
