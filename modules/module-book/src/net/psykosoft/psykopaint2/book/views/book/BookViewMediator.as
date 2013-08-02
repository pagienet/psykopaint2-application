package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.views.book.content.SampleImagesBookDataProvider;
	import net.psykosoft.psykopaint2.book.views.book.content.UserPhotosBookDataProvider;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		private var _samplesDataProvider:SampleImagesBookDataProvider;
		private var _userPhotosDataProvider:UserPhotosBookDataProvider;
		private var _tracedSheet:Boolean;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.BOOK_STANDALONE );
			registerEnablingState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS );
			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );

			// From view.
			view.animateOutCompleteSignal.add( onAnimateOutComplete );
			view.animateInCompleteSignal.add( onAnimateInComplete );
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			// Decide which data provider to set.
			switch( newState ) {

				// Tests.
				case NavigationStateType.BOOK_STANDALONE: {

//					var provider:TestBookDataProvider = new TestBookDataProvider();
//					provider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
//					view.book.dataProvider = provider;

					initializeSamplesDataProvider();

//					initializeUserPhotosDataProvider();

					break;
				}

				// Sample images.
				case NavigationStateType.BOOK_PICK_SAMPLE_IMAGE: {
					initializeSamplesDataProvider();
					break;
				}

				// User photos iOS.
				case NavigationStateType.BOOK_PICK_USER_IMAGE_IOS: {
					initializeUserPhotosDataProvider();
					break;
				}
			}
		}

		private var _selectedBmd:BitmapData;

		private function onFullImagePicked( bmd:BitmapData ):void {
			_selectedBmd = bmd;
			view.animateOut();
		}

		private function onAnimateOutComplete():void {
			// TODO: this is a hack, the state should be enough
			notifyColorStyleCompleteSignal.dispatch( _selectedBmd );
//			requestStateChange( StateType.PREPARE_FOR_PAINT_MODE );
		}

		private function onAnimateInComplete():void {
			//TODO: blocker deactivation
		}

		private function initializeUserPhotosDataProvider():void {
			_userPhotosDataProvider = new UserPhotosBookDataProvider( stage3dProxy );
			_userPhotosDataProvider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
			_userPhotosDataProvider.fullImagePickedSignal.add( onFullImagePicked );
			_userPhotosDataProvider.readySignal.add( onUserPhotosDataProviderReady );
			// Uncomment to visualize data coming from the user photos extension.
//			_userPhotosDataProvider.sheetGeneratedSignal.add( onUserPhotosSheetGenerated );
			//TODO: blocker activation
		}

		private function onUserPhotosSheetGenerated( iosBmd:BitmapData ):void {
			if( _tracedSheet ) return;
			var bitmap:Bitmap = new Bitmap( iosBmd );
			bitmap.scaleX = bitmap.scaleY = 0.35;
			bitmap.x = 1024 * CoreSettings.GLOBAL_SCALING - bitmap.width;
			view.addChild( bitmap );
			_tracedSheet = true;
		}

		private function onUserPhotosDataProviderReady():void {
			view.book.dataProvider = _userPhotosDataProvider;
			view.animateIn();
		}

		private function initializeSamplesDataProvider():void {
			_samplesDataProvider = new SampleImagesBookDataProvider( stage3dProxy );
			_samplesDataProvider.setSheetDimensions( view.book.pageWidth, view.book.pageHeight );
			_samplesDataProvider.fullImagePickedSignal.add( onFullImagePicked );
			_samplesDataProvider.readySignal.add( onSamplesDataProviderReady );
			//TODO: blocker activation
		}

		private function onSamplesDataProviderReady():void {
			view.book.dataProvider = _samplesDataProvider;
			view.animateIn();
		}
	}
}
