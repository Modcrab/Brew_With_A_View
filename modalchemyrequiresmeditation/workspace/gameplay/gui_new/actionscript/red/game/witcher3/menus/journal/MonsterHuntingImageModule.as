/***********************************************************************
/** Journal tabs module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.journal
{
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	
	public class MonsterHuntingImageModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcIconLoader : W3UILoader;
		//public var mcTransitionClip : MovieClip;
		public var bitmap1 : Bitmap;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function MonsterHuntingImageModule()
		{
			super();
		}
		
		protected override function configUI() : void
		{
			super.configUI();
			focusable = false;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "journal.hunting.monster.image", [handleMonsterImageSet]));
		}

		override public function toString() : String
		{
			return "[W3 MonsterHuntingImageModule]"
		}
		
		protected function handleMonsterImageSet( value : String ):void
		{
			if ( mcIconLoader.source )
			{
				CreateBitmap();
			}
			if (mcIconLoader)
			{
				mcIconLoader.source = value;
			}
		}
		
		protected function CreateBitmap()
		{
			var bd1:BitmapData = new BitmapData(mcIconLoader.width,mcIconLoader.height,true,0xFFFFFFFF);
			var bitmap1:Bitmap = new Bitmap(bd1);
			bd1.draw(mcIconLoader);
			
			bitmap1.x = mcIconLoader.x;
			bitmap1.y = mcIconLoader.y;
			bitmap1.alpha = 1;
			mcIconLoader.alpha = 0;
			this.addChild(bitmap1);
			GTweener.to( bitmap1, 3, { alpha:0 },  { ease: Exponential.easeOut } );
			GTweener.to( mcIconLoader, 3, { alpha:1 },  { ease: Exponential.easeOut } );
		}
	}
}
