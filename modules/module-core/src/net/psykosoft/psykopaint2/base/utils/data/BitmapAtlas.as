package net.psykosoft.psykopaint2.base.utils.data
{

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class BitmapAtlas
	{
		private var _bmd:BitmapData;
		private var _names:Vector.<String>;
		private var _regions:Dictionary;
		private var _frames:Dictionary;
		private var _subTextures:Dictionary;

		public function BitmapAtlas( bmd:BitmapData, xml:XML ) {
			super();
			_bmd = bmd;
			parseAtlasXml( xml );
		}

		private function parseAtlasXml( atlasXml:XML ):void {
			_names = new Vector.<String>();
			_regions = new Dictionary();
			_frames = new Dictionary();
			_subTextures = new Dictionary();
			for each ( var subTexture:XML in atlasXml.SubTexture ) {
				var name:String = subTexture.attribute( "name" );
				var x:Number = parseFloat( subTexture.attribute( "x" ) );
				var y:Number = parseFloat( subTexture.attribute( "y" ) );
				var width:Number = parseFloat( subTexture.attribute( "width" ) );
				var height:Number = parseFloat( subTexture.attribute( "height" ) );
				var frameX:Number = parseFloat( subTexture.attribute( "frameX" ) );
				var frameY:Number = parseFloat( subTexture.attribute( "frameY" ) );
				var frameWidth:Number = parseFloat( subTexture.attribute( "frameWidth" ) );
				var frameHeight:Number = parseFloat( subTexture.attribute( "frameHeight" ) );
				var region:Rectangle = new Rectangle( x, y, width, height );
				var frame:Rectangle = frameWidth > 0 && frameHeight > 0 ? new Rectangle( frameX, frameY, frameWidth, frameHeight ) : null;
//				trace( this, "region '" + name + "': " + region );
//				trace( this, "frame '" + name + "': " + frame );
				_names.push( name );
				_regions[ name ] = region;
				_frames[ name ] = frame;
			}
		}

		public function getSubTextureForId( id:String ):BitmapData {
//			trace( this, "getting sub texture for id: " + id );
			if( _subTextures[ id ] ) return _subTextures[ id ];
			var region:Rectangle = _regions[ id ];
			var bmd:BitmapData = new BitmapData( region.width, region.height, false, 0 );
			var mat:Matrix = new Matrix();
			mat.translate( -region.x, -region.y );
			bmd.draw( _bmd, mat );
			_subTextures[ id ] = bmd;
			return bmd;
		}

		public function get names():Vector.<String> {
			return _names;
		}

		public function dispose():void {
			_bmd.dispose();
			_bmd = null;
			for each( var bmd:BitmapData in _subTextures ) {
				bmd.dispose();
			}
			_subTextures = null;
			_regions = null;
			_frames = null;
			_names = null;
		}
	}
}
