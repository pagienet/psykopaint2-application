package net.psykosoft.psykopaint2.book.views.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.core.base.CompactSubGeometry;

	import away3d.primitives.PlaneGeometry;

	import flash.geom.Vector3D;

	public class BookCraft extends ObjectContainer3D
	{
		private const PAGE_WIDTH:uint = 970;
		private const PAGE_HEIGHT:uint = 1095;

		private var _coverRight:Mesh;
		private var _backPage:Mesh;
		private var _rings:Rings;

		private var _offset : Vector3D = new Vector3D();

		function BookCraft (material:TextureMaterial, ringsMaterial:TextureMaterial):void
		{
			super();
			generateRings(ringsMaterial);
			generate(material);
		}

		public function disposeContent():void
		{
			_coverRight.material = null;
			_backPage.material = null;
			_rings.material = null;
			
			_coverRight.geometry.dispose();
			_backPage.geometry.dispose();
			_rings.geometry.dispose();
			 
			_coverRight = null;
			_backPage = null;
			_rings = null;
		}

		public function get coverRight():Mesh
		{
			return _coverRight;
		}
		
		public function show():void
		{
			_coverRight.visible = _rings.visible = true;
		}
 
		public function setClosedState():void
		{
			_coverRight.rotationZ = 0;
			this.rotationY = 10;
 
			x = -500 + _offset.x;
			y = _offset.y;
			z = 100 + _offset.z;//70;

		}
		public function setOpenState():void
		{
			_coverRight.rotationZ = 180;
			x = _offset.x;
			y = _offset.x;
			z = _offset.x;
		}

		private function generateRings(material:TextureMaterial):void
		{
			_rings = new Rings(material);
			addChild(_rings);
		}
		 
		private function generate(material:TextureMaterial):void
		{
			var rectoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 1, 1, true);
			_coverRight = new Mesh(rectoGeom, material);
			offsetGeometry(CompactSubGeometry(_coverRight.geometry.subGeometries[0]) );
			_backPage = new Mesh(_coverRight.geometry.clone(), material);

			_backPage.y = -10;
			_coverRight.y = 30;

			addChild(_backPage);
			addChild(_coverRight);

			_coverRight.visible = _rings.visible = false;
		}

		private function offsetGeometry(subGeometry:CompactSubGeometry):void
		{
			var vertexData:Vector.<Number> = subGeometry.vertexData;
			var halfWidth:Number = PAGE_WIDTH *.5;

			for (var i:int = 0; i < vertexData.length; i+=13)
				vertexData[i]+= halfWidth;

			subGeometry.updateData(vertexData);
		}

		public function get offset() : Vector3D
		{
			return _offset;
		}

		public function set offset(value : Vector3D) : void
		{
			var diff : Vector3D = value.subtract(_offset);
			x += diff.x;
			y += diff.y;
			z += diff.z;
			_offset = value;
		}
	}
}