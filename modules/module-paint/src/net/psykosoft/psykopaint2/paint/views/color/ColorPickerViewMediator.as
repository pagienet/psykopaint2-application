package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	
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

			
		}

		// -----------------------
		// From view.
		// -----------------------

		
		
		// -----------------------
		// From app.
		// -----------------------

		

		override protected function onStateChange( newState:String ):void {
//			trace( this, "state change: " + newState );

			
		}
	}
}
