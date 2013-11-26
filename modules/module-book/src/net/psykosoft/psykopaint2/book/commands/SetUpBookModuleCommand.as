package net.psykosoft.psykopaint2.book.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.services.CameraRollService;

	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.views.base.ViewLayerOrdering;

	public class SetUpBookModuleCommand extends AsyncCommand
	{
		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal : RequestAddViewToMainLayerSignal;

		override public function execute() : void
		{
			trace(this, "execute");
			var bookRootView : BookRootView = new BookRootView();
			bookRootView.onSubViewsReady.add(onSubViewReady);
			requestAddViewToMainLayerSignal.dispatch(bookRootView, ViewLayerOrdering.AT_BOTTOM_LAYER);
		}

		private function onSubViewReady() : void
		{
			notifyBookModuleSetUpSignal.dispatch();
		}
	}
}
