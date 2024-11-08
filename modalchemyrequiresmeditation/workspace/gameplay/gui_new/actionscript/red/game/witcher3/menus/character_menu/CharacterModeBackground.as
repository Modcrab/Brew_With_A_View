package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.menus.character.SkillSlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class CharacterModeBackground extends UIComponent
	{
		protected static const ANIM_DURATION:Number = 1;
		
		public var txtCaption:TextField;
		public var btnApply:InputFeedbackButton;
		public var btnCancel:InputFeedbackButton;
		public var mcBackground:MovieClip; // external MC
		public var mcBackgroundHitTest:MovieClip;
		
		protected var _isActive:Boolean;
		protected var _slotAvatar:SlotBase;
		protected var _avatarCanvas:Sprite;
		
		public var originalSlot:SlotBase;
		
		public static var CANCEL:String = "Background.Close.Cancel";
		public static var ACCEPT:String = "Background.Close.Accept";
		
		public function CharacterModeBackground()
		{
			_isActive = false;
			visible = false;
			tabEnabled = tabChildren = focusable = false;
			_avatarCanvas = new Sprite();
			addChild(_avatarCanvas);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			// TODO: LOCALIZATION
			// TODO: Context related behevior
			
			txtCaption.htmlText = "[[panel_character_skill_dialog_title]]";
			btnApply.label = "[[panel_common_accept]]";
			btnCancel.label = "[[panel_common_cancel]]";
			btnApply.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
			btnCancel.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			
			btnApply.addEventListener(ButtonEvent.CLICK, handleApplyClick, false, 0, true);
			btnCancel.addEventListener(ButtonEvent.CLICK, handleCancelClick, false, 0, true);
		}
		
		public function setCaption(capation:String):void
		{
			txtCaption.htmlText = capation;
		}
		
		public function activate(targetSlot:SlotBase = null):void
		{
			createSlotAvatar(targetSlot);
			visible = _isActive = true;
			
			mcBackground.visible = true;
			mcBackground.alpha = 0;
			GTweener.to(mcBackground, ANIM_DURATION, { alpha:1 }, { ease:Exponential.easeOut } );
			
			originalSlot = targetSlot;
		}
		
		public function deactivate():void
		{
			if (_slotAvatar)
			{
				GTweener.removeTweens(_avatarCanvas);
				_avatarCanvas.removeChild(_slotAvatar);
			}
			visible = _isActive = false;
			mcBackground.visible = false;
		}
		
		public function isActive():Boolean
		{
			return _isActive;
		}
		
		protected function createSlotAvatar(targetSlot:SlotBase):void
		{
			if (targetSlot)
			{
				var slotClassRef:Class = Class(getDefinitionByName(getQualifiedClassName(targetSlot)));
				var slotPosition:Point = new Point(targetSlot.x, targetSlot.y);
				var avatarPos:Point = targetSlot.parent.localToGlobal(slotPosition);
				
				_slotAvatar = new slotClassRef() as SlotBase;
				_slotAvatar.data = targetSlot.data;
				_slotAvatar.tabEnabled = true;
				_slotAvatar.focusable = false;
				_slotAvatar.alpha = 1;
				
				_avatarCanvas.addChild(_slotAvatar);
				_slotAvatar.validateNow();
				var slotRect:Rectangle = _slotAvatar.getSlotRect();
				var offsetX:Number = slotRect.width / 2;
				var offsetY:Number = slotRect.height / 2;
				_avatarCanvas.x = avatarPos.x + offsetX;
				_avatarCanvas.y = avatarPos.y + offsetY;
				_slotAvatar.x = - offsetX;
				_slotAvatar.y = - offsetY;
				
				_avatarCanvas.alpha = 0;
				_slotAvatar.filters = [new GlowFilter(0xFFFFB8, .5, 8, 8, 1, BitmapFilterQuality.HIGH)];
				GTweener.to(_avatarCanvas, ANIM_DURATION, { scaleX:1.1, scaleY:1.1, alpha:1 }, { ease:Exponential.easeOut } );
			}
		}
		
		private function handleApplyClick(event:ButtonEvent):void
		{
			userApply();
		}
		
		private function handleCancelClick(event:ButtonEvent):void
		{
			userCancel();
		}
		
		protected function userCancel():void
		{
			dispatchEvent(new Event(CharacterModeBackground.CANCEL));
		}
		
		protected function userApply():void
		{
			dispatchEvent(new Event(CharacterModeBackground.ACCEPT));
		}
		
	}

}
