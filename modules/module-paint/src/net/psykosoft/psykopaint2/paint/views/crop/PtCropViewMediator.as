package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtCropViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtCropView;

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( CrStateType.STATE_CROP );

			// From app.
			notifyCropModuleActivatedSignal.add( onCropModuleActivated );
			notifyCropConfirmSignal.add( onCropConfirmed );
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onCropConfirmed():void {
			notifyCropCompleteSignal.dispatch( view.renderPreviewToBitmapData() );
		}

		private function onCropModuleActivated( bitmapData:BitmapData ):void {
			view.sourceMap = bitmapData;
		}
	}
}
