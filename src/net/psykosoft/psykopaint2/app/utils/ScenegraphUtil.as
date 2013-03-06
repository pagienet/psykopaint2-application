package net.psykosoft.psykopaint2.app.utils
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;

	public class ScenegraphUtil
	{
		public static function applyMaterialToAllChildMeshes( object:Object3D, material:MaterialBase, level:String = "" ):void {

			trace( "applyMaterialToAllChildMeshes: " + object + ", " + material );

			if( object is Mesh ) {
				trace( level + "object is mesh." );
				Mesh( object ).material = material;
			}
			else if( object is ObjectContainer3D ) {
				trace( level + "object is container." );
				var container:ObjectContainer3D = object as ObjectContainer3D;
				var len:uint = container.numChildren;
				for( var i:uint; i < len; ++i ) {
					var child:Object3D = container.getChildAt( i );
					applyMaterialToAllChildMeshes( ObjectContainer3D( child ), material, level + ">" );
				}
			}
		}
	}
}
