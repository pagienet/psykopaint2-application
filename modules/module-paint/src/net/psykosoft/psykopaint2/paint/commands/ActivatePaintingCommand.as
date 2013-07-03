package net.psykosoft.psykopaint2.paint.commands
{

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingActivatedSignal;

	import robotlegs.bender.framework.api.IContext;

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

		[Inject]
		public var context:IContext;

		private var _file:File;
		private var _vo:PaintingVO;

		public function ActivatePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Get painting data, translate and pass on to the drawing core.
			_vo = paintingDataModel.getVoWithId( paintingId );
			if( _vo.dataDeSerialized ) applyVo();
			else { // Need to read and de-serialize data.
				readVoData();
			}
		}

		private function readVoData():void {
			context.detain( this );
			// Identify file.
			var file:File = CoreSettings.RUNNING_ON_iPAD ? File.applicationStorageDirectory : File.desktopDirectory;
			_file = file.resolvePath( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_DATA_FILE_EXTENSION );
			_file.addEventListener( Event.COMPLETE, onFileRead );
			_file.load();
		}

		private function onFileRead( event:Event ):void {
			_file.removeEventListener( Event.COMPLETE, onFileRead );
			var serializer:PaintingSerializer = new PaintingSerializer();
			serializer.deSerializePaintingVoData( _file.data, _vo );
			_file = null;
			applyVo();
		}

		private function applyVo():void {
			var data:Vector.<ByteArray> = Vector.<ByteArray>( [ _vo.colorImageBGRA, _vo.heightmapImageBGRA, _vo.sourceImageARGB ] );
			canvasModel.loadLayers(data);
			notifyPaintingActivatedSignal.dispatch();
			context.release( this );
		}
	}
}
