﻿/**
 * The ButtonBar is similar to the ButtonGroup although it has a visual representation. It is also able to create Button instances on the fly based on a DataProvider. The ButtonBar is useful for creating dynamic tab-bar like UI elements.
 *
 * <p><b>Inspectable Properties</b></p>
 * <p>
 * The inspectable properties of the Button component are:
 * <ul>
 *  <li><i>autoSize</i>: Determines if the ButtonBar's Buttons will scale to fit the text that it contains and which direction to align the resized Button. Setting the autoSize property to TextFieldAutoSize.NONE ("none") will leave the child Buttons' size unchanged.</li>
 *  <li><i>buttonWidth</i>: Sets a common width to all Button instances. If autoSize is set to true this property is ignored.</li>
 *  <li><i>direction</i>: Button placement. Horizontal will place the Button instances side-by-side, while vertical will stack them on top of each other.</li>
 *  <li><i>enabled</i>: Disables the button if set to true.</li>
 *  <li><i>focusable</i>: By default the ButtonBar can receive focus for user interactions. Setting this property to false will disable focus acquisition.</li>
 *  <li><i>itemRenderer</i>: Linkage ID of the Button component symbol. This symbol will be instantiated as needed based on the data assigned to the ButtonBar.</li>
 *  <li><i>spacing</i>: The spacing between the Button instances. Affects only the current direction (see direction property).</li>
 *  <li><i>visible</i>: Hides the component if set to false.</li>
 * </ul>
 * </p>
 * 
 * <p><b>States</b></p>
 * <p>
 * The CLIK ButtonBar does not have any visual states because its managed Button components are used to display the group state.
 * </p>
 * 
 * <p><b>Events</b></p>
 * <p>
 * All event callbacks receive a single Event parameter that contains relevant information about the event. The following properties are common to all events. <ul>
 * <li><i>type</i>: The event type.</li>
 * <li><i>target</i>: The target that generated the event.</li></ul>
 *
 * The events generated by the Button component are listed below. The properties listed next to the event are provided in addition to the common properties.
 * <ul>
 *   <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
 *   <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
 *   <li><i>FocusHandlerEvent.FOCUS_IN</i>: The component has received focus.</li>
 *   <li><i>FocusHandlerEvent.FOCUS_OUT</i>: The component has lost focus.</li>
 *   <li><i>ButtonBar.BUTTON_SELECT</i>: The selected property has changed.</li>
 *   <li><i>IndexEvent.INDEX_CHANGE,</i>: The button has been pressed.</li>
 * </ul>
 * </p>
 */

