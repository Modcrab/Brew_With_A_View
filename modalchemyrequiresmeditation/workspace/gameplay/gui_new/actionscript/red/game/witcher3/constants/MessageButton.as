package red.game.witcher3.constants 
{
	import scaleform.clik.constants.NavigationCode;
	
	/**
	 * User actions in the system dialog
	 * @author Getsevich Yaroslav
	 */
	public class MessageButton 
	{
		// WARNING: Mapped to the WS enum
		public static const MB_OK:uint = 0;
		public static const MB_CANCEL:uint = 1;
		public static const MB_ABORT:uint = 2;
		public static const MB_YES:uint = 3;
		public static const MB_NO:uint = 4;
		
		public static function getLocalizedLabel(buttonId:uint):String
		{
			var resultString:String = "ERROR";
			switch (buttonId)
			{
				case MB_OK:
					resultString = "OK";
					break;
				case MB_CANCEL:
					resultString = "CANCEL";
					break;
				case MB_ABORT:
					resultString = "ABORT";
					break;
				case MB_YES:
					resultString = "YES";
					break;
				case MB_NO:
					resultString = "NO";
					break;
			}
			return resultString;
		}
		
		public static function getGamepadNavCode(buttonId:uint):String
		{
			var resultCode:String = "ERROR";
			switch (buttonId)
			{
				case MB_OK:
				case MB_YES:
					resultCode = NavigationCode.GAMEPAD_A;
					break;
				case MB_CANCEL:
				case MB_NO:
					resultCode = NavigationCode.GAMEPAD_B;
					break;
				case MB_ABORT:
					resultCode = NavigationCode.GAMEPAD_Y;
					break;
			}
			return resultCode;
		}
		
		public static function getPcKeyCode(buttonId:uint):uint
		{
			var resultCode:uint = 0;
			switch (buttonId)
			{
				case MB_OK:
				case MB_YES:
					resultCode = KeyCode.ENTER;
					break;
				case MB_CANCEL:
				case MB_NO:
					resultCode = KeyCode.ESCAPE;
					break;
				case MB_ABORT:
					resultCode = 0; // #Y TODO: Define KeyCode
					break;
			}
			return resultCode;
		}
		
		public static function isPositive(buttonId:uint):Boolean
		{
			switch (buttonId)
			{
				case MB_OK:
				case MB_YES:
					return true;
					break;
				case MB_CANCEL:
				case MB_NO:
				case MB_ABORT:
					return false;
					break;
			}
			return false;
		}
	}
}
