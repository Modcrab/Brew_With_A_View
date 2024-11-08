package red.game.witcher3.constants 
{
	public class AspectRatio 
	{
		static public const ASPECT_RATIO_UNDEFINED	: int = 0;
		static public const ASPECT_RATIO_DEFAULT	: int = 1;
		static public const ASPECT_RATIO_4_3		: int = 2;
		static public const ASPECT_RATIO_21_9		: int = 3;

		static public function getCurrentAspectRatio( screenWidth : int , screenHeight : int ) : int
		{
            var ar:Number = screenWidth / screenHeight;
				
			if ( Math.abs(ar - (4 / 3)) < 0.1 || Math.abs(ar - (5 / 4)) < 0.1 )
			{
				return ASPECT_RATIO_4_3;
			}
			else if (Math.abs(ar - (21 / 9)) < 0.1 || Math.abs(ar - (43 / 18)) < 0.1)
			{
				return ASPECT_RATIO_21_9
			}
			
			return ASPECT_RATIO_DEFAULT;
		}

	}

}