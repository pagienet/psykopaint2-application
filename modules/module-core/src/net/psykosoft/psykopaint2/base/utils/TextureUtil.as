package net.psykosoft.psykopaint2.base.utils
{

	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;

	import br.com.stimuli.loading.BulkLoader;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	public class TextureUtil
	{
		private static const MAX_SIZE:uint = 2048;

		public static function createPlaneThatFitsNonPowerOf2TransparentImage( image:BitmapData, stage3dProxy:Stage3DProxy ):Mesh {

			// Obtain "safe" ( power of 2 sized image ) from the original.
			var safeImage:BitmapData = TextureUtil.ensurePowerOf2ByCentering( image );

			// Remember original image and safe image dimensions.
			var imageDimensions:Point = new Point( image.width, image.height );
			var textureDimensions:Point = new Point( safeImage.width, safeImage.height );

			// Create texture from image.
			var texture:BitmapTexture = new BitmapTexture( safeImage );
			texture.getTextureForStage3D( stage3dProxy ); // Force image creation before the disposal of the bitmap data.
			image.dispose();
			safeImage.dispose();

			// Create material.
			var material:TextureMaterial = new TextureMaterial( texture );
			material.mipmap = false;
			material.smooth = true;

			// Build geometry.
			// Note: Plane takes original image size ( not power of 2 dimensions ) and shifts and re-scales uvs
			// so that the image perfectly fits in the plane without using transparency on the edges.
			var dw:Number = ( ( textureDimensions.x - imageDimensions.x ) / 2 ) / textureDimensions.x; // TODO: math can be optimized
			var dh:Number = ( ( textureDimensions.y - imageDimensions.y ) / 2 ) / textureDimensions.y;
			var dsw:Number = textureDimensions.x / imageDimensions.x;
			var dsh:Number = textureDimensions.y / imageDimensions.y;
			var planeGeometry:PlaneGeometry = new PlaneGeometry( imageDimensions.x, imageDimensions.y );
			var subGeometry:CompactSubGeometry = planeGeometry.subGeometries[ 0 ] as CompactSubGeometry;
			var combinedVertexData:Vector.<Number> = subGeometry.vertexData;
			var len:uint = combinedVertexData.length / 13; // See CompactSubGeometry.as, updateData()
			for( var i:uint = 0; i < len; i++ ) { // Sweeps vertices.
				var ii:uint = i * 13;
				combinedVertexData[ ii + 9  ] = combinedVertexData[ ii + 9  ] / dsw + dw;
				combinedVertexData[ ii + 10 ] = combinedVertexData[ ii + 10 ] / dsh + dh;
			}
			subGeometry.updateData( combinedVertexData );

			// Build mesh.
			var plane:Mesh = new Mesh( planeGeometry, material );

			return plane;

		}

		public static function ensurePowerOf2ByScaling( bitmapData:BitmapData, scale:Number = 1 ):BitmapData {

//			trace( "TextureUtil - ensurePowerOf2ByScaling --------------------------" );

			if( isDimensionValid( bitmapData.width ) && isDimensionValid( bitmapData.height ) ) {
				return bitmapData;
			}

			var origWidth:int = bitmapData.width;
			var origHeight:int = bitmapData.height;
//			trace( "ensurePowerOf2ByScaling - original: " + origWidth + ", " + origHeight );
			var legalWidth:int = getNextPowerOfTwo( origWidth );
			var legalHeight:int = getNextPowerOfTwo( origHeight );
//			trace( "ensurePowerOf2ByScaling - altered: " + legalWidth + ", " + legalHeight );

			if( legalWidth > origWidth || legalHeight > origHeight ) {
				var modifiedBmd:BitmapData = new BitmapData( scale * legalWidth, scale * legalHeight, bitmapData.transparent, 0 );
				var transform:Matrix = new Matrix();
				transform.scale( scale * legalHeight / origWidth, scale * legalHeight / origHeight );
				modifiedBmd.draw( bitmapData, transform );
				bitmapData = modifiedBmd;
			}

			return bitmapData;

		}

		public static function ensurePowerOf2ByCentering( bitmapData:BitmapData ):BitmapData {

//			trace( "TextureUtil - ensurePowerOf2ByCentering - is source transparent? " + bitmapData.transparent );

			if( isDimensionValid( bitmapData.width ) && isDimensionValid( bitmapData.height ) ) {
				return bitmapData;
			}

			var origWidth:int = bitmapData.width;
			var origHeight:int = bitmapData.height;
//			trace( "ensurePowerOf2 - original: " + origWidth + ", " + origHeight );
			var legalWidth:int = getNextPowerOfTwo( origWidth );
			var legalHeight:int = getNextPowerOfTwo( origHeight );
//			trace( "ensurePowerOf2 - altered: " + legalWidth + ", " + legalHeight );

			if( legalWidth > origWidth || legalHeight > origHeight ) {
				var modifiedBmd:BitmapData = new BitmapData( legalWidth, legalHeight, bitmapData.transparent, 0 );
				var transform:Matrix = new Matrix();
				transform.translate(
						( legalWidth - origWidth ) / 2,
						( legalHeight - origHeight ) / 2
				);
				modifiedBmd.draw( bitmapData, transform );
				bitmapData = modifiedBmd;
			}

			return bitmapData;
		}

		private static function isDimensionValid( d:uint ):Boolean {
			return d >= 1 && d <= MAX_SIZE && isPowerOfTwo( d );
		}

		private static function getNextPowerOfTwo( number:int ):int {
			if( number > 0 && (number & (number - 1)) == 0 ) // see: http://goo.gl/D9kPj
				return number;
			else {
				var result:int = 1;
				while( result < number ) result <<= 1;
				return result;
			}
		}

		private static function isPowerOfTwo( value:int ):Boolean {
			return value ? ((value & -value) == value) : false;
		}

		public static function getAtfMaterial( bundle:String, id:String, view:View3D ):TextureMaterial {
			return new TextureMaterial( getAtfTexture( bundle, id, view ) );
		}

		public static function getBitmapMaterial( bundle:String, id:String, view:View3D ):TextureMaterial {
			return new TextureMaterial( getBitmapTexture( bundle, id, view ) );
		}

		public static function getAtfTexture( bundle:String, id:String, view:View3D ):ATFTexture {
			var bytes:ByteArray = BulkLoader.getLoader( bundle ).getBinary( id, true );
			var texture:ATFTexture = new ATFTexture( bytes );
			texture.getTextureForStage3D( view.stage3DProxy );
			bytes.clear();
			return texture;
		}

		public static function getBitmapTexture( bundle:String, id:String, view:View3D ):BitmapTexture {
			var bmd:BitmapData = BulkLoader.getLoader( bundle ).getBitmapData( id, true );
			var texture:BitmapTexture = new BitmapTexture( bmd );
			texture.getTextureForStage3D( view.stage3DProxy );
			bmd.dispose();
			return texture;
		}
	}
}
