package net.psykosoft.psykopaint2.home.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class SetUpHomeModuleCommand extends TracingCommand
	{
		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		override public function execute():void
		{
			notifyHomeModuleSetUpSignal.dispatch();
		}
	}
}
