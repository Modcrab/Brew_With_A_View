package red.game.witcher3.menus.meditation
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.meditation.MeditationBonusItemRenderer
	 * @author Getsevich Yaroslav
	 */
	public class MeditationBonusItemRenderer extends UIComponent
	{
		public var mcColoredBorder : MovieClip;
		public var mcIcon 		   : MovieClip;
		public var mcLockIcon	   : MovieClip;
		
		public var tfTitle 	 	 : TextField;
		public var tfDuration 	 : TextField;
		public var tfDescription : TextField;
		
		private var _data:Object;
		private var _activate:Boolean;
		private var _locked:Boolean;
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			tfTitle.text = CommonUtils.toUpperCaseSafe( _data.title );
			tfDuration.text = _data.duration;
			tfDescription.text = _data.description;
			tfDescription.height = tfDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			if (_data.duration)
			{
				tfDescription.y = tfDuration.y + tfDuration.textHeight;
			}
			else
			{
				tfDescription.y = tfDuration.y;
			}
			
			_locked = !_data.available;
			
			mcIcon.gotoAndStop( _data.type );
			
			updateLockedState();
		}
		
		public function get activate():Boolean { return _activate; }
		public function set activate(value:Boolean):void
		{
			_activate = value;
			updateLockedState();
		}
		
		private function updateLockedState():void
		{
			if (_locked)
			{
				mcColoredBorder.gotoAndStop( 3 );
				mcIcon.visible = false;
				mcLockIcon.visible = true;
				
				tfTitle.textColor = 0x5E5E5E;
				tfDuration.textColor = 0x5E5E5E;
				tfDescription.textColor = 0x5E5E5E;
			}
			else
			{
				mcColoredBorder.gotoAndStop( _activate ? 2 : 1 );
				mcIcon.alpha = _activate ? 1 : 0.5;
				mcColoredBorder.mcGreenFrame.gotoAndPlay( _activate ? "show" : "hide" )
				mcIcon.visible = true;
				mcLockIcon.visible = false;
				
				tfTitle.textColor = 0x9B9184;
				tfDuration.textColor = 0x9B9184;
				tfDescription.textColor = 0xD2D2D2;
			}
		}
		
	}

}
