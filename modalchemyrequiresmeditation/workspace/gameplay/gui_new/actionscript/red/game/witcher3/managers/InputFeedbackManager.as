package red.game.witcher3.managers
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Manager provides access to common input feedback module in the commonMenu
	 * @author Yaroslav Getsevich
	 */
	public class InputFeedbackManager
	{
		public static var useOverlayPopup:Boolean = false;
		public static var eventDispatcher:EventDispatcher;
		
		private static var _currentMaxIdx:uint = 0;
		private static var _buttonsList:Object = {}
		
		public static function appendButtonById(actionId:uint, gamepadNavCode:String, keyboardKeyCode:int, label:String, hold:Boolean = false):void
		{
			if (!eventDispatcher) return
			
			if (useOverlayPopup)
			{
				label = "[[" + label + "]]";
				eventDispatcher.dispatchEvent(new GameEvent(GameEvent.CALL, "OnAppendButton", [actionId, gamepadNavCode, keyboardKeyCode, label]) );
			}
			else
				eventDispatcher.dispatchEvent(new GameEvent(GameEvent.CALL, "OnAppendGFxButton", [actionId, gamepadNavCode, keyboardKeyCode, label, hold]) );
				
				
			
		}
		
		public static function removeButtonById(actionId:uint):void
		{
			if (!eventDispatcher) return
			
			if (useOverlayPopup)
				eventDispatcher.dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveButton", [actionId]));
			else
				eventDispatcher.dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveGFxButton", [actionId]));
		}
		
		/**
		 * Add/Modify input feedback button
		 * @param	context EventDispatcher		 
		 * @param	gamepadNavCode NavigationEquivalent for gamepad
		 * @param	keyboardKeyCode ASCII key code for keyboard
		 * @param	label Localized string
		 */
		public static function appendButton(context:EventDispatcher, gamepadNavCode:String, keyboardKeyCode:int, label:String, hold:Boolean = false):int
		{
			var contextComponent:UIComponent = context as UIComponent;
			if (contextComponent && !contextComponent.initialized)
			{
				return -1;	
			}
			_currentMaxIdx++;
			
			if (useOverlayPopup)
			{
				context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnAppendButton", [_currentMaxIdx, gamepadNavCode, keyboardKeyCode, label]) );
			}
			else
			{
				context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnAppendGFxButton", [_currentMaxIdx, gamepadNavCode, keyboardKeyCode, label, hold]) );
			}
			return _currentMaxIdx;
		}
		
		/**
		 * Remove input feedback button
		 * @param	context EventDispatcher
		 * @param	actionId Unique key field
		 */
		public static function removeButton(context:EventDispatcher, actionId:uint):void
		{
			if (useOverlayPopup)
			{
				context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveButton", [actionId]));
			}
			else
			{
				context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveGFxButton", [actionId]));
			}
		}
		
		/**
		 * Remove all buttons added by current swf
		 * @param	context EventDispatcher
		 */
		public static function cleanupButtons(context:EventDispatcher = null):void
		{
			var rootDispatcher:EventDispatcher = eventDispatcher ? eventDispatcher : context;
			if (!rootDispatcher)
			{
				return;
			}
			if (useOverlayPopup)
			{
				rootDispatcher.dispatchEvent(new GameEvent(GameEvent.CALL, "OnCleanupButtons"));
			}
			else
			{
				// not supported
			}
		}
		
		/*
		 *   Managing buttons without id tracking
		 * 	 Use context name + gamepadNavCode + keyboardKeyCode as hash key
		 */
		
		public static function appendUniqueButton(context:EventDispatcher, gamepadNavCode:String, keyboardKeyCode:int, label:String):void
		{
			var contextComponent:UIComponent = context as UIComponent;
			if (contextComponent && !contextComponent.initialized)
			{
				return;	
			}
			var uniqCode:String = context.toString() + gamepadNavCode + "_" + keyboardKeyCode;
			tryRemoveUniqueButton(context, uniqCode);
			_currentMaxIdx++;
			_buttonsList[uniqCode] = _currentMaxIdx;
			context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnAppendGFxButton", [_currentMaxIdx, gamepadNavCode, keyboardKeyCode, label]) );
		}
		
		public static function removeUniqueButton(context:EventDispatcher, gamepadNavCode:String, keyboardKeyCode:int):void
		{
			var uniqCode:String = context.toString() + gamepadNavCode + "_" + keyboardKeyCode;
			tryRemoveUniqueButton(context, uniqCode);
		}
		
		private static function tryRemoveUniqueButton(context:EventDispatcher, uniqCode:String):void
		{
			var targetActionId:int = _buttonsList[uniqCode];
			if (targetActionId)
			{
				context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveGFxButton", [targetActionId]));
				delete _buttonsList[uniqCode];
			}
		}
		
		/**
		 * Update butttons
		 * @param	context EventDispatcher
		 */
		public static function updateButtons(context:EventDispatcher):void
		{
			context.dispatchEvent(new GameEvent(GameEvent.CALL, "OnUpdateGFxButtonsList"));
		}
		
	}

}
