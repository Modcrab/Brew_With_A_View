package red.game.witcher3.constants
{
	/**
	 * Convert ASCII key code to display string or controller icon name
	 * Used for input feedback module
	 * @author Yaroslav Getsevich
	 */
	public class KeyboardKeys
	{
		// #TODO: Localize #B Tomek Kozera added localize keys, ask him
		public static var keyCodesMap:Object =
		{
			1: "LeftMouse",   // icon
			2: "RightMouse",  // icon
			3: "MiddleMouse", // icon
			9 : "[[input_device_key_name_IK_Tab]]",
			13 : "[[input_device_key_name_IK_Enter]]",
			16 : "[[input_device_key_name_IK_Shift]]",
			17 : "[[input_device_key_name_IK_Ctrl]]",
			18 : "[[input_device_key_name_IK_Alt]]",
			19 : "[[input_device_key_name_IK_Pause]]",
			20 : "[[input_device_key_name_IK_CapsLock]]",
			27 : "[[input_device_key_name_IK_Escape]]",
			32 : "[[input_device_key_name_IK_Space]]",
			33 : "[[input_device_key_name_IK_PageUp]]",
			34 : "[[input_device_key_name_IK_PageDown]]",
			35 : "[[input_device_key_name_IK_End]]",
			36 : "[[input_device_key_name_IK_Home]]",
			38 : "Up",   	// icon
			37 : "Left", 	// icon
			39 : "Right", 	// icon
			40 : "Down", 	// icon
			41 : "Select", 
			44 : "[[input_device_key_name_IK_Print]]",
			45 : "[[input_device_key_name_IK_Insert]]",
			46 : "[[input_device_key_name_IK_Delete]]",
			96 : "NumPad0",
			97 : "NumPad1",
			98 : "NumPad2",
			99 : "NumPad3",
			100 : "NumPad4",
			101 : "NumPad5",
			102 : "NumPad6",
			103 : "NumPad7",
			104 : "NumPad8",
			105 : "NumPad9",
			106 : "NumStar",
			107 : "NumPlus",
			108 : "Separator",
			109 : "[[input_device_key_name_IK_NumMinus]]",
			110 : "NumPeriod",
			111 : "NumSlash",
			112 : "F1",
			113 : "F2",
			114 : "F3",
			115 : "F4",
			116 : "F5",
			117 : "F6",
			118 : "F7",
			119 : "F8",
			120 : "F9",
			121 : "F10",
			122 : "F11",
			123 : "F12",
			124 : "F13",
			125 : "F14",
			126 : "F15",
			127 : "F16",
			128 : "F17",
			128 : "F18",
			130 : "F19",
			131 : "F20",
			132 : "F21",
			133 : "F22",
			134 : "F23",
			135 : "F24",
			156 : "NumLock",
			157 : "[[input_device_key_name_IK_ScrollLock]]",
			160 : "[[input_device_key_name_IK_LShift]]", // left
			161 : "[[input_device_key_name_IK_RShift]]", // right
			162 : "[[input_device_key_name_IK_LControl]]", // left
			163 : "[[input_device_key_name_IK_RControl]]", // right
			
			
			/*
			IK_Semicolon=186,
			IK_Equals=187,
			IK_Comma=188,
			IK_Minus=189,
			IK_Period=190,
			IK_Slash=191,
			IK_Tilde=192,
			IK_LeftBracket=219,
			IK_Backslash=220,
			IK_RightBracket=221,
			IK_SingleQuote=222,*/
			
			186: ";",
			187: "=",
			188: ",",
			189: "-",
			190: ".",
			191: "/",
			192: "~",
			220: "[",
			221: "]",
			222: "'",
			
			
			193: "Mouse4",
			194: "Mouse5",
			195: "Mouse6",
			196: "Mouse7",
			197: "Mouse8"
		}
		
		public static function getKeyLabel(keyCode:int):String
		{
			if (!keyCode)
			{
				return "[[input_device_key_name_IK_none]]";
			}
			
			var resString:String = keyCodesMap[keyCode];
			if (resString)
			{
				return resString;
			}
			resString = String.fromCharCode(keyCode);
			return resString;
		}
	}
}
