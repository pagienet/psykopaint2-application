package net.psykosoft.psykopaint2.app.service.packagedimages
{

	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.app.model.packagedimages.vo.PackagedImageVO;

	public class LoadPackagedImagesServiceBase
	{
		private var _file:File;
		private var _bulkLoader:BulkLoader;
		private var _thumbNames:Vector.<String>;
		private var _originalNames:Vector.<String>;

		protected var FOLDER_PATH:String;
		protected var DUPLICATE_COUNT:uint = 1;

		public function LoadPackagedImagesServiceBase() {
			var path:String = File.applicationDirectory.url + FOLDER_PATH;
			trace( this, "path: " + path );
			_file = new File( path );
			_bulkLoader = new BulkLoader( FOLDER_PATH );
			_bulkLoader.addEventListener( BulkProgressEvent.COMPLETE, onAllThumbsLoaded );
			_bulkLoader.addEventListener( BulkProgressEvent.PROGRESS, onAllThumbsProgress );
		}

		public function loadThumbs():void {

			// TODO: review recurring calls

			Cc.log( this, "loadThumbs()." );

			// Obtain directory listing.
			var listing:Array;
			try {
				listing = _file.getDirectoryListing();
				traceListingNames( listing );
			}
			catch( e:Error ) {
				throw new Error( "Could not find packaged assets. If you are compiling for desktop, make sure the psykopaint-application/assets-packaged folder is in your bin folder." );
			}

			// Extract file names with "thumb" contained in their name.
			_thumbNames = new Vector.<String>();
			_originalNames = new Vector.<String>();
			for( var i:uint; i < listing.length; i++ ) {
				var file:File = listing[ i ];
				if( file.name.indexOf( "thumb" ) != -1 ) {
					_thumbNames.push( file.url );
				}
				else {
					_originalNames.push( file.url );
				}
				_bulkLoader.add( file.url );
			}
			Cc.info( this, _thumbNames );

			// Load all thumb image files.
			_bulkLoader.start();
		}

		private function traceListingNames( listing:Array ):void {
			trace( this, "files in listing: " );
			var len:uint = listing.length;
			for( var i:uint; i < len; ++i ) {
				var file:File = listing[ i ];
				trace( "file " + i + ": " + file.nativePath );
			}
		}

		private function onAllThumbsProgress( event:BulkProgressEvent ):void {
			Cc.log( this, "all progress: " + event.percentLoaded );
			// TODO: report this somewhere
		}

		private function onAllThumbsLoaded( event:BulkProgressEvent ):void {
			Cc.log( this, "all loaded" );

			var i:uint, j:uint;

			// Produce all bitmapdatas.
			var images:Vector.<PackagedImageVO> = new Vector.<PackagedImageVO>();
			for( i = 0; i < _thumbNames.length; i++ ) {
				for( j = 0; j < DUPLICATE_COUNT; j++ ) { // TODO: temporarily adding multiple items for tests
					var vo:PackagedImageVO = new PackagedImageVO( _thumbNames[ i ] );
					vo.thumbBmd = _bulkLoader.getBitmapData( _thumbNames[ i ] );
					vo.originalBmd = _bulkLoader.getBitmapData( _originalNames[ i ] );
					images.push( vo );
				}
			}
			images = images.sort( randomSort );
			Cc.log( this, "images: " + images );

			reportImages( images );
		}

		protected function reportImages( images:Vector.<PackagedImageVO> ):void {
			// override
		}

		private function randomSort( itemA:Object, itemB:Object ):Number {
			return Math.random() > 0.5 ? 1 : -1;
		}
	}
}
