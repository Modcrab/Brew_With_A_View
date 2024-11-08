package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import red.game.witcher3.interfaces.IBaseSlot;
	
	/**
	 * WIP; dummy item renderer; should be replaced with real one
	 * @author Getsevich Yaroslav
	 */
	public class SlotDummy extends SlotBase
	{
		public var dummy:MovieClip;
		
		protected var _tempData:Object;
		protected var _isReadyToRock:Boolean = false;
		
		override protected function config_init_call() { } // blocked
		override protected function constructor_init_call() { } // blocked
		
		override protected function draw():void
		{
			if (_isReadyToRock)
			{
				var canValidate:Boolean = _validationBounds == null || getBounds(stage).intersects( _validationBounds );
				
				if (canValidate)
				{
					// TODO: Replace
				}
			}
		}
		
		override public function set data(value:*):void
		{
			const CELL_SIZE : Number = 64;
			
			if (value)
			{
				_tempData = value;
				_isReadyToRock = true;
				
				gridSize = _tempData.gridSize;
				dummy.height = CELL_SIZE * gridSize;
			}
		}
		
	}

}
