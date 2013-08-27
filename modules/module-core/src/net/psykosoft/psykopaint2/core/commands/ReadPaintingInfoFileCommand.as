package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.events.Event;

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoFileReadSignal;

	public class ReadPaintingInfoFileCommand extends AsyncCommand
	{
		[Inject]
		public var fileName:String; // From signal.

		[Inject]
		public var notifyPaintingInfoFileReadSignal:NotifyPaintingInfoFileReadSignal;

		[Inject]
		public var ioAne:IOAneManager;

		private var _as3ReadUtil:BinaryIoUtil;

		override public function execute():void {

			trace( this, "execute()" );

//			readAS3();
			if( CoreSettings.RUNNING_ON_iPAD ) readANE(); else readAS3();
		}

		private function readAS3():void {
			if( !_as3ReadUtil ) {
				_as3ReadUtil = new BinaryIoUtil( CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP );
			}
			_as3ReadUtil.readBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + fileName, onAs3FileRead );
		}

		private function onAs3FileRead( bytes:ByteArray ):void {
			bytes.uncompress();
			onFileRead( bytes );
		}

		private function readANE():void {
			var bytes:ByteArray = new ByteArray();
	   		ioAne.extension.readWithDeCompression( bytes, fileName );
			onFileRead( bytes );
		}

		private function onFileRead( bytes:ByteArray ):void {

			trace( this, "file read: " + bytes.length + " bytes" );
			trace( this, "de-serializing vo..." );
			try {
				var deserializer:PaintingInfoDeserializer = new PaintingInfoDeserializer();
				deserializer.addEventListener( Event.COMPLETE, onVODeserialized );
				deserializer.deserialize( bytes );
			} catch( error:Error ) {
				notifyPaintingInfoFileReadSignal.dispatch( null );
				trace( this, "***WARNING*** Error de-serializing file." );
			}
		}

		private function onVODeserialized( event:Event ):void {
			var deserializer:PaintingInfoDeserializer = PaintingInfoDeserializer( event.target );
			var paintingInfoVO:PaintingInfoVO = deserializer.paintingInfoVO;
			deserializer.removeEventListener( Event.COMPLETE, onVODeserialized );
			trace( this, "produced vo: " + paintingInfoVO );
			notifyPaintingInfoFileReadSignal.dispatch( paintingInfoVO );
			if( _as3ReadUtil ) _as3ReadUtil.dispose();
			dispatchComplete( true );
		}
	}
}
