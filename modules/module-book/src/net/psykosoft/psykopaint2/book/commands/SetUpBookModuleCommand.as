package net.psykosoft.psykopaint2.book.commands
{
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;

	public class SetUpBookModuleCommand
	{
		[Inject]
		public var imageSource : String;

		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal : RequestAddViewToMainLayerSignal;

		private var _bookRootView : BookRootView;


		public function execute() : void
		{
			_bookRootView = new BookRootView(imageSource);
			_bookRootView.onSubViewsReady.add(onSubViewReady);
			requestAddViewToMainLayerSignal.dispatch( _bookRootView );
		}

		private function onSubViewReady() : void
		{
			notifyBookModuleSetUpSignal.dispatch();
		}
	}
}
