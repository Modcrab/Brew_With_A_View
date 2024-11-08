package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationTooltipButton
	 * @author Getsevich Yaroslav
	 */
	public class MutationTooltipButton extends UIComponent
	{
		public static const TYPE_START_RESEARCH:uint = 0;
		public static const TYPE_CLOSE_RESEARCH:uint = 1;
		public static const TYPE_EQUIP:uint = 2;
		public static const TYPE_UNEQUIP:uint = 3;
		public static const TYPE_APPLY:uint = 4;
		
		private static const RED_FRAME:uint = 1;
		private static const GREEN_FRAME:uint = 2;
		
		private static const BTN_PADDING:Number = 5;
		
		public var mcBackground 		: MovieClip;
		public var tfLabelRequirements  : TextField;
		public var btnAction    		: InputFeedbackButton;
		
		private var _type 			  : uint;
		private var _canBeHighlighted : Boolean;
		
		override protected function configUI():void
		{
			super.configUI();
			
			addEventListener( MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true );
			
			InputManager.getInstance().addEventListener( ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}
		
		public function setType( value : uint ) : void
		{
			var targetFrame : uint;
			var targetLabel : String;
			
			btnAction.clickable = false;
			_type = value;
			
			switch( _type )
			{
				case TYPE_APPLY:
					targetLabel = "[[panel_common_apply]]";
					targetFrame = GREEN_FRAME;
					btnAction.setDataFromStage( NavigationCode.GAMEPAD_A, KeyCode.ENTER );
					_canBeHighlighted = true;
					break;
					
				case TYPE_START_RESEARCH:
					targetLabel = "[[mutation_input_research_mutation]]";
					targetFrame = GREEN_FRAME;
					btnAction.setDataFromStage( NavigationCode.GAMEPAD_A, KeyCode.ENTER );
					break;
					
				case TYPE_CLOSE_RESEARCH:
					targetLabel = "[[mutation_input_close_research]]";
					targetFrame = RED_FRAME;
					btnAction.setDataFromStage( NavigationCode.GAMEPAD_B, KeyCode.ESCAPE );
					_canBeHighlighted = true;
					break;
					
				case TYPE_EQUIP:
					targetLabel = "[[mutation_input_activate_mutation]]";
					targetFrame = GREEN_FRAME;
					btnAction.setDataFromStage( NavigationCode.GAMEPAD_A, KeyCode.ENTER );
					break;
					
				case TYPE_UNEQUIP:
					targetLabel = "[[mutation_input_deactivate_mutation]]";
					targetFrame = RED_FRAME;
					btnAction.setDataFromStage( NavigationCode.GAMEPAD_A, KeyCode.ENTER );
					break;
			}
			
			gotoAndStop( targetFrame );
			tfLabelRequirements.text = targetLabel;
			updateAlignment();
		}
		
		private function handleControllerChanged(event:Event):void
		{
			updateAlignment()
		}
		
		private function handleMouseOver(event:MouseEvent):void
		{
			// TODO: ANIMATIONS
			
			//trace("GFX MutationTooltipButton :: handleMouseOver ", _canBeHighlighted, mcBackground);
			
			if ( _canBeHighlighted && mcBackground )
			{
				mcBackground.gotoAndStop("highlighted");
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void
		{
			// TODO: ANIMATIONS
			
			//trace("GFX MutationTooltipButton :: handleMouseOut ", _canBeHighlighted, mcBackground);
			
			if ( _canBeHighlighted && mcBackground )
			{
				mcBackground.gotoAndStop("normal");
			}
		}
		
		private function updateAlignment():void
		{
			tfLabelRequirements.x = btnAction.x +btnAction.getViewWidth() + BTN_PADDING;
			
		}
		
	}

}
