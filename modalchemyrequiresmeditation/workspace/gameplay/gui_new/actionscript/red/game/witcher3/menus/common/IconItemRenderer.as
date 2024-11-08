package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import red.game.witcher3.controls.W3UILoader;
	import red.core.CoreComponent;

	public class IconItemRenderer extends W3DropDownItemRenderer
	{
		public var mcIconLoader 		: W3UILoader;
		public var mcSelectionHighlight : MovieClip;
		public var skipTextCentering 	: Boolean = false;
		public var headerColor			: MovieClip;
		public var crests				: MovieClip;

		protected var _activeSelectionEnabled : Boolean = true;
		public function set activeSelectionEnabled(value:Boolean):void
		{
			_activeSelectionEnabled = value;
			if (mcSelectionHighlight)
			{
				mcSelectionHighlight.visible = value;
			}
		}

		public function IconItemRenderer()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
		}

		override public function toString() : String
		{
			return "[W3 IconItemRenderer]"
		}

		override public function setData( data:Object ):void
		{
			if (! data )
			{
				return;
			}

			super.setData( data );
			if (data.iconPath && mcIconLoader)
			{
				mcIconLoader.source = "img://" + data.iconPath;
			}
			
			if (crests)
			{
				crests.gotoAndStop(data.questArea);
			}
			
			if (headerColor)
			{
				headerColor.gotoAndStop( 1 );
				switch(data.isStory)
				{
					case 0://Main Story Quests
						headerColor.gotoAndStop( "main" );
						break;
					case 1: //Main Quests
						headerColor.gotoAndStop( "main" );
						break;
					case 2://Secondary Quests
						headerColor.gotoAndStop( "secondary" );
						break;
					case 3://Witcher Contracts
						headerColor.gotoAndStop( "contract" );
						break;
					case 4://Treasure Hunts
						headerColor.gotoAndStop( "treasurehunt" );
						break;
				}
			}

			if (selected)
			{
				if(data.id)
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnEntrySelected", [data.id]));
				}
				else if(data.tag)
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnEntrySelected", [data.tag]));
				}
			}
		}

		override public function handleEntryPress() : void
		{
			if (data)
			{
				if ( data.tag )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnEntryPress", [data.tag] ));
				}
			}
		}
		
		override protected function handleMouseRollOver(event:MouseEvent):void {
			setState("over");
		}
		
		override protected function handleMouseRollOut(event:MouseEvent):void {
			setState("up");
		}

		override protected function draw():void
		{
			super.draw();

			if (mcSelectionHighlight)
			{
				mcSelectionHighlight.visible = _activeSelectionEnabled;
			}
		}

		const SINGLE_TF_ONE_LINE:Number = 18;
		const TF1_SINGLE_LINE_TEXT_POS:Number = 14;
		const TF1_MULTI_LINE_TEXT_POS:Number = 6;
		const TF2_SINGLE_LINE_TEXT_POS:Number = 45;
		const TF2_MULTI_LINE_TEXT_POS:Number = 55;

		//overriding this coz the base function doesn't use htmlText which doesn't allow us to employ colors
        override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
                textField.htmlText = _label;
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;

				var isMultiLine:Boolean = textField.height > 35;
				var isDoubleTextField:Boolean = tfSecondLine && tfSecondLine.visible && tfSecondLine.htmlText != "";

				if ( isMultiLine )
				{
					textField.y = TF1_MULTI_LINE_TEXT_POS;
				}
				else
				{
					if (!isDoubleTextField)
					{
						textField.y = SINGLE_TF_ONE_LINE;
					}
					else
					{
						textField.y = TF1_SINGLE_LINE_TEXT_POS;
					}
				}

				if (isDoubleTextField)
				{
					if (isMultiLine)
					{
						tfSecondLine.y = TF2_MULTI_LINE_TEXT_POS;
					}
					else
					{
						tfSecondLine.y = TF2_SINGLE_LINE_TEXT_POS;
					}
				}
				if ( CoreComponent.isArabicAligmentMode )
				{
					textField.htmlText = "<p align=\"right\">" + _label+"</p>";
				}
            }
        }
	}

}
