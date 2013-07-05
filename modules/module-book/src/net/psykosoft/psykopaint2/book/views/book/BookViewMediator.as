package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.views.book.content.SampleImagesBookDataProvider;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var requestSourceImageSetSignal:RequestDrawingCoreSourceImageSetSignal;

		private var _samplesDataProvider:SampleImagesBookDataProvider;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
<<<<<<< HEAD
			registerEnablingState( StateType.BOOK_PICK_IMAGE );
=======
			registerEnablingState( StateType.BOOK_STANDALONE );
			registerEnablingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
>>>>>>> c40394182458403007ce571ddc02fe889795f430
			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			// Decide which data provider to set.
			switch( newState ) {

				// Tests.
				case StateType.BOOK_STANDALONE: {
//					view.dataProvider = new TestBookDataProvider();
					initializeSamplesDataProvider();
					break;
				}

				case StateType.BOOK_PICK_SAMPLE_IMAGE: {
					initializeSamplesDataProvider();
					break;
				}
			}
		}

		private function initializeSamplesDataProvider():void {
			_samplesDataProvider = new SampleImagesBookDataProvider();
			_samplesDataProvider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
			_samplesDataProvider.fullImagePickedSignal.add( onFullImagePicked );
			_samplesDataProvider.readySignal.addOnce( onSamplesDataProviderReady );
		}

		private function onFullImagePicked( bmd:BitmapData ):void {
			requestSourceImageSetSignal.dispatch( bmd );
		}

		private function onSamplesDataProviderReady():void {
			view.dataProvider = _samplesDataProvider;
		}
	}
}
