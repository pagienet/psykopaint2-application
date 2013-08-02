package net.psykosoft.psykopaint2.crop.views
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.models.EaselRectModel;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CropView;

		[Inject]
		public var requestUpdateCropImageSignal:RequestUpdateCropImageSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal:RequestOpenCroppedBitmapDataSignal;

		[Inject]
		public var notifyCropConfirmSignal:RequestFinalizeCropSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.CROP );

			// From app.
			requestUpdateCropImageSignal.add( updateCropSourceImage );
			notifyCropConfirmSignal.add( onRequestFinalizeCropMediator );
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onRequestFinalizeCropMediator():void {
			requestOpenCroppedBitmapDataSignal.dispatch( view.getCroppedImage() );
			view.disposeCropData();
		}

		private function updateCropSourceImage( bitmapData:BitmapData ):void {
			trace( this, "updateCropSourceImage" );
			view.easelRect = easelRectModel.rect;
			view.sourceMap = bitmapData;
		}
	}
}
