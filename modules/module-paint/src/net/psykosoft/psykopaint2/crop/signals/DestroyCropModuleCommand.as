package net.psykosoft.psykopaint2.crop.signals
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class DestroyCropModuleCommand extends TracingCommand
	{
		[Inject]
		public var notifyCropModuleDestroyedSignal : NotifyCropModuleDestroyedSignal;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		override public function execute() : void
		{
			super.execute();

			requestSetCropBackgroundSignal.dispatch(null);
			notifyCropModuleDestroyedSignal.dispatch();
		}
	}
}
