package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.core.managers.Stage3DProxy;

	import net.psykosoft.psykopaint2.book.views.book.content.SampleImagesBookDataProvider;

	import net.psykosoft.psykopaint2.book.views.book.content.TestBookDataProvider;

	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;

	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.BOOK_STANDALONE );
			registerEnablingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
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
					view.dataProvider = new TestBookDataProvider();
//					view.dataProvider = new SampleImagesBookDataProvider();
					break;
				}

				case StateType.BOOK_PICK_SAMPLE_IMAGE: {
					view.dataProvider = new SampleImagesBookDataProvider();
					break;
				}
			}
		}
	}
}
