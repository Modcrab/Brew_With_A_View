package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.game.witcher3.events.SlotConnectorEvent;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Color line
	 * @author Yaroslav Getsevich
	 */
	public class SkillSlotConnector extends UIComponent
	{
		protected static var LABEL_START:String = "start";
		protected static var LABEL_COMPLETE:String = "complete";
		
		public var lineAnim:MovieClip;
		public var lineStatic:MovieClip;
		protected var _currentColor:String;
		
		public function SkillSlotConnector()
		{
			_currentColor = "SC_None";
		}
		
		public function get currentColor():String { return _currentColor };
		public function set currentColor(value:String):void
		{
			if (value != _currentColor)
			{
				trace("GFX -----------------------------------  from color: " + _currentColor + ", to color: " + value);
				
				gotoAndPlay(LABEL_START);
				
				addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
				
				if (_currentColor)
				{
					lineStatic.gotoAndStop(_currentColor);
				}
				
				_currentColor = value;
				
				lineAnim.gotoAndStop(_currentColor);
			}
		}
		
		protected function handleEnterFrame(event:Event):void
		{
			if (currentFrameLabel == LABEL_COMPLETE)
			{
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
				
				var completeEvent:SlotConnectorEvent = new SlotConnectorEvent(SlotConnectorEvent.EVENT_COMPLETE);
				
				completeEvent.connectorColor = _currentColor;
				dispatchEvent(completeEvent);
			}
		}
	}

}
