package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopBinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var canvasModel:CanvasModel;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Produce data vo.
			var vo:PaintingVO = new PaintingVO();
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayersARGB();
			vo.colorImageARGB = imagesRGBA[ 0 ];
			vo.heightmapImageARGB = imagesRGBA[ 1 ];
			vo.sourceImageARGB = imagesRGBA[ 2 ];
			vo.id = paintingId;

			// Serialize data.
			var voBytes:ByteArray = vo.serialize();

			// Deliver to binary writer.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else {
				DesktopBinarySaveUtil.saveToDesktop( voBytes, PaintSettings.desktopDataFolderName + "/painting-" + paintingId + PaintSettings.paintingFileExtension );
			}
		}
	}
}
