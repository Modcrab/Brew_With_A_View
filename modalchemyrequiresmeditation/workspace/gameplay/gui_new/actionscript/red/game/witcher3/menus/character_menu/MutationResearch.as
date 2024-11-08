package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationResearch
	 * @author Getsevich Yaroslav
	 */
	public class MutationResearch extends UIComponent
	{
		public var tooltipInstance : MutationTooltip;
		public var tfButtonLabel   : TextField;
		public var btnResearch	   : InputFeedbackButton;
		public var btnResearchPC   : Button;
		
		public var researchCallback	: Function;
		public var closeCallback	: Function;
		
		private var _selectedRes	  : MutationProgressItemRenderer;
		private var _resourcesList	  : MutationResourcesList;
		private var _attachedMutation : MutationItemRenderer;
		
		private var _anchorPoint 	  : Point;
		private var _data		 	  : Object;
		private var _replica	 	  : Object;
		private var _changeList  	  : Object;
		private var _researchProgress : Boolean = false;
		
		public function MutationResearch()
		{
			/*
			visible = false;
			
			_resourcesList = new MutationResourcesList();
			_resourcesList.addEventListener(Event.ACTIVATE, handleResourcesListActivated, false, 0, true);
			_resourcesList.addEventListener(Event.DEACTIVATE, handleResourcesListDeactivated, false, 0, true);
			_resourcesList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick, false, 0, true);
			_resourcesList.addEventListener(ListEvent.INDEX_CHANGE, handleItemIndexChanged, false, 0, true);
			
			addChild(_resourcesList);
			*/
		}
		
		override protected function configUI():void
		{
			super.configUI();
			/*
			tfButtonLabel.text = "[[mutation_input_research_mutation_short]]";
			btnResearch.label = "";
			btnResearch.setDataFromStage(NavigationCode.GAMEPAD_X, -1);
			btnResearch.addEventListener(ButtonEvent.CLICK, handleResearchClick, false, 0, true);
			btnResearchPC.addEventListener(ButtonEvent.CLICK, handleResearchClick, false, 0, true);
			btnResearchPC.alpha = InputManager.getInstance().isGamepad() ? 0 : 1;
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			*/
		}
		
		public function getChangeList():Object
		{
			return _changeList;
		}
		
		public function getResearchProgress():Boolean
		{
			return _researchProgress;
		}
		
		public function getListComponent():MutationResourcesList
		{
			return _resourcesList;
		}
		
		public function attachTo(target:MutationItemRenderer):void
		{
			trace("GFX [MutationResearch] attachTo ", target);
			/*
			if (!target.parent)
			{
				return;
			}
			
			var originLocation:Point = target.parent.localToGlobal( new Point( target.x, target.y ) );
			
			_data = target.data;
			_replica = CommonUtils.replicateDataObject(_data);
			_attachedMutation = target;
			
			_attachedMutation.mcStateSelectedActive.visible = false;
			_anchorPoint = globalToLocal( originLocation );
			
			_resourcesList.x = _anchorPoint.x;
			_resourcesList.y = _anchorPoint.y;
			_resourcesList.data = _replica.progressDataList as Array;
			_resourcesList.enabled = true;
			_resourcesList.activate();
			
			_changeList = {};
			
			visible = true;
			
			tooltipInstance.showApplyResearchBtn = false;
			*/
		}
		
		public function detach():void
		{
			trace("GFX [MutationResearch] detach from ", _attachedMutation);
			/*
			_attachedMutation.mcStateSelectedActive.visible = true;
			_resourcesList.enabled = false;
			visible = false;
			*/
		}
		
		// events handling
		
		private function handleControllerChanged( event : ControllerChangeEvent  ) :void
		{
			btnResearchPC.alpha = InputManager.getInstance().isGamepad() ? 0 : 1;
		}
		
		private function handleItemIndexChanged(event:ListEvent):void
		{
			var newSelection:MutationProgressItemRenderer = event.itemRenderer as MutationProgressItemRenderer;
			
			if (newSelection)
			{
				_selectedRes = newSelection;
				updateSelectionInfo(_selectedRes.data);
			}
		}
		
		private function handleItemDoubleClick(event:ListEvent):void
		{
			researchCurrent();
		}
		
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			
			trace("GFX [MutationResearch] handleInput, event.handled ", event.handled);
			
			super.handleInput(event);
			
			if (event.handled)
			{
				return; // ignore
			}
			
			if ( details.value == InputValue.KEY_UP )
			{
				switch (details.code)
				{
					case KeyCode.ENTER:
					case KeyCode.PAD_A_CROSS:
						
						// accept
						if (_researchProgress)
						{
							confirmResearch();
						}
						break;
						
					case KeyCode.ESCAPE:
					case KeyCode.PAD_B_CIRCLE:
					
						// cancel
						cancelResearch();
						break;
					
					case KeyCode.E:
					case KeyCode.PAD_X_SQUARE:
					case KeyCode.SPACE:
						// research
						researchCurrent();
						break;
					default:
						//...
				}
			
			}
			
			if (_resourcesList.enabled && !event.handled)
			{
				_resourcesList.handleInput(event)
			}
		}
		
		private function handleResearchClick(event:ButtonEvent = null):void
		{
			researchCurrent();
		}
		
		private function handleResourcesListActivated(event:Event):void    {}
		private function handleResourcesListDeactivated(event:Event):void  {}
		
		// ---- actions
		

		public function callResearch():void
		{
			confirmResearch();
		}
		
		public function callCancelResearch():void
		{
			cancelResearch();
		}
		
		private function researchCurrent():void
		{
			/*
			trace("GFX [MutationResearch] DO: researchCurrent, _selectedRes ", _selectedRes );
			
			if (_selectedRes)
			{
				var resData:Object = _selectedRes.data;
				
				if ( resData.required > resData.used )
				{
					if (resData.avaliableResources > 0)
					{
						var changeResDelta:Number = _changeList[resData.type];
						
						if (changeResDelta && !isNaN(changeResDelta))
						{
							_changeList[resData.type] = _changeList[resData.type] + 1;
						}
						else
						{
							_changeList[resData.type] = 1;
						}
						
						resData.used++;
						resData.avaliableResources--;
						_researchProgress = true;
						
						_resourcesList.updateMutationResearch(resData);
						updateSelectionInfo(resData);
						
						displayCurrentProgress();
						
						dispatchEvent(new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", [ "gui_no_stamina" ] ) );
					}
					else
					{
						dispatchEvent(new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", [ "gui_global_denied" ] ) );
					}
				}
			}
			*/
		}
		
		private function displayCurrentProgress():void
		{
			/*
			if (_attachedMutation && _changeList)
			{
				var resCounter:int = 0;
				
				for (var k : String in _changeList)
				{
					resCounter += _changeList[k];
				}
				
				_attachedMutation.setFakeProgressValue(resCounter);
			}
			
			if (tooltipInstance)
			{
				tooltipInstance.showApplyResearchBtn = true;
			}
			*/
		}
		
		private function confirmResearch():void
		{
			/*
			trace("GFX [MutationResearch] confirmResearch ", _changeList);
			
			if ( _researchProgress )
			{
				researchCallback( _changeList );
			}
			
			closeCallback();
			_attachedMutation.setFakeProgressValue( -1);
			
			_changeList = { };
			_researchProgress = false;
			
			tooltipInstance.showApplyResearchBtn = false;
			*/
		}
		
		private function cancelResearch():void
		{
			/*
			_changeList = { };
			_researchProgress = false;
			
			detach();
			closeCallback();
			
			_attachedMutation.setFakeProgressValue( -1);
			
			tooltipInstance.showApplyResearchBtn = false;
			*/
		}
		
		private function updateSelectionInfo( resData : Object ) : void
		{
			/*
			if ( tooltipInstance )
			{
				tooltipInstance.setSelectedResourceData( resData );
			}
			
			if ( resData.used < resData.required && resData.avaliableResources > 0 )
			{
				// #Y PROTO
				// Align button to the resource item renderer
				
				if (_selectedRes)
				{
					const BTN_PADDING_Y = 55;
					const BTN_PADDING_X = -20;
					const TF_PADDING_Y = 15;
					const TF_PADDING_X = 0;
					const PC_BTN_PADDING = 20;
					
					var localPos    : Point = new Point( _selectedRes.x, _selectedRes.y );
					var globalPos   : Point = _selectedRes.parent.localToGlobal( localPos );
					var curLocalPos : Point = globalToLocal( globalPos );
					var itemWidth   : Number = _selectedRes.mcHitArea.width;
					var itemHeight  : Number = _selectedRes.mcHitArea.height;
					
					btnResearch.x = curLocalPos.x + itemWidth / 2 + BTN_PADDING_X;
					btnResearch.y = curLocalPos.y + itemHeight + BTN_PADDING_Y;
					btnResearch.visible = true;
					
					btnResearchPC.x = btnResearch.x;
					btnResearchPC.y = btnResearch.y - PC_BTN_PADDING;
					btnResearchPC.visible = true;
					
					tfButtonLabel.x = curLocalPos.x + ( itemWidth - tfButtonLabel.textWidth ) / 2 + TF_PADDING_X;
					tfButtonLabel.y = btnResearch.y + TF_PADDING_Y;
					tfButtonLabel.visible = true;
				}
				else
				{
					btnResearch.visible = false;
					tfButtonLabel.visible = false;
					btnResearchPC.visible = false;
				}
			}
			else
			{
				btnResearch.visible = false;
				tfButtonLabel.visible = false;
				btnResearchPC.visible = false;
			}
		}
		*/
	}
	
	}
}
