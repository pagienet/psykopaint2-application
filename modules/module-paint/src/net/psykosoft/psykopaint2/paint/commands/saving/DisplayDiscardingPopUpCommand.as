package net.psykosoft.psykopaint2.paint.commands.saving
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;

	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.Jokes;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class DisplayDiscardingPopUpCommand extends AsyncCommand
	{
		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var notifyPopUpShownSignal:NotifyPopUpShownSignal;

		override public function execute():void {
			super.execute();

			requestShowPopUpSignal.dispatch( PopUpType.MESSAGE );
			requestUpdateMessagePopUpSignal.dispatch( "Going back home...", "There are some ugly things going on behind this paper.\nBelieve me, you rather do not want to see that." );
			notifyPopUpShownSignal.addOnce( onSavingPopUpShown );
		}

		private function onSavingPopUpShown():void {
			dispatchComplete( true );
		}
	}
}
