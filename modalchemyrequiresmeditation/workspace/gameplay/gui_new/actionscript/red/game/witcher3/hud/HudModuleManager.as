package red.game.witcher3.hud
{
	import flash.utils.Dictionary;
	import red.game.witcher3.controls.Label;

	public class HudModuleManager
	{
		public var entries : Vector.<HudModuleManagerEntry>;
		
		private var entriesDic : Dictionary;
		
		public function HudModuleManager()
		{
			entries = new Vector.<HudModuleManagerEntry>;
			entriesDic = new Dictionary();
		}
		
		public function AddEntry( moduleName : String, moduleFilename : String , depthIndex : int )
		{
			var newEntry:HudModuleManagerEntry = new HudModuleManagerEntry( moduleName, moduleFilename , depthIndex  );
			entries.push( newEntry );
			entriesDic[moduleName] = newEntry;
		}
		
		// #Y this function is much faster than FindModuleByName (0.0041 ms vs 0.031 ms)
		public function FindModuleByNameDict( moduleName : String ): HudModuleManagerEntry
		{
			return entriesDic[moduleName];
		}
		
		public function FindModuleByName( moduleName : String ) : HudModuleManagerEntry
		{
			var i   : int;
			var len : int = entries.length;
			for ( i = 0; i < len; i++ )
			{
				if ( entries[ i ].m_name == moduleName )
				{
					return entries[ i ];
				}
			}
			return null;
		}
		
		public function FindModuleByFilename( moduleFilename : String ) : HudModuleManagerEntry
		{
			var i : int;
			var len : int = entries.length;
			for ( i = 0; i < len; i++ )
			{
				if ( entries[ i ].m_filename == moduleFilename )
				{
					return entries[ i ];
				}
			}
			return null;
		}
		
		public function SortEntries()
		{
			PrintInfo();
			entries.sort( sortModulesByDepth );
			PrintInfo();
		}
		
		
		protected function sortModulesByDepth( a, b ):int
		{
			if ( a.m_depthIndex < b.m_depthIndex )	return -1;
			if ( a.m_depthIndex > b.m_depthIndex )	return 1;
			return 0;
		}
		
		public function ShowModules( show : Boolean )
		{
			/*var i : int;
			for ( i = 0; i < entries.length; i++ )
			{
				if ( entries[ i ].m_movieClip )
				{
					if ( show )
					{
						if ( entries[ i ].m_isCommon )
						{
							entries[ i ].m_movieClip.ShowElement( true, true );
						}
					}
					else
					{
						entries[ i ].m_movieClip.ShowElement( false, true );
					}
				}
			}*/
		}
		
		public function PrintInfo()
		{
			/*
			var i : int;
			for ( i = 0; i < entries.length; i++ )
			{
				trace("LOAD " + i + " " + entries[ i ].m_filename + " " + ( entries[ i ].m_movieClip != null ) );
			}
			*/
		}

	}
}
