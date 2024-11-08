package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.Slider;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.SliderEvent;
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import red.core.events.GameEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
	import red.game.witcher3.managers.InputManager;
	
	public class PhotomodeSliderRenderer extends BaseListItem implements IListItemRenderer
	{	
		public var m_txtValue : TextField;
		public var m_txtLabel : TextField;
		public var m_slider : Slider;
		
		private var _currentDataModel : PhotomodeSliderDataModel;
		private var _valuePrecision : Number;
		
		public function PhotomodeSliderRenderer() 
		{
            super();
			preventAutosizing = true;
        }
		
        public override function set selected(value:Boolean):void 
		{
            super.selected = value;
			
			if (value){
				gotoAndStop("focused");
			}
			else{
				gotoAndStop("unfocused");
			}
        }
		
        public override function set enabled(value:Boolean):void 
		{
            if (value == super.enabled) 
				return;
				
            super.enabled = value;
			
			m_slider.enabled = value;
			this.visible = value;
        }
		
		public override function setListData(listData:ListData):void 
		{
			index = listData.index;
			selected = listData.selected;
        }
        
        public override function setData(data:Object):void 
		{
			if (data == null)
				return;
			
			var dataModel : PhotomodeSliderDataModel = data.data as PhotomodeSliderDataModel;
			
			if (dataModel == null)
				return;
				
			if (_currentDataModel == dataModel)
				return;
				
			_currentDataModel = dataModel;
			
			if (dataModel.stringValues.length > 0)
			{				
				m_txtLabel.text = dataModel.label;
				m_slider.minimum = 0;
				m_slider.maximum = dataModel.stringValues.length - 1;
				m_slider.snapping = true;
				m_slider.snapInterval = 1.0;
				
				m_txtValue.text = dataModel.stringValues[dataModel.currentValue];
				m_slider.value = dataModel.currentValue;
			}
			else
			{
				m_txtLabel.text = dataModel.label;
				m_slider.minimum = dataModel.minValue;
				m_slider.maximum = dataModel.maxValue;
				m_slider.snapping = dataModel.slideStep > 0.0 ? true : false;
				m_slider.snapInterval = dataModel.slideStep;
				
				_valuePrecision = getCorrectPrecision( dataModel.slideStep );
				
				m_txtValue.text = dataModel.currentValue.toFixed( _valuePrecision ).toString();
				m_slider.value = dataModel.currentValue;
			}
        }
       
        override protected function configUI():void 
		{
			super.configUI();	
			
			m_slider.addEventListener(SliderEvent.VALUE_CHANGE, onValueChange);
			
			m_slider.removeEventListener(InputEvent.INPUT, m_slider.handleInput);
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.update_param", [onUpdateParam] ) );
        }
		
		private function onValueChange(event : SliderEvent)
		{
			m_txtValue.text = _currentDataModel.stringValues.length > 0 ? _currentDataModel.stringValues[event.value] : event.value.toFixed( _valuePrecision ).toString();
			_currentDataModel.currentValue = event.value;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterChanged", [ _currentDataModel.id, event.value ] ) );	
		}
	
		
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			if (!keyDown)
				return;
				
			if (!selected)
				return;
				
			trace(details);
			
			switch (details.code) 
			{
			case KeyCode.PAD_DIGIT_RIGHT:
				m_slider.value += m_slider.snapInterval;
				break;
			case KeyCode.RIGHT:
				if (InputManager.getInstance().isGamepad())
					break;
				m_slider.value += m_slider.snapInterval;
				break;
			case KeyCode.PAD_DIGIT_LEFT:
				m_slider.value -= m_slider.snapInterval;
					break;
			case KeyCode.LEFT:
				if (InputManager.getInstance().isGamepad())
					break;
				m_slider.value -= m_slider.snapInterval;
				break;
			default:
				break;
			}
		}
		
		private function onUpdateParam( param : Object):void 
		{
			var id : uint = param.id;
			var value : Number = param.value;
			
			if ( id != _currentDataModel.id )
				return;
				
			m_slider.value = value;
		}
		
		private function getCorrectPrecision( value : Number ) : int 
		{
			const maxPrecision : uint = 5;
			var valueStr : String = value.toFixed( maxPrecision ).toString();
			var precision : uint = maxPrecision;
			
			for ( var i : uint = 0; i < maxPrecision; i++ )
			{	
				var charIdx = valueStr.length - i;
				
				trace( "charIdx: " + charIdx.toString() + ", char: " + valueStr.charAt( valueStr.length - i - 1 ).toString() );
				
				if ( ( charIdx >= 0 ) && ( valueStr.charAt( valueStr.length - i - 1 ) == "0" ) )
				{
					precision--;
					continue;
				}
				
				return precision;
			}
			
			return precision;
		}
	}
}