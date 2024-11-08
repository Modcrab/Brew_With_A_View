package red.game.witcher3.utils 
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CTwoFramesButton 
	{
		public var viewComponent:MovieClip;
		
		//mc_hit
		public var rollListener:MovieClip;
		
		public function CTwoFramesButton(viewComponent:MovieClip) 
		{
			this.viewComponent = viewComponent;
			if (viewComponent.mc_hit)
			{
				rollListener = viewComponent.mc_hit;
				viewComponent.mouseEnabled = false;
				rollListener.mouseEnabled = true;
				viewComponent.mouseChildren = true;
				
				
			}
			else 
			{
				rollListener = viewComponent;
				viewComponent.mouseChildren = false;
			}
			rollListener.buttonMode = true;
			
			viewComponent.addFrameScript(0, viewComponent.stop);
			initListeners();
		}
		public function initListeners():void 
		{
			rollListener.addEventListener(MouseEvent.MOUSE_OVER, hOver);
			rollListener.addEventListener(MouseEvent.MOUSE_OUT, hOut);
			viewComponent.addEventListener(Event.REMOVED_FROM_STAGE, hRemovedFromStage);
		}
		
		private function hRemovedFromStage(e:Event):void 
		{
			viewComponent.removeEventListener(Event.REMOVED_FROM_STAGE, hRemovedFromStage);
			destroy();
		}
		public function hOut(e:MouseEvent):void 
		{
			if (viewComponent.enabled == true)
			{
				viewComponent.gotoAndStop(1);
			}
		}
		public function hOver(e:MouseEvent):void 
		{
			if (viewComponent.enabled == true)
			{
				viewComponent.gotoAndStop(2);
			}
		}
		public function destroy():void 
		{
			
			rollListener.removeEventListener(MouseEvent.MOUSE_OVER, hOver);
			rollListener.removeEventListener(MouseEvent.MOUSE_OUT, hOut);
		}
		
		
	}

}