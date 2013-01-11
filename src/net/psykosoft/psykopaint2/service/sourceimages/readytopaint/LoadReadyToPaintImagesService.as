package net.psykosoft.psykopaint2.service.sourceimages.readytopaint
{

	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.model.sourceimages.SourceImagesModel;

	public class LoadReadyToPaintImagesService
	{
		[Inject]
		public var sourceImagesModel:SourceImagesModel;

		private var _file:File;
		private var _bulkLoader:BulkLoader;
		private var _thumbNames:Vector.<String>;

		private const FOLDER_PATH:String = "assets-packaged/source-images/";

		public function LoadReadyToPaintImagesService() {
			super();
			_file = new File( File.applicationDirectory.url + FOLDER_PATH );
			_bulkLoader = new BulkLoader( "ready-to-paint-images-loader" );
			_bulkLoader.addEventListener( BulkProgressEvent.COMPLETE, onAllThumbsLoaded );
			_bulkLoader.addEventListener( BulkProgressEvent.PROGRESS, onAllThumbsProgress );
		}

		public function loadThumbs():void {

			// TODO: review recurring calls

			Cc.log( this, "loadThumbs()." );

			// Obtain directory listing.
			var listing:Array = _file.getDirectoryListing();

			// Extract file names with "thumb" contained in their name.
			_thumbNames = new Vector.<String>();
			for( var i:uint; i < listing.length; i++ ) {
				var file:File = listing[ i ];
				if( file.name.indexOf( "thumb" ) != -1 ) {
					_thumbNames.push( file.url );
					_bulkLoader.add( file.url );
				}
			}
			Cc.info( this, _thumbNames );

			// Load all thumb image files.
			_bulkLoader.start();
		}

		private function onAllThumbsProgress( event:BulkProgressEvent ):void {
			Cc.log( this, "all progress: " + event.percentLoaded );
			// TODO: report this somewhere
		}

		private function onAllThumbsLoaded( event:BulkProgressEvent ):void {
			Cc.log( this, "all loaded" );

			// Produce all bitmapdatas.
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>();
			for( var i:uint; i < _thumbNames.length; i++ ) {
				bmds.push( _bulkLoader.getBitmapData( _thumbNames[ i ] ) );
			}
			Cc.log( this, "bmds: " + bmds );

			sourceImagesModel.thumbs = bmds;
		}
	}
}
