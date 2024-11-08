/***********************************************************************/
/** Action Script file - controlling meditation clock
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent; //@FIXME BIDON -> remove it (or integrate mouse to everything)
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	
	import scaleform.clik.constants.InputValue; //#B
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	
	public class Clock extends UIComponent
	{
		static var DAWN : int = 6;
		static var NOON : int = 12;
		static var DUSK : int = 18;
		static var NITE : int = 24;
		
		public var CurrentTimeHours : int;
		public var CurrentTimeMinutes : int;
		
		public var lbName : TextField;
		public var lbTimeCurrent : TextField;
		public var lbDuration : TextField;
		public var lbCurrentHours : TextField;
		
		public var fxArrow : MovieClip;
		public var fxCircle : MovieClip;
		
		public var fxButtonN : MovieClip;
		public var fxButtonE : MovieClip;
		public var fxButtonS : MovieClip;
		public var fxButtonW : MovieClip;
		
		public var m_tfDusk : TextField;
		public var m_tfNoon : TextField;
		public var m_tfDawn : TextField;
		public var m_tfMidnight : TextField;
		
		public var fxActiveIconN : MovieClip;
		public var fxPassiveIconN : MovieClip;
		public var fxActiveIconE : MovieClip;
		public var fxPassiveIconE : MovieClip;
		public var fxActiveIconS : MovieClip;
		public var fxPassiveIconS : MovieClip;
		public var fxActiveIconW : MovieClip;
		public var fxPassiveIconW : MovieClip;
		
		public var fxIconN : MovieClip;
		public var fxIconE : MovieClip;
		public var fxIconS : MovieClip;
		public var fxIconW : MovieClip;
		
		public var m_mcLabelDawn : MovieClip;
		public var m_mcLabelDusk : MovieClip;

		
		public var mcCurrentTime : MovieClip;
		
		private var baseArc : int;
		
		//private var ctx : int;
		private var val : int; //@FIXME BIDON -> variable "val" ? change name to more descriptive one
		private var timeSelected : Number;
		private var dayHour : int; //@FIXME BIDON -> _DayHour
		private var dayMinutes : int; //@FIXME BIDON -> _DayMinutes
		
		public var bHandleInput :Boolean = true;
		
		public function Clock()
		{
			//fxCircle.addEventListener(MouseEvent.MOUSE_OVER, setMsMove, false, 0, false);
			//fxCircle.onRollOver = Delegate.create (this, setMsMove);
			//fxCircle, addEventListener(MouseEvent.MOUSE_OUT, remMsMove, false, 0, false);
			//fxCircle.onRollOut = Delegate.create (this, remMsMove);
			
			//fxCircle.onReleaseOutside = Delegate.create (this, remMsMove);
			
			// change to listeners
			fxButtonN.addEventListener(MouseEvent.CLICK, onClick, false, 0, false);
			fxButtonN.addEventListener(MouseEvent.DOUBLE_CLICK, onUse, false, 0, false);
			fxButtonE.addEventListener(MouseEvent.CLICK, onClick, false, 0, false);
			fxButtonE.addEventListener(MouseEvent.DOUBLE_CLICK, onUse, false, 0, false);
			fxButtonS.addEventListener(MouseEvent.CLICK, onClick, false, 0, false);
			fxButtonS.addEventListener(MouseEvent.DOUBLE_CLICK, onUse, false, 0, false);
			fxButtonW.addEventListener(MouseEvent.CLICK, onClick, false, 0, false);
			fxButtonW.addEventListener(MouseEvent.DOUBLE_CLICK, onUse, false, 0, false);
			
			addEventListener('mouseMove', onMouseMove, false, 0, false);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.hours', [OnSetCurrentDayHours]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.minutes', [OnSetCurrentDayMinutes]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.blocked', [OnBlockClock]));
			dispatchEvent( new GameEvent(GameEvent.CALL,'OnGetCurrentDayTime' ));
		}
		
		function OnSetCurrentDayHours( value : int )
		{
			dayHour = value;
			CurrentTimeHours = dayHour;
			CurrentTimeMinutes = dayMinutes;
			
			lbCurrentHours.text = String( CurrentTimeHours );
			
			baseArc = (180 + (CurrentTimeHours) * (360 / 24) + (CurrentTimeMinutes) * (360 / 24 / 60)) % 360;

			fxCircle.fxClip.rotation = baseArc;

			var iMinutesInDay:int = 24 * 60;
			var iCurrentMinuteInDay:int = CurrentTimeHours * 60 + CurrentTimeMinutes;
			
			mcCurrentTime.rotationZ = baseArc;
			if ( bHandleInput )
			{
				setSelection(((12 + CurrentTimeHours) / 24) * 360 +1 );
			}
		}
		
		function OnSetCurrentDayMinutes( value : int )
		{
			dayMinutes = value;
		}
		
		function OnBlockClock( value : Boolean )
		{
			bHandleInput = value;
		}
		
		private function onMouseMove (event:Event = null) : void
		{
			if ( bHandleInput )
			{
				if (Math.sqrt (fxCircle.mouseX * fxCircle.mouseX + fxCircle.mouseY * fxCircle.mouseY) < 150)
				{
					var l : Number = (360 + 90 + (Math.atan2 (fxCircle.mouseY, fxCircle.mouseX) * 180 / Math.PI)) % 360
					
					setSelection (l);
				}
			}
		}
		
		private function setSelection (v) : void
		{
			if (v < 0)
			{
				v += 360;
			}
			if ( v >= 360 )
			{
				v-= 360
			}
			
			val = (360 + (v - baseArc)) % 360;
			
			// Pre-constrain the range to fix bug #767.
			// Otherwise you update the duration text before the Flash VM constrains the range for you,
			// if you cross over into a negative range and then are just about to switch back to a positive one.
			// See MovieClip._rotation in the AdobeDocs for details.

			lbDuration.text = ((Math.floor((v * 24 / 360) + 12) % 24)).toString ();
			timeSelected = Number( lbDuration.text );
			//trace('lbDuration text '+((Math.floor((v * 24 / 360) + 12) % 24)).toString ());
			
			
			fxCircle.fxIconN.visible = false;
			fxCircle.fxIconE.visible = false;
			fxCircle.fxIconS.visible = false;
			fxCircle.fxIconW.visible = false;
			
/*			fxActiveIconN.visible = false;
			fxActiveIconE.visible = false;
			fxActiveIconS.visible = false;
			fxActiveIconW.visible = false;*/
			
			m_mcLabelDawn.m_tfDawn.textColor = 0xDADADA;
			m_mcLabelDusk.m_tfDusk.textColor = 0xDADADA;
			m_tfMidnight.textColor = 0xDADADA;
			m_tfNoon.textColor = 0xDADADA;
			
			fxArrow.rotation = v;
			
			var off : int = 0;
			
			var v1 : int = off + baseArc | 0;
			var v2 : int = off + v | 0;
			
			if (v1 < v2)
			{
				if (v1 < off && v2 > off) fxCircle.fxIconN.visible = true;
				if (v1 < off + 90 && v2 > off + 90) fxCircle.fxIconE.visible = true;
				if (v1 < off + 180 && v2 > off + 180) fxCircle.fxIconS.visible = true;
				if (v1 < off + 270 && v2 >= off + 270) fxCircle.fxIconW.visible = true;
			}
			else
			{
				
				fxCircle.fxIconN.visible = true;
				fxCircle.fxIconE.visible = true;
				fxCircle.fxIconS.visible = true;
				fxCircle.fxIconW.visible = true;
				
				if (v2 < off && v1 > off) fxCircle.fxIconN.visible = false;
				if (v2 < off + 90 && v1 > off + 90) fxCircle.fxIconE.visible = false;
				if (v2 < off + 180 && v1 >= off + 180) fxCircle.fxIconS.visible = false;
				if (v2 < off + 270 && v1 > off + 270) fxCircle.fxIconW.visible = false;
			}
			
			//fxCircle.fxRing.fxAnim.gotoAndStop ((100 * val / 360 | 0))
			/*fxCircle.fxClip.graphics.beginFill (0);*/ //#B FIXME Check why this doesn't work
			DrawPie(fxCircle.fxClip, val, 175);
			//Graphics.drawPie (fxCircle.fxClip, val, 175);
			
			if ( v >= 315 && v < 360 )
			{
				//fxActiveIconN._visible = Boolean (1);
				m_tfNoon.textColor = 0x6098AF;
			}
			if ( v >= 0 && v < 45 )
			{
				//fxActiveIconN._visible = Boolean (1);
				m_tfNoon.textColor = 0x6098AF;
			}
			else if ( v < 315 && v >= 225 )
			{
				//xActiveIconW._visible = Boolean (1);
				m_mcLabelDawn.m_tfDawn.textColor = 0x6098AF;
			}
			else if ( v >= 135 && v < 225 )
			{
				//fxActiveIconS._visible = Boolean (1);
				m_tfMidnight.textColor = 0x6098AF;
			}
			else if (v >= -180 && v < -135 )
			{
				//fxActiveIconS._visible = Boolean (1);
				m_tfMidnight.textColor = 0x6098AF;
			}
			
			else if ( v >= 45 && v < 135 )
			{
				//fxActiveIconE._visible = Boolean (1);
				m_mcLabelDusk.m_tfDusk.textColor = 0x6098AF;
			}
		}
		
		public function onUse () : void
		{
			if ( bHandleInput )
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnMeditate', [timeSelected] )); //
			}
		}
		
		private function onExit () : void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, 'OnCloseMenu'));
		}
		
		private function onClick () : void 
		{
			if ( bHandleInput )
			{
				onUse ();
			}
		}
		
		private function DrawPie(o : MovieClip, arc : Number, radius : Number): void // , style : Object) //@FIXME BIDON -> this function works ?
		{
			var l : Number = Math.ceil (arc / 45);
			var angle : Number = - .5 * Math.PI;
			var theta : Number = (arc / l / 180) * Math.PI;
			
			var sX : Number = radius - Math.cos (angle) * radius;
			var sY : Number = 0 - Math.sin (angle) * radius;

			//o.clear ();
			//o.beginFill (0)
			//o.moveTo (0, - radius);
//
			//for (var j : Number = 0; j < l; ++ j)
			//{
				//angle += theta;
//
				//o.curveTo (
					//sX + Math.cos (angle - (theta / 2)) * (radius / Math.cos (theta / 2)) - radius,
					//sY + Math.sin (angle - (theta / 2)) * (radius / Math.cos (theta / 2)) - radius,
					//sX + Math.cos (angle) * radius - radius,
					//sY + Math.sin (angle) * radius - radius)
			//}
			//
			//o.lineTo (0, 0)
		}
		
		override public function handleInput( event:InputEvent ):void //#B
		{
			if ( bHandleInput )
			{
				var details:InputDetails = event.details;
				var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
				
				var axisData:InputAxisData;
				var xvalue:Number;
				var yvalue:Number;
				var magnitude:Number;
				var magnitudeCubed:Number;
				var angleRadians:Number;

				switch( details.code )
				{
					case KeyCode.PAD_LEFT_STICK_AXIS:
					{
						axisData = InputAxisData(details.value);
						xvalue = axisData.xvalue;
						yvalue = axisData.yvalue;
						magnitude = InputUtils.getMagnitude( xvalue, yvalue );
						magnitudeCubed = magnitude * magnitude * magnitude;
						angleRadians = InputUtils.getAngleRadians( xvalue, yvalue );
						
						if ( magnitude < 0.5 )
						{
							break;
						}

						var angle : Number = (360 + 90 - (angleRadians * 180 / Math.PI)) % 360;
					
						setSelection (angle);
						event.handled = true;
						break;
					}
					case KeyCode.PAD_A_CROSS:
					{
						if ( keyPress )
						{
							onUse();
							event.handled = true;
							event.stopImmediatePropagation();
						}
						break;
					}
					default:
						return;
				}
			}
		}
	}
}