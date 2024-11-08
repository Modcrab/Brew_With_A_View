package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.Math2;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.constants.NavigationCode;

	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;

	public class InteriorMap extends BaseMap
	{
		protected override function configUI():void
		{
			super.configUI();
		}

		private function Clear()
		{
		}

		override public function handleInput( event : InputEvent ) : void
		{
            if ( event.handled || !IsEnabled())
			{
				return;
			}
/*			
			//trace("GFX [HUB_MAP] handleInput ", event.details.code);

            var details : InputDetails = event.details;
            var keyDown : Boolean    = ( details.value == InputValue.KEY_DOWN );
            var keyUp : Boolean    = ( details.value == InputValue.KEY_UP );
            var keyPress : Boolean = ( details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD );
			
			var axisData			: InputAxisData;
			var magnitude			: Number;
			var magnitudeSquared	: Number;
			var magnitudeCubed		: Number;
			
			var zoomDir : int = 1;

            switch( details.code )
			{
				case KeyCode.PAD_A_CROSS:
					if ( keyDown )
					{
						UseSelectedPin();
					}
					break;
				case KeyCode.PAD_Y_TRIANGLE:
					if ( keyDown )
					{
						mcHubMapContainer.mcImageContainer._SwitchTextureLod();
					}
					break;
				case KeyCode.PAD_LEFT_THUMB:
					if ( keyUp )
					{
						CenterOnPlayer();
					}
					break;

				case KeyCode.PAD_DIGIT_UP:
					if ( keyPress )
					{
						scrollMap( 0, -_scrollCoef );
					}
                    break;

                case KeyCode.PAD_DIGIT_DOWN:
					if ( keyPress )
					{
						scrollMap( 0, _scrollCoef );
					}
                    break;
					
				case KeyCode.PAD_DIGIT_LEFT:
					if ( keyPress )
					{
						scrollMap( -_scrollCoef, 0 );
					}
                    break;
					
				case KeyCode.PAD_DIGIT_RIGHT:
					if ( keyPress )
					{
						scrollMap( _scrollCoef, 0 );
					}
                    break;

				case KeyCode.PAD_LEFT_STICK_AXIS:
					{
						axisData = InputAxisData( details.value );
						magnitude = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
						magnitudeSquared = magnitude * magnitude;
						magnitudeCubed = magnitude * magnitude * magnitude;
						var scrollValue : Number = Math.min( _scrollCoef, _scrollCoef * magnitudeSquared );
						scrollMap( -scrollValue * axisData.xvalue, scrollValue * axisData.yvalue );
					}
					break;
				
				case KeyCode.PAD_RIGHT_STICK_AXIS:
					{
						axisData = InputAxisData(details.value);
						magnitude = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
						magnitudeSquared = magnitude * magnitude;
						magnitudeCubed = magnitude * magnitude * magnitude;
						
						//var moveUp:Boolean = angle > 0 && angle < Math.PI;
						var angle:Number = InputUtils.getAngleRadians( axisData.xvalue, axisData.yvalue );
						var direction:InputDetails =  CommonUtils.convertAxisToNavigationCode(angle);
						if (direction.code == KeyCode.UP)
						{
							zoomMap( true );
						}
						else
						if (direction.code == KeyCode.DOWN)
						{
							zoomMap( false );
						}
					}
					return;
                default:
                    return;
            }
*/
			// Neccessary or else the selectedness state can stay on another item if going back and forth too fast
			// Apparently not enough to validate in the item changed event either.
			//validateNow();
           // event.handled = true;
		}
		
	}
}
