package red.game.witcher3.managers 
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.motion.Tween;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	/**
	 * @author Getsevich Yaroslav
	 */
	public class ZoomManager 
	{
		protected static const SCALE:Number = 1.8;
		protected static const DURATION:Number = 1;
		
		protected static var _instance:ZoomManager;
		public static function getInstanse():ZoomManager
		{
			if (!_instance)
			{
				_instance = new ZoomManager();
			}
			return _instance;
		}
		
		private var _avatarShown:Boolean;
		private var _parent:Sprite;
		private var _canvas:Sprite;
		private var _shadow:Sprite;
		private var _targetItem:BaseListItem;
		private var _currentAvatar:BaseListItem;
		
		// -- API
		
		public function init(mgrParent:Sprite):void
		{
			var visibleRect:Rectangle = Extensions.visibleRect;
			
			_parent = mgrParent;
			_canvas = new Sprite();	
			_shadow = CommonUtils.createSolidColorSprite(visibleRect, 0x000000, .75);
			_shadow.visible = false;
			
			_parent.addChild(_shadow);
			_parent.addChild(_canvas);
			
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 100000, true);
		}
		
		public function setTargetRenderer(targetItem:BaseListItem):void
		{
			trace("GFX setTargetRenderer ", targetItem);
			
			if (_currentAvatar)
			{
				destroyAvatar(true);
			}
			
			_targetItem = targetItem;
		}
		
		// -- ctrl
		
		private function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			
			if (details.navEquivalent == NavigationCode.GAMEPAD_R3 && details.value == InputValue.KEY_UP)
			{
				trace("GFX handleInput show/hide; _avatarShown ", _avatarShown, "; _targetItem", _targetItem);
				
				if (_avatarShown)
				{
					destroyAvatar();
				}
				else
				if (_targetItem)
				{
					createAvatar(_targetItem);
				}
				
				event.handled = true;
				event.stopImmediatePropagation();
			}
			else
			if (details.navEquivalent == NavigationCode.GAMEPAD_B && details.value == InputValue.KEY_DOWN && _avatarShown)
			{
				destroyAvatar();
				event.handled = true;
				event.stopImmediatePropagation();
			}
		}
		
		// -- show / hide scaled copy
		
		private function createAvatar(target:BaseListItem):void
		{
			_shadow.visible = true;
			_shadow.alpha = 0;
			
			trace("GFX createAvatar ", _currentAvatar);
			
			GTweener.removeTweens(_shadow);
			GTweener.to(_shadow, DURATION, { alpha: 1 }, { ease:Exponential.easeOut } )
			
			if (_currentAvatar)
			{
				GTweener.removeTweens(_currentAvatar);
				_canvas.removeChild(_currentAvatar);
				_currentAvatar = null;
			}
			
			_currentAvatar = copy(target);
			
			GTweener.to(_currentAvatar, DURATION, { scaleX:SCALE, scaleY:SCALE }, {ease:Exponential.easeOut} )
			
			target.visible = false;
			_avatarShown = true;
		}
		
		private function destroyAvatar(immediately:Boolean = false):void
		{
			GTweener.removeTweens(_shadow);
			GTweener.to(_shadow, DURATION, { alpha: 0 }, { ease:Exponential.easeOut, onComplete:handleFadeOutComplete} );
			
			trace("GFX destroyAvatar ", _currentAvatar, "; immediately ", immediately);
			
			if (_currentAvatar)
			{
				if (!immediately)
				{
					GTweener.removeTweens(_currentAvatar);
					GTweener.to(_currentAvatar, DURATION, { scaleX:1, scaleY:1 }, { ease:Exponential.easeOut, onComplete : handleRemoveCurrentAvatar } );
				}
				else
				{
					_canvas.removeChild(_currentAvatar);
					_currentAvatar = null;
					_targetItem.visible = true;
				}
			}
			
			_avatarShown = false;
		}
		
		// -- handlers
		
		private function handleFadeOutComplete(tw:GTween):void
		{
			_shadow.visible = false;
		}
		
		private function handleRemoveCurrentAvatar(tw:Tween):void
		{
			_canvas.removeChild(_currentAvatar);
			_currentAvatar = null;
			_targetItem.visible = true;
		}
		
		// -- underhood
		
		private function copy(target:BaseListItem):BaseListItem
		{
			trace("GFX copy ", target);
			
			if (target)
			{
				var constructorRef:Class = Object(target).constructor;
				
				_currentAvatar = new constructorRef();
				_currentAvatar.data = target.data;
				
				var localPos:Point = new Point(target.x, target.y);
				var globalPos:Point = target.parent.localToGlobal(localPos);
				
				_currentAvatar.x = globalPos.x;
				_currentAvatar.y = globalPos.y;				
				
				_canvas.addChild(_currentAvatar);
				
				return _currentAvatar;
			}
			
			return null;
		}
		
	}

}
