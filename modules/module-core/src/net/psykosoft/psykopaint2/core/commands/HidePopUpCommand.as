package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;

	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;

	public class HidePopUpCommand extends AsyncCommand
	{
		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		override public function execute():void {

			trace( this, "execute" );

			notifyPopUpRemovedSignal.add( onPopUpRemoved );
			requestHidePopUpSignal.dispatch();

		}

		private function onPopUpRemoved():void {
			dispatchComplete( true );
		}
	}
}
