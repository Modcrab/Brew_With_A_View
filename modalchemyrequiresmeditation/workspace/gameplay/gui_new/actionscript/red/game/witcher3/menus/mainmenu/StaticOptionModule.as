/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.core.CoreMenuModule;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class StaticOptionModule extends CoreMenuModule
	{
		override protected function configUI():void
		{
			super.configUI();
			
			enabled = false;
			visible = false;
			alpha = 0;
		}
		
		public function show():void
		{
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
		}
		
		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
			}
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			visible = false;
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( keyUp && !event.handled )
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_B:
						{
							handleNavigateBack();
						}
						break;
					}
				}
			}
		}
		
		public function onRightClick(event:MouseEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}
		
		protected function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
		}
	}
}