package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;

	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutType;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var requestSourceImageSetSignal:RequestDrawingCoreSourceImageSetSignal;

		[Inject]
		public var requestInteractionBlockSignal:RequestInteractionBlockSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( StateType.BOOK_STANDALONE );
			registerEnablingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( StateType.BOOK_PICK_USER_IMAGE_IOS );

			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );

			view.requiresInteractionSignal.add(onInteractionRequested);
			view.imageSelectedSignal.add(onImageSelected);
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			switch( newState ) {
				// Sample images. as default
				case StateType.BOOK_STANDALONE:
				case StateType.BOOK_PICK_SAMPLE_IMAGE: 
					view.layoutType = LayoutType.NATIVE_SAMPLES;
					break;
				 
				// User photos iOS.//defaulted to samples for now
				case StateType.BOOK_PICK_USER_IMAGE_IOS: 
					view.layoutType = LayoutType.NATIVE_SAMPLES;
					break;
			}
		}

		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifyColorStyleCompleteSignal.dispatch( selectedBmd );
		}

		private function onInteractionRequested(doRequest:Boolean):void
		{
			requestInteractionBlockSignal.dispatch(doRequest);
		}
	}
}
