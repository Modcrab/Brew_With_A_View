package red.game.witcher3.menus.overlay 
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import red.core.constants.KeyCode;
	import red.game.witcher3.menus.common.ButtonContainerModule;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	
	/**
	 * Base class for all popups
	 * @author Getsevich Yaroslav
	 */
	public class BasePopup extends UIComponent
	{
		public var mcInpuFeedback:ModuleInputFeedback;
		protected var _data:Object;
		protected var _fixedPosition:Boolean;
		
		public function BasePopup()
		{
			mcInpuFeedback.addHotkey(KeyCode.ENTER, KeyCode.SPACE);
			mcInpuFeedback.addHotkey(KeyCode.ENTER, KeyCode.NUMPAD_ENTER);
			mcInpuFeedback.addHotkey(KeyCode.ENTER, KeyCode.E);
			mcInpuFeedback.addHotkey(KeyCode.E, KeyCode.ENTER);
			mcInpuFeedback.addHotkey(KeyCode.E, KeyCode.NUMPAD_ENTER);
			mcInpuFeedback.addHotkey(KeyCode.E, KeyCode.SPACE);
			mcInpuFeedback.buttonAlign = "center";
			mcInpuFeedback.coloringButtons = true;
			visible = false;
		}
		
		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			_data = value;
			populateData();
		}
		
		public function get fixedPosition():Boolean { return _fixedPosition }
		public function set fixedPosition(value:Boolean):void
		{
			_fixedPosition = value;
		}
		
		protected function populateData():void
		{
			visible = true;
			
			if (_fixedPosition)
			{
				return;
			}
			if (_data.ScreenPosX > 0 || _data.ScreenPosY > 0)
			{
				var screenRect:Rectangle = CommonUtils.getScreenRect();
				var targetX:Number = screenRect.x + screenRect.width * _data.ScreenPosX;
				var targetY:Number = screenRect.y + screenRect.height * _data.ScreenPosY;
				x = targetX;
				y = targetY;
			}
			else
			{				
				var visibleRect:Rectangle = CommonUtils.getScreenRect();
				var bkMovie:MovieClip = getChildByName("mcBackground") as MovieClip;
				
				if (bkMovie)
				{
					x = visibleRect.x + visibleRect.width / 2  - bkMovie.width / 2;
				}
				else
				{
					x = visibleRect.x + visibleRect.width / 2  - actualWidth / 2;
				}
				
				y = visibleRect.y + visibleRect.height / 2  - actualHeight / 2;
			}
			
			const animOffset = 8;
			var targetAnimY = y;
			alpha = 0;
			y -= animOffset;
			GTweener.to(this, .5, { alpha:1, y:targetAnimY }, { ease:Exponential.easeOut } );
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			super.handleInput(event);
		}
		
	}
}
