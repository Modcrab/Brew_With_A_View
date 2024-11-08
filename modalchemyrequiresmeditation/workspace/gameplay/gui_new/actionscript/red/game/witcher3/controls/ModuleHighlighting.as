package red.game.witcher3.controls 
{
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Menu's module background highlight
	 * @author Yaroslav Getsevich
	 */
	public class ModuleHighlighting extends UIComponent
	{
		protected static const STATE_FOCUSED_LABEL:String = "focused";
		protected static const STATE_NORMAL_LABEL:String = "normal";
		public var imageStumb:Sprite;
		public var navigationIcons:Sprite;
		protected var _highlighted:Boolean;
		protected var _showNavigation:Boolean;
		protected var _alwaysHighlight:Boolean;
		
		public function ModuleHighlighting()
		{
			if (imageStumb)
			{
				imageStumb.visible = false;
			}
		}
		
		[Inspectable(defaultValue="true")]
		public function get showNavigation():Boolean { return _showNavigation }
		public function set showNavigation(value:Boolean):void
		{
			_showNavigation = value;
			navigationIcons.visible = _showNavigation && _highlighted;
		}
		
		[Inspectable(defaultValue="false")]
		public function get alwaysHighlight():Boolean { return _alwaysHighlight }
		public function set alwaysHighlight(value:Boolean):void
		{
			_alwaysHighlight = value;
			if (_alwaysHighlight)
			{
				highlighted = true;
			}
		}
		
		[Inspectable(defaultValue="false")]
		public function get highlighted():Boolean { return _highlighted }
		public function set highlighted(value:Boolean):void
		{
			// #J Highlighting system should now be removed/disabled. This is a first pass, someone should do a real cleanup at some point
			_highlighted = value;
			
			//trace("GFX ***** highlighted ", value, _highlighted, _alwaysHighlight);
			/*if (_highlighted != value && !(!value && _alwaysHighlight))
			{
				_highlighted = value;
				applyState(_highlighted ? STATE_FOCUSED_LABEL : STATE_NORMAL_LABEL);
				navigationIcons.visible = _showNavigation && _highlighted;
			}*/
		}
		
		protected function applyState(styleName:String):void
		{
			if (_labelHash[styleName])
			{
				//gotoAndPlay(styleName);
			}
			else
			{
				trace("GFX [WARNING] ", this, " - ", styleName, " state don't exist on the timeline");
			}
		}
	}
}