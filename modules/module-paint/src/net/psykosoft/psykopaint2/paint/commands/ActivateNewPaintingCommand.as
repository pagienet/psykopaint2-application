package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;

	public class ActivateNewPaintingCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestPaintingActivationSignal:RequestPaintingActivationSignal;

		public function ActivateNewPaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Generate a new, empty vo.
			var vo:PaintingVO = new PaintingVO();
			var emptyImages:Vector.<ByteArray> = canvasModel.getEmptyLayersARGB();
			vo.id = PaintingVO.DEFAULT_ID;
			vo.colorImageARGB = emptyImages[ 0 ];
			vo.heightmapImageARGB = emptyImages[ 1 ];
			vo.sourceImageARGB = emptyImages[ 2 ];
			vo.fileVersion = CoreSettings.PAINTING_FILE_VERSION;
			// TODO: need to add additional stuff to vo?

			paintingModel.addSinglePaintingData( vo );
			requestPaintingActivationSignal.dispatch( vo.id );
		}
	}
}
