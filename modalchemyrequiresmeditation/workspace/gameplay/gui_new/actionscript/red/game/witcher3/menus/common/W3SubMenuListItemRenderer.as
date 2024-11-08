/***********************************************************************
/** Sub menu list item renderer
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.geom.Transform;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3OptionStepper;
	import red.game.witcher3.controls.W3OptionsSeparator;
	import red.game.witcher3.menus.mainmenu.IngameMenu;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import flash.events.MouseEvent;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3Slider;
	import scaleform.clik.events.SliderEvent;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputManager;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import scaleform.clik.events.InputEvent;
	import red.game.witcher3.menus.common.DownloadButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.controls.W3Background;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.constants.InvalidationType;
	import flash.text.TextFieldAutoSize;
	import red.core.CoreComponent;
	
	public class W3SubMenuListItemRenderer extends BaseListItem
	{
		public var tfCurrentValue : TextField;
		public var tfMinValue : TextField;
		public var tfMaxValue : TextField;
		public var downloadBtn : DownloadButton;
		public var hintBtn : InputFeedbackButton;
		public var mcHitArea : MovieClip;
		public var mcSlider : W3Slider;
		public var mcStepper : W3OptionStepper;
		public var mcSeparator : W3OptionsSeparator;
		public var mcBackground : MovieClip;
		public var mcDropDownBG : MovieClip;
		public var mcDeveloperHighlightBG : MovieClip;
		private var _currentValue : String = "";
		private var _currentTextColor:Number;
		private var _id : String = "";
		private var _type : int;
		public var mcSelectionHighlightPro:MovieClip;
		private var _startingXForCurrent:Number;
		
		private static const gamepadButtonDownload:String = NavigationCode.GAMEPAD_X;
		private static const keyboardButtonDownload:uint = KeyCode.ENTER;

		protected static const TOGGLE_ON_STRING:String = "[[panel_mainmenu_option_value_on]]";
		protected static const TOGGLE_OFF_STRING:String = "[[panel_mainmenu_option_value_off]]";

		private static const ACTION_DOWNLOAD : uint = 66;
		
		protected var _supressEvents:Boolean = false;
		protected var _ingameMenu : IngameMenu;
		
		protected var _tfCurrentValueStartUpX : int;
		protected var _startUpX : int;
		protected var _selectionStartUpX : int;
		protected var _selectionStartUpWidth : int;
		protected var _textFieldStartUpX : int;
		protected var _mcDropDownBGStartUpX : int;

		public function W3SubMenuListItemRenderer()
		{
			preventAutosizing = true;
			//constraintsDisabled = true;
			mouseEnabled = true;
			mouseChildren = true;
			
			super();
			
			hitArea = mcHitArea;
			
			if (mcSlider)
				mcSlider.enableSounds = true;
			
			tfMinValue.visible = false;
			tfMaxValue.visible = false;
		}

		protected override function configUI():void
		{
			super.configUI();
			
			if (tfCurrentValue)
			{
				_startingXForCurrent = tfCurrentValue.x;
			}
			
			if (mcSelectionHighlightPro)
			{
				mcSelectionHighlightPro.mouseEnabled = false;
			}
			
			_ingameMenu = parent.parent as IngameMenu;
			_startUpX = this.x;
			_selectionStartUpX = mcSelectionHighlightPro.x;
			_selectionStartUpWidth = mcSelectionHighlightPro.width;
			_tfCurrentValueStartUpX = tfCurrentValue.x;
			_textFieldStartUpX = textField.x;
			_mcDropDownBGStartUpX = mcDropDownBG.x;
		}

		override public function setData( data:Object ):void
		{
			_supressEvents = true;
			super.setData( data );

			if ( !data )
				return;

			label = data.label;
			
			_currentValue = data.current as String;
			if ( !_currentValue )
			{
				_currentValue = data.current.toString();
			}
			
			createSubElementByType( data.type );	
			initializeStreamableUi( data );
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "option.updateSliderValue", [onSelectedOptionIdChanged] ) );

			if ( data.isDropdownContent )
			{
				mcDropDownBG.visible = true;
				mcBackground.visible = false;
				this.x = _startUpX + 50;
				mcSelectionHighlightPro.width = 900;
				mcSelectionHighlightPro.x = 205;
				tfCurrentValue.x = _tfCurrentValueStartUpX - 200;
			}
			else
			{
				mcDropDownBG.visible = false;
				mcBackground.visible = 
					_type != IngameMenu.IGMActionType_Separator &&
					_type != IngameMenu.IGMActionType_SubtleSeparator;
				this.x = _startUpX;
				tfCurrentValue.x = _tfCurrentValueStartUpX;
				mcSelectionHighlightPro.width = _selectionStartUpWidth;
				mcSelectionHighlightPro.x = _selectionStartUpX;
			}
			
			// Disable state
			if (data.disabled)
			{
				this.alpha = 0.35; // Gray out
				this.selectable = false;
			}
			else
			{
				this.alpha = 1.0;
				this.selectable = (_type != IngameMenu.IGMActionType_SubtleSeparator);
			}

			// Indent for sub-group
			if (data.indent)
			{
				textField.x = _textFieldStartUpX + 32;
				mcBackground.x = mcDropDownBG.x = _mcDropDownBGStartUpX + 32;
			}
			else
			{
				textField.x = _textFieldStartUpX - ( CoreComponent.isArabicAligmentMode ? 20 : 0 );
				mcBackground.x = mcDropDownBG.x = _mcDropDownBGStartUpX;
			}
			
			mcDeveloperHighlightBG.visible = data.isDeveloper;
			
			this.invalidate();
			this.validateNow();
			
			OnSliderValueChanged(null);
			
			//slection might change before right tag is set
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionSelectionChanged', [ data.tag, selected ] ) );
			
			_supressEvents = false;
		}
		
		public function setSelectionVisible(value:Boolean):void
		{			
			if (mcSlider)
				mcSlider.focused = 0;
		}
		
		private function initializeStreamableUi( data:Object )
		{
			if ( !data.streamable )
				return;
				
/*			var classRef:Class = getDefinitionByName("DownloadButtonRef") as Class;
			if ( downloadBtn == null && classRef != null )
			{
				downloadBtn = new classRef() as DownloadButton;
				downloadBtn.x = 1030;
				downloadBtn.y = 10;
				downloadBtn.removeEventListener(ButtonEvent.PRESS, onDownloadBtnPressed);
				downloadBtn.addEventListener(ButtonEvent.PRESS, onDownloadBtnPressed);
				downloadBtn.gamepadButton = NavigationCode.GAMEPAD_X;
				downloadBtn.keyboardButton = KeyCode.ENTER;
				this.addChild(downloadBtn);
			}
			
			classRef = getDefinitionByName("InputFeedbackButtonRef") as Class;
			if ( hintBtn == null && classRef != null )
			{
				hintBtn = new classRef() as InputFeedbackButton;
				hintBtn.x = 1035;
				hintBtn.y = -20;
				hintBtn.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.ENTER);
				hintBtn.label = "Download";
				hintBtn.clickable = false;
				this.addChild(hintBtn);
			}*/
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "streamable.status", [onStreamableStatusUpdated] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "option.changedId", [onSelectedOptionIdChanged] ) );
		}
		
		private function onDownloadBtnPressed( event:ButtonEvent ):void 
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnDownloadContentRequested", [ data.groupID, data.tag, data.current ] ) );
		}
		
		private function onStreamableStatusUpdated( status : Object ):void 
		{	
			if ( data.tag != status.optionTag )
				return;			
				
			for (var i:uint = 0; i < this.data.streamableStatus.length; i++)
			{	
				if ( this.data.streamableStatus[i].optionValueString != status.optionValueString )
					continue;
					
				this.data.streamableStatus[i].optionStatus = status.optionStatus;
				
				if ( mcSlider.value == i )
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionValueChanged', [ data.groupID, data.tag, data.current ] ) );
			}
			
			updateCurrentValue();
		}
		
		private function onSelectedOptionIdChanged( option : Object):void 
		{
			if ( data.tag != option.optionTag || !mcSlider)
				return;	
				
			mcSlider.value = option.optionSelectedId;
		}
		
		function createSubElementByType( type : uint )
		{
			if ( mcSlider != null )
			{
				mcSlider.removeEventListener( SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false );
				mcSlider.removeEventListener( MouseEvent.MOUSE_OUT, onSliderMouseOut, false );
				removeEventListener( ButtonEvent.PRESS, OnCallConfirm, false );
				removeChild( mcSlider );
				mcSlider.gEvent = null;
				mcSlider = null;
			}
			
			if ( mcStepper )
				mcStepper.visible = false;
				
			if ( mcSeparator )
				mcSeparator.visible = false;
				
			// set defaults
			textField.visible = true;
			tfCurrentValue.visible = true;
			this.selectable = true;
			mcBackground.visible = true;
			
			_type = type;
			
			mouseChildren = false; // actual value does not matter as its forces to a particular one

			switch( type )
			{
				case IngameMenu.IGMActionType_Slider :
					CreateSlider();
					break;
				case IngameMenu.IGMActionType_Toggle :
					CreateToggleSlider(1);
					break;
				case IngameMenu.IGMActionType_List :
					CreateToggleSlider(data.subElements.length - 1);
					break;
				case IngameMenu.IGMActionType_ListWithCondition :
					CreateToggleSlider(data.subElements.length - 1);
					break;
				case IngameMenu.IGMActionType_Stepper :
					tfCurrentValue.visible = false;
					initializeOptionStepper( false );
					break;
				case IngameMenu.IGMActionType_ToggleStepper :
					tfCurrentValue.visible = false;
					initializeOptionStepper( true );
					break;
				case IngameMenu.IGMActionType_Separator :
					textField.visible = false;
					tfCurrentValue.visible = false;
					this.selectable = false;	
					mcBackground.visible = false;
					initialzeSeparator();
					break;
				case IngameMenu.IGMActionType_SubtleSeparator :
					textField.visible = false;
					tfCurrentValue.visible = false;
					this.selectable = false;	
					mcBackground.visible = false;
					initialzeSubtleSeparator();
					break;
			}
		}
		
		function initializeOptionStepper( toggle : Boolean )
		{
			if ( mcStepper == null )
			{
				var classRef : Class = getDefinitionByName( "SubMenuOptionStepper" ) as Class;
				mcStepper = new classRef() as W3OptionStepper;
				addChildAt( mcStepper, getChildIndex(textField) );
				
			}
			
			mcStepper.removeEventListener( IndexEvent.INDEX_CHANGE, onStepperValueChanged );
			
			mcStepper.x = data.isDropdownContent ? 350 : 650;
			mcStepper.y = 35;
			mcStepper.hideIndicator = data.hideIndicator;
			
			if ( toggle )
			{
				mcStepper.dataProvider = new DataProvider([ "Off" , "On" ]);
				mcStepper.selectedIndex = data.current == "true" ? 1 : 0;
			}
			else
			{
				mcStepper.dataProvider = new DataProvider(data.subElements);
				mcStepper.selectedIndex = parseInt( data.current );
			}
			
			mcStepper.visible = true;
			mcStepper.invalidate();
			mcStepper.validateNow();
			mcStepper.addEventListener( IndexEvent.INDEX_CHANGE, onStepperValueChanged )
		}
		
		function initialzeSeparator()
		{
			if ( mcSeparator == null )
			{
				var classRef : Class = getDefinitionByName( "OptionsSeparator" ) as Class;
				mcSeparator = new classRef() as W3OptionsSeparator;
				addChildAt( mcSeparator, getChildIndex(textField) );
			}
			
			mcSeparator.label.text = data.label;
			mcSeparator.x = -150;
			mcSeparator.y = 34;
			mcSeparator.width = this.width;
			mcSeparator.height = this.height;
			
			mcSeparator.visible = true;
			mcSeparator.alpha = 1.0;
			
			this.invalidate();
			this.validateNow();
		}

		function initialzeSubtleSeparator()
		{
			if ( mcSeparator == null )
			{
				var classRef : Class = getDefinitionByName( "OptionsSeparator" ) as Class;
				mcSeparator = new classRef() as W3OptionsSeparator;
				addChildAt( mcSeparator, getChildIndex(textField) );
			}
			
			mcSeparator.label.text = "";
			mcSeparator.x = -150 + 300;
			mcSeparator.y = 34;
			mcSeparator.width = this.width - 600;
			mcSeparator.height = this.height;
			
			mcSeparator.visible = true;
			mcSeparator.alpha = 0.05;
			
			this.invalidate();
			this.validateNow();
		}

		function CreateSlider() : void
		{
			if ( mcSlider == null )
			{
				var classRef : Class = getDefinitionByName("SubMenuSlider") as Class;
				mcSlider = new classRef() as W3Slider;
			}
			
			// remove all listeners while reconfiguring
			mcSlider.removeEventListener( SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false);
			mcSlider.removeEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut, false);
			removeEventListener( ButtonEvent.PRESS, OnCallConfirm, false);
						
			mcSlider.x = data.isDropdownContent ? 520 : 720;
			mcSlider.y = 35;
			mcSlider.setActualSize(data.isDropdownContent ? 200 : 296, mcSlider.height);
			
			mcSlider.snapInterval = data.subElements.length >= 3 ?
				Number((data.subElements[1] - data.subElements[0]) / data.subElements[2]) :
				1;
			
			mcSlider.snapping = true;
			mcSlider.offsetLeft = 30;
			mcSlider.offsetRight = 35;
			
			mcSlider.maximum = data.subElements.length >= 2 ? 
				Number(data.subElements[1]) :
				1;
			
			mcSlider.minimum = data.subElements.length >= 1 ?
				Number(data.subElements[0]) :
				0;
				
			mcSlider.previousValue = -1;
			mcSlider.lockedValue = mcSlider.maximum + 1;
			mcSlider.value = Number(data.current);
			
			mcSlider.addEventListener(SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false, 0, false);
			mcSlider.addEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut, false, 0, true);
			addEventListener(ButtonEvent.PRESS, OnCallConfirm, false, 0, false);
			addChildAt(mcSlider, getChildIndex(textField));
			
			mcSlider.invalidate();
			mcSlider.validateNow();
		}

		function OnSliderValueChanged( event : SliderEvent ) : void
		{
			var sliderValue : Number;

			if ( mcSlider )
			{
				// mcSlider does not exist for BUTTON
				sliderValue = mcSlider.value;
			}

			if ( data.type == IngameMenu.IGMActionType_Slider )
			{
				data.current = sliderValue.toString();
				var tempValue:Number = int(Math.ceil( 100 * mcSlider.value )) / 100;
				_currentValue = tempValue.toString();
				
				if (tempValue != (int)(tempValue))
				{
					if (_currentValue.length < 4)
					{
						_currentValue += "0";
					}
					else if (_currentValue.length > 4)
					{
						_currentValue.slice(0, 4);
					}
				}
				else if (_currentValue.length > 4)
				{
					_currentValue = _currentValue.slice(0, 4);
				}
			}
			else if ( data.type == IngameMenu.IGMActionType_Toggle )
			{
				if (sliderValue == 0)
				{
					data.current = "false";
					_currentValue = (data.hasOwnProperty("offString")) ? data.offString : TOGGLE_OFF_STRING;
					_currentTextColor = 0x808080;
				}
				else
				{
					data.current = "true";
					_currentValue = (data.hasOwnProperty("onString")) ? data.onString : TOGGLE_ON_STRING;
					_currentTextColor = 0xFFFFFF;
				}
			}
			else if ( data.type == IngameMenu.IGMActionType_List || data.type == IngameMenu.IGMActionType_ListWithCondition )
			{
				data.current = sliderValue.toString();
				_currentValue = data.subElements[sliderValue];
			}
			

			updateCurrentValue();
			if ( _ingameMenu && _ingameMenu.mcOptionListModule && data.descriptionTrue && data.descriptionFalse )
				_ingameMenu.mcOptionListModule.updateDescriptionText(data);
			
			if ( !_supressEvents ) //#J To avoid sending this when its just the initial value being set
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionValueChanged', [ data.groupID, data.tag, data.current ] ) );
		}
		
		private function onStepperValueChanged( event : IndexEvent ):void 
		{
			if ( _type == IngameMenu.IGMActionType_ToggleStepper )
			{
				data.current = event.index == 0 ? "false" : "true";
			}
			else
			{
				data.current = event.index.toString();
			}
			
			if ( _ingameMenu && _ingameMenu.mcOptionListModule && data.descriptionTrue && data.descriptionFalse )
				_ingameMenu.mcOptionListModule.updateDescriptionText(data);
					
			if( !_supressEvents )
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionValueChanged', [ data.groupID, data.tag, data.current ] ) );
		}

		function CreateToggleSlider( value : int ) : void
		{
			if ( mcSlider == null )
			{
				var classRef : Class = _type == IngameMenu.IGMActionType_Toggle ? 
					getDefinitionByName("SubMenuSliderToggle") as Class :
					getDefinitionByName("SubMenuSlider") as Class;		
					
				mcSlider = new classRef() as W3Slider;			
			}
			
			mcSlider.removeEventListener( SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false);
			mcSlider.removeEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut, false);
			removeEventListener( ButtonEvent.PRESS, OnCallConfirm, false);
			
			if (_type == IngameMenu.IGMActionType_Toggle)
			{
				mcSlider.x = data.isDropdownContent? 520 : 720;
				mcSlider.y = 35;
				mcSlider.setActualSize( data.isDropdownContent ? 100 : 140, mcSlider.actualHeight );
				mcSlider.offsetLeft = 35;
				mcSlider.offsetRight = 45;
			}
			else
			{
				mcSlider.x = data.isDropdownContent ? 520 : 720;
				mcSlider.y = 35;
				mcSlider.setActualSize( data.isDropdownContent ? 200 : 296, mcSlider.actualHeight );
				mcSlider.offsetLeft = 32;
				mcSlider.offsetRight = 35;
			}
				
			mcSlider.snapInterval = 1;
			mcSlider.maximum = value;
			mcSlider.minimum = 0;
			mcSlider.snapping = true;
				
			if (data.current == "true")
			{
				mcSlider.value = 1;
			}
			else if (data.current == "false")
			{
				mcSlider.value = 0;
			}
			else
			{
				mcSlider.value = Number(data.current);
			}
			
			updateCurrentValue();
				
			if (_type == IngameMenu.IGMActionType_ListWithCondition)
			{
				mcSlider.skipValue = Number(data.skip);
				mcSlider.lockedValue = Number(data.lock);
				mcSlider.gEvent = new GameEvent( GameEvent.CALL, 'OnCancelOptionValueChange', [ data.groupID, data.tag ] ) ;
			}
			
			mcSlider.addEventListener(SliderEvent.VALUE_CHANGE, OnSliderValueChanged, false, 0, false);
			mcSlider.addEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut, false, 0, true);
			addEventListener(ButtonEvent.PRESS, OnCallConfirm, false, 0, false);
			addChildAt(mcSlider, getChildIndex(textField));
			
			mcSlider.invalidate();
			mcSlider.validateNow();
		}
		
		public function activate() : void
		{
			if ((data && data.disabled) || _type == IngameMenu.IGMActionType_SubtleSeparator) return;

			if (_type == IngameMenu.IGMActionType_Toggle)
			{
				mcSlider.value = mcSlider.value == 0 ? 1 : 0;
			}
			else if (_type == IngameMenu.IGMActionType_Button)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnButtonClicked', [ data.tag ] ) );
			}
		}

		function OnCallConfirm( event : ButtonEvent ) : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfirm' ) );
		}
		
		protected function onSliderMouseOut(e:MouseEvent):void
		{
			mcSlider.focused = 0;
		}

		override protected function updateText():void
		{
			super.updateText();
			updateCurrentValue();
			
			if (mcSelectionHighlightPro)
			{
				mcSelectionHighlightPro.mouseEnabled = false;
			}
		}
		protected function updateCurrentValue():void
		{
			if ( this.data && !this.data.streamable && _ingameMenu )
				_ingameMenu.mcInputFeedbackModule.removeButton(ACTION_DOWNLOAD, true);
			
			if (_type == IngameMenu.IGMActionType_Toggle)
			{
				tfCurrentValue.htmlText = _currentValue;
				tfCurrentValue.textColor = _currentTextColor;
			}
			else
			{
				if ( this.data && this.data.streamable)
				{
					var isInstalled = (Boolean) (this.data.streamableStatus[mcSlider.value].optionStatus);
					tfCurrentValue.htmlText = isInstalled ? "" : "[[options_language_not_installed]]";
					tfCurrentValue.htmlText = isInstalled ? _currentValue : _currentValue + " (" + tfCurrentValue.htmlText + ")";
					
					if ( downloadBtn )
						downloadBtn.visible = !isInstalled;
						
					if ( hintBtn )
						hintBtn.visible = !isInstalled;
						
					if ( _ingameMenu )
					{
						if( !isInstalled && !_ingameMenu.mcInputFeedbackModule.showBackground )
							_ingameMenu.mcInputFeedbackModule.appendButton(ACTION_DOWNLOAD, gamepadButtonDownload, keyboardButtonDownload, "[[options_language_request_download]]", true);
						else 
							_ingameMenu.mcInputFeedbackModule.removeButton(ACTION_DOWNLOAD, true);	
					}						
				}
				else
				{
					tfCurrentValue.htmlText =  _currentValue;;
				}
			}
			
		}

		override protected function updateAfterStateChange():void
		{

		}
		
		override protected function handleClick(controllerIndex:uint = 0):void 
		{
			if ((data && data.disabled) || _type == IngameMenu.IGMActionType_SubtleSeparator) return;

			activate();
		}
		
		override public function set mouseChildren (enable:Boolean) : void
		{
			if (_type == IngameMenu.IGMActionType_Toggle ||
				_type == IngameMenu.IGMActionType_SubtleSeparator ||
				(data && data.disabled))
			{
				super.mouseChildren = false;
			}
			else
			{
				// Don't allow them to set this to false ([dsl] Who them?)
				super.mouseChildren = true;
			}
		}

		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var isDownloadAction:Boolean = details.navEquivalent == gamepadButtonDownload || details.code == keyboardButtonDownload;
			
			if ( details.value == InputValue.KEY_DOWN && isDownloadAction )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnDownloadContentRequested", [ data.groupID, data.tag, data.current ] ) );
				event.handled = true;
			}
								
			if ( mcSlider && mcSlider.visible )
				mcSlider.handleInput( event );
				
			if ( mcStepper && mcStepper.visible )
				mcStepper.handleInput( event );
			
			if ( !event.handled )
				super.handleInput(event);
        }

		override public function set selected(value:Boolean):void
		{
			if (super.selected == value)
			{
				//when item is first shown, it's not changing
				if (data && data.hasOwnProperty("tag"))
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionSelectionChanged', [ data.tag, value ] ) );
				return;
			}
			
			super.selected = value;

            // Return focus to menu
			if (!value && (_type == IngameMenu.IGMActionType_List || _type == IngameMenu.IGMActionType_ListWithCondition))
			{
				focused = 0;
				_ingameMenu.focused = 1;
            }

			// #J wierd hack to initial selection visibility bug since timeline changes aren't reflected properly when starting out
			
			if (mcSelectionHighlightPro)
			{
				if (value)
				{
					mcSelectionHighlightPro.alpha = 1;
				}
				else
				{
					mcSelectionHighlightPro.alpha = 0;
				}
			}
			if(data && data.hasOwnProperty("tag"))
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOptionSelectionChanged', [ data.tag, value ] ) );
		}


		// We use pending because of problem with data transfering during one tick
		public function showTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] showTooltip", InputManager.getInstance().isGamepad());
			//if (InputManager.getInstance().isGamepad())
			//{
				/*trace("HUD W3MLIR showTooltip " );
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipShow, false, 0, true);*/
			//}
		}
		public function hideTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] hideTooltip", InputManager.getInstance().isGamepad());
			//if (InputManager.getInstance().isGamepad())
			//{
				/*removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipHide, false, 0, true);*/
			//}
		}

		protected function pendedTooltipShow(event:Event):void
		{
			//trace("GFX [SlotBase] pendedTooltipShow");
			//removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
			//trace("HUD W3MLIR pendedTooltipShow " );
			//fireTooltipShowEvent(false);
		}
		protected function pendedTooltipHide(event:Event):void
		{
			//trace("GFX [SlotBase] pendedTooltipHide");
			//removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
			//fireTooltipHideEvent(false);
		}

		protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase] fireTooltipShowEvent ", isMouseTooltip);
			/*var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
			trace("HUD W3MLIR fireTooltipShowEvent " );
			displayEvent.isMouseTooltip = isMouseTooltip;
			displayEvent.directData = true;
			displayEvent.tooltipContentRef = "InGameMenuTooltipRef";
			displayEvent.anchorRect = getGlobalRect();
			dispatchEvent(displayEvent);*/
		}
		protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase] fireTooltipHideEvent ", isMouseTooltip);
			//var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
			//dispatchEvent(hideEvent);
		}

		public function getGlobalRect():Rectangle
		{
			var targetRect:Rectangle = new Rectangle(x, y, width, height);
			var globalPoint:Point =	localToGlobal(new Point(targetRect.x, targetRect.y));
			targetRect.x = globalPoint.x;
			targetRect.y = globalPoint.y;
			return targetRect;
		}
		
		override protected function draw():void 
		{
            if (isInvalid(InvalidationType.DATA)) {
                updateText();
                if (autoSize != TextFieldAutoSize.NONE) {
                    invalidateSize();
                }
            }

            if (isInvalid(InvalidationType.SIZE) ) {
                if (!preventAutosizing) {
                    alignForAutoSize();
                    setActualSize(_width, _height);
                }
                if (!constraintsDisabled) {
                    constraints.update(_width, _height);
                }
            }
		} 
	}
}
