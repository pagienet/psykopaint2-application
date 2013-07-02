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
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
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
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			trace( this, "incoming painting id: " + paintingId );

			// Need to create a new id and vo?
			var vo:PaintingVO;
			if( paintingId == "new" || paintingId == "" ) {

				// Create id and focus model on it.
				var nowDate:Date = new Date();
				var dateMs:Number = nowDate.getTime();
				paintingId = userModel.uniqueUserId + "-" + dateMs;
				trace( this, "creating a new id: " + paintingId );
				paintingModel.focusedPaintingId = paintingId;

				// Produce data vo.
				vo = new PaintingVO();
				vo.id = paintingId;
				paintingModel.addSinglePaintingData( vo );
			}
			else { // Otherwise just retrieve the vo.
				vo = paintingModel.getVoWithId( paintingId );
			}

			// Update vo.
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayers();
			var hr:Boolean = CoreSettings.RUNNING_ON_RETINA_DISPLAY;
			vo.fileVersion = CoreSettings.PAINTING_FILE_VERSION;
			vo.lastSavedOnDateMs = dateMs;
			vo.width = hr ? 2048 : 1024;
			vo.height = hr ? 1536 : 768;
			vo.colorImageARGB = imagesRGBA[ 0 ];
			vo.heightmapImageARGB = imagesRGBA[ 1 ];
			vo.sourceImageARGB = imagesRGBA[ 2 ];
			trace( this, "using vo: " + vo );

			// Update easel.
			if( updateEasel ) {
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height );
				requestEaselUpdateSignal.dispatch( bmd );
			}

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
