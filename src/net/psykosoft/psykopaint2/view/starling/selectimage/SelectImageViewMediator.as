package net.psykosoft.psykopaint2.view.starling.selectimage
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;
	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifySourceImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectImageViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectImageView;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var notifySourceImagesUpdatedSignal:NotifySourceImagesUpdatedSignal;

		override public function initialize():void {

			// From view.
			view.listChangedSignal.add( onListItemSelected );

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifySourceImagesUpdatedSignal.add( onSourceImagesUpdated );

			super.initialize();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onListItemSelected():void {

			// TODO: notify some model that the image was selected

			// A selection of an image triggers the "pick colors" state of the new painting process.
			notifyStateChangedSignal.dispatch( new StateVO( States.PAINTING_SELECT_COLORS ) );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onSourceImagesUpdated( thumbs:Vector.<PackagedImageVO> ):void {
			Cc.log( this, "thumbs updated: " + thumbs );
			view.displayThumbs( thumbs );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			if( newState.name == States.PAINTING_SELECT_IMAGE ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}
	}
}
