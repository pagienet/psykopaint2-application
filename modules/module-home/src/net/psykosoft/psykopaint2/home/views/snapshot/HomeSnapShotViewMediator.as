package net.psykosoft.psykopaint2.home.views.snapshot
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class HomeSnapShotViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeSnapShotView;

		[Inject]
		public var notifyCanvasBitmapSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var notifyNavigationMovingSignal:NotifyNavigationMovingSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.GOING_TO_PAINT );
			registerEnablingState( StateType.PAINT );
			registerEnablingState( StateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( StateType.PAINT_SELECT_BRUSH );

			// From app.
			notifyCanvasBitmapSignal.add( onCanvasSnapShot );
			notifyNavigationToggledSignal.add( onNavigationToggled );
			notifyNavigationMovingSignal.add( onNavigationMoving );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationMoving( ratio:Number ):void {
			view.toggleSnapShot( true );
			view.widen( ratio );
		}

		private function onCanvasSnapShot( bmd:BitmapData ):void {
			if( !view.visible ) return;
			view.updateSnapShot( bmd );
		}

		private function onNavigationToggled( value:int ):void {
			view.toggleSnapShot( value == 1 );
		}
	}
}
