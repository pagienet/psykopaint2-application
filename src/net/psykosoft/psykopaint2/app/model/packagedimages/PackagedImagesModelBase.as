package net.psykosoft.psykopaint2.app.model.packagedimages
{

	import net.psykosoft.psykopaint2.app.model.packagedimages.vo.PackagedImageVO;

	public class PackagedImagesModelBase
	{
		private var _images:Vector.<PackagedImageVO>;

		public function PackagedImagesModelBase() {
		}

		public function set images( value:Vector.<PackagedImageVO> ):void {
			_images = value;
			reportUpdate( value );
		}

		public function getOriginal( id:String ):PackagedImageVO {
			for( var i:uint; i < _images.length; i++ ) {
				if( _images[ i ].id == id ) {
					return _images[ i ];
				}
			}
			throw new Error( this, "requested id not found: " + id );
		}

		protected function reportUpdate( images:Vector.<PackagedImageVO> ):void {
			// override.
		}
	}
}
