package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.game.witcher3.events.MapAnimation;
	import scaleform.clik.core.UIComponent;

	public class BaseMap extends UIComponent
	{
		protected var _enabled : Boolean = false;
		protected var _transitionTween:GTween;
		protected var _defaultScale:Number = 1;
		
		protected const UNIVERSE_MAP_ZOOM = 0.9;

		protected override function configUI():void
		{
			super.configUI();
		}
		
		public function CanProcessInput() : Boolean
		{
			return false;
		}

		public function Enable( value : Boolean, force : Boolean = false )
		{
			if (_enabled == value)
			{
				if ( !force )
				{
					return;
				}
			}
			
			_enabled = value;
			if (_enabled)
			{
				showMap()
			}
			else
			{
				hideMap();
			}
		}
		
		protected function showMap(animTween:Boolean = true):void
		{
			GTweener.removeTweens(this);
			if (animTween)
			{
				alpha = 0;
				scaleX = scaleY = 2;
				visible = true;
				GTweener.removeTweens(this);
				_transitionTween = GTweener.to(this, 1,  { scaleX:UNIVERSE_MAP_ZOOM, scaleY:UNIVERSE_MAP_ZOOM, alpha:1 }, { ease:Exponential.easeOut, onComplete: handleShowAnim } );
			}
			else
			{
				handleShowAnim();
			}
		}
		
		protected function hideMap(animTween:Boolean = true):void
		{
			GTweener.removeTweens(this);
			if (animTween)
			{
				visible = true;
				GTweener.removeTweens(this);
				_transitionTween = GTweener.to(this, 1,  { scaleX:2, scaleY:2, alpha:0 }, { ease:Exponential.easeOut, onComplete: handleHideAnim } );
			}
			else
			{
				handleHideAnim();
			}
		}
		
		protected function handleShowAnim(curTween:GTween = null):void
		{
			visible = true;
			alpha = 1;
			scaleX = scaleY = UNIVERSE_MAP_ZOOM;
			_transitionTween = null;
			dispatchEvent(new MapAnimation(MapAnimation.COMPLETE_SHOW, true));
		}
		
		protected function handleHideAnim(curTween:GTween = null):void
		{
			visible = false;
			_transitionTween = null;
			dispatchEvent(new MapAnimation(MapAnimation.COMPLETE_HIDE, true));
		}

		public function OnControllerChanged( isGamepad : Boolean )
		{
		}

		public function IsEnabled() : Boolean
		{
			return _enabled;
		}
		
		// avoid click invalidation system for tweens
		override public function get scaleX():Number { return super.actualScaleX; }
		override public function get scaleY():Number { return super.actualScaleY; }	
	}

}
