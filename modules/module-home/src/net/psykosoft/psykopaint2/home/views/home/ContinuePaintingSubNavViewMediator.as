package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingLoadSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.models.CurrentPaintingCache;
	import net.psykosoft.psykopaint2.home.signals.RequestZoomThenChangeStateSignal;

	public class ContinuePaintingSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ContinuePaintingSubNavView;

		[Inject]
		public var requestZoomThenChangeStateSignal:RequestZoomThenChangeStateSignal;

		[Inject]
		public var requestPaintingLoadSignal:RequestPaintingLoadSignal;

		public function ContinuePaintingSubNavViewMediator() {
			super();
		}

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case ContinuePaintingSubNavView.LBL_CONTINUE: {
					trace( this, "loading painting with id: " + CurrentPaintingCache.currentPaintingId );
					requestZoomThenChangeStateSignal.dispatch( true, StateType.PAINT );
					requestPaintingLoadSignal.dispatch( CurrentPaintingCache.currentPaintingId );
					break;
				}
				case ContinuePaintingSubNavView.LBL_DELETE: {
					// TODO
					break;
				}
			}
		}
	}
}
