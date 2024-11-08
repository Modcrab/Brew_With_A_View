package red.game.witcher3.interfaces 
{	
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotDragAvatar;
	import scaleform.clik.interfaces.IUIComponent;
	
	/**
	 * Slot data transfer system. Dragable component
	 * @author Yaroslav Getsevich
	 */
	public interface IDropTarget extends IUIComponent
	{
		function get dropSelection():Boolean;
        function set dropSelection(value:Boolean):void;
		
		function get dropEnabled():Boolean;
        function set dropEnabled(value:Boolean):void;
		
		function processOver(avatar:SlotDragAvatar):int;
		function canDrop(sourceObject:IDragTarget):Boolean;
		function applyDrop(sourceObject:IDragTarget):void;
	}
	
}
