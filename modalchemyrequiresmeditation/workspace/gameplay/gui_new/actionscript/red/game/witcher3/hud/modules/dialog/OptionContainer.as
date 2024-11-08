package red.game.witcher3.hud.modules.dialog
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Quadratic;
	import com.gskinner.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.events.Event;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.utils.motion.TweenEx;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import fl.transitions.easing.Strong;
	import scaleform.clik.interfaces.IListItemRenderer;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import red.game.witcher3.hud.modules.dialog.OptionList;

	public class OptionContainer extends UIComponent
	{
		public var mcOptionList:OptionList;
		public var mcOption1:Option;
		public var mcOption2:Option;
		public var mcOption3:Option;
		public var mcOption4:Option;
		public var mcOption5:Option;
		public var mcOption6:Option;
		public var mcOption7:Option;

		public var mcUpArrow : MovieClip;
		public var mcDownArrow : MovieClip;

		private static const DEFAULT_X:Number = -234;
		private static const ANIMATION_DURATION : Number = 2500;
		private static const MAXIMAL_Y : Number = 120;
		private static const DIALOG_STEP_Y : Number = 40;
		private static const DIALOG_STEP_Y_EXTRA : Number = 35;
		private static const MAXIMAL_DIALOG_CHOICES : Number = 7;

		protected var OPACITY_MAX : Number = 0.8;

		private var previousSelectedIndex : int = -1;
		
		private var closeAnimation:Boolean;

		public function OptionContainer()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			tabEnabled = tabChildren = false;
			mcOptionList.tabEnabled = mcOptionList.tabChildren = false;
			mcOptionList.bSkipFocusCheck = true;
			visible = true;
			alpha = 0;
			//mcOptionList.labelField = "name";
			mcOptionList.addEventListener( ListEvent.INDEX_CHANGE, onOptionChange, false, 0, true );
			mcOptionList.addEventListener( ListEvent.ITEM_CLICK,   onOptionClick );
			stage.addEventListener(W3ScrollingList.REPOSITION, SetOptionItemsY, false, 0, true);
			
			mcOptionList.selectOnOver = true;
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}
		
		private function handleControllerChanged(event:Event):void
		{
			mcOptionList.invalidateData();
			mcOptionList.validateNow();
		}
		
		public function DataReset():void
		{
			mcOptionList.selectedIndex = -1;
			if ( mcOptionList.dataProvider.length > 0 )
			{
				mcOptionList.dataProvider = new DataProvider();
			}
			mcOptionList.validateNow();
		}

		public function ChoicesSet( choices:Array ):void
		{
			closeAnimation = false;
			mcOptionList.selectedIndex = -1;
			mcOptionList.dataProvider = new DataProvider( choices );
			mcOptionList.validateNow();
			
			previousSelectedIndex = 0;
			
			mcOptionList.clearLastDir();
			var firstFreeIndex : int = FindFirstAvailableDialogIndex( 0 );
			if ( firstFreeIndex != -1 )
			{
				ChoiceSelectionSet( firstFreeIndex );
			}
			else
			{
				if ( mcOptionList.dataProvider.length > 0 )
				{
					ChoiceSelectionSet( 0 );
				}
			}
		}

		public function ChoiceSelectionSet( index:int ):void
		{
			if ( index >= 0 && index < mcOptionList.dataProvider.length )
			{
				mcOptionList.focused = 1;
				mcOptionList.selectedIndex = index;
				mcOptionList.validateNow();
			}
			else
			{
				mcOptionList.selectedIndex = -1;
				mcOptionList.validateNow();
			}
		}
		
		private function FindFirstAvailableDialogIndex( startFrom : int ) : int
		{
			var realIndex : int;
			var lastDir : int = mcOptionList.getLastDir();
			var dataLength : int = mcOptionList.dataProvider.length;

			for ( var i : int = 0; i < dataLength; ++i )
			{
				if ( lastDir >= 0 )
				{
					// check next
					realIndex = ( i + startFrom + dataLength ) % dataLength;
					//trace("Minimap #1 " + realIndex );
				}
				else
				{
					// check prev
					realIndex = ( ( dataLength - i - 1 ) + startFrom + dataLength ) % dataLength;
					//trace("Minimap #2 " + realIndex );
				}
				
				var data : Object = mcOptionList.dataProvider[ realIndex ];
				if ( data )
				{
					//trace("Minimap # " + dialog.isLocked );
					if ( !data.locked )
					{
						//trace("Minimap # returning " + realIndex );
						return realIndex;
					}
				}
			}
			return -1;
		}

		private function UpdateArrows( forceHide : Boolean = false ) : void
		{
			if ( forceHide )
			{
				mcUpArrow.alpha = 0;
				mcDownArrow.alpha = 0;
			}
			else
			{
				if ( mcOptionList.scrollPosition > 0 )
				{
					mcUpArrow.alpha = OPACITY_MAX;
				}
				else
				{
					mcUpArrow.alpha = 0;
				}

				mcDownArrow.alpha = 0;
				if ( mcOptionList.dataProvider && mcOptionList.dataProvider.length > MAXIMAL_DIALOG_CHOICES && mcOptionList.scrollPosition < mcOptionList.dataProvider.length - MAXIMAL_DIALOG_CHOICES )
				{
					mcDownArrow.alpha = OPACITY_MAX;
				}
			}
			
			trace("^^^^^^^ UP   ARROW ", mcUpArrow.alpha );
			trace("^^^^^^^ DOWN ARROW ", mcDownArrow.alpha );
		}

		private function SetOptionItemsY(event:Event = null) : void
		{
			var i :int;
			var curOption : Option;
			var NextPosY : Number = MAXIMAL_Y;
			
			trace("Minimap1 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ handle REPOSITION");

			if (closeAnimation) return;
			
			// keep it disabled for mouse while updating
			mcOptionList.mouseChildren = false;
			mcOptionList.mouseEnabled = false;
			
			if (mcOptionList == null )
			{
				return;
			}
			if (mcOptionList.dataProvider == null )
			{
				return;
			}

			var extraHeight : Number = 0;
			for ( i = Math.min(mcOptionList.dataProvider.length -1 ,MAXIMAL_DIALOG_CHOICES-1); i > -1; i-- )
			{
				curOption = mcOptionList.getRendererAt(i) as Option;
				curOption.visible = true; // #B kill
				curOption.alpha = 1;  // #B kill
				curOption.scaleX = curOption.scaleY = 1;
				curOption.x = DEFAULT_X;
				GTweener.removeTweens(curOption);
				
				//curOption.updateRendererSize();
				
				if ( curOption.mcSelectionBck != null )
				{
					curOption.mcSelectionBck.mcImg.height = 35;
				}
				if ( curOption.mcShadow != null )
				{
					curOption.mcShadow.height = 35;
				}
				if (curOption.tfLine.numLines > 1)
				{
					var curlineDelta : int = curOption.tfLine.numLines - 1;
					NextPosY -= DIALOG_STEP_Y_EXTRA * curlineDelta;
					if ( curOption.mcSelectionBck != null )
					{
						curOption.mcSelectionBck.mcImg.height += (24 * curlineDelta);
					}
					if ( curOption.mcShadow != null )
					{
						curOption.mcShadow.height += 24 * curlineDelta;
					}
				}
				if (curOption == null )
				{
					return;
				}
				curOption.y = NextPosY;
				NextPosY -= DIALOG_STEP_Y;
				
				if ( extraHeight == 0 )
				{
					extraHeight = curOption.height;
				}

			}

			if (mcUpArrow == null )
			{
				return;
			}
			if (mcDownArrow == null )
			{
				return;
			}

			if (curOption == null )
			{
				return;
			}
			
			mcUpArrow.y = NextPosY + mcUpArrow.height;
			mcDownArrow.y = MAXIMAL_Y + extraHeight - mcDownArrow.height;
			
			UpdateArrows();
			
			// enable mouse
			mcOptionList.mouseChildren = false;
			mcOptionList.mouseEnabled = false;
			
		}

		private function onOptionChange( event:ListEvent ) : void
		{
			var option : Option;
			var dataIndex : int;
			var rendererIndex : int;

			dataIndex = mcOptionList.selectedIndex;
			rendererIndex = mcOptionList.selectedIndex - mcOptionList.scrollPosition;

			trace("Minimap1 ************************************************************ ", dataIndex, rendererIndex );
			option = mcOptionList.getRendererAt( rendererIndex ) as Option;
			if ( !option )
			{
				// multiple events coming when changing event in W3ScrollingList, ignore when there's no related renderer
				return;
			}
			
			if ( dataIndex < 0 || dataIndex >= mcOptionList.dataProvider.length )
			{
				//something wrong? ignore
				return;
			}
			var data : Object = mcOptionList.dataProvider[ dataIndex ];
			if ( data )
			{
				if ( data.locked )
				{
					trace("Minimap1 ************************************************************ locked" );
					var firstFreeIndex : int = FindFirstAvailableDialogIndex( dataIndex );
					if ( firstFreeIndex != -1 )
					{
						trace("Minimap1 ************************************************************ new index ", firstFreeIndex );
						ChoiceSelectionSet( firstFreeIndex );
						UpdateArrows();
						return;
					}
				}
			}
			else
			{
				trace("Minimap1 ************************************************************ ERROR" );
			}
			
			UpdateArrows();
			
			if (closeAnimation)
			{
				return;
			}

			if ( dataIndex > -1 && previousSelectedIndex != dataIndex )
			{
				option = mcOptionList.getRendererAt( rendererIndex ) as Option;
				if (option)
				{
					setChildIndex(option, 0);
					//updateSelection(option, true);
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionSelected', [ dataIndex ] ) );
				}
			}
			previousSelectedIndex = dataIndex;
		}

		private function onOptionClick( event:ListEvent ) : void
		{
			trace("Minimap1 onClickOption ", mcOptionList.selectedIndex, mcOptionList.scrollPosition );
			var option : Option = mcOptionList.getRendererAt( mcOptionList.selectedIndex - mcOptionList.scrollPosition ) as Option;
			
			if (option && (event == null || event.itemRenderer == option) )
			{
				// #J: WS now decides what to do when its locked. This was needed for progressive install
				//if (!option.isLocked)
				//{
					//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionAccepted', [mcOptionList.selectedIndex + offset ] ) );
					activateOption( mcOptionList.selectedIndex );
				//}
			}
		}

		override public function set focused(value:Number):void
		{
			super.focused = 1;
			mcOptionList.focused = 1;
			var option : Option = mcOptionList.getRendererAt(mcOptionList.selectedIndex) as Option;
			if (option)
			{
				option.focused = 1;
			}
		}

		public function SetMaxOpacity( value : Number )
		{
			OPACITY_MAX = value;
		}

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}

		public function GetOptionsListLength() : int
		{
			return mcOptionList.dataProvider.length;
		}

		override public function handleInput( event:InputEvent ) : void
		{
			if( event.handled || closeAnimation )
			{
				return;
			}
			
			var details:InputDetails = event.details;
			
			if ( details.value == InputValue.KEY_UP )
			{
				switch( details.code )
				{
					
					case KeyCode.E:
					case KeyCode.NUMPAD_ENTER:
					case KeyCode.PAD_A_CROSS:
						if ( GetOptionsListLength() != 0 )
						{
							// send accept only if it's a single line and not multiple dialog options (skip equivalent)
							event.handled = true;
							onOptionClick(null);
						}
						return;
						break;
				}
				
				if (!event.handled && details.code >= KeyCode.NUMBER_1 && details.code <= KeyCode.NUMBER_9)
				{					
					var dataIndex:int = details.code - KeyCode.NUMBER_0 - 1;
					var rendererIndex:int = dataIndex - mcOptionList.scrollPosition;
					
					var targetRenderer:Option = mcOptionList.getRendererAt( rendererIndex ) as Option;
					if (targetRenderer && !targetRenderer.isLocked && targetRenderer.visible && targetRenderer.alpha != 0 && targetRenderer.tfLine.text != "")
					{
						mcOptionList.selectedIndex = dataIndex;
						mcOptionList.validateNow();
						
						//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionAccepted', [ targetIdx + offset ] ) );
						activateOption( dataIndex );
						
						event.stopImmediatePropagation();
						event.handled = true;
						return;
					}
				}
			}
			mcOptionList.handleInput(event);
		}
		
		private function activateOption( idx : int ):void
		{
			trace("Minimap1 activateOption ", idx );
			
			var renderersList:Vector.<IListItemRenderer> =  mcOptionList.getRenderers();
			var callbackAdded:Boolean = false;
			var tweenProps:Object;
			
			var targetRenderer:Option = mcOptionList.getRendererAt( idx - mcOptionList.scrollPosition ) as Option;
			
			if (targetRenderer && targetRenderer.isLocked)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionAccepted', [ int( idx ) ] ) );
				return;
			}
			
			UpdateArrows( true );
			
			if (mcOptionList.dataProvider.length > 1)
			{
				for ( var i = Math.min(mcOptionList.dataProvider.length -1 ,MAXIMAL_DIALOG_CHOICES-1); i > -1; i-- )
				{
					var curRenderer:Option = mcOptionList.getRendererAt(i) as Option;
					tweenProps = {  };
					tweenProps.data = { idx : idx };
					
					if (curRenderer && curRenderer.index != idx) 
					{
						if (!callbackAdded)
						{
							tweenProps.onComplete = fadeSelectedOption;
							callbackAdded = true;
						}
						tweenProps.ease = Exponential.easeOut;
						GTweener.to(curRenderer, .4, { alpha : 0 }, tweenProps );
					}
				}
			}
			
			if (callbackAdded)
			{
				closeAnimation = true;
			}
			else
			{
				// only one dialog option
				
				var selectedRenderer:Option = mcOptionList.getSelectedRenderer() as Option;
				
				if (selectedRenderer)
				{
					tweenProps = {  };
					tweenProps.data = { idx : idx };
					tweenProps.ease = Quadratic.easeIn;
					tweenProps.onComplete = callActivateOption;
					
					GTweener.removeTweens(selectedRenderer);
					GTweener.to(selectedRenderer, .3, { alpha:0 }, tweenProps );
					
					closeAnimation = true;
				}
				else
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionAccepted', [ int( idx ) ] ) );
				}
			}
		}
		
		private function fadeSelectedOption(targetTween:GTween):void
		{			
			var curRenderer:Option = mcOptionList.getSelectedRenderer() as Option;
			
			if (curRenderer)
			{			
				var tweenProps:Object = {  };
				
				tweenProps.data = targetTween.data;
				tweenProps.ease = Quadratic.easeIn;
				tweenProps.onComplete = callActivateOption;
				
				GTweener.to(curRenderer, .3, { alpha:0 }, tweenProps );
			}
			else
			{
				closeAnimation = false;
			}
		}
		
		private function callActivateOption(targetTween:GTween):void
		{
			closeAnimation = false;
			
			if (targetTween.data && !isNaN(targetTween.data.idx))
			{
				if ( mcOptionList.dataProvider.length > 0 )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogOptionAccepted', [ int( targetTween.data.idx ) ] ) );
				}
			}
		}
		
		
		
		
	}
}
