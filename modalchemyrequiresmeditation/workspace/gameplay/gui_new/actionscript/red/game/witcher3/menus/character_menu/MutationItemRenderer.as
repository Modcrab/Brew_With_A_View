package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.TooltipAnchor;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListPreset;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationItemRenderer
	 * @author Getsevich Yaroslav
	 */
	public class MutationItemRenderer extends SlotBase
	{
		const DISABLED_ALPHA_COLOR = .7;
		const DISABLED_ALPHA_ICON = .3;
		
		protected static const COLOR_MAP : Object = [ { color : "yellow", id_list : [1, 7, 11, 12, 9, 5] },
											   { color : "red", id_list : [3, 8] },
											   { color : "green", id_list : [4, 10] },
											   { color : "blue", id_list : [2, 6] },
											 ];
		protected const MAX_PROGRESS = 100;
		
		// only after manual changes
		public static var TRIGGER_EQUIP_FX:Boolean = false;
		public static var TRIGGER_UNEQUIP_FX:Boolean = false;
		public static var TRIGGER_RESEARCHED_ID_FX:int = -1;
		
		public var tfMutationName:TextField;
		public var tfTempText:TextField;
		
		public var mcFakeProgressbar:StatusIndicator;
		public var mcProgressbar:StatusIndicator;
		public var mcMutagenColor:MovieClip;
		public var mcIconBackground:MovieClip;
		public var mcEquippedIndicator:MovieClip;
		public var mcFlashAnimation:MovieClip;
		public var mcMutagenColorAnim:MovieClip;
		public var mcEquippedBkg:MovieClip;
		public var mcResearchCompleteAnim:MovieClip;
		
		private var _mutationId:int;
		private var _slotNavigationId:int;
		private var _firstDataUpdate:Boolean;
		protected var _blocked:Boolean;
		protected var _tooltipAnchorName:String;
		protected var _tooltipAnchorComponent:TooltipAnchor;
		
		// upgrades
		protected var _renderersContainer:Sprite;
		public var mcProgressList:SlotsListPreset;
		public var mcMutationResource1:MutationProgressItemRenderer;
		public var mcMutationResource2:MutationProgressItemRenderer;
		public var mcMutationResource3:MutationProgressItemRenderer;
		public var mcMutationResource4:MutationProgressItemRenderer;
		
		protected var _connectorsList:Vector.<MutationConnector>;
		
		public function MutationItemRenderer()
		{
			_firstDataUpdate = true;
			
			if (tfMutationName)
			{
				tfMutationName.visible = false;
			}
			
			_connectorsList = new Vector.<MutationConnector>;
			addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
			
			if (mcMutagenColorAnim)
			{
				mcMutagenColorAnim.visible = false;
			}
		}
		
		public function addConnector( value : MutationConnector ):void
		{
			_connectorsList.push(value);
			updateConnectors();
		}
		
		[Inspectable(name = "tooltipAnchorName")]
		public function get tooltipAnchorName():String { return _tooltipAnchorName; }
		public function set tooltipAnchorName(value:String):void
		{
			_tooltipAnchorName = value;
			
			if (_tooltipAnchorName && parent)
			{
				_tooltipAnchorComponent = parent.getChildByName( _tooltipAnchorName ) as TooltipAnchor;
			}
		}
		
		public function getTooltipAnchorComponent():TooltipAnchor
		{
			return _tooltipAnchorComponent;
		}
		
		override public function getSlotRect():Rectangle
		{
			if (mcStateSelectedActive)
			{
				var selSize   : Number;
				var widthSize : Number;
				var textWidth : Number;
				
				if (tfMutationName)
				{
					textWidth = tfMutationName.textWidth;
					//textWidth = 0; // ignore for now
				}
				
				selSize = mcStateSelectedActive.width;
				widthSize = Math.max(textWidth , selSize );
				
				return new Rectangle( -widthSize / 2, -selSize / 2, widthSize, selSize );
			}
			
			return super.getSlotRect();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (mcEquippedIndicator)
			{
				mcEquippedIndicator.visible = false;
			}
			
			if (mcIconBackground)
			{
				mcEquippedBkg = mcIconBackground.getChildByName("mcEquipped") as MovieClip;
				
				if (mcEquippedBkg)
				{
					mcEquippedBkg.visible = false;
				}
			}
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			updateMutationData();
		}
		
		public function setFakeProgressValue(value:Number):void
		{
			if (!mcFakeProgressbar)
			{
				return;
			}
			
			if (value >= 0)
			{
				mcFakeProgressbar.maximum = MAX_PROGRESS;
				mcFakeProgressbar.value = (_data.usedResourcesCount + value) / _data.requaredResourcesCount * 100;
				mcFakeProgressbar.visible = true;
			}
			else
			{
				mcFakeProgressbar.visible = false;
			}
		}
		
		protected function handleEnterFrame(event:Event):void
		{
			if (mcMutagenColorAnim && mcMutagenColorAnim.visible && _data && _data.researchCompleted)
			{
				mcMutagenColorAnim.rotation += .5;
			}
		}
		
		protected function updateMutationData()
		{
			const HIDE_ICON = true;
			
			if (_data)
			{
				trace("GFX MutationItemRenderer :: updateData", _data.mutationId, _data.overallProgress);
				
				if (mcProgressbar)
				{
					mcProgressbar.maximum = MAX_PROGRESS;
					mcProgressbar.value = _data.overallProgress;
					mcProgressbar.visible = false;
				}
				
				var colorId:String = getColorById( _data.mutationId );
				
				if (colorId != "")
				{
					if (mcMutagenColor)
					{
						mcMutagenColor.gotoAndStop( colorId );
						mcIconBackground.gotoAndStop( colorId );
						
						if (_imageLoader)
						{
							_imageLoader.alpha = 1;
						}
						
						if (mcMutagenColorAnim)
						{
							mcMutagenColorAnim.gotoAndStop( colorId );
						}
					}
					
					if (mcEquippedIndicator && mcEquippedIndicator["mcEquippedIndicator"])
					{
						mcEquippedIndicator["mcEquippedIndicator"].gotoAndStop(colorId);
						
					}
				}
				
				if (tfMutationName)
				{
					if (_data.name)
					{
						tfMutationName.text = _data.name;
					}
					else
					{
						tfMutationName.text = "";
					}
				}
				
				if ( mcMutagenColor  && !_data.enabled)
				{
					//mcMutagenColor.visible = true;
					//mcMutagenColor.alpha = _data.enabled ? 1 : .1;
					mcMutagenColor.gotoAndStop("gray");
					mcIconBackground.gotoAndStop("gray");
					
					if (mcMutagenColorAnim)
					{
						mcMutagenColorAnim.gotoAndStop( "gray" );
					}
					
					//mcMutagenColor.scaleX = mcMutagenColor.scaleY = _data.enabled ? 1 : 1;
				}
				
				var dataIsEquipped:Boolean =  _data.isEquipped;
				
				if (mcEquippedIndicator && mcEquippedIndicator.visible != dataIsEquipped)
				{
					GTweener.removeTweens(mcEquippedIndicator);
					
					if (dataIsEquipped)
					{
						mcEquippedIndicator.visible = true;
						mcEquippedBkg.visible = true;
						mcMutagenColor.scaleX = 1.15;
						mcMutagenColor.scaleY = 1.15;
						
						if (TRIGGER_EQUIP_FX)
						{
							TRIGGER_EQUIP_FX = false;
							mcEquippedIndicator.alpha = 0;
							mcEquippedIndicator.scaleX = mcEquippedIndicator.scaleY = .1;
							GTweener.to(mcEquippedIndicator, 1, { alpha:1, scaleX:1, scaleY:1 }, { ease:Exponential.easeOut } );
							mcFlashAnimation.gotoAndPlay("animation");
						}
						else
						{
							mcEquippedIndicator.alpha = 1;
							mcEquippedIndicator.scaleX = mcEquippedIndicator.scaleY = 1;
						}
					}
					else
					{
						if (TRIGGER_UNEQUIP_FX)
						{
							TRIGGER_UNEQUIP_FX = false;
							GTweener.to(mcEquippedIndicator);
							GTweener.to(mcEquippedIndicator, 0.3, { alpha:0, scaleX:.1, scaleY:.1 }, { onComplete:handleUnequippedAnimation, ease:Exponential.easeIn } );
						}
						else
						{
							handleUnequippedAnimation();
						}
					}
					
				}
				
				if (!HIDE_ICON && _data.iconPath && _data.iconPath != "None")
				{
					// ???
				}
				else
				{
					if (mcHitArea)
					{
						addChild(mcHitArea);
					}
				}
				
				_firstDataUpdate = false;
				
				if (mcFakeProgressbar)
				{
					mcFakeProgressbar.visible = false;
				}
				
				if (mcMutagenColorAnim)
				{
					mcMutagenColorAnim.visible = _data.researchCompleted;
				}
				
				if (mcMutagenColor)
				{
					//mcMutagenColor.alpha = ( _data.canResearch || _data.researchCompleted ) ? 1 : DISABLED_ALPHA_COLOR;
					mcMutagenColor.alpha = _data.researchCompleted ? 1 : DISABLED_ALPHA_COLOR;
				}
				
				if (_imageLoader)
				{
					//_imageLoader.alpha = ( ( _data.canResearch || _data.researchCompleted ) && enabled ) ? 1 : DISABLED_ALPHA_ICON;
					_imageLoader.alpha = ( _data.researchCompleted && enabled ) ? 1 : DISABLED_ALPHA_ICON;
				}
				
				if (enabled && _data && _data.researchCompleted && _data.mutationId == TRIGGER_RESEARCHED_ID_FX )
				{
					if (mcResearchCompleteAnim)
					{
						mcResearchCompleteAnim.gotoAndPlay ("start");
						TRIGGER_RESEARCHED_ID_FX = -1;
					}
				}
				
				updateConnectors();
			}
		}
		
		protected function updateConnectors():void
		{
			var baseColor:String;
			
			if (_data && _data.enabled && !_blocked && _data.researchCompleted )
			{
				baseColor = getColorById( _data.mutationId );
			}
			else
			{
				baseColor = "gray";
			}
			
			var len:int = _connectorsList.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var curConnector:MutationConnector = _connectorsList[i];
				
				curConnector.alpha = _blocked ? .1 : 1;
				curConnector.color = baseColor;
			}
		}
		
		private function handleUnequippedAnimation(tw:GTween = null):void
		{
			mcEquippedIndicator.visible = false;
			mcMutagenColor.scaleX = 1;
			mcMutagenColor.scaleY = 1;
			mcEquippedBkg.visible = false;
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			if (tfMutationName)
			{
				tfMutationName.visible = _selected;
			}
		}
		
		override protected function handleIconLoaded(event:Event):void
		{
			super.handleIconLoaded(event);
			
			if (_imageLoader)
			{
				_imageLoader.x = mcIconBackground.x - _imageLoader.width / 2 ;
				_imageLoader.y = mcIconBackground.y - _imageLoader.height / 2 ;
				//_imageLoader.alpha = ( !_data || !_data.enabled ) ? 0.5 : 1;
				//_imageLoader.alpha = ( ( _data.canResearch || _data.researchCompleted ) && enabled ) ? 1 : DISABLED_ALPHA_ICON;
				_imageLoader.alpha = ( _data.researchCompleted && enabled ) ? 1 : DISABLED_ALPHA_ICON;
			}
			
			addChild(mcProgressbar);
			addChild(mcIconBackground);
			addChild(_imageLoader);
			addChild( mcProgressbar );
			addChild( mcFakeProgressbar );
			addChild(mcHitArea);
			
		}
		
		override protected function updateImageLoaderStates():void
		{
			//
		}
		
		override protected function loadIcon(iconPath:String):void
		{
			super.loadIcon(iconPath);
			//_imageLoader.visible = false;
		}
		
		override protected function canExecuteAction():Boolean
		{
			return false;
		}
		
		override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent : MouseEventEx = event as MouseEventEx;
			
			if (_data && superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				fireActionEvent(_data.actionType);
			}
		}
		
		public static function getColorById(id:int):String
		{
			for each ( var curDataItem:Object in COLOR_MAP )
			{
				var dataList:Array = curDataItem.id_list as Array;
				
				if (dataList && dataList.indexOf(id) > -1)
				{
					return curDataItem.color;
				}
			}
			
			return "";
		}
		
		[Inspectable(defaultValue = "0")]
		public function get mutationId():int { return _mutationId; }
		public function set mutationId(value:int):void
		{
			_mutationId = value;
		}
		
		[Inspectable(defaultValue = "0")]
		public function get slotNavigationId():int { return _slotNavigationId; }
		public function set slotNavigationId(value:int):void
		{
			_slotNavigationId = value;
		}
		
		public function get blocked():Boolean { return _blocked; }
		public function set blocked(value:Boolean):void
		{
			_blocked = value;
			updateConnectors();
		}
		
	}

}
