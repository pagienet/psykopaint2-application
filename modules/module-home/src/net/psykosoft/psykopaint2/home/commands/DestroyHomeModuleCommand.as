package net.psykosoft.psykopaint2.home.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class DestroyHomeModuleCommand extends TracingCommand
	{
		[Inject]
		public var notifyHomeModuleDestroyedSignal : NotifyHomeModuleDestroyedSignal;

		override public function execute():void
		{
			notifyHomeModuleDestroyedSignal.dispatch();
		}
	}
}
