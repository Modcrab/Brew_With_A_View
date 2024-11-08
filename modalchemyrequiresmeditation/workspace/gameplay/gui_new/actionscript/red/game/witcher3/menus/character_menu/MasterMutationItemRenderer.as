package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	
	/**
	 * red.game.witcher3.menus.character_menu.MasterMutationItemRenderer
	 * @author Getsevich Yaroslav
	 */
	public class MasterMutationItemRenderer extends MutationItemRenderer
	{
		private const MUTATION_STATE_FRAME_OFFSET:int = 5;
		private const TEXT_PADDING = 15;
		
		public var tfState 				 : TextField;
		public var tfAdditionalState 	 : TextField;
		public var tfMutationDescription : TextField;
		
		public var mcStateBackground:MovieClip;
		public var mcLevelBackground:MovieClip;
		public var mcIconLock:MovieClip;
		
		public var mcMutationBackground:MovieClip;
		public var mcMutationAnimation:MovieClip;
		public var mcDescriptionBackground:MovieClip;
		public var mcTitleBackground:MovieClip;
		
		private var _mcColorOverlay:MovieClip;
		private var _mcColorBackground:MovieClip;
		private var _equippedMutationData:Object;
		private var _color:String;

		
		private var _standalone:Boolean;
		
		function MasterMutationItemRenderer()
		{
			super();
			
			_mcColorOverlay = mcMutationAnimation.mcAnimation.mcColor;
			_mcColorBackground = mcMutationAnimation.mcAnimation.background;
			
			mouseChildren = false;
		}
		
		public function setColorByMutationId(id:int):void
		{
			var colorMut:String = getColorById( id );
			
			_color = colorMut;
			_mcColorOverlay.gotoAndStop(colorMut);
			_mcColorBackground.gotoAndStop(colorMut);
			
			updateConnectors();
		}
		
		public function resetColor():void
		{
			_color = "";
			_mcColorOverlay.gotoAndStop(1);
			_mcColorBackground.gotoAndStop(1);
			
			updateConnectors();
		}
		
		public function hideDescription(value:Boolean):void
		{
			tfState.visible = !value;
			tfMutationDescription.visible = !value;
			mcDescriptionBackground.visible = !value;
			mcTitleBackground.visible = !value;
		}
		
		public function setEquippedMutationData(value:Object):void
		{
			_equippedMutationData = value;
			updateMutationData();
		}
		
		override protected function updateConnectors():void
		{
			var baseColor:String;
			
			if (_color && _color != "default" && !_blocked)
			{
				baseColor = _color;
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
		
		override protected function updateMutationData()
		{
			trace("Minimap2 -------------------- updateMutationData ", _data, _equippedMutationData);
			
			if (_data)
			{
				if (mcProgressbar)
				{
					mcProgressbar.maximum = MAX_PROGRESS;
					mcProgressbar.value = _data.overallProgress;
				}
				
				if (mcMutationAnimation && _data.stage)
				{
					mcMutationAnimation.gotoAndPlay("state" + _data.stage);
				}
				
				if (tfState)
				{
					if (_equippedMutationData)
					{
						tfState.text = _equippedMutationData.name;
					}
					else
					{
						tfState.text = _data.stageLabel;
					}
				}
				
				trace("GFX [MasterMutationItemRenderer] [ at menu ? ", ((mcIconLock != null) ? "YES" : "NO"), "! ] ", tfAdditionalState, mcStateBackground, _data.stageNumbLabel);
				
				if ( tfAdditionalState )
				{
					if (_data.stageNumbLabel)
					{
						tfAdditionalState.text = _data.stageNumbLabel;
						tfAdditionalState.visible = true;
						
						mcIconLock.visible = true;
						
						if (mcIconLock)
						{
							mcIconLock.visible = false;
						}
						
					}
					else
					{
						tfAdditionalState.visible = false;
						
						if (mcIconLock)
						{
							mcIconLock.visible = true;
						}
					}
				}
				
				if (mcTitleBackground && tfState)
				{
					mcTitleBackground.x = tfState.x + (tfState.width - tfState.textWidth) - TEXT_PADDING;
					mcTitleBackground.width = tfState.textWidth + TEXT_PADDING * 2;
				}
				
				if (tfMutationDescription && _equippedMutationData)
				{
					tfMutationDescription.htmlText = _equippedMutationData.description;
					tfMutationDescription.y = -tfMutationDescription.textHeight / 2;
					tfMutationDescription.height = tfMutationDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				}
				
				if (mcDescriptionBackground && tfMutationDescription)
				{
					mcDescriptionBackground.y = tfMutationDescription.y - TEXT_PADDING;
					mcDescriptionBackground.width = tfMutationDescription.width + TEXT_PADDING ;
					mcDescriptionBackground.height = tfMutationDescription.textHeight + TEXT_PADDING * 2;
					
				}
				
			}
		}
		
		override protected function loadIcon(iconPath:String):void
		{
			// ignores
		}
		
		public function get standalone():Boolean { return _standalone; }
		public function set standalone(value:Boolean):void
		{
			_standalone = value;
		}
		
	}

}
