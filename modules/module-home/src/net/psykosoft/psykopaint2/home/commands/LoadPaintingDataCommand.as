package net.psykosoft.psykopaint2.home.commands
{

	import flash.events.Event;
	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.home.signals.NotifyPaintingDataLoadedSignal;

	import robotlegs.bender.framework.api.IContext;

	public class LoadPaintingDataCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingModel;

		[Inject]
		public var context:IContext;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var notifyPaintingDataLoadedSignal : NotifyPaintingDataLoadedSignal;

		private var _file:File;

		public function LoadPaintingDataCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Read surface data.
			context.detain( this );
			var file:File = CoreSettings.RUNNING_ON_iPAD ? File.applicationStorageDirectory : File.desktopDirectory;
			_file = file.resolvePath( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION );
			_file.addEventListener( Event.COMPLETE, onFileRead );
			_file.load();
		}

		private function onFileRead( event:Event ):void {
			_file.removeEventListener( Event.COMPLETE, onFileRead );

			// De-serialize.
			var deserializer:PaintingDataDeserializer = new PaintingDataDeserializer();
			var vo:PaintingDataVO = deserializer.deserialize( _file.data );
			_file.data.clear();
			_file = null;

			notifyPaintingDataLoadedSignal.dispatch(vo);

			context.release( this );
		}
	}
}
