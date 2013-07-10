package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.views.book.content.SampleImagesBookDataProvider;
	import net.psykosoft.psykopaint2.book.views.book.content.TestBookDataProvider;
	import net.psykosoft.psykopaint2.book.views.book.content.UserPhotosBookDataProvider;
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
		private var _userPhotosDataProvider:UserPhotosBookDataProvider;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.BOOK_STANDALONE );
			registerEnablingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( StateType.BOOK_PICK_USER_IMAGE_IOS );
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

					var provider:TestBookDataProvider = new TestBookDataProvider();
					provider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
					view.book.dataProvider = provider;

//					initializeSamplesDataProvider();
//					initializeUserPhotosDataProvider();
					break;
				}

				// Sample images.
				case StateType.BOOK_PICK_SAMPLE_IMAGE: {
					initializeSamplesDataProvider();
					break;
				}

				// User photos iOS.
				case StateType.BOOK_PICK_USER_IMAGE_IOS: {
					initializeUserPhotosDataProvider();
					break;
				}
			}
		}

		private function onFullImagePicked( bmd:BitmapData ):void {
			requestSourceImageSetSignal.dispatch( bmd );
		}

		private function initializeUserPhotosDataProvider():void {
			trace( this, "init user photos provider..." );
			_userPhotosDataProvider = new UserPhotosBookDataProvider();
			_userPhotosDataProvider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
			_userPhotosDataProvider.fullImagePickedSignal.add( onFullImagePicked );
			_userPhotosDataProvider.readySignal.add( onUserPhotosDataProviderReady );
		}

		private function onUserPhotosDataProviderReady():void {
			trace( this, "user photos provider ready" );
			view.book.dataProvider = _userPhotosDataProvider;
		}

		private function initializeSamplesDataProvider():void {
			trace( this, "init sample images provider..." );
			_samplesDataProvider = new SampleImagesBookDataProvider();
			_samplesDataProvider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
			_samplesDataProvider.fullImagePickedSignal.add( onFullImagePicked );
			_samplesDataProvider.readySignal.add( onSamplesDataProviderReady );
		}

		private function onSamplesDataProviderReady():void {
			trace( this, "sample images provider ready" );
			view.book.dataProvider = _samplesDataProvider;
		}
	}
}
