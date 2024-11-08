package red.game.witcher3.menus.ryan_alchemy
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import red.game.witcher3.controls.BaseListItem;
	
	public class RecipeListItem extends BaseListItem
	{
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		public var mcUnavalaibleFeedback : MovieClip
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		public function RecipeListItem() 
		{
			super();
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();			
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.			
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		override public function setData( data:Object ):void
		{	
			if( data != null && data.label == "" ) data.label = "No name recipe"
			
			super.setData( data );
			if (! data )
			{
				return;
			}	
			
			this.label = data.label;
			
			mcUnavalaibleFeedback.visible = !data.canBeBrewed;
		}
	}

}