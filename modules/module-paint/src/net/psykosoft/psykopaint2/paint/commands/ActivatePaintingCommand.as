package net.psykosoft.psykopaint2.paint.commands
{

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
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

		public function ActivatePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Read surface data.
			context.detain( this );
			var file:File = CoreSettings.RUNNING_ON_iPAD ? File.applicationStorageDirectory : File.desktopDirectory;
			_file = file.resolvePath( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_DATA_FILE_EXTENSION );
			_file.addEventListener( Event.COMPLETE, onFileRead );
			_file.load();
		}

		private function onFileRead( event:Event ):void {
			_file.removeEventListener( Event.COMPLETE, onFileRead );

			// De-serialize.
			var vo:PaintingDataVO = new PaintingDataVO();
			var serializer:PaintingSerializer = new PaintingSerializer();
			serializer.deSerializePaintingVoData( _file.data, vo );
			_file = null;

			// TODO: if we ever need to consider incoming canvas size, read dimensions from vo here
			canvasModel.loadLayers( vo.surfaces );
			notifyPaintingActivatedSignal.dispatch();
			context.release( this );
		}
	}
}
