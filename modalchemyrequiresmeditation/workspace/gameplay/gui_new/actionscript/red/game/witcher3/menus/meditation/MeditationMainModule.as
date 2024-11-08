/***********************************************************************
/** Meditation Main module : Base Version
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation
{
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	
	import scaleform.clik.data.DataProvider;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class MeditationMainModule extends UIComponent
	{
		public var mcMeditationList : W3MeditationScrollingList;
		public var mcMeditationListItem1 : MeditationListItem;
		public var mcMeditationListItem2 : MeditationListItem;
		public var mcMeditationListItem3 : MeditationListItem;
		public var mcMeditationListItem4 : MeditationListItem;
		
		protected var _inputHandlers:Vector.<UIComponent>;
		
		public function MeditationMainModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "meditation.main.subpanels", [handleDataSet]));
			mouseEnabled = false;
			_inputHandlers.push( mcMeditationList );
		}
		
		
		private function handleDataSet( gameData:Object, index:int ):void
		{
			if (gameData)
			{
				var dataArray:Array = gameData as Array
				
				if ( index > 0 )
				{
					mcMeditationList.dataProvider = new DataProvider( dataArray );
					
				}
				else
				{
					mcMeditationList.dataProvider = new DataProvider( dataArray );
				}
			}
			mcMeditationList.validateNow();
			mcMeditationList.ShowRenderers(true);
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			for each ( var handler:UIComponent in _inputHandlers )
			{
				handler.handleInput( event );
				if ( event.handled )
				{
					return;
				}
			}
			return;
		}
	}
}
