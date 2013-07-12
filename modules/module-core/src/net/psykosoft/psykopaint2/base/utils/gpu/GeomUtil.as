package net.psykosoft.psykopaint2.base.utils.gpu
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Sprite3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class GeomUtil
	{
		/*public static function exploreMeshGeometry( mesh:Mesh ):void {

			var subGeom:SubGeometry = mesh.geometry.subGeometries[ 0 ];
			trace( "num vertices: " + subGeom.vertices.length / 3 + ", " + subGeom.numVertices );
			trace( "vertices: " + subGeom.vertices );

			// Explode mesh.
			var newVertices:Vector.<Number> = new Vector.<Number>();
			for( var i:uint; i < subGeom.vertices.length / 3; ++i ) {
				var index:uint = i * 3;
				var vx:Number = subGeom.vertices[ index + 0 ] + subGeom.vertexNormals[ index + 0 ] * 50;
				var vy:Number = subGeom.vertices[ index + 1 ] + subGeom.vertexNormals[ index + 1 ] * 50;
				var vz:Number = subGeom.vertices[ index + 2 ] + subGeom.vertexNormals[ index + 2 ] * 50;
				newVertices.push( vx, vy, vz );
				traceVertex( mesh, i, vx, vy, vz );
			}
			subGeom.updateVertexData( newVertices );

		}*/

		public static function tracePoints( object:ObjectContainer3D, points:Vector.<Vector3D> ):void {
			for( var i:uint; i < points.length; i++ ) {
				var point:Vector3D = points[ i ];
				traceVertex( object, i, point.x, point.y, point.z );
			}
		}

		public static function traceVertex( object:ObjectContainer3D, index:uint, vx:Number, vy:Number, vz:Number ):void {
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat();
			var size:Number = 16;
			format.size = size;
			tf.text = index + "";
			tf.setTextFormat( format );
			var bmd:BitmapData = new TrackedBitmapData( size, size, false, 0x00FF00 );
			bmd.draw( tf );
			var tracer:Sprite3D = new Sprite3D( new TextureMaterial( new BitmapTexture( bmd ) ), size, size );
			tracer.position = object.transform.transformVector( new Vector3D( vx, vy, vz ) );
			object.parent.addChild( tracer );
		}
	}
}
