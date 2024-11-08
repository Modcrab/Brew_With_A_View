package red.game.witcher3.menus.testmap
{
	import flash.display.MovieClip;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;
	import flash.text.TextField;
	import flash.geom.Vector3D;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	
	public class TestMenu extends CoreMenu
	{
		var lookAtPos : Vector3D = new Vector3D();
		var camYaw : Number = 0;
		var camPitch : Number  = 0;
		var camDistance : Number = 2;
		var sunYaw : Number = 0;
		var sunPitch : Number = 0;

		var entityTemplate : String;
		var environmentDefinition : String;

		public var tfCamera : TextField;

		public function TestMenu()
		{
			super();

			lookAtPos.x = 0;
			lookAtPos.y = 0;
			lookAtPos.z = 1;
			camYaw = 180;
			camPitch = 0;
			camDistance = 1;
			sunYaw = 0;
			sunPitch = 0;
		}
		
		override protected function get menuName():String
		{
			return "TestMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'test.entityTemplate',        [ handleSetEntityTemplate ] ) );
			dispatchEvent(new GameEvent(GameEvent.REGISTER, 'test.environmentDefinition', [ handleSetEnvironmentDefinition ] ) );

			registerRenderTarget( "test_nopack", 1024, 1024 );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			SendCameraUpdate();
			SendSunUpdate();
			UpdateTextField();
		}

		protected function handleSetEntityTemplate( template : String )
		{
			trace("Minimap handleSetEntityTemplate [" + template + "]" );
			entityTemplate = template;
		}
		
		protected function handleSetEnvironmentDefinition( definition : String )
		{
			trace("Minimap handleSetEnvironmentDefinition [" + definition + "]" );
			environmentDefinition = definition;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var axisData:InputAxisData;
			var magnitude:Number;
			const DISTANCE_COEF : Number = 0.1;
			const ROTATION_COEF : Number = 4;

			if ( event.handled )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyDown:Boolean = (details.value == InputValue.KEY_DOWN);
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			switch(details.code)
			{
				case KeyCode.PAD_A_CROSS:
					if ( keyDown )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNextEntityTemplate' ) );
					}
					break;
				case KeyCode.PAD_B_CIRCLE:
					if ( keyDown )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNextAppearance' ) );
					}
					break;
	
				case KeyCode.PAD_X_SQUARE:
					if ( keyDown )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNextEnvironmentDefinition' ) );
					}
					break;
				case KeyCode.PAD_Y_TRIANGLE:
					break;
						
				// ditance & angles
				case KeyCode.PAD_LEFT_STICK_AXIS:
					{
						axisData = InputAxisData(details.value);
						camYaw   +=  axisData.xvalue * ROTATION_COEF;
						camPitch += -axisData.yvalue * ROTATION_COEF;
						camYaw   = NormalizeAngle( camYaw );
						camPitch = NormalizeAngle( camPitch );
						SendCameraUpdate();
					}
					break;
				case KeyCode.PAD_RIGHT_STICK_AXIS:
					{
						axisData = InputAxisData(details.value);
						camDistance += -axisData.yvalue * DISTANCE_COEF;
						camDistance = ClampDistance( camDistance );
						SendCameraUpdate();
					}
					break;

				// look at z
				case KeyCode.PAD_LEFT_SHOULDER:
					if (keyPress)
					{
						lookAtPos.z -= 0.1;
						SendCameraUpdate();
					}
					break;
				case KeyCode.PAD_RIGHT_SHOULDER:
					if (keyPress)
					{
						lookAtPos.z += 0.1;
						SendCameraUpdate();
					}
					break;

				// sun
				case KeyCode.PAD_DIGIT_LEFT:
					if (keyPress)
					{
						sunYaw  = NormalizeAngle( sunYaw - 10 );
						SendSunUpdate();
					}
					break;
				case KeyCode.PAD_DIGIT_RIGHT:
					if (keyPress)
					{
						sunYaw  = NormalizeAngle( sunYaw + 10 );
						SendSunUpdate();
					}
					break;
				case KeyCode.PAD_DIGIT_UP:
					if (keyPress)
					{
						sunPitch  = NormalizeAngle( sunPitch - 10 );
						SendSunUpdate();
					}
					break;
				case KeyCode.PAD_DIGIT_DOWN:
					if (keyPress)
					{
						sunPitch  = NormalizeAngle( sunPitch + 10 );
						SendSunUpdate();
					}
					break;

				case KeyCode.PAD_LEFT_TRIGGER:
					if (keyPress)
					{
					}
					break;
				case KeyCode.PAD_RIGHT_TRIGGER:
					if (keyPress)
					{
					}
					break;

				// exit
				case KeyCode.PAD_LEFT_STICK_DOWN:
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenuTemp' ) );
					return;
			}
			UpdateTextField();
		}
		
		protected function NormalizeAngle( angle : Number ) : Number
		{
			while ( angle < 0 )
				angle += 360;
			while ( angle >= 360 )
				angle -= 360;
			return angle;
		}
		
		protected function ClampDistance( distance : Number ) : Number
		{
			if ( distance < 0.2 )
				distance = 0.2;
			else if ( distance > 10 )
				distance = 10;
			return distance;
		}
		
		protected function deg2rad( deg : Number ) : Number
		{
			return deg * Math.PI / 180;
		}
		protected function rad2deg( rad : Number ) : Number
		{
			return rad * 180 / Math.PI;
		}
		
		protected function SendCameraUpdate()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCameraUpdate', [ lookAtPos.x, lookAtPos.y, lookAtPos.z, camYaw, camPitch, camDistance ] ) );
		}
		
		protected function SendSunUpdate()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSunUpdate', [ sunYaw, sunPitch ] ) );
		}
		
		protected function UpdateTextField()
		{
			if ( tfCamera )
			{
				tfCamera.text = "LookAt    " + lookAtPos.x.toFixed(2) + "  " + lookAtPos.y.toFixed(2) + "  " + lookAtPos.z.toFixed(2) + "\n"
							  + "CamYaw    " + camYaw.toFixed(2) + "\n"
							  + "CamPitch  " + camPitch.toFixed(2) + "\n"
							  + "CamDist   " + camDistance.toFixed(2) + "\n"
							  + "SunYaw    " + sunYaw.toFixed(2) + "\n"
							  + "SunPitch  " + sunPitch.toFixed(2) + "\n"
							  + "Template  " + entityTemplate + "\n"
							  + "Enviro    " + environmentDefinition + "\n"
							  ;
								
								entityTemplate
								environmentDefinition
			
			}
		}

		protected function handleWhatever2( whatever : String )
		{
			trace("Minimap handleWhatever2 " + whatever );
		}
		
		private function handleArray( gameData:Object, index:int ):void
		{
			trace("Minimap handleArray " +  (gameData as Array).length );
			
			var staticMapPinData:StaticMapPinData;
			var dataArray:Array = gameData as Array
			if ( index > -1 )
			{
			}
			else if (gameData)
			{
				for each ( staticMapPinData in dataArray )
				{
					++index;
				}
			}
		}

	}
}
