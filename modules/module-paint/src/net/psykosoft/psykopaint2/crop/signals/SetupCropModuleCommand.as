package net.psykosoft.psykopaint2.crop.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;

	public class SetupCropModuleCommand extends TracingCommand
	{
		[Inject]
		public var bitmapData : BitmapData;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		// TODO: Replace this?
		[Inject]
		public var requestUpdateCropImageSignal : RequestUpdateCropImageSignal;

		override public function execute() : void
		{
			super.execute();
			requestUpdateCropImageSignal.dispatch(bitmapData);
			notifyCropModuleSetUpSignal.dispatch();
		}
	}
}
