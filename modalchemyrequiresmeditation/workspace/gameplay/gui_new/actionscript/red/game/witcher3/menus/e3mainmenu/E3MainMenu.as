package red.game.witcher3.menus.e3mainmenu
{
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants .NavigationCode;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.core.CoreMenu;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	
	public class E3MainMenu extends CoreMenu
	{
		protected var closeTimer : Timer;
		public var mcText1 : TextField;
		public var mcText2 : TextField;
		public var mcTextShadow1 : MovieClip;
		public var mcTextShadow2 : MovieClip;
		public var mcVideo : W3StartScreenVideoObject;
		
		protected var _fadeTime : Number = 0;
		protected var _movieName : String = "mainmenu.usm";
		protected var _selectedDemo : int = 0;
		
		public function E3MainMenu()
		{
			super();
		}
					
		override protected function get menuName():String
		{
			return "E3MainMenu";
		}
		
		protected override function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );

			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			mcVideo.OpenVideo(_movieName);
			
			UpdateLabels( _selectedDemo );
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
		
			switch ( details.code )
			{
				case KeyCode.PAD_A_CROSS:
					if ( keyPress )
					{
						stage.removeEventListener(InputEvent.INPUT, handleInput, false);

						dispatchEvent( new GameEvent( GameEvent.CALL, "OnFadeOut" ) );

						closeTimer = new Timer( _fadeTime, 1 );
						closeTimer.addEventListener(TimerEvent.TIMER, TimerFinishedCounting );
						closeTimer.start();
					
						mcVideo.SetSoundVolume(0);
					}
					break;

				case KeyCode.PAD_LEFT_STICK_AXIS:
				case KeyCode.PAD_RIGHT_STICK_AXIS:
					{
						var axisData			: InputAxisData;
							
						axisData = InputAxisData(details.value);
					
						var angle:Number = InputUtils.getAngleRadians( axisData.xvalue, axisData.yvalue );
						if ( angle != 0 )
						{
							var moveUp:Boolean = angle > 0 && angle < Math.PI;
							if ( moveUp )
							{
								UpdateLabels( 0 );
							}
							else
							{
								UpdateLabels( 1 );
							}
						}
					}
					break;
			}
		}
		
		function UpdateLabels( index : int )
		{
			_selectedDemo = index;
			if ( _selectedDemo == 0 )
			{
				mcText1.alpha = 1.0;
				mcTextShadow1.visible = true;
				mcTextShadow1.gotoAndPlay(1);
				mcText2.alpha = 0.5;
				mcTextShadow2.visible = false;
			}
			else
			{
				mcText2.alpha = 1.0;
				mcTextShadow2.visible = true;
				mcTextShadow2.gotoAndPlay(1);
				mcText1.alpha = 0.5;
				mcTextShadow1.visible = false;
			}
		}

		function TimerFinishedCounting( event : TimerEvent ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnStartGame", [ _selectedDemo ] ) );
		}
		
		public function SetFadeDuration( fadeTime: Number ):void
		{
			trace("Minimap SetFadeDuration");
			
			_fadeTime = fadeTime;
		}

	}
}








