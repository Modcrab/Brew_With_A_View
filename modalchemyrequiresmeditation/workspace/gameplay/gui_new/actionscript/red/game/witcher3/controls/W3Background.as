package red.game.witcher3.controls
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	public class W3Background extends UIComponent
	{
		public var mcFogEffect1:MovieClip;
		public var mcFogEffect2:MovieClip;
		public var visibilityChangeCallback:Function;
		
		protected var _fogStartX:int = int.MAX_VALUE;
		protected var _fogEndX:int = int.MAX_VALUE;
		
		protected var _forceVisible:Boolean = false;
		
		override protected function configUI():void
		{
			super.configUI();
			
			startBackgroundFogTween();
		}
		
		public function forceHide():void
		{
			_backgroundVisible = false;
			alpha = 0;
			visible = false;
		}
		
		protected function handleBackgroundFogTweener1Complete(curTween:GTween):void
		{
			if (mcFogEffect1)
			{
				GTweener.removeTweens(mcFogEffect1);
				mcFogEffect1.x = _fogStartX;
				GTweener.to(mcFogEffect1, 60, { x:_fogEndX }, { onComplete:handleBackgroundFogTweener1Complete } );
			}
		}
		
		protected function handleBackgroundFogTweener2Complete(curTween:GTween):void
		{
			if (mcFogEffect2)
			{
				GTweener.removeTweens(mcFogEffect2);
				mcFogEffect2.x = _fogEndX;
				GTweener.to(mcFogEffect2, 100, { x:_fogStartX }, { onComplete:handleBackgroundFogTweener1Complete } );
			}
		}
		
		protected function startBackgroundFogTween():void
		{
			if (mcFogEffect1 && mcFogEffect2)
			{
				if (_fogStartX == int.MAX_VALUE)
				{
					_fogStartX = mcFogEffect1.x;
				}
				
				if (_fogEndX == int.MAX_VALUE)
				{
					_fogEndX = mcFogEffect2.x;
				}
				
				mcFogEffect1.x = _fogStartX;
				mcFogEffect1.alpha = 0.8;
				
				GTweener.to(mcFogEffect1, 60, { x:_fogEndX }, { onComplete:handleBackgroundFogTweener1Complete } );
				
				mcFogEffect2.x = _fogEndX;
				
				GTweener.to(mcFogEffect2, 100, { x:_fogStartX }, { onComplete:handleBackgroundFogTweener2Complete } );
			}
		}
		
		public function set backgroundForceVisible(value:Boolean):void
		{
			if (_forceVisible != value)
			{
				_forceVisible = value;
				
				if (_forceVisible)
				{
					applyVisibility(true);
				}
				else
				{
					applyVisibility(_backgroundVisible);
				}
			}
		}
		
		protected var _backgroundVisible:Boolean = true;
		public function set backgroundVisible(value:Boolean):void
		{
			if (value != _backgroundVisible)
			{
				_backgroundVisible = value;
				
				GTweener.removeTweens(this);
				
				if (!_forceVisible)
				{
					applyVisibility(value);
				}
			}
		}
		
		protected var _lastVisiblityApplied:Boolean = false;
		protected function applyVisibility(isVisible:Boolean):void
		{
			if (_lastVisiblityApplied != isVisible)
			{
				_lastVisiblityApplied = isVisible;
				
				if (isVisible)
				{
					visible = true;
					GTweener.to(this, 0.2, { alpha:1.0 }, { } );
				}
				else
				{
					GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:handleBackgroundHideComplete } );
				}
				
				if ( visibilityChangeCallback != null )
				{
					visibilityChangeCallback( isVisible );
				}
			}
		}
		
		protected function handleBackgroundHideComplete(curTween:GTween):void
		{
			visible = false;
		}
	}
}