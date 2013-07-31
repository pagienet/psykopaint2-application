package net.psykosoft.psykopaint2.crop.views
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.models.EaselRectModel;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CropView;

		[Inject]
		public var requestUpdateCropImageSignal:RequestUpdateCropImageSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.CROP );

			// From app.
			requestUpdateCropImageSignal.add( updateCropSourceImage );
			notifyCropConfirmSignal.add( onCropConfirmed );
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onCropConfirmed():void {
			notifyCropCompleteSignal.dispatch( view.renderPreviewToBitmapData() );
		}

		private function updateCropSourceImage( bitmapData:BitmapData ):void {
			trace( this, "updateCropSourceImage" );
			view.easelRect = easelRectModel.rect;
			view.sourceMap = bitmapData;
		}
	}
}