/**************************************************************************

Filename    :   ButtonBar.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls 
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    
    import scaleform.clik.controls.Button;
    import scaleform.clik.controls.ButtonGroup;
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.events.IndexEvent;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.events.ButtonBarEvent;
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.ui.InputDetails;
    
    public class ButtonBar extends UIComponent 
    {
    // Constants:
        public static const DIRECTION_HORIZONTAL:String = "horizontal";
        public static const DIRECTION_VERTICAL:String = "vertical";
        
    // Public Properties:
        
    // Protected Properties:
        /** @private */
        protected var _autoSize:String = "none";
        /** @private */
        protected var _buttonWidth:Number = 0;
        /** @private */
        protected var _dataProvider:IDataProvider;
        /** @private */
        protected var _direction:String = DIRECTION_HORIZONTAL;
        /** @private */
        protected var _group:ButtonGroup;
        /** @private */
        protected var _itemRenderer:String = "Button";
        /** @private */
        protected var _itemRendererClass:Class;
        /** @private */
        protected var _labelField:String = "label";
        /** @private */
        protected var _labelFunction:Function;
        /** @private */
        protected var _renderers:Array;
        /** @private */
        protected var _spacing:Number = 0;
        /** @private */
        protected var _selectedIndex:Number = -1;
        
    // UI Elements:
        public var container:MovieClip;
        
    // Initialization:
        public function ButtonBar() {
            super();
        }
        
        /** @private */
        override protected function initialize():void {
            super.initialize();
            dataProvider = new DataProvider(); // Default Data.
            _renderers = [];
        }
        
    // Public Getter / Setters:
        /**
         * Enable/disable this component. Focus (along with keyboard events) and mouse events will be suppressed if disabled.
         */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            if (enabled == value) { return; }
            super.enabled = value;
            for (var i:Number = 0; i < _renderers.length; i++) {
                if (_itemRendererClass) { 
                    (_renderers[i] as _itemRendererClass).enabled = value;
                } else {
                    (_renderers[i] as UIComponent).enabled = value;
                }
                
            }
        }
        
        /**
         * Enable/disable focus management for the component. Setting the focusable property to 
         * false will remove support for tab key, direction key and mouse
         * button based focus changes.
         * @see focusable
         */
        [Inspectable(defaultValue="true")]
        override public function get focusable():Boolean { return _focusable; }
        override public function set focusable(value:Boolean):void { 
            super.focusable = value;
        }
        
        /**
         * The data model displayed in the component. The dataProvider must implement the 
         * IDataProvider interface. When a new DataProvider is set, the selectedIndex
         * property will be reset to 0.
         * @see DataProvider
         * @see IDataProvider
         */
        public function get dataProvider():IDataProvider { return _dataProvider; }
        public function set dataProvider(value:IDataProvider):void {
            if (_dataProvider == value) { return; }
            if (_dataProvider != null) {
                _dataProvider.removeEventListener(Event.CHANGE, handleDataChange, false);
            }
            _dataProvider = value;
            if (_dataProvider == null) { return; }
            _dataProvider.addEventListener(Event.CHANGE, handleDataChange, false, 0, true);
            invalidateData();
        }
        
        /**
         * The linkage ID for the renderer used to display each item in the list. The list components only support
         * a single itemRenderer for all items.
         */
        [Inspectable(name="itemRenderer", defaultValue="Button")]
        public function set itemRendererName(value:String):void {
            if ((_inspector && value == "Button") || value == "") { return; }
            
            // Need a try/catch in case the specified class cannot be found:
            try { 
                var classRef:Class = getDefinitionByName(value) as Class;
            } catch (error:*) {
                throw new Error("The class " + value + " cannot be found in your library. Please ensure it exists.");
            }
            
            if (classRef != null) {
                _itemRendererClass = classRef;
                invalidate();
            }
        }
        
        /**
         * The spacing between each item in pixels. Spacing can be set to a negative value to overlap items.
         */
        [Inspectable(defaultValue="0")]
        public function get spacing():Number { return _spacing; }
        public function set spacing(value:Number):void {
            _spacing = value;
            invalidateSettings();
        }
        
        /**
         * The direction the buttons draw. When the direction is set to "horizontal", the buttons will draw on the same y-coordinate, with the spaceing between each instance.  When the direction is set to "vertical", the buttons will draw with the same x-coordinate, with the spacing between each instance.
         * @see #spacing
         */
        [Inspectable(defaultValue="horizontal", type="list", enumeration="horizontal,vertical")]
        public function get direction():String { return _direction; }
        public function set direction(value:String):void {
            _direction = value;
            invalidateSettings();
        }
        
        /**
         * Determines if the buttons auto-size to fit their label. This parameter will only be applied if the itemRenderer supports it.
         */
        [Inspectable(type="String", enumeration="none,left,center,right", defaultValue="none")]
        public function get autoSize():String { return _autoSize; }
        public function set autoSize(value:String):void {
            if (value == _autoSize) { return; }
            _autoSize = value;
            for (var i:Number=0; i < _renderers.length; i++) {
                (_renderers[i] as _itemRendererClass).autoSize = _autoSize;
            }
            invalidateSettings();
        }
        
        /**
         * The width of each button.  Overrides the {@code autoSize} property when set.  Set to 0 to let the component auto-size.
         */
        [Inspectable(defaultValue="0")]
        public function get buttonWidth():Number { return _buttonWidth; }
        public function set buttonWidth(value:Number):void {
            _buttonWidth = value;
            invalidate();
        }
        
        /**
         * The index of the item that is selected in a single-selection list.
         */
        public function get selectedIndex():int { return _selectedIndex; }
        public function set selectedIndex(value:int):void {
            if (value == _selectedIndex) { return; }
            var oldSelectedIndex:int = _selectedIndex;
            
            var renderer:Button = _renderers[oldSelectedIndex] as Button;
            if (renderer) {
                renderer.selected = false;
            }
            
            _selectedIndex = value;
            
            renderer = _renderers[_selectedIndex] as Button;
            if (renderer) {
                renderer.selected = true;
            }
            
            dispatchEvent( new IndexEvent(IndexEvent.INDEX_CHANGE, true, true, _selectedIndex, oldSelectedIndex, _dataProvider[_selectedIndex]) );
        }
    
        /**
         * The item at the selectedIndex in the DataProvider.
         */
        public function get selectedItem():Object { return _dataProvider.requestItemAt(_selectedIndex); }
        
        /**
         * The {@code data} property of the selectedItem.
         * @see Button#data
         */
        public function get data():Object { return selectedItem.data; }
        
        /**
         * The name of the field in the {@code dataProvider} model to be displayed as the label for itemRenderers.  A labelFunction will be used over a labelField if it is defined.
         */
        public function get labelField():String { return _labelField; }
        public function set labelField(value:String):void {
            _labelField = value;
            invalidateData();
        }
        
        /**
         * The function used to determine the label for itemRenderers. A labelFunction will override a labelField if it is defined.
         */
        public function get labelFunction():Function { return _labelFunction; }
        public function set labelFunction(value:Function):void {
            _labelFunction = value;
            invalidateData();
        }
        
    // Public Methods:
        /** Mark the settings of this component invalid and schedule a draw() on next Stage.INVALIDATE event. */
        public function invalidateSettings():void {
            invalidate(InvalidationType.SETTINGS);
        }
        
        /**
         * Convert an item to a label string using the labelField and labelFunction. If the item is not an object, then it will be converted to a string, and returned.
         * @param item The item to convert to a label.
         * @returns The converted label string.
         * @see #labelField
         * @see #labelFunction
         */
        public function itemToLabel(item:Object):String {
            if (item == null) { return ""; }
            if (_labelFunction != null) {
                return _labelFunction(item);
            } else if (item is String) { 
                return item as String;
            } else if (_labelField != null && item[_labelField] != null) {
                return item[_labelField];
            }
            return item.toString();
        }
        
        /** Retrieve a reference to one of the ButtonBar's Buttons. */
        public function getButtonAt(index:int):Button {
            if (index >= 0 && index < _renderers.length) { 
                return _renderers[index];
            } else {
                return null;
            }
        }
        
        /** @private */
        override public function handleInput(event:InputEvent):void {
            if (event.handled) { return; } // Already handled.
            
            // Pass on to selected renderer first
            var renderer:Button = _renderers[_selectedIndex] as Button;
            if (renderer != null) {
                renderer.handleInput(event); // Since we are just passing on the event, it won't bubble, and should properly stopPropagation.
                if (event.handled) { return; }
            }
            
            // Only allow actions on key down, but still set handled=true when it would otherwise be handled.
            var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
            if (!keyPress) { return; }
            
            var indexChanged:Boolean = false;
            var newIndex:Number;
            
            switch(details.navEquivalent) {
                case NavigationCode.LEFT:
                    if (_direction == DIRECTION_HORIZONTAL) {
                        newIndex = _selectedIndex - 1;
                        indexChanged = true;
                    }
                    break;
                case NavigationCode.RIGHT:
                    if (_direction == DIRECTION_HORIZONTAL) {
                        newIndex = _selectedIndex + 1;
                        indexChanged = true;
                    }
                    break;
                case NavigationCode.UP:
                    if (_direction == DIRECTION_VERTICAL) {
                        newIndex = _selectedIndex - 1;
                        indexChanged = true;
                    }
                    break;
                case NavigationCode.DOWN:
                    if (_direction == DIRECTION_VERTICAL) {
                        newIndex = _selectedIndex + 1;
                        indexChanged = true;
                    }
                    break;
                default:
                    break;
            }
            
            if (indexChanged) {
                newIndex = Math.max(0, Math.min(_dataProvider.length - 1, newIndex));
                if (newIndex != _selectedIndex) { 
                    selectedIndex = newIndex;
                    event.handled = true;
                }
            }
        }
        
        /** @private */
        override public function toString():String {
            return "[CLIK ButtonBar " + name + "]";
        }
        
    // Protected Methods:
        /** @private */
        override protected function configUI():void {
            super.configUI();
            
            tabEnabled = (_focusable && enabled);
            
            if (_group == null) {
                _group = new ButtonGroup(name + "Group", this);
            }
            _group.addEventListener(ButtonEvent.CLICK, handleButtonGroupChange, false, 0, true);
            
            if (container == null) {
                container = new MovieClip();
                addChild(container);
            }
            
            addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }
        
        /** @private */
        override protected function draw():void {
            if (isInvalid(InvalidationType.RENDERERS) || isInvalid(InvalidationType.DATA) ||
                isInvalid(InvalidationType.SETTINGS) || isInvalid(InvalidationType.SIZE)) { 
                
                removeChild(container);
                setActualSize(_width, _height);
                container.scaleX = 1 / scaleX;
                container.scaleY = 1 / scaleY;
                addChild(container);
            
                updateRenderers();
            }
        }
        
        /** @private */
        protected function refreshData():void {
            selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex);
            if (_dataProvider) {
                _dataProvider.requestItemRange(0, _dataProvider.length-1, populateData);
            }
        }
        
        /** @private */
        protected function updateRenderers():void {
            var w:Number = 0;
            var h:Number = 0;
            var overflowIndex:int = -1;
            
            // If the rendererClass the same as the previous rendererClass, remove them properly.
            if (_renderers[0] is _itemRendererClass) {
                while (_renderers.length > _dataProvider.length) {
                    var c:int = _renderers.length - 1;
                    if (container.contains( _renderers[c] )) {
                        container.removeChild( _renderers[c] );
                    }
                    _renderers.splice(c--, 1);
                }
            }
            else {
                while (container.numChildren > 0) {
                    container.removeChildAt(0);
                }
                _renderers.length = 0;
            }
            
            // Create any new renderers we may need without overflowing.
            for (var i:uint = 0; i < _dataProvider.length && overflowIndex == -1; i++) {
                var renderer:Button;
                var isNew:Boolean = false;
                
                if ( i < _renderers.length ) {
                    renderer = _renderers[i];
                }
                else {
                    renderer = new _itemRendererClass();
                    setupRenderer(renderer, i);
                    isNew = true;
                }
                
                // NFM: Consider tracking changes to renderer and then deciding on whether invalidation is necessary.
                populateRendererData(renderer, i);
                if (_autoSize == TextFieldAutoSize.NONE && _buttonWidth > 0) {
                    renderer.width = _buttonWidth; // Manually size the renderer
                } 
                else if (_autoSize != TextFieldAutoSize.NONE) {
                    renderer.autoSize = _autoSize;
                }
                
                renderer.validateNow();
                
                if (_direction == DIRECTION_HORIZONTAL) {
                    if ( _width > (renderer.width + _spacing + w)) {
                        renderer.y = 0;
                        renderer.x = w;
                        w += renderer.width + _spacing;
                    } else {
                        // If the ButtonBar is not large enough to support the renderer, do not create it.
                        overflowIndex = i;
                        renderer = null;
                    }
                } else {
                    if ( _height > (renderer.height + _spacing + h)) {
                        renderer.x = 0;
                        renderer.y = h;
                        h += renderer.height + _spacing;
                    } else {
                        // If the ButtonBar is not large enough to support the renderer, do not create it.
                        overflowIndex = i;
                        renderer = null;
                    }
                }
                
                if (isNew && renderer != null) { // Renderer will be null if it was overflow.
                    renderer.group = _group; // Don't set renderer.group beforehand or it will be added to group's array.
                    container.addChild(renderer);
                    _renderers.push(renderer);
                }
            }
            
            // Clean up the renderers now that the overflowIndex has been set.
            if (overflowIndex > - 1) {
                for (var j:int = _renderers.length - 1; j >= overflowIndex; j--) { 
                    var rend:Button = _renderers[j]
                    if (rend) { 
                        if (container.contains(rend)) {
                            container.removeChild(rend);
                        }
                        _renderers.splice(j, 1);
                    }
                }
            }
            
            selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex);
        }
        
        /** @private */
        protected function populateData(data:Array):void {
            for (var i:uint = 0; i < _renderers.length; i++) {
                var renderer:Button = _renderers[i] as Button;
                populateRendererData( renderer, i );
                renderer.validateNow();
            }
        }
        
        /** @private */
        protected function populateRendererData(renderer:Button, index:uint):void {
            renderer.label = itemToLabel( _dataProvider.requestItemAt(index) );
            renderer.data = _dataProvider.requestItemAt(index);
            renderer.selected = (index == selectedIndex);
        }
        
        /** @private */
        protected function setupRenderer(renderer:Button, index:uint):void {
            renderer.owner = this;
            renderer.focusable = false;
            renderer.focusTarget = this;
            renderer.toggle = true;
            renderer.allowDeselect = false;
        }
        
        /** @private */
        protected function handleButtonGroupChange(event:Event):void {
            if (_group.selectedIndex != selectedIndex) {
                selectedIndex = _group.selectedIndex;
                dispatchEvent(new ButtonBarEvent(ButtonBarEvent.BUTTON_SELECT, false, true, _selectedIndex, event.target as Button));
            }
        }
        
        /** @private */
        protected function handleDataChange(event:Event):void {
            invalidate(InvalidationType.DATA);
        }
        
        /** @private */
        override protected function changeFocus():void {
            var renderer:Button = _renderers[_selectedIndex] as Button;
            if (renderer == null) { return; }
            renderer.displayFocus = (_focused > 0);
        }
    }
}
