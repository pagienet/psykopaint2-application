package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class RightButton extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:IconButtonPaperFold;

		public function RightButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			label.visible = false; // TODO: if we are not using the label in the end, remove it from logic and fla to save resources
		}
		
		
		override protected function onStageMouseUp( event:MouseEvent ):void {
			super.onStageMouseUp(event);
			icon.fold=true;
		}
		
		override protected function onThisMouseDown( event:MouseEvent ):void {
			super.onThisMouseDown(event);
			icon.fold=false;
		}
		
	}
}
