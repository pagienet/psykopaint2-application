package net.psykosoft.psykopaint2.crop.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;

	public class SetupCropModuleCommand extends TracingCommand
	{
		[Inject]
		public var bitmapData : BitmapData;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		// TODO: Replace this?
		[Inject]
		public var notifyCropModuleActivatedSignal : NotifyCropModuleActivatedSignal;

		override public function execute() : void
		{
			super.execute();
			notifyCropModuleActivatedSignal.dispatch(bitmapData);
			notifyCropModuleSetUpSignal.dispatch();
		}
	}
}
