package red.core.overlay {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	import scaleform.clik.controls.StatusIndicator;
	
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class LoadingOverlay extends MovieClip 
	{
		public var mcProgressBar:StatusIndicator;
		public var mcLoading:MovieClip;
		
		private var lastFrameTimeInMS:int = 0;
		private var alphaAccel:Number = 0.;
		private var spinnerAnimationTime:int = 0;

		private var currentProgress:Number = 0.;
		private var displayFakeProgress:Boolean = false;

		
		public function LoadingOverlay() 
		{
			mcProgressBar.visible = false;
			mcProgressBar.minimum = 0;
			mcProgressBar.maximum = 1;
			mcProgressBar.validateNow();

			mcLoading.visible = false;
			mcLoading.alpha = 0.;
			
			if ( ! stage )
			{
				addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			}
			else
			{
				registerLoadingOverlay();
			}			
		}

		public function setProgressValue(value:Number):void
		{
			mcProgressBar.value = value;
		}

		public function showProgressBar(value:Boolean):void
		{
			mcProgressBar.visible = value;
		}
		
		public function fadeIn( fadeInTime : Number ):void
		{
			trace("LoadingOverlay fadeIn: " + fadeInTime );

			removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );


			if ( fadeInTime <= 0. )
			{
				mcLoading.alpha = 1.;
				mcLoading.visible = true;
			}
			else
			{
				mcLoading.alpha = 0.;
				mcLoading.visible = true;	
				alphaAccel = 1. / fadeInTime;
				lastFrameTimeInMS = getTimer();
				
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
			}
		}
		
		public function fadeOut( fadeOutTime : Number ):void
		{
			trace("LoadingOverlay fadeOut: " + fadeOutTime );

			removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
			

			if ( fadeOutTime <= 0. )
			{
				mcLoading.alpha = 0.;
				mcLoading.visible = false;
			}
			else
			{
				mcLoading.alpha = 1.;
				mcLoading.visible = true;
				alphaAccel = -1. / fadeOutTime;
				lastFrameTimeInMS = getTimer();
				
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
			}
		}
		
		private function handleEnterFrame(event:Event):void
		{
			var curTime:int = getTimer();
			var timeDelta:Number = (curTime - lastFrameTimeInMS)/1000.;
			mcLoading.alpha += timeDelta * alphaAccel;
			
			// Check the accel so not finishing when fading in from invisible
			if ( alphaAccel < 0 && mcLoading.alpha <= 0. )
			{
				removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
				mcLoading.visible = false;
				mcLoading.alpha = 0.;
				trace("LoadingOverlay finish fadeOut");
			}
			else if ( alphaAccel > 0 && mcLoading.alpha >= 1. )
			{
				removeEventListener( Event.ENTER_FRAME, handleEnterFrame, false );
				mcLoading.visible = true;
				mcLoading.alpha = 1.;
				trace("LoadingOverlay finish fadeIn");
			}

			lastFrameTimeInMS = curTime;
		}
		
		private function handleAddedToStage( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false );
			registerLoadingOverlay();
		}
		
		private function registerLoadingOverlay():void
		{
			trace("LoadingOverlay registerLoadingOverlay");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "registerLoadingOverlay", this );
			}
		}
	}
}
