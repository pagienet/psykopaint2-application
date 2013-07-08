package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class SetSurfaceImageCommand extends TracingCommand
	{
		[Inject]
		public var normalSpecularData:ByteArray;

		[Inject]
		public var color : BitmapData;

		[Inject]
		public var canvasModel:CanvasModel;

		override public function execute():void {
			super.execute();
			canvasModel.setNormalSpecularMap( normalSpecularData );
			canvasModel.setColorBackgroundOriginal( color );
		}
	}
}
