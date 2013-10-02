package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavView;
	
	public class ColorPickerViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ColorPickerView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;

			manageStateChanges = false;
			view.enable();
			view.colorChangedSignal.add( onColorChanged );
			notifyPickedColorChangedSignal.add( onColorChangedFromOutside )
		}
		
		// -----------------------
		// From view.
		// -----------------------
		private function onColorChanged():void
		{
			notifyPickedColorChangedSignal.dispatch(view.currentColor, false);
		}
		
		
		// -----------------------
		// From app.
		// -----------------------
		private function onColorChangedFromOutside( newColor:uint, reallyFromOutside:Boolean ):void
		{
			if ( reallyFromOutside ) view.setCurrentColor(newColor,false,false,false);
		}
		
		
	}
}
