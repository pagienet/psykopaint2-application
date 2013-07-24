package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class ActivateBlankSourceImageCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		public function ActivateBlankSourceImageCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			var dummyBmd:BitmapData = new BitmapData( 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING, false, 0 );
			canvasModel.setSourceBitmapData( dummyBmd );
		}
	}
}
