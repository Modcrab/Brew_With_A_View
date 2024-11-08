package red.game.witcher3.hud.modules.dialog
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.constants.InvalidationType;
	import red.game.witcher3.utils.motion.TweenEx;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import fl.transitions.easing.Strong;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import red.game.witcher3.controls.W3ScrollingList;
	import flash.events.Event;
	import scaleform.clik.ui.InputDetails;

	public class Option extends ListItemRenderer implements IListItemRenderer
	{
		public static var ALTERNATIVE_ARROW_SKIN:Boolean = false;
		
		private const DEFAULT_WIDTH:Number = 540;
		
		public var mcActionIcon:MovieClip;
		public var mcActionIconSmall:MovieClip;
		public var mcArrowPointer:MovieClip;
		public var mcShadow:MovieClip;
		public var mcSelectionBck:MovieClip;
		public var tfLine : TextField;
		public var mcHitTest : MovieClip;
		
		private var _isLocked  : Boolean = false;
		
		public function Option()
		{
			super();
			constraintsDisabled = true;
			preventAutosizing = true;
			
			tfLine.mouseEnabled = false;
		}
		
		public function get isLocked():Boolean { return _isLocked }
		public function set isLocked(value:Boolean):void 
		{ 
			_isLocked = value 
			mouseEnabled = !_isLocked;
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}

		override public function setData( data:Object ):void
		{
			trace("Minimap1 --------- SETDATA ", name );
			
			if ( data )
			{
				if (mcArrowPointer)
				{
					if ( ALTERNATIVE_ARROW_SKIN )
					{
						mcArrowPointer.mcArrowYellow.visible = false;
						mcArrowPointer.mcArrowBlue.visible   = true;
					}
					else
					{
						mcArrowPointer.mcArrowYellow.visible = true;
						mcArrowPointer.mcArrowBlue.visible   = false;
					}
				}
			}

			super.setData( data );

			updateTextLine();
			updateIcon();
			updateBck();
		}
		
		private function updateTextLine()
		{
			isLocked = false;

			if ( data )
			{
				//trace("Minimap1 UPDATETEXTLINE gamepad? [" + InputManager.getInstance().isGamepad() + "]" );
				if ( tfLine )
				{
					var prefix : String;
					if ( InputManager.getInstance().isGamepad() || CoreComponent.isArabicAligmentMode)
					{
						prefix = "";
					}
					else
					{
						prefix = data.prefix; // + ". "; (NGE - removing the dot from here)
					}
					
					if ( data.locked )
					{
						tfLine.textColor = 0xCC0000;
						isLocked = data.locked;
					}
					else if ( !data.read )
					{
						tfLine.textColor = 0xa7a7a7;
					}
					else if ( data.emphasis )
					{
						if (data.read)
						{
							tfLine.textColor = 0xd9b215;
						}
						else
						{
							tfLine.textColor = 0xa7a7a7;
						}
					}
					else
					{
						tfLine.textColor = 0xF2D6B7;
					}
					tfLine.htmlText =  prefix + data.name;	// NGE - made it htmlText so font size could be changed
					updateTextFieldSize();
				}
				//trace("Minimap1 UPDATETEXTLINE [" + prefix + "][" + data.name + "] ");
				trace("Minimap1 UPDATETEXTLINE [" + tfLine.htmlText + "]");
			}
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			mcArrowPointer.visible = value;
			mcSelectionBck.visible = value;
		}

		/*
		public function updateRendererSize():void
		{
			trace("Minimap1 === updateRendererSize ", name );
			
			updateText();
		}
		*/

		private function updateTextFieldSize():void
		{
			//trace("Minimap1 === updateTextFieldSize ", name );
			
			if (tfLine)
			{
				tfLine.width = DEFAULT_WIDTH;
				tfLine.height = tfLine.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				mcHitTest.x = tfLine.x;
				mcHitTest.y = tfLine.y;
				mcHitTest.height = tfLine.height;
				mcHitTest.width = tfLine.width;
			}
		}
		
		private function updateBck()
		{
			//trace("Minimap1 === updateBck ", name );
			
			if( label != "" )
			{
				mcShadow.alpha = 1;
			}
			else
			{
				mcShadow.alpha = 0;
			}

			if (tfLine.textWidth > 0)
			{
				mcShadow.width = tfLine.textWidth + 20;
			}
			else
			{
				mcShadow.width = 0;
			}
		}
		
		private function updateIcon()
		{
			//trace("Minimap1 === updateIcon ", name );
			
			if ( data && data.icon )
			{
				showIcon( data.icon );
			}
			else
			{
				showIcon( 0 );
			}
		}

		private function showIcon( dialogActionType:uint )
		{
			//trace("Minimap1 === showIcon ", name, dialogActionType );
			
			switch ( dialogActionType )
			{
				case 0:
					mcActionIcon.gotoAndStop( "NoIcon" );
					mcActionIconSmall.gotoAndStop("NoIcon");
					break;
				case DialogActionType.BRIBE:
					mcActionIcon.gotoAndStop( "Bribe" );
					mcActionIconSmall.gotoAndStop( "Bribe" );
					break;
				case DialogActionType.HOUSE:
					mcActionIcon.gotoAndStop( "House" );
					mcActionIconSmall.gotoAndStop( "House" );
					break;
				case DialogActionType.GAME_DICES:
					mcActionIcon.gotoAndStop( "DicePoker" );
					mcActionIconSmall.gotoAndStop( "DicePoker" );
					break;
				case DialogActionType.GAME_FIGHT:
					mcActionIcon.gotoAndStop( "FistFighting" );
					mcActionIconSmall.gotoAndStop( "FistFighting" );
					break;
				case DialogActionType.GAME_WRESTLE:
					mcActionIcon.gotoAndStop( "Armwrestling" );
					mcActionIconSmall.gotoAndStop( "Armwrestling" );
					break;
				case DialogActionType.SHOPPING:
					mcActionIcon.gotoAndStop( "Shop" );
					mcActionIconSmall.gotoAndStop( "Shop" );
					break;
				case DialogActionType.EXIT:
					mcActionIcon.gotoAndStop( "Exit" );
					mcActionIconSmall.gotoAndStop( "Exit" );
					break;
				case DialogActionType.GIFT:
					mcActionIcon.gotoAndStop( "Gift" );
					mcActionIconSmall.gotoAndStop( "Gift" );
					break;
				case DialogActionType.GAME_DRINK:
					mcActionIcon.gotoAndStop( "Drinking" );
					mcActionIconSmall.gotoAndStop( "Drinking" );
					break;
				case DialogActionType.GAME_DAGGER:
					mcActionIcon.gotoAndStop( "DaggerThrowing" );
					mcActionIconSmall.gotoAndStop( "DaggerThrowing" );
					break;
				case DialogActionType.SMITH:
					mcActionIcon.gotoAndStop( "Blacksmith" );
					mcActionIconSmall.gotoAndStop( "Blacksmith" );
					break;
				case DialogActionType.ARMORER:
					mcActionIcon.gotoAndStop( "Armorer" );
					mcActionIconSmall.gotoAndStop( "Armorer" );
					break;
				case DialogActionType.RUNESMITH:
					mcActionIcon.gotoAndStop( "Enchant" );
					mcActionIconSmall.gotoAndStop( "Enchant" );
					break;
				case DialogActionType.TEACHER:
					mcActionIcon.gotoAndStop( "Teacher" );
					mcActionIconSmall.gotoAndStop( "Teacher" );
					break;
				case DialogActionType.FAST_TRAVEL:
					mcActionIcon.gotoAndStop( "FastTravel" );
					mcActionIconSmall.gotoAndStop( "FastTravel" );
					break;
				case DialogActionType.AXII:
					mcActionIcon.gotoAndStop( "Axii" );
					mcActionIconSmall.gotoAndStop( "Axii" );
					break;
				case DialogActionType.SHAVING:
					mcActionIcon.gotoAndStop( "Shaving" );
					mcActionIconSmall.gotoAndStop( "Shaving" );
					break;
				case DialogActionType.HAIRCUT:
					mcActionIcon.gotoAndStop( "Haircut" );
					mcActionIconSmall.gotoAndStop( "Haircut" );
					break;
				case DialogActionType.GAME_CARDS:
					mcActionIcon.gotoAndStop( "CardGame" );
					mcActionIconSmall.gotoAndStop( "CardGame" );
					break;
				case DialogActionType.BET:
					mcActionIcon.gotoAndStop( "Bet" );
					mcActionIconSmall.gotoAndStop( "Bet" );
					break;
				case DialogActionType.MONSTERCONTRACT:
					mcActionIcon.gotoAndStop( "MonsterContract" );
					mcActionIconSmall.gotoAndStop( "MonsterContract" );
					break;
				case DialogActionType.GETBACK:
					mcActionIcon.gotoAndStop( "GetBack" );
					mcActionIconSmall.gotoAndStop( "GetBack" );
					break;
				case DialogActionType.AUCTION:
					mcActionIcon.gotoAndStop( "Auction" );
					mcActionIconSmall.gotoAndStop( "Auction" );
					break;
					
				case DialogActionType.LEVELUP1:
					mcActionIcon.gotoAndStop( "EnchanterLvl1" );
					mcActionIconSmall.gotoAndStop( "EnchanterLvl1" );
					break;
				case DialogActionType.LEVELUP2:
					mcActionIcon.gotoAndStop( "EnchanterLvl2" );
					mcActionIconSmall.gotoAndStop( "EnchanterLvl2" );
					break;
				case DialogActionType.LEVELUP3:
					mcActionIcon.gotoAndStop( "EnchanterLvl3" );
					mcActionIconSmall.gotoAndStop( "EnchanterLvl3" );
					break;
					
				default:
					mcActionIcon.gotoAndStop( "NoIcon" );
					mcActionIconSmall.gotoAndStop("NoIcon");
					return;
			}

			if (data && data.emphasis)
			{
				mcActionIcon.visible = true;
				mcActionIconSmall.visible = false;
			}
			else
			{
				mcActionIconSmall.visible = true;
				mcActionIcon.visible = false;
			}
		}

		// #Y In Scaleform KeyCode.SPACE and KeyCode.ENTER have the same navEquivalent, so KeyCode.SPACE triggers ButtonClick event
		// For dialog options we ignore KeyCode.SPACE, to avoid conflicts with dialog skipping functionality
		override public function handleInput(event:InputEvent):void 
		{
            var details:InputDetails = event.details;
			
			if (details.navEquivalent == NavigationCode.ENTER && details.code == KeyCode.SPACE)
			{
				return;
			}
			else
			{
				super.handleInput(event);
			}
		}
		
		override public function get scaleX():Number 
		{
			return super.actualScaleX;
		}
		
		override public function get scaleY():Number 
		{
			return super.actualScaleY;
		}
		
	}

}
