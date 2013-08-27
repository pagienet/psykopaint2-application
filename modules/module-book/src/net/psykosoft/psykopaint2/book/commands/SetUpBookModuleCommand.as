package net.psykosoft.psykopaint2.book.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;

	public class SetUpBookModuleCommand extends AsyncCommand
	{
		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal : RequestAddViewToMainLayerSignal;

		override public function execute() : void
		{
			var bookRootView : BookRootView = new BookRootView();
			bookRootView.onSubViewsReady.add(onSubViewReady);
			requestAddViewToMainLayerSignal.dispatch(bookRootView);
		}

		private function onSubViewReady() : void
		{
			notifyBookModuleSetUpSignal.dispatch();
		}
	}
}
