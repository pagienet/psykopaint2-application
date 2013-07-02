package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopBinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var updateEasel:Boolean; // From signal.

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var userModel:UserModel;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			trace( this, "incoming painting id: " + paintingId );

			// Need to create a new id?
			// NOTE: The incoming signal's id is populated from the home module. If it's empty
			// or is 'easel', we're supposed to create a new file. If it is anything else,
			// we're coming from a painting that was saved before at some point.
			var nowDate:Date = new Date();
			var dateMs:Number = nowDate.getTime();
			if( paintingId == "easel" || paintingId == "" ) {
				paintingId = userModel.uniqueUserId + "-" + dateMs;
			}

			// Produce data vo.
			var vo:PaintingVO = new PaintingVO();
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayers();
			var hr:Boolean = CoreSettings.RUNNING_ON_RETINA_DISPLAY;
			vo.fileVersion = CoreSettings.PAINTING_FILE_VERSION;
			vo.lastSavedOnDateMs = dateMs;
			vo.width = hr ? 2048 : 1024;
			vo.height = hr ? 1536 : 768;
			vo.height = canvasModel.stage.stageHeight;
			vo.colorImageARGB = imagesRGBA[ 0 ];
			vo.heightmapImageARGB = imagesRGBA[ 1 ];
			vo.sourceImageARGB = imagesRGBA[ 2 ];
			vo.id = paintingId;
			trace( this, "generated vo: " + vo );

			// Update easel.
			if( updateEasel ) {
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height )
				requestEaselUpdateSignal.dispatch( bmd );
			}

			// TODO: set or update model vo

			// Serialize data.
			var voBytes:ByteArray = vo.serialize();

			// Deliver to binary writer.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else {
				DesktopBinarySaveUtil.saveToDesktop( voBytes, CoreSettings.PAINTING_DESKTOP_DATA_FOLDER_NAME + "/painting-" + paintingId + CoreSettings.PAINTING_FILE_EXTENSION );
			}
		}
	}
}
