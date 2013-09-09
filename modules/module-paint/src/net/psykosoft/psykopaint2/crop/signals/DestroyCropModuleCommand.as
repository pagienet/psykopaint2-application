package net.psykosoft.psykopaint2.crop.signals
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class DestroyCropModuleCommand extends TracingCommand
	{
		[Inject]
		public var notifyCropModuleDestroyedSignal : NotifyCropModuleDestroyedSignal;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var requestCropRootViewRemovalSignal:RequestCropRootViewRemovalSignal;

		override public function execute() : void
		{
			super.execute();

			requestCropRootViewRemovalSignal.dispatch();
			notifyCropModuleDestroyedSignal.dispatch();
		}
	}
}
