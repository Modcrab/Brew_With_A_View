package red.game.witcher3.controls
{
	//import scaleform.clik.core.UIComponent;
	
/*	import flash.display.MovieClip;*/
	//import flash.text.TextField;
	import scaleform.clik.controls.Label;
	//import witcher3.game.GameInterface;
	
	//import witcher3.motion.TweenEx;
/*	import fl.transitions.easing.Strong;*/
	
/*	import flash.utils.Timer;
	import flash.events.TimerEvent;*/
	
	public class W3Label extends Label
	{

	//{region Art clips
	// ------------------------------------------------
			
		//public var mcTextShadow : MovieClip;
	//{region Private constants
	// ------------------------------------------------
	
/*		private static const TEXT_SHADOW_INITIAL_HEIGHT : Number = 32;
		private static const TEXT_LINE_HEIGHT : Number = 24.35;
		private static const TEXT_LINE_WIDTH_BORDERS : Number = 20;
		private static const TEXT_LINE_HEIGHT_BORDERS : Number = 5;	*/
		
	//{region Private variables
	// ------------------------------------------------
	
		
	//{region Initialization
	// ------------------------------------------------
	
		public function W3Label()
		{
			super();
		}
		
	//{region Overrides
	// ------------------------------------------------
	
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function updateText():void
		{
			super.updateText();
			//updateShadow();
        }
	}
}