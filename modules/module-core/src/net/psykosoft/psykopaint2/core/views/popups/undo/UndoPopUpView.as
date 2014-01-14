package net.psykosoft.psykopaint2.core.views.popups.undo
{

	import flash.display.Sprite;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	public class UndoPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var messageTxt:TextField;
		public var okBtn:FoldButton;
		public var undoBtn:FoldButton;
		
	
		public function UndoPopUpView() {
			super();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			messageTxt.selectable = messageTxt.mouseEnabled = false;
			messageTxt.text = "";
			
			okBtn.labelText = "OK";

			// TODO: why the reparenting?
			_container.addChild( messageTxt );
		

			layout();
		}

		public function updateMessage( newTitle:String, newMessage:String ):void {
			messageTxt.text = newTitle;
		}
	}
}
