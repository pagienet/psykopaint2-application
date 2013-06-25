package net.psykosoft.psykopaint2.home.commands
{

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;

	import robotlegs.bender.framework.api.IContext;

	public class ZoomThenChangeStateCommand extends TracingCommand
	{
		[Inject]
		public var zoomDirection:Boolean; // From signal.

		[Inject]
		public var stateName:String; // From signal.

		[Inject]
		public var requestZoomToggleSignal:RequestZoomToggleSignal;

		[Inject]
		public var notifyZoomCompleteSignal:NotifyZoomCompleteSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var context:IContext;

		public function ZoomThenChangeStateCommand() {
			super();
		}

		override public function execute():void {
			super.execute();
			requestZoomToggleSignal.dispatch( zoomDirection );
			notifyZoomCompleteSignal.addOnce( onZoomComplete );
			context.detain( this );
		}

		private function onZoomComplete():void {
			requestStateChangeSignal.dispatch( stateName );
			context.release( this );
		}
	}
}
