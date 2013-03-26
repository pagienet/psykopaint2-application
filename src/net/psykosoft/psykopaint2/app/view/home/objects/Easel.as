package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	public class Easel extends ObjectContainer3D
	{
		public function Easel() {
			super();

			var cube:Mesh = new Mesh( new CubeGeometry( 1000, 500, 25 ), new ColorMaterial( 0xFF0000 ) );
			addChild( cube );
		}

		override public function dispose():void {
			// TODO...
			super.dispose();
		}

		public function get width():Number {
			return 1000;
		}
	}
}
