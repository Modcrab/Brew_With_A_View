package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.TooltipAlignment;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.TooltipAnchor;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.hud.states.OnDemandState;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotsListPreset;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * @author Getsevich Yaroslav
	 * red.game.witcher3.menus.character_menu.MutationsPanel
	 */
	public class MutationsPanel extends UIComponent
	{
		protected const RESEARCH_BUTTON_PADDING:Number = 20;
		
		public var mcMutationList:MutationItemsList;
		
		public var mcMutation1:MutationItemRenderer;
		public var mcMutation2:MutationItemRenderer;
		public var mcMutation3:MutationItemRenderer;
		public var mcMutation4:MutationItemRenderer;
		public var mcMutation5:MutationItemRenderer;
		public var mcMutation6:MutationItemRenderer;
		public var mcMutation7:MutationItemRenderer;
		public var mcMutation8:MutationItemRenderer;
		public var mcMutation9:MutationItemRenderer;
		public var mcMutation10:MutationItemRenderer;
		public var mcMutation11:MutationItemRenderer;
		public var mcMutation12:MutationItemRenderer;
		public var mcMutation13:MutationItemRenderer;
		
		public var mcMutConnector3_8:MutationConnector;
		public var mcMutConnector8_7:MutationConnector;
		public var mcMutConnector8_9:MutationConnector;
		public var mcMutConnector9_12:MutationConnector;
		public var mcMutConnector7_11:MutationConnector;
		public var mcMutConnector6_7:MutationConnector;
		public var mcMutConnector10_9:MutationConnector;
		public var mcMutConnector4_10:MutationConnector;
		public var mcMutConnector2_6:MutationConnector;
		public var mcMutConnector6_1:MutationConnector;
		public var mcMutConnector10_5:MutationConnector;
		
		public var mcMasterMutationConnector1:MutationConnector;
		public var mcMasterMutationConnector2:MutationConnector;
		public var mcMasterMutationConnector3:MutationConnector;
		
		public var mcAnchor1:TooltipAnchor;
		public var mcAnchor2:TooltipAnchor;
		public var mcAnchor3:TooltipAnchor;
		public var mcAnchor4:TooltipAnchor;
		public var mcAnchor5:TooltipAnchor;
		public var mcAnchor6:TooltipAnchor;
		public var mcAnchor7:TooltipAnchor;
		public var mcAnchor8:TooltipAnchor;
		public var mcAnchor9:TooltipAnchor;
		public var mcAnchor10:TooltipAnchor;
		public var mcAnchor11:TooltipAnchor;
		public var mcAnchor12:TooltipAnchor;
		public var mcAnchor13:TooltipAnchor;
		
		public var mcFadeoutSprite:MovieClip;
		public var mcMutationBackground:MovieClip;
		
		// info about selected mutation
		public var mcMutagenTooltip:MutationTooltip;
		
		public var equippedMutationId:int = -1;
		
		protected var _fadeOutComponents:Vector.<MovieClip>;
		protected var _fadeInComponent:Vector.<MovieClip>;
		
		protected var _selectedMutationData:Object;
		protected var _selectedMutationRenderer:MutationItemRenderer;
		protected var _researchMode:Boolean;
		protected var _active:Boolean;
		protected var _data:Array;
		protected var _linesCanvas:Sprite;
		
		protected var _mutationChanged:Boolean = false;
		private var tooltipTimer:Timer;
		
		private var _cachedChangeList:Object;
		
		public function MutationsPanel()
		{
			visible = false;
			
			mcMutationList.sortData = true;
			mcMutationList.focusable = false;
			
			mcMutationList.addEventListener(ListEvent.INDEX_CHANGE, handleMutationSelected, false, 0, true );
			mcMutationList.addEventListener(ListEvent.ITEM_CLICK, hanldeMutationClick, false, 0, true);
			mcMutationList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, hanldeMutationDoubleClick, false, 0, true);
			mcMutationList.addEventListener(ListEvent.ITEM_ROLL_OVER, hanldeMutationOver, false, 0, true );
			mcMutationList.addEventListener(ListEvent.ITEM_ROLL_OUT, hanldeMutationOut, false, 0, true );
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		private function handleControllerChanged(e:Event):void
		{
			if (_selectedMutationRenderer)
			{
				alignControls();
			}
		}
		
		private function hanldeMutationClick( event : ListEvent ):void
		{
		}
		
		private function hanldeMutationDoubleClick( event : ListEvent ):void
		{
			mutationAction();
		}
		
		private function hanldeMutationOver(event:ListEvent):void
		{
			var targetRenderer:MutationItemRenderer = event.itemRenderer as MutationItemRenderer;
			
			trace("GFX MutationPanel::hanldeMutationOver ");
			
			mcMutationList.selectedIndex = targetRenderer.index;
			mcMutationList.validateNow();
			
			if ( targetRenderer && !targetRenderer.blocked )
			{
				if ( tooltipTimer )
				{
					tooltipTimer.stop()
					tooltipTimer.removeEventListener( TimerEvent.TIMER, handleTooltipTimer, false );
					tooltipTimer = null;
				}
				
				GTweener.removeTweens( mcMutagenTooltip );
				
				mcMutagenTooltip.alpha = 0;
				mcMutagenTooltip.visible = true;
				mcMutagenTooltip.data = targetRenderer.data;
				mcMutagenTooltip.validateNow();
				
				alignTooltip( targetRenderer );
				GTweener.to( mcMutagenTooltip, 1, { alpha:1 }, { ease:Exponential.easeOut } );
			}
		}
		
		private function hanldeMutationOut(event:ListEvent):void
		{
			trace("GFX hanldeMutationOut ");
			
			if (tooltipTimer)
			{
				tooltipTimer.stop()
				tooltipTimer.removeEventListener(TimerEvent.TIMER, handleTooltipTimer, false);
				tooltipTimer = null;
			}
			
			mcMutagenTooltip.visible = false;
			mcMutagenTooltip.alpha = 0;
			GTweener.removeTweens(mcMutagenTooltip);
		}
		
		// Update context information
		private function handleMutationSelected(e:ListEvent):void
		{
			var selectedItem:MutationItemRenderer = mcMutationList.getSelectedRenderer() as MutationItemRenderer;
			
			selectMutation(selectedItem);
		}
		
		private function selectMutation(selectedItem : MutationItemRenderer, forced:Boolean = false):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			trace("GFX [MutationsPanel] ----------------------- handleMutationSelected ", selectedItem);
			
			if (_selectedMutationRenderer == selectedItem && !forced)
			{
				return;
			}
			
			if (isGamepad)
			{
				if (tooltipTimer)
				{
					tooltipTimer.stop()
					tooltipTimer.removeEventListener(TimerEvent.TIMER, handleTooltipTimer, false);
					tooltipTimer = null;
				}
				
				mcMutagenTooltip.alpha = 0;
				GTweener.removeTweens(mcMutagenTooltip);
			}
			
			if (selectedItem && selectedItem.data)
			{
				_selectedMutationRenderer = selectedItem;
				_selectedMutationData = selectedItem.data;
				
				if (isGamepad)
				{
					mcMutagenTooltip.data = _selectedMutationData;
					mcMutagenTooltip.validateNow();
					
					tooltipTimer = new Timer(500);
					tooltipTimer.addEventListener(TimerEvent.TIMER, handleTooltipTimer, false, 0, true);
					tooltipTimer.start();
				}
				else
				{
					if (mcMutagenTooltip.data != selectedItem.data)
					{
						mcMutagenTooltip.visible = false;
					}
				}
			}
			else
			{
				if (isGamepad)
				{
					mcMutagenTooltip.visible = false;
				}
			}
			
			if (_selectedMutationData)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnMutationSelected", [ int( _selectedMutationData.mutationId ) ] ) );
			}
			
			if (isGamepad)
			{
				alignControls();
			}
		}
		
		private function alignControls():void
		{
			removeEventListener(Event.ENTER_FRAME, validateAlignControls);
			addEventListener(Event.ENTER_FRAME, validateAlignControls, false, 0, true);
		}
		
		private function validateAlignControls(e:Event = null):void
		{
			trace("GFX MutationPanel::validateAlignControls ");
			
			removeEventListener(Event.ENTER_FRAME, validateAlignControls);
			
			if (_selectedMutationRenderer)
			{
				alignTooltip(_selectedMutationRenderer);
			}
		}
		
		private function alignTooltip( attachedRenderer : MutationItemRenderer, moveWithTween : Boolean = false ) : void
		{
			const TO_PADDING_X = 0;
			const TO_PADDING_Y = 0;
			var targetX:Number;
			var targetY:Number;
			
			var curAnchor : TooltipAnchor = attachedRenderer.getTooltipAnchorComponent();
			
			trace("GFX MutationPanel::alignTooltip ");
			trace("GFX curAnchor  ", curAnchor );
			
			if ( curAnchor )
			{
				var curAlignment : String = curAnchor.alignment;
				var ttHeight : Number = mcMutagenTooltip.currentHeight;
				var ttWidth : Number = mcMutagenTooltip.mcBackground.width;
				
				mcMutagenTooltip.anchor = curAnchor;
				
				switch ( curAlignment )
				{
					case TooltipAlignment.BOTTOM_LEFT:
						targetY = curAnchor.y;
						targetX = curAnchor.x - ttWidth;
						break;
						
					case TooltipAlignment.BOTTOM_RIGHT:
						targetY = curAnchor.y;
						targetX = curAnchor.x;
						
						break;
					case TooltipAlignment.TOP_LEFT:
						targetY = curAnchor.y - ttHeight;
						targetX = curAnchor.x - ttWidth;
						
						break;
					case TooltipAlignment.TOP_RIGHT:
						targetY = curAnchor.y - ttHeight;
						targetX = curAnchor.x;
						
						break;
				}
			}
			
			if ( moveWithTween )
			{
				GTweener.removeTweens( mcMutagenTooltip );
				GTweener.to( mcMutagenTooltip, .5, { x : targetX, y : targetY, alpha : 1 }, { ease : Exponential.easeOut } );
			}
			else
			{
				mcMutagenTooltip.x = targetX;
				mcMutagenTooltip.y = targetY;
			}
		}
		
		private function handleTooltipTimer(event:TimerEvent):void
		{
			tooltipTimer.stop()
			tooltipTimer.removeEventListener(TimerEvent.TIMER, handleTooltipTimer, false);
			tooltipTimer = null;
			
			trace("GFX MutationPanel::handleTooltipTimer ");
			
			GTweener.removeTweens(mcMutagenTooltip);
			
			mcMutagenTooltip.alpha = 0;
			
			if (_selectedMutationRenderer)
			{
				alignControls();
			}
			
			if ( !GTweener.getTweens(mcMutagenTooltip).length )
			{
				GTweener.to(mcMutagenTooltip, 1, { alpha:1 }, { ease:Exponential.easeOut } );
			}
		}
		
		public function get active():Boolean { return _active; }
		public function set active(value:Boolean):void
		{
			trace("GFX MutationPanel::active ", _active, value);
			
			if (_active != value)
			{
				_active = value;
				
				enabled = _active;
				stage.removeEventListener(InputEvent.INPUT, handleInput, false);
				
				if (_active)
				{
					stage.addEventListener(InputEvent.INPUT, handleInput, false, 1000, true);
					dispatchEvent(new Event(Event.ACTIVATE));
					mcMutationList.enabled = true;
					initPopulateData(true);
					
					_mutationChanged = false;
				}
				else
				{
					mcMutationList.selectedIndex =  -1;
					mcMutationList.enabled = false;
					mcMutationList.focused = 0;
					dispatchEvent(new Event(Event.DEACTIVATE));
					
					if (_mutationChanged)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateMutationData", [] ) );
						_mutationChanged = false;
					}
				}
			}
		}
		
		public function get data():Array { return _data; }
		public function set data(value:Array):void
		{
			trace("GFX *data ", value);
			
			_data = value;
			
			if (_active)
			{
				initPopulateData();
			}
		}
		
		public function setSingleMutationData(value:Object):void
		{
			//trace("GFX MutationPanel :: setSingleMutationData ", value, value.mutationId, value.description );
			
			if (_data)
			{
				var count:int = _data.length;
				
				for (var i:int = 0; i < count; i++)
				{
					var itemData:Object = _data[i];
					
					if (itemData.mutationId == value.mutationId)
					{
						_data[i] = value;
						mcMutationList.data[i] = value;
						mcMutationList.updateSingleMutation(value);
						mcMutationList.validateNow()
						return;
					}
				}
			}
		}
		
		public function setDataList(value:Array):void
		{
			data = value;
		}
		
		private function initPopulateData(resetSelection:Boolean = false):void
		{
			var cachedSelectedIdx:int = mcMutationList.selectedIndex;
			
			trace("GFX [MutationPanel] initPopulateData ", resetSelection);
			
			mcMutationList.focused = 1;
			mcMutationList.selectedIndex = -1;
			
			mcMutationList.data = data as Array;
			mcMutationList.validateNow();
			
			if (!resetSelection)
			{
				mcMutationList.selectedIndex = cachedSelectedIdx;
				
				selectMutation( mcMutationList.getSelectedRenderer() as MutationItemRenderer, true );
			}
			else
			{
				mcMutationList.selectedIndex = 12; // Master mutation
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var axisData:InputAxisData;
			var isKeyUp:Boolean = details.value == InputValue.KEY_UP;
			var isKeyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var inputCaptured:Boolean = false;
			
			super.handleInput(event);
			
			//trace("GFX ---------------------------------------------- handleInput ", _active, isKeyUp, details.code);
			
			if (_active && isKeyUp)
			{
				switch (details.code)
				{
					case KeyCode.E:
					case KeyCode.SPACE:
					case KeyCode.ENTER:
					case KeyCode.PAD_A_CROSS:
						
						mutationAction();
						inputCaptured = true;
						break;
					
					case KeyCode.C:
					case KeyCode.ESCAPE:
					case KeyCode.PAD_B_CIRCLE:
					case KeyCode.PAD_Y_TRIANGLE:
						
						inputCaptured = true;
						active = false;
						break;
				}
			}
			
			// Mutations list input
			if (_active && !inputCaptured)
			{
				mcMutationList.handleInputPreset(event);
				//mcMutationList.handleInputNavSimple(event);
				inputCaptured = true;
			}
			
			// Don't propagate to the menu if captured
			if (inputCaptured)
			{
				event.handled = true;
				event.stopImmediatePropagation();
			}
		}
		
		private function mutationAction():void
		{
			_selectedMutationRenderer =	mcMutationList.getSelectedRenderer() as MutationItemRenderer;
			
			if (_selectedMutationRenderer)
			{
				_selectedMutationData = _selectedMutationRenderer.data;
			}
			
			if (_selectedMutationData && _selectedMutationData.enabled)
			{
				//trace("GFX * researchCompleted: ", _selectedMutationData.researchCompleted, "; canResearch: ", _selectedMutationData.canResearch, "; enabled: ", _selectedMutationData.enabled);
				
				if (!_selectedMutationData.researchCompleted)
				{
					if (_selectedMutationData.canResearch)
					{
						var params:Array = [ _selectedMutationData.mutationId, _selectedMutationData.skillpointsRequired, _selectedMutationData.redRequired, _selectedMutationData.greenRequired, _selectedMutationData.blueRequired ];
						
						MutationItemRenderer.TRIGGER_RESEARCHED_ID_FX = _selectedMutationData.mutationId;
						
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnResearchMutation", params ) );
					}
					else
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnCantResearchMutation", [] ) );
						
						mcMutagenTooltip.mcRequaredResources.playFeedbackAnim();
					}
				}
				else
				if (_selectedMutationData.isEquipped)
				{
					MutationItemRenderer.TRIGGER_UNEQUIP_FX = true;
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnequipMutation", [] ) );
				}
				else
				{
					MutationItemRenderer.TRIGGER_EQUIP_FX = true;
					if (equippedMutationId != -1 && equippedMutationId != _selectedMutationData.mutationId)
					{
						MutationItemRenderer.TRIGGER_UNEQUIP_FX = true;
					}
					
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnEquipMutation", [ _selectedMutationData.mutationId ] ) );
				}
			}
		}
		
	}

}
