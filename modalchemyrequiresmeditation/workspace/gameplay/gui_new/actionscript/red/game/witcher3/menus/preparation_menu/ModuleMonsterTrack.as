package red.game.witcher3.menus.preparation_menu 
{
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.JournalRewards;
	import red.game.witcher3.slots.SlotBase;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * Monster info with description, recomended potions, etc
	 * @author Getsevich Yaroslav
	 */
	public class ModuleMonsterTrack extends CoreMenuModule
	{
		public var mcHeader:TrackedMonsterHeader;
		public var mcMonsterInfo:TrackedMonsterInfo;
		public var mcMonsterRecommend:TrackedMonsterRecommend;
		public var mcRewards:JournalRewards;
		
		protected var trackedMonsterData:Object;
		
		public function ModuleMonsterTrack()
		{
			super();
			
			if (mcRewards)
			{
				mcRewards.titleString = "[[panel_glossary_recommended]]";
				mcRewards.dataBindingKeyReward = "tracked.monster.recommended.items";
				mcRewards.mcRewardGrid.focusable = false;
				mcRewards.activeSelectionVisible = false;
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "preparation.tracked.monster.info", [setTrackedMonsterInfo]));
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			if (mcRewards)
			{
				mcRewards.visible = false;
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return mcMonsterInfo.mcScrollbar.visible;
		}
		
		protected function setTrackedMonsterInfo(monsterData:Object):void
		{
			trackedMonsterData = monsterData;
			
			mcHeader.setupMonsterInfo(trackedMonsterData);
			mcMonsterInfo.setupMonsterInfo(trackedMonsterData);
			mcMonsterRecommend.setupMonsterInfo(trackedMonsterData);
		}
		
		override public function set focused(value:Number):void
		{
            super.focused = value;
			
			if (mcRewards)
			{
				mcRewards.activeSelectionVisible = value != 0;
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if (!focused || event.handled)
				return;
			
			var details : InputDetails = event.details;
			if (details.code == KeyCode.PAD_RIGHT_STICK_AXIS)
			{
				mcMonsterInfo.txtDescription.handleInput(event);
			}
			
			if (mcRewards)
			{
				mcRewards.handleInput(event);
			}
		}
	}

}