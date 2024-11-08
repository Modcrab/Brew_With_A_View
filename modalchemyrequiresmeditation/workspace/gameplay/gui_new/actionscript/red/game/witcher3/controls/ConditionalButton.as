package red.game.witcher3.controls
{
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.ButtonEvent
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class ConditionalButton extends Button
	{
		private var _showOnGamepad:Boolean = false;
		[Inspectable(defaultValue="false")]
		public function get showOnGamepad():Boolean { return _showOnGamepad }
		public function set showOnGamepad( value:Boolean ):void	
		{ 
			_showOnGamepad = value;
			updateControllerVisibility();
		}
		
		private var _showOnMouseKeyboard:Boolean = true;
		[Inspectable(defaultValue="true")]
		public function get showOnMouseKeyboard():Boolean { return _showOnMouseKeyboard }
		public function set showOnMouseKeyboard( value:Boolean ):void	
		{ 
			_showOnMouseKeyboard = value;
			updateControllerVisibility();
		}
		
		private var _showOnPC:Boolean = true;
		[Inspectable(defaultValue="true")]
		public function get showOnPC():Boolean { return _showOnPC }
		public function set showOnPC( value:Boolean ):void
		{
			_showOnPC = value;
			updateControllerVisibility();
		}
		
		private var _showOnXbox:Boolean = true;
		[Inspectable(defaultValue="true")]
		public function get showOnXbox():Boolean { return _showOnXbox }
		public function set showOnXbox( value:Boolean ):void
		{
			_showOnXbox = value;
			updateControllerVisibility();
		}
		
		private var _showOnPS4:Boolean = true;
		[Inspectable(defaultValue="true")]
		public function get showOnPS4():Boolean { return _showOnPS4 }
		public function set showOnPS4( value:Boolean ):void
		{
			_showOnPS4 = value;
			updateControllerVisibility();
		}
		
		public var mcClickRect:KeyboardButtonClickArea;
		
		// For code based visiblity triggering that goes beyond the conditional system
		private var _visiblityEnabled:Boolean = true;
		override public function get visible():Boolean
		{
			return _visiblityEnabled;
		}
		override public function set visible(value:Boolean):void
		{
			_visiblityEnabled = value;
			updateControllerVisibility();
		}
		
		public function ConditionalButton()
		{
			visible = false;
			preventAutosizing = true;
			constraintsDisabled = true;
		}
		
		override protected function configUI():void 
		{
			super.visible = false;
			
			super.configUI();
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			updateControllerVisibility();
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			updateControllerVisibility();
		}
		
		protected var _clickRectWidth:Number = -1;
        public function set visibleWidth(value:Number):void 
		{ 
           _clickRectWidth = value;
			
			if (mcClickRect)
			{
				updateClickRectWidth();
			}
			else
			{
				super.width = value;
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
			
			if (mcClickRect)
			{
				mcClickRect.state = state;
				updateClickRectWidth();
			}
		}
		
		protected function updateClickRectWidth():void
		{
			if (mcClickRect && _clickRectWidth != -1)
			{
				mcClickRect.x = -(_clickRectWidth / 2);
				trace("GFX -------- Setting actual size to: " + _clickRectWidth);
				mcClickRect.setActualSize(_clickRectWidth, mcClickRect.height);
			}
		}
		
		protected function updateControllerVisibility():void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			var platformType:uint = InputManager.getInstance().getPlatform();
			
			if (_visiblityEnabled)
			{			
				if (isGamepad)
				{
					if (showOnGamepad)
					{
						if (InputManager.getInstance().isXboxPlatform())
						{
							super.visible = _showOnXbox;
						}
						else if (InputManager.getInstance().isPsPlatform())
						{
							super.visible = _showOnPS4;
						}
						else
						{
							super.visible = _showOnPC;
						}
					}
					else
					{
						super.visible = false;
					}
				}
				else
				{
					if (showOnMouseKeyboard)
					{
						if (InputManager.getInstance().isXboxPlatform())
						{
							super.visible = _showOnXbox;
						}
						else if (InputManager.getInstance().isPsPlatform())
						{
							super.visible = _showOnPS4;
						}
						else
						{
							super.visible = _showOnPC;
						}
					}
					else
					{
						super.visible = false;
					}
				}
			}
			else
			{
				super.visible = false;
			}
		}
	}
}