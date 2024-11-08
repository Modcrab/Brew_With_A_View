package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Bounce;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.MutationResourceType;
	import red.game.witcher3.constants.TooltipAlignment;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.controls.TooltipAnchor;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.menus.character.MutationTooltipTitle;
	import red.game.witcher3.slots.SlotsListPreset;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationTooltip
	 * @author Getsevich Yaroslav
	 */
	public class MutationTooltip extends UIComponent
	{
		protected const TXT_DESCRIPTION_PADDING : Number = 10;
		protected const TXT_LIST_PADDING		: Number = 20;
		protected const BK_PADDING 				: Number = 4;
		protected const BLOCK_PADDING 			: Number = 10;
		
		public var tfDescription : TextField;
		public var tfColorsTitle : TextField;
		
		public var mcRequaredResources  : MutationResourcePanel;
		public var mcMasterRequirements : MutationMasterRequirements;
		public var mcColorsList   		: RenderersList;
		public var mcRequirements 		: MutationRequirements;
		public var mcBackground   		: MovieClip;
		public var mcName         		: MutationTooltipTitle;
		
		public var mcButtonPanel : MutationTooltipButton;
		private var _textValue : String;
		private var _showApplyResearchBtn : Boolean;
		
		protected var _data   		 : Object;
		protected var _mode   		 : uint;
		protected var _anchor 		 : TooltipAnchor;
		protected var _currentHeight : Number = 0;
		
		public function MutationTooltip()
		{
			visible = false;
			mouseEnabled = mouseChildren = false;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			//mcButtonPanel.addEventListener(MouseEvent.CLICK, handleButtonPanelClick, false, 0, true);
		}
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			invalidateData();
		}
		
		public function get anchor():TooltipAnchor { return _anchor; }
		public function set anchor(value:TooltipAnchor):void
		{
			_anchor = value;
			invalidateData();
		}
		
		public function get currentHeight():Number { return _currentHeight; }
		public function set currentHeight(value:Number):void
		{
			_currentHeight = value;
		}
		
		public function get showApplyResearchBtn():Boolean { return _showApplyResearchBtn; }
		public function set showApplyResearchBtn(value:Boolean):void
		{
			if ( _showApplyResearchBtn != value )
			{
				_showApplyResearchBtn = value;
				populateData();
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if ( isInvalid( InvalidationType.DATA ) )
			{
				populateData();
			}
		}
		
		private function populateData():void
		{
			const DESCRIPTION_PADDING : Number = 8;
			currentHeight = 0;
			
			if ( !_data )
			{
				visible = false;
				return;
			}
			
			visible = true;
			mcName.visible = false;
			
			var placeNameOnTop : Boolean = true;
			
			if ( _anchor )
			{
				placeNameOnTop = _anchor.alignment == TooltipAlignment.BOTTOM_LEFT || _anchor.alignment == TooltipAlignment.BOTTOM_RIGHT;
			}
			
			if ( placeNameOnTop )
			{
				mcName.visible = true;
				mcName.y = 0;
				mcName.setText( _data.name );
				currentHeight += mcName.height;
			}
			
			var isMutationCompleted:Boolean = _data.overallProgress >= 100;
			
			// - DESCRIPTION -
			
			mcBackground.y = currentHeight;
			if (CoreComponent.isArabicAligmentMode)
			{
				tfDescription.htmlText = "<p align=\"right\">" + _data.description + "</p>";
			}
			else
			{
				tfDescription.htmlText = _data.description;
			}
			tfDescription.height = tfDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			tfDescription.y = mcBackground.y + DESCRIPTION_PADDING;
			currentHeight = tfDescription.y + tfDescription.height + BLOCK_PADDING;
			
			// - COLORS -
			
			if( !_data.isMasterMutation && data.colorsList )
			{
				tfColorsTitle.y = currentHeight;
				tfColorsTitle.visible = true;
				_textValue = "[[mutation_allow_equip_of]]";
				if (CoreComponent.isArabicAligmentMode)
				{
					tfColorsTitle.htmlText = "<p align=\"right\">" + _textValue + "</p>";
				}
				else
				{
					tfColorsTitle.text = _textValue;
					tfColorsTitle.text = CommonUtils.toUpperCaseSafe( tfColorsTitle.text );
				}
				
				
				currentHeight += tfColorsTitle.height;
				
				mcColorsList.dataList = data.colorsList;
				mcColorsList.validateNow();
				mcColorsList.y = currentHeight;
				mcColorsList.visible = true;
				currentHeight += ( mcColorsList.actualHeight + BLOCK_PADDING );
				if (CoreComponent.isArabicAligmentMode)
				{
					mcColorsList.x = mcBackground.x + mcBackground.width - mcColorsList.actualWidth;
				}
			}
			else
			{
				mcColorsList.visible = false;
				tfColorsTitle.visible = false;
			}
			
			// - REQUIREMENTS -
			
			if (_data.progressDataList && _data.enabled && !_data.researchCompleted)
			{
				currentHeight += BLOCK_PADDING;
				
				mcRequaredResources.visible = true;
				mcRequaredResources.data = _data.progressDataList;
				mcRequaredResources.y = currentHeight;
				
				currentHeight += mcRequaredResources.getListHeight();
				
				currentHeight += BLOCK_PADDING;
			}
			else
			{
				mcRequaredResources.y = 0;
				mcRequaredResources.visible = false;
			}
			
			if (_data.isMasterMutation && _data.lockedDescription)
			{
				mcMasterRequirements.text = _data.lockedDescription;
				mcMasterRequirements.visible = true;
				mcMasterRequirements.y = currentHeight;
				currentHeight += mcMasterRequirements.actualHeight;
			}
			else
			{
				mcMasterRequirements.visible = false;
				mcMasterRequirements.y = 0;
			}
			
			var requirementsList:Array = _data.requiredMutations as Array;
			
			if( !_data.enabled && requirementsList && requirementsList.length > 0 )
			{
				currentHeight += BLOCK_PADDING;
				mcRequirements.y = currentHeight;
				mcRequirements.setData( requirementsList );
				mcRequirements.visible = true;
				currentHeight +=  mcRequirements.actualHeight;
			}
			else
			{
				mcRequirements.visible = false;
			}
			
			// - MODE -
			
			if( _data.enabled && !_data.isMasterMutation )
			{
				mcButtonPanel.filters = [];
				mcButtonPanel.alpha = 1;
				
				if ( isMutationCompleted )
				{
					mcButtonPanel.setType( data.isEquipped ? MutationTooltipButton.TYPE_UNEQUIP : MutationTooltipButton.TYPE_EQUIP );
				}
				else
				{
					mcButtonPanel.setType( MutationTooltipButton.TYPE_START_RESEARCH );
					
					if ( !_data.canResearch )
					{
						mcButtonPanel.filters = [ CommonUtils.generateDesaturationFilter( .1 ) ];
						mcButtonPanel.alpha = .2;
					}
				}
				
				mcButtonPanel.y = currentHeight;
				mcButtonPanel.visible = true;
				
				addChild(mcButtonPanel);
				currentHeight += mcButtonPanel.height;
			}
			else
			{
				mcButtonPanel.visible = false;
			}
			
			// - BK -
			
			if ( mcName.visible)
			{
				mcBackground.height = currentHeight - mcName.height + BK_PADDING;
			}
			else
			{
				mcBackground.height = currentHeight + BK_PADDING;
			}
			
			if ( !placeNameOnTop )
			{
				mcName.visible = true;
				mcName.y = currentHeight;
				mcName.setText( _data.name );
			}
			
			if ( mcName && _anchor )
			{
				if ( anchor.alignment == TooltipAlignment.BOTTOM_LEFT || anchor.alignment == TooltipAlignment.TOP_LEFT )
				{
					mcName.x = mcBackground.x + mcBackground.width - mcName.actualWidth;
				}
				else
				if ( anchor.alignment == TooltipAlignment.BOTTOM_RIGHT || anchor.alignment == TooltipAlignment.TOP_RIGHT )
				{
					mcName.x = 0;
				}
			}
		}
		
	}
}
