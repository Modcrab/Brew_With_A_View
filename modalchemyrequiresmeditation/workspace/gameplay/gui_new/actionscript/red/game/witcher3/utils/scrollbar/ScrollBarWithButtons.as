package red.game.witcher3.utils.scrollbar 
{
	import red.game.witcher3.utils.Math2;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	public class ScrollBarWithButtons extends ScrollBar
	{
		public var jumpPercentValue:Number = 5;
		public var btn_up:MovieClip;
		public var btn_down:MovieClip;
		public function ScrollBarWithButtons(thumb:MovieClip,track:MovieClip,btn_down:MovieClip,btn_up:MovieClip) 
		{
			this.btn_down = btn_down;
			this.btn_up = btn_up;
			btn_down.addEventListener(MouseEvent.CLICK, hDown);
			btn_up.addEventListener(MouseEvent.CLICK, hUp);
			super(thumb, track);
		}
		
		private function hUp(e:MouseEvent):void 
		{
			setPositionFromPercent(Math2.between(getPercent() - jumpPercentValue,0,100));
			hMove(new MouseEvent(""));
		}
		
		private function hDown(e:MouseEvent):void 
		{
			
			setPositionFromPercent(Math2.between(getPercent() + jumpPercentValue,0,100));
			
			hMove(new MouseEvent(""));
		}
		override public function set visible(val:Boolean):void 
		{
			super.visible = val;
			btn_down.visible = val;
			btn_up.visible = val;
		}
		
	}

}