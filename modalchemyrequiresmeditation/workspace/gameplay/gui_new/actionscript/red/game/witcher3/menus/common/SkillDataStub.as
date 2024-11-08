package red.game.witcher3.menus.common
{
	public dynamic class SkillDataStub
	{
		//public var id : uint;
		public var iconPath : String;
		public var abilityName : uint;
		public var acquired : Boolean;
		public var avialable : Boolean;
		public var positonID: int;
		public var isNew : Boolean;
		public var isSkill : Boolean;
		
		public function toString():String
		{
			return "[W3 SkillDataStub: " + abilityName + "]";
		}
	}
}