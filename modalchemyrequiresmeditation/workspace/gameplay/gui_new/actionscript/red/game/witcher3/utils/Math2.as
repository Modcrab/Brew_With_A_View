package red.game.witcher3.utils 
{
	import flash.geom.Point;
	
	public class Math2
	{
		public static var numeralArray:Array = new Array();
		public function Math2() 
		{
			
		}
		/*
		 * get radians from degrees
		 * */
		public static function degreesToRadians(degrees:Number):Number
		{
			var angleInRadians:Number = Math.PI * 2 * (degrees / 360);
			return angleInRadians;
		}
		/*
		 * get degrees from radians
		 * */
		public static function radiansToDegrees(radians:Number):Number 
		{
			var angleInDegrees:Number = radians * 180 / Math.PI;
			return angleInDegrees;
		}
		/*
		 * return value between min and max
		 * 
		 * */
		public static function between (value:Number,min:Number,max:Number):Number 
		{
			value=value>max?max:value;
			value = value < min? min:value;
			return value;
		}
		/**
		 * method returns rounded number with n signs after coma
		 * @param	value value to round
		 * @param	n - sings after coma
		 * @return return rounded number
		 */
		public static function round(value:Number,n:uint):Number
		{
			var zeroCounter:Number = Math.pow(10, n);
			var a:Number = Math.round(value * zeroCounter);
			var b:Number = a / zeroCounter;
			return b;
		}
		/**
		 * returns value between min and max when percent value is given
		 * @param	min- minimum value
		 * @param	max- maximum value
		 * @param	percent- percent between values
		 * @return 
		 */
		public static function getValueFromPercent(min:Number,max:Number,percent:Number):Number
		{
			var value:Number = (percent * (max - min) / 100) + min;
			return value;
		}
		//this method is inverse of getValueFromPercent
		public static function getPercentFromValue(min:Number,max:Number,value:Number):Number
		{
			if (max == min)
			{
				return 100;
			}
			var percent:Number = ((value-min) * 100) / (max - min);
			return percent;
		}
	
		public static function getPolymonialSolution(a:Number,b:Number,c:Number):Array
		{
			var del:Number = b * b - 4 * a * c;
			var x1:Number = ( -b + Math.pow(del, 0.5)) / (2 * a);
			var x2:Number = ( -b - Math.pow(del, 0.5)) / (2 * a);
			var values:Array = new Array(x1, x2);
			return values;
		}
		
		public static function getXInCircle(y:Number,r:Number,centerX:Number,centerY:Number):Number
		{
			var a:Number = 1;
			var b:Number = -2 * centerX;
			var c:Number = (y - centerY) * (y - centerY) -r * r +centerX * centerX;
			var solutions:Array = getPolymonialSolution(a, b, c);
			return solutions[0];
			
		}
		public static function getXFromCircleByAngle(r:Number,angle:Number):Number
		{
			var numerator:Number = r;
			var denominator:Number = 1 + Math.tan(Math2.degreesToRadians(angle))
			var fraction :Number = numerator / denominator;
			var myX:Number = Math.pow(Math.abs(fraction), 0.5);
			return myX;
		}
		/**
		 * replaces "." to "," return string
		 * @param	num - number
		 * @return string with ","
		 */
		public static function toCommaNumber(num:Number):String
		{
			var commaNumber:String = num.toString();
			var temp:Array = commaNumber.split(".");
			if (temp.length>0)
			{
				commaNumber = temp[0] + "," + temp[1];
			}
			return commaNumber;
		}
		/**
		 *  replaces "," to "." return NUmber
		 * @param	num - string with ","
		 * @return Number with "."
		 */
		public static function toDotNumber(num:String):Number
		{
			var dotNumber:Number;
			var temp:Array = num.split(",");
			if (temp.length>0)
			{
				dotNumber = Number(temp[0] + "." + temp[1]);
			}
			else
			{
				dotNumber = Number(num);
			}
			return dotNumber;
		}
		
		/**
		 * Get segment length between two points
		 * @param	p1 start point
		 * @param	p2 end point
		 * @return	length
		 */
		public static function getSegmentLength(p1:Point, p2:Point):Number
		{
			return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
		}

		/**
		 * Get squared segment length between two points
		 * @param	p1 start point
		 * @param	p2 end point
		 * @return	squared length
		 */
		public static function getSquaredSegmentLength(p1:Point, p2:Point):Number
		{
			return Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2);
		}

		/**
		 * get Angle between two points (you can use it when a hero must rotate with the mouse move)
		 * @param	p1 starting point (hero position)
		 * @param	p2 second point (mouse position)
		 * @return angle
		 */
		public static function getAngleBetweenPoints(p1:Point,p2:Point):Number
		{
			var dist_x:Number = p1.x - p2.x;
			var dist_y:Number = p1.y - p2.y;
			var value:Number = radiansToDegrees(Math.atan2( - dist_y, - dist_x)) + 90;
			return value;
		}
		/**
		 * Method saves names for numeral names
		 * @param	name0 - 0" glosow"
		 * @param	name1 - 1" glos"
		 * @param	name2_4- 2" slosy" 
		 * @param	nameMore 85"glosow"
 		 */
		public static function setNumeralName(name0:String,name1:String,name2_4:String,nameMore:String,groupName:String="default"):void 
		{
			if (!numeralArray[groupName])
			{
				numeralArray[groupName] = new Array();
			}
			var a:Array 	= numeralArray[groupName];
			a[0] = name0;
			a[1] = name1;
			a[2] = name2_4;
			a[3] = nameMore;
			
		}
		/**
		 * function get numeral name if numeral name was setted in setNumeralName static Method
		 * @param	n: our int
		 * @param	groupName
		 * @return numeral name
		 */
		public static function getNumeralName(n:int,groupName:String="default"):String 
		{
			if (numeralArray[groupName])
			{
				switch (n) 
				{
					case 0:
						return numeralArray[groupName][0];
					break;
					case 1:
						return numeralArray[groupName][1];
					break;
					case 2:
					case 3:
					case 4:
						return numeralArray[groupName][2];
					break;
					default:
						return numeralArray[groupName][3];
					break;
					
				}
			}
			else 
			{
				return "";
			}
		}
		
		/**
		 * function  returns integer from min to max includes this values
		 * @param	min - miniimum value
		 * @param	max -  maximum value
		 * @return random int that is between min and max values
		 */
		public static function randomInt(min:int,max:int):int
		{
			var rand:int = Math.floor(Math.random() * (max - min + 1)) + min;
			
			return rand;
		}
		
		/**
		 * return sinus function from degrees not radians
		 * @param	degrees
		 * @return
		 */
		public static function sinDegrees(degrees:Number):Number
		{
			return Math.sin(degreesToRadians(degrees));
		}
		
		/**
		 * return cosinus function from degrees not radians
		 * @param	degrees
		 * @return
		 */
		public static function cosDegrees(degrees:Number):Number
		{
			return Math.cos(degreesToRadians(degrees));
		}
		/**
		 * add leading zeros for example time 13:9 number 9 leading zeros 2=09
		 * @param	value
		 * @param	zeros
		 * @return
		 */
		public static function addLeadingZeros(value:Number,zeros:uint=2):String
		{
			value = Math.floor(value);
			var retString:String = "";
			for (var i:int = zeros-1; i >=0; i--)
 			{
				if (value < Math.pow(10,i))
				{
					retString += "0";
				}
				else 
				{
					retString += value.toString();
					break;
				}
			}
			return retString;
			
		}
		/**
		 * separate thousands exampler: 1300 will bee "1 300"
		 * @param	num num to separate
		 * @param	separator
		 * @return separatet string
		 */
		public static function separateThousands(num:int,separator:String= " "):String 
		{
			var retString:String = "";
			var s:String = num.toString();
			if (num<1000) 
			{
				return s;
			}
			else 
			{
				var pointer:int = 0;
				for (var i:int = s.length-1; i >=0; i--) 
				{
					
					retString =  s.substr(i, 1)+retString;
					pointer++;
					if (pointer%3==0) 
					{
						retString = " " + retString;
					}
				}
				return retString ;
				
			}
			
			
		}

	}

}