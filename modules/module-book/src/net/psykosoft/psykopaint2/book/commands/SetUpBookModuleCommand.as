package net.psykosoft.psykopaint2.book.commands
{

	import away3d.core.managers.Stage3DProxy;

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.book.views.book.BookView;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.views.base.ViewLayerOrdering;

	public class SetUpBookModuleCommand extends AsyncCommand
	{
//		[Inject]
//		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal : RequestAddViewToMainLayerSignal;

		[Inject]
		public var stage3DProxy : Stage3DProxy;

		override public function execute() : void
		{
			trace(this, "execute");
			var bookView : BookView = new BookView(stage3DProxy);
			requestAddViewToMainLayerSignal.dispatch(bookView, ViewLayerOrdering.AT_BOTTOM_LAYER);
//			notifyBookModuleSetUpSignal.dispatch();
		}
	}
}
