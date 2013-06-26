package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopBinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var userModel:UserModel;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Need to create a new id?
			// NOTE: The incoming signal's id is populated from the home module. If it's empty
			// or is 'easel', we're supposed to create a new file. If it is anything else,
			// we're coming from a painting that was saved before at some point.
			if( paintingId == "easel" || paintingId == "" ) {
				var nowDate:Date = new Date();
				paintingId = userModel.uniqueUserId + "-" + Math.floor( nowDate.getTime() );
			}

			// Produce data vo.
			var vo:PaintingVO = new PaintingVO();
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayersARGB();
			var hr:Boolean = CoreSettings.RUNNING_ON_RETINA_DISPLAY;
			vo.width = hr ? 2048 : 1024;
			vo.height = hr ? 1536 : 768;
			vo.height = canvasModel.stage.stageHeight;
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
				DesktopBinarySaveUtil.saveToDesktop( voBytes, CoreSettings.paintingDesktopDataFolderName + "/painting-" + paintingId + CoreSettings.paintingFileExtension );
			}
		}
	}
}
