package red.game.witcher3.hud.modules.pickeditemsinfo
{
	import scaleform.clik.controls.ScrollingList;
	import flash.text.TextField;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.None;
	import red.core.events.GameEvent;

	public class HudPickedItemsInfoListItem extends ListItemRenderer
	{
	
	//{region Private variables
	// ------------------------------------------------
		
		private var _initX : Number;
		private var _initY : Number;
		private var _isLast : Boolean = false;
	
	//{region Private constants
	// ------------------------------------------------

		private static const ANIMATION_DURATION : Number = 500;
		private static const ANIMATION_DELAY : Number = 3000;
		
	//{region Art clips
	// ------------------------------------------------
	public var tfQuantity : TextField;
	//{region Initialization
	// ------------------------------------------------
	
		public function HudPickedItemsInfoListItem() 
		{
			super();
		}
		
	//{region Overrides
	// ------------------------------------------------
		
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			textField.wordWrap = true;
			_initY = this.y;
		}
		
		override public function setData( data:Object ):void
		{
			tfQuantity.text = "";
			if (data)
			{
				if ( data.label && data.label != "" )
				{
					this.y = _initY;
					if ( _isLast )
					{
						this.alpha = 0;
					}
					else
					{
						this.alpha = 1;
					}
					super.setData( data );
					startAnimation();
				}
				if( data.quantity )
				{
					tfQuantity.text = "x" + data.quantity;
				}
				else
				{
					tfQuantity.text = "";
				}
			}
		}
		
	//{region private functions
	// ------------------------------------------------
		
		private function startAnimation():void
		{
			if ( index == 0 )
			{		
				TweenToHide();
			}
			else
			{
				TweenUp();
			}
		}
		
		private function TweenToHide() : void 
		{
			TweenEx.to(ANIMATION_DURATION, this, { y:(this.y - this.height ), alpha:0 }, { paused:false, onComplete:handleTweenToHideComplete, delay:ANIMATION_DELAY, ease:None.easeOut } );
		}
			
		private function TweenUp() : void 
		{
			TweenEx.to(ANIMATION_DURATION, this, { y:(this.y - this.height ), alpha:1 }, { paused:false, delay:ANIMATION_DELAY, ease:None.easeOut } );
		}
		
		private function handleTweenToHideComplete( tween:TweenEx ) : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRemovePickedItemsInfoFirstItem' ) );
		}
		
		public function set isLast( value : Boolean ) : void
		{
			_isLast = value;
		}
	}
}