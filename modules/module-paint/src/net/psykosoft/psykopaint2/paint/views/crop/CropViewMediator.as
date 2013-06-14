package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CropView;

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;
		
		
		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.CROP );

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
