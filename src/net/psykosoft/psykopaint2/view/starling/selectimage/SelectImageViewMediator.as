package net.psykosoft.psykopaint2.view.starling.selectimage
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

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

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifySourceImagesUpdatedSignal.add( onSourceImagesUpdated );

			super.initialize();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onSourceImagesUpdated( thumbs:Vector.<BitmapData> ):void {
			Cc.log( this, "thumbs updated: " + thumbs );
			view.displayThumbs( thumbs );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			if( newState.name == States.SELECT_IMAGE ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}
	}
}
