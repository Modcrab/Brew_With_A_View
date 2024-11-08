package red.game.witcher3.hud
{
	import red.game.witcher3.hud.modules.HudModuleBase;

	public class HudModuleManagerEntry
	{
		public var m_name		: String;
		public var m_filename	: String;
		public var m_depthIndex	: int;
		public var m_movieClip	: HudModuleBase;
		public var m_state		: String;

		public function HudModuleManagerEntry( name : String, filename : String, depthIndex : int )
		{
			m_name		= name;
			m_filename	= filename;
			m_depthIndex	= depthIndex;
		}
		
        public function toString():String
		{
            return "Name: " + m_name + ", Filename: " + m_filename + ", DepthIndex: " + m_depthIndex;
        }
	}
}
