package red.game.witcher3.utils.scrollbar
{
	import red.game.witcher3.utils.Math2;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class ScrollBar extends EventDispatcher
	{
		/* 
		 * v 2.1
		 * bugs deleted
		 * You must create two movieclips:
		 * track
		 * thumb
		 */
		public var track:MovieClip;
		public var thumb:MovieClip;
		
		private var clicked:Boolean=false;
		private var yOffset:Number;
		private var yMin:Number;
		private var yMax:Number;		
		private var sp:Number;
		private var stage:Stage;
		


		public function ScrollBar(thumb:MovieClip,track:MovieClip):void
		{
			
			
			this.thumb = thumb;
			this.track = track;
			yMin=track.y;
			yMax=track.y+track.height-thumb.height;
			thumb.addEventListener(MouseEvent.MOUSE_DOWN,hMouseDown);
			if (track.stage) 
			{
				setStage();
			}
			else 
			{
				track.addEventListener(Event.ADDED_TO_STAGE, hTrackAddedToStage);
			}
			
			
		}
		
		private function hTrackAddedToStage(e:Event):void 
		{
			track.removeEventListener(Event.ADDED_TO_STAGE, hTrackAddedToStage);
			setStage();
		}
		
		
		private function setStage():void 
		{
			if (!stage) 
			{
				stage = track.stage;
				stage.addEventListener(MouseEvent.MOUSE_UP, hMouseUp);
				
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, hMouseWheel);
			}
			
		}
		
		private function hMouseWheel(e:MouseEvent):void 
		{		
			setPositionFromPercent(Math2.between(getPercent() - e.delta,0,100));
		}
		
		
		
		private function hMouseDown(e:MouseEvent):void
		{
			clicked=true;
			yOffset=stage.mouseY-thumb.y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, hMove);
			dispatchEvent(new ScrollBarEvent(ScrollBarEvent.START_DRAG, getPercent()));
		}
		protected function hMove(e:MouseEvent):void
		{
			if (clicked == true)
			{
				thumb.y = stage.mouseY - yOffset;
			}
			sp = getPercent();
			dispatchEvent(new ScrollBarEvent(ScrollBarEvent.VALUE_CHANGED, sp));
			if (e)
			{
				//e.updateAfterEvent();
			}


		}
		public function getPercent():Number
		{
			
			thumb.y = Math2.between(thumb.y, yMin, yMax);
			return Math2.getPercentFromValue(yMin, yMax, thumb.y);
			//return  100*(thumb.y - track.y) / yMax;
		}
		
		public function setPositionFromPercent(percent:Number):void
		{
			var value:Number = Math2.getValueFromPercent(yMin, yMax, percent);
			thumb.y = Math2.between(value, yMin, yMax);
			hMove(null);
		}
		private function hMouseUp(E:MouseEvent):void
		{
			if(clicked==true)
			{
				clicked=false;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, hMove);
				dispatchEvent(new ScrollBarEvent(ScrollBarEvent.STOP_DRAG, getPercent()));
			}
			
		}
		
		public function get isDragged():Boolean { return clicked; }
		public function set visible(val:Boolean):void 
		{
			thumb.visible = val;
			track.visible = val;
		}
	}
	
}