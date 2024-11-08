/***********************************************************************
/** Wrapper for showing renderToTexture
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	
	public class W3RenderToTextureHolder extends UIComponent
	{
		// #J For this to work, you need to go into the configUI in the CoreMenu derived class using this and add:
		// registerRenderTarget( "test_nopack", 1024, 1024 );
		
		public var mcLoadingAnim:MovieClip;
		public var mcTextureHolder:MovieClip;
		
		override protected function configUI():void
		{
			super.configUI();
			
			setRenderToTextureLoading(false);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "render.to.texture.loading", [setRenderToTextureLoading] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "render.to.texture.texture.visible", [setRenderToTextureTextureVisible] ) );
		}
		
		protected function setRenderToTextureLoading(value:Boolean):void
		{
			if (mcLoadingAnim)
			{
				if (value)
				{
					mcLoadingAnim.visible = true;
					mcLoadingAnim.gotoAndPlay("startAnim");
				}
				else
				{
					mcLoadingAnim.stop();
					mcLoadingAnim.visible = false;
				}
			}
		}
		
		protected function setRenderToTextureTextureVisible(value:Boolean):void
		{
			if (mcTextureHolder)
			{
				mcTextureHolder.visible = value;
			}
		}
	}
}