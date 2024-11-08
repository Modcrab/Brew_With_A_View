package red.game.witcher3.hud.modules.statbars
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	
	/*import witcher3.motion.TweenEx;
	import fl.transitions.easing.Bounce;
	import fl.transitions.easing.Elastic;
	import fl.transitions.easing.Strong;*/
	
	public class HudHealthBarVines extends UIComponent
	{
		
	//{region Art clips
	// ------------------------------------------------
	
		public var mcVinesSmall:MovieClip;
		public var mcVinesBig:MovieClip;
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
	//{region Internal properties
	// ------------------------------------------------
		
	//{region Component properties
	// ------------------------------------------------
		
		/*protected var _GrowTime:int = 350;
		protected var _ShrinkTime:int = 850;
		
		protected var _VinesSmallMaxWidth : Number = 210;
		protected var _VinesBigMinWidth : Number = 255;
				
		protected var _VinesSmallInitialWidth : Number;
		protected var _VinesBigInitialWidth : Number;
		
		protected var _VinesSmallMaxHeight : Number = 42;
		protected var _VinesBigMinHeight : Number = 32;
				
		protected var _VinesSmallInitialHeight : Number;
		protected var _VinesBigInitialHeight : Number;*/
		
		
	//{region Component setters/getters
	// ------------------------------------------------
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudHealthBarVines()
		{
			super();
		}
	
	//{region Public functions
	// ------------------------------------------------
	
	//{region Overrides
	// ------------------------------------------------
		
		override protected function configUI():void
		{
			super.configUI();
		/*	_VinesSmallInitialHeight = mcVinesSmall.height;
			_VinesSmallInitialWidth = mcVinesSmall.width;
			
			_VinesBigInitialHeight = mcVinesBig.height;
			_VinesBigInitialWidth = mcVinesBig.width;
			
			trace("_VinesBigInitialHeight "+_VinesBigInitialHeight);
			
			AnimationShrinkFirst(mcVinesBig);
			AnimationGrowFirst(mcVinesSmall);*/
		}
	
	//{region Updates
	// ------------------------------------------------
		
	/*	private function AnimationShrinkFirst( target : MovieClip )
		{
			TweenEx.to( _ShrinkTime, target, { width:_VinesBigMinWidth, height:_VinesBigMinHeight},{ paused:false, ease:Strong.easeInOut ,onComplete:AnimationShrinkFirstEnd, delay: 150} );
		}
		
		private function AnimationGrowFirst( target : MovieClip )
		{
			TweenEx.to( _GrowTime, target, { width:_VinesSmallMaxWidth, height:_VinesSmallMaxHeight},{ paused:false, ease:Strong.easeInOut ,onComplete:AnimationGrowFirstEnd} );
		}
		
		private function AnimationShrinkSecond( target : MovieClip )
		{
			TweenEx.to( _ShrinkTime, target, { width:_VinesSmallInitialWidth, height:_VinesSmallInitialHeight},{ paused:false, ease:Strong.easeInOut ,onComplete:AnimationShrinkSecondEnd, delay : 150} );
		}
		
		private function AnimationGrowSecond( target : MovieClip )
		{
			TweenEx.to( _GrowTime, target, { width:_VinesBigInitialWidth, height:_VinesBigInitialHeight},{ paused:false, ease:Strong.easeInOut ,onComplete:AnimationGrowSecondEnd} );
		}
		
		private function AnimationShrinkFirstEnd( handledTween: TweenEx )
		{
			AnimationGrowSecond(MovieClip(handledTween.target));
		}
		
		private function AnimationGrowFirstEnd( handledTween: TweenEx )
		{
			AnimationShrinkSecond(MovieClip(handledTween.target));
		}
		
		private function AnimationShrinkSecondEnd( handledTween: TweenEx )
		{
			AnimationGrowFirst(MovieClip(handledTween.target));
		}
		
		private function AnimationGrowSecondEnd( handledTween: TweenEx )
		{
			AnimationShrinkFirst(MovieClip(handledTween.target));
		}*/
	}
}