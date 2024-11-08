package red.core.utils
{
	public class InputUtils 
	{		
		public static function toggleAnalogInput( value:Boolean ):void
		{
			// TBD: Toggle the engine sending analog events to flash.
		}
		
		public static function getAngleRadians( x:Number, y:Number ):Number
		{
			var angleRadians:Number = Math.atan2( y, x );
			
			// bring into the range [0, 2*pi)
			if ( angleRadians < 0. )
			{
				angleRadians += 2 * Math.PI;
			}
			
			return angleRadians;
		}
		
		public static function getMagnitudeSquared( x:Number, y:Number ):Number
		{
			return x * x + y * y;
		}
		
		public static function getMagnitude( x:Number, y:Number ):Number
		{
			return Math.sqrt( x * x + y * y );
		}
		
		public static function radiansToDegrees( angleRadians:Number ):Number
		{
			return angleRadians * 180. / Math.PI;
		}
		
		public static function degreesToRadians( angleDegrees:Number ):Number
		{
			return angleDegrees * Math.PI / 180.;
		}
	}
}