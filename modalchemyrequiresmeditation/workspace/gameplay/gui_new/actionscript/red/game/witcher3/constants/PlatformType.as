package red.game.witcher3.constants 
{	
	public class PlatformType 
	{
		public static const PLATFORM_PC : uint = 0;
		public static const PLATFORM_XBOX1 : uint = 1;
		public static const PLATFORM_PS4 : uint = 2;
		public static const PLATFORM_PS5 : uint = 3;
		public static const PLATFORM_XB_SCARLETT_ANACONDA = 4;
		public static const PLATFORM_XB_SCARLETT_LOCKHART = 5;
		public static const PLATFORM_UNKNOWN : uint = 255;
		
		public static function getPlatformSpecificResourceString(platformType : uint, resourcePrefix : String):String
		{	
			switch(platformType)
			{
				case PlatformType.PLATFORM_UNKNOWN:
				case PlatformType.PLATFORM_PC:
					return "[[" + resourcePrefix + "" + "]]";
					break;
				case PlatformType.PLATFORM_XBOX1:
				case PlatformType.PLATFORM_XB_SCARLETT_LOCKHART:
				case PlatformType.PLATFORM_XB_SCARLETT_ANACONDA:
					return "[[" + resourcePrefix + "_x1" + "]]";
					break;
				case PlatformType.PLATFORM_PS4:
				case PlatformType.PLATFORM_PS5:
					return "[[" + resourcePrefix + "_ps4" + "]]";
					break;
			}
			return "";
		}
	}
}
