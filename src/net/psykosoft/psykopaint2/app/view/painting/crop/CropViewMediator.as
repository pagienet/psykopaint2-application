package net.psykosoft.psykopaint2.app.view.painting.crop
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;

	public class CropViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var cropView:CropView;

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		override public function initialize():void {

			super.initialize();
			registerView( cropView );
			registerEnablingState( ApplicationStateType.PAINTING_CROP_IMAGE );

			// From app.
			notifyCropModuleActivatedSignal.add( onModuleActivated );
			notifyCropConfirmSignal.add( doCrop );
		}

		// -----------------------
		// From app.
		// -----------------------

		public function doCrop():void {
			if( cropView.visible ) {
				notifyCropCompleteSignal.dispatch( cropView.renderPreviewToBitmapData() );
			}
		}

		private function onModuleActivated( bitmapData:BitmapData ):void {
			cropView.sourceMap = bitmapData;
		}
	}
}
