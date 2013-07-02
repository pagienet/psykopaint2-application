package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingActivatedSignal;

	public class ActivatePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingModel;

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var notifyPaintingActivatedSignal:NotifyPaintingActivatedSignal;

		public function ActivatePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Get painting data, translate and pass on to the drawing core.
			var vo:PaintingVO = paintingDataModel.getVoWithId( paintingId );
			var data:Vector.<ByteArray> = Vector.<ByteArray>( [ vo.colorImageARGB, vo.heightmapImageARGB, vo.sourceImageARGB ] );

			canvasModel.loadLayers(data);

			notifyPaintingActivatedSignal.dispatch();
		}
	}
}
