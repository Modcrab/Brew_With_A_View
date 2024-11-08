package red.core.data
{
	import red.core.utils.InputUtils;
	
	public class InputAxisData 
	{
		public var xvalue:Number;
		public var yvalue:Number;
		
		public function InputAxisData( xvalue:Number, yvalue:Number ) 
		{
			this.xvalue = xvalue;
			this.yvalue = yvalue;
		}
		
		public function toString():String
		{
			return "";
			/*
			var magnitude:Number = InputUtils.getMagnitude( xvalue, yvalue );
			var angleRadians:Number = InputUtils.getAngleRadians( xvalue, yvalue );
			var angleDegrees:Number = InputUtils.radiansToDegrees( angleRadians );
			
			return "[Core InputAxisData: xvalue = " + xvalue + ", yvalue = " + yvalue + "( magnitude = " + magnitude + ", angleRad = " + angleRadians + ", angleDeg = " + angleDegrees + " )]";
			*/
		}
	}
}
