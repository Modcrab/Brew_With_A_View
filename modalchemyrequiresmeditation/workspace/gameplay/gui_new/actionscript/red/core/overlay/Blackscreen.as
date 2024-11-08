package red.core.overlay {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.utils.getTimer;
	
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	// A loadingscreen that's just a blackscreen.
	public class Blackscreen extends MovieClip {
			
		public var mcBlackscreen:MovieClip;
		
		private var lastFrameTimeInMS:int = 0;
		private var blackscreenAlphaAccel:Number = 0.;
		
		public function Blackscreen()
		{				
			var initString:String = "0x000000";
			if ( Extensions.enabled )
			{
				initString = ExternalInterface.call( "initString" ) as String;
			}
			trace("LoadingScreen initString: " + initString);
			
			var color:uint = parseInt( initString, 16 );
			trace("color: " + color );
			var ct:ColorTransform = mcBlackscreen.transform.colorTransform;
			ct.color = color;
			ct.alphaOffset = 255;
			mcBlackscreen.transform.colorTransform = ct;
			trace("Blackscreen color: " + mcBlackscreen.transform.colorTransform);
		
			if ( ! stage )
			{
				addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			}
			else
			{
				registerLoadingScreen();
			}
		}
		
		private function handleAddedToStage( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false );
			registerLoadingScreen();
		}
		
		private function registerLoadingScreen():void
		{
			trace("Blackscreen registerLoadingScreen");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "registerLoadingScreen", this );
			}
		}
		
		public function setPlatform( platformType:uint ):void
		{
		}
		
		public function setVideoSubtitles( text:String ):void
		{
		}
		
		public function setTipText( text:String ):void
		{
		}
		
		public function showVideoSkip():void
		{
		}
		
		public function hideVideoSkip():void
		{
		}
		
		public function showImage():void
		{
		}
		
		public function hideImage():void
		{
		}
		
		// Note fadeIn/fadeOut is the reverse of a normal loading screen. Since here we're fading in and out the blackscreen
		// itself, instead of using a blackscreen to fadeIn/fadeOut a loading screen
		
		public function fadeOut( fadeOutTime : Number ):void
		{
			trace("fadeOut: " + fadeOutTime );

			// Stay visible! If we're color-matching the postprocess don't want color flickering
			//mcBlackscreen.visible = false;
			onFadeOutCompleted();
		}
		
		public function fadeIn( fadeInTime : Number ):void
		{
			// Always instant to cover any transitions from other colored postprocess ASAP
			trace("fadeIn");
			mcBlackscreen.visible = true;
			mcBlackscreen.alpha = 1.;
		}
		
		private function onFadeOutCompleted():void
		{
			trace("LoadingScreen fadeOutCompleted");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "fadeOutCompleted", this );
			}
		}
	}
}
