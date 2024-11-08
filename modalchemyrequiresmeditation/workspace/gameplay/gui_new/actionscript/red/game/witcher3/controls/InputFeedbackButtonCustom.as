package red.game.witcher3.controls
{
	import adobe.utils.CustomActions;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.core.data.InputAxisData;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.KeyboardKeys;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * Input button binded
	 * @author Voinescu Dan
	 */
	public class InputFeedbackButtonCustom extends InputFeedbackButton
	{
		protected static const TEXT_OFFSET_HIGH:Number = 20;
		
		public function InputFeedbackButtonCustom()
		{
			
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
		}
		override protected function updateText():void
		{
			if (_label != null && textField != null)
			{
					
				if (_overrideTextColor >= 0)
				{
					textField.textColor = _overrideTextColor
                	textField.text = _label;
				}
				else
				{
					textField.htmlText = _label;
				}
				
				if (_lowercaseLabels)
				{
					textField.text = CommonUtils.toLowerCaseExSafe(textField.text);
				}
				
				textField.height = textField.textHeight + TEXT_OFFSET;
				
				if (mcClickRect && mcClickRect.visible)
				{
					var animStateClip:KeyboardButtonClickArea = mcClickRect as KeyboardButtonClickArea;
					
					if (animStateClip)
					{
						animStateClip.state = state;
						animStateClip.setActualSize( textField.textWidth + TEXT_OFFSET_HIGH, tfKeyLabel.height + textField.textHeight + TEXT_OFFSET_HIGH + TEXT_OFFSET);
						
						mcClickRect.x = textField.x + textField.width / 2;
						mcClickRect.y = tfKeyLabel.y - TEXT_OFFSET;
						mcClickRect.visible = true;
						//mcClickRect.height = tfKeyLabel.height + textField.y + textField.textHeight + TEXT_OFFSET;
					}
					else
					if (mcClickRect)
					{
						mcClickRect.visible = false;
					}
				}
				
				
			}
		}
		override protected function displayKeyboardIcon():void 
		{
			super.displayKeyboardIcon();
			tfKeyLabel.x = textField.x + textField.width / 2 - tfKeyLabel.width / 2;
		}
		
	}
}
