package red.core.overlay {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class SavingOverlay extends MovieClip {
		
		
		public function SavingOverlay() {
			if ( ! stage )
			{
				addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			}
			else
			{
				registerSavingOverlay();
			}
		}
		
		private function handleAddedToStage( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false );
			registerSavingOverlay();
		}
		
		private function registerSavingOverlay():void
		{
			trace("SavingOverlay registerSavingOverlay");
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "registerSavingOverlay", this );
			}
		}
	}
	
}