/*

package red.game.witcher3.menus.mainmenu
{
	import flash.events.Event;
	import flash.display.MovieClip;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import flash.events.FocusEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import flash.events.MouseEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	
	public class MainMenu extends CoreMenu
	{
		public var mcMainMenu			: MovieClip;
		public var mcMainMenuLoad		: MovieClip;
		public var mcMainMenuSettings	: MovieClip;
		
		private var m_currentScreen : int = SCREEN_MAINMENU;
		private var m_currentSavegameIndex : int = 0;
		private var m_savegameList : Array;
		
		private static const SCREEN_MAINMENU				: int = 0;
		private static const SCREEN_MAINMENU_LOAD		: int = 1;
		private static const SCREEN_MAINMENU_SETTINGS	: int = 2;

		public function MainMenu()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function get menuName():String
		{
			return "MainMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			focused = 1;

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "mainmenu.savegames", [handleSavegameList] ) );
	
			UpdateScreen( SCREEN_MAINMENU );
		}
		
		private function onFastMenuItemClicked( event : ListEvent ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemChosen', [ event.index] ) );
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}
			
			switch ( m_currentScreen )
			{
				case SCREEN_MAINMENU:
					return handleInputMainMenu( event );
				case SCREEN_MAINMENU_LOAD:
					return handleInputMainMenuLoad( event );
				case SCREEN_MAINMENU_SETTINGS:
					return handleInputMainMenuSettings( event );
			}
		}
		
		protected function handleSavegameList( gameData : Object, index : int ) : void
		{
			var gameArray : Array = gameData as Array;
			
			m_savegameList = new Array(); 

			if ( index > 0 )
			{
				// nvm
			}
			else if ( gameArray )
			{
				for ( var i : int = 0; i < gameArray.length; i++ )
				{
					trace( "Minimap handleSavegameSelected " + i + " " + gameArray[ i ].filename );
					m_savegameList.push( gameArray[ i ].filename );
				}
			}
		}

		public function handleInputMainMenu( event:InputEvent ) : void
		{
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						trace("Minimap OnNewGame" );
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNewGame' ) );
						return;
					case NavigationCode.GAMEPAD_X:
						UpdateScreen( SCREEN_MAINMENU_LOAD );
						return;
					case NavigationCode.GAMEPAD_Y:
						UpdateScreen( SCREEN_MAINMENU_SETTINGS );
						return;
					case NavigationCode.GAMEPAD_B:
						trace("Minimap OnExit" );
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnExit' ) );
						return;
				}
			}
		}
		public function handleInputMainMenuLoad( event:InputEvent ) : void
		{
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						trace("Minimap OnLoadGame" );
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnLoadGame', [ m_currentSavegameIndex ] ) );
						return;
					case NavigationCode.GAMEPAD_B:
						UpdateScreen( SCREEN_MAINMENU );
						return;
					case NavigationCode.DOWN:
						if ( m_savegameList.length > 0 )
						{
							m_currentSavegameIndex = ( m_currentSavegameIndex + 1 ) % m_savegameList.length;
							UpdateSavegameLabel();
						}
						return;
					case NavigationCode.UP:
						if ( m_savegameList.length > 0 )
						{
							m_currentSavegameIndex = ( m_currentSavegameIndex - 1 + m_savegameList.length ) % m_savegameList.length;
							UpdateSavegameLabel();
						}
						return;
				}
			}
		}

		public function handleInputMainMenuSettings( event:InputEvent ) : void
		{
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						return;
					case NavigationCode.GAMEPAD_B:
						UpdateScreen( SCREEN_MAINMENU );
						return;
				}
			}
		}

		private function UpdateScreen( screen : int )
		{
			m_currentScreen = screen;

			mcMainMenu.visible			= ( m_currentScreen == SCREEN_MAINMENU );
			mcMainMenuLoad.visible		= ( m_currentScreen == SCREEN_MAINMENU_LOAD );
			mcMainMenuSettings.visible	= ( m_currentScreen == SCREEN_MAINMENU_SETTINGS );
			
			if ( m_currentScreen == SCREEN_MAINMENU_LOAD )
			{
				UpdateSavegameLabel();
			}
		}
		
		private function UpdateSavegameLabel()
		{
			trace("Minimap UpdateSavegameLabel " + m_savegameList.length );
			if ( m_savegameList.length == 0 )
			{
				mcMainMenuLoad.mcLabel.text = "No savegames";
			}
			else
			{
				trace("Minimap UpdateSavegameLabel " + m_savegameList.length + "[" + m_savegameList[ m_currentSavegameIndex ] + "]");
				mcMainMenuLoad.mcLabel.text = ( m_currentSavegameIndex + 1 ) + "/" + m_savegameList.length + "\n" + m_savegameList[ m_currentSavegameIndex ];
			}
		}
		
	}
}
*/
