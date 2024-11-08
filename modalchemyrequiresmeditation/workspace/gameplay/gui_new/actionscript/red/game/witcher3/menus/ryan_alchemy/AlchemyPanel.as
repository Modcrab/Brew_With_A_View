//>---------------------------------------------------------------------------
// Quest List Menu
//----------------------------------------------------------------------------
//>---------------------------------------------------------------------------
// Copyright © 2014 CDProjektRed
// R. Pergent
//----------------------------------------------------------------------------
package  red.game.witcher3.menus.ryan_alchemy
{
	import flash.events.Event;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.controls.ScrollBar;
	import red.game.witcher3.controls.W3GamepadButton;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class AlchemyPanel extends CoreMenu 
	{
		//>---------------------------------------------------------------------------
		// VARIABLES
		//----------------------------------------------------------------------------
		public var 			recipeList 			: W3ScrollingList;
		public var 			scrollBar 			: ScrollBar;
		public var 			mcExitButton 		: W3GamepadButton;
		public var 			mcBrewButton 		: W3GamepadButton;
		
		public var 			recipeItem1 		: RecipeListItem;
		public var 			recipeItem2 		: RecipeListItem;
		public var 			recipeItem3 		: RecipeListItem;
		public var 			recipeItem4 		: RecipeListItem;
		public var 			recipeItem5 		: RecipeListItem;
		public var 			recipeItem6 		: RecipeListItem;
		public var 			recipeItem7 		: RecipeListItem;
		
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		public function AlchemyPanel() 
		{
			super();
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		override protected function get menuName():String
		{
			return "RyanAlchemyMenu";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			
			registerDataBinding( "RecipeList", handleRecipeListData );
			
			// DEBUG ==================
			/*var dataArray : Array = new Array();
			
			dataArray.push( { label:"Cat potion", canBeBrewed: true } );
			dataArray.push( { label:"Anti-poison", canBeBrewed: true } );
			dataArray.push( { label:"Strength potion", canBeBrewed: false } );
			dataArray.push( { label:"", canBeBrewed: false } );
			dataArray.push( { label:"Intelligence potion", canBeBrewed: false } );
			dataArray.push( { label:"Vigor potion", canBeBrewed: true } );
			dataArray.push( { label:"Speed potion", canBeBrewed: false } );
			dataArray.push( { label:"Rune potion", canBeBrewed: false } );
			
			handleRecipeListData( dataArray, -1 );*/
			// =======================
			
			stage.addEventListener( InputEvent.INPUT, handleInput );
			
			
			mcExitButton.addEventListener( ButtonEvent.CLICK, handleButtonExit, false, 0, true );
			mcExitButton.navigationCode = NavigationCode.GAMEPAD_B;
			
			mcBrewButton.addEventListener( ButtonEvent.CLICK, handleButtonBrew, false, 0, true );
			mcBrewButton.navigationCode = NavigationCode.GAMEPAD_A;
			
			ScrollingList( recipeList ).addEventListener( ListEvent.INDEX_CHANGE, handleSelection, false, 0, true );
			
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleButtonBrew( event : ButtonEvent = null ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBrew', [ ScrollingList( recipeList ).selectedIndex ] ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleButtonExit( event : ButtonEvent = null ):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleRecipeListData(  gameData:Object, index:int ):void
		{			
			//recipeList.updateData( gameData as Array );
			ScrollingList( recipeList ).dataProvider = new DataProvider ( gameData as Array );
			if (  ScrollingList( recipeList ).dataProvider.length > 0 )
			{
				ScrollingList( recipeList ).selectedIndex = 0;
				stage.focus = ScrollingList( recipeList );
			}	
			
			ScrollingList( recipeList ).invalidateData();
			ScrollingList( recipeList ).invalidateRenderers();
			ScrollingList( recipeList ).validateNow();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function handleSelection( event : ListEvent )
		{
			mcBrewButton.enabled = ScrollingList( recipeList ).dataProvider[event.index].canBeBrewed;
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails 	= event.details;
			var keyPress:Boolean 		= ( details.value == InputValue.KEY_DOWN );
			
			if ( keyPress )
			{
				if (details.navEquivalent == NavigationCode.GAMEPAD_A )
				{
					if( mcBrewButton.enabled ) handleButtonBrew();
				}				
				else if (details.navEquivalent == NavigationCode.GAMEPAD_B)
				{
					handleButtonExit();
				}
			}
		}
	}

}