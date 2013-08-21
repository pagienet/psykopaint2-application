package net.psykosoft.psykopaint2.book.views.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.core.base.Geometry;
	import away3d.materials.TextureMaterial;
	import away3d.materials.MaterialBase;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;

	import flash.geom.Matrix3D;

	public class BookCraft extends ObjectContainer3D
	{
		private var _coverRight:Mesh;
		private var _coverLeft:Mesh;
		private var _coverCenter:Mesh;

		function BookCraft (material:TextureMaterial):void
		{
			super();
			generate(material);
		}

		public function disposeContent():void
		{
			_coverRight.material = null;
			_coverLeft.material = null;
			_coverCenter.material = null;

			_coverRight.geometry.dispose();
			_coverLeft.geometry.dispose();
			_coverCenter.geometry.dispose();

			_coverRight = null;
			_coverLeft = null;
			_coverCenter = null;
		}

		public function get coverRight():Mesh
		{
			return _coverRight;
		}
		public function get coverLeft():Mesh
		{
			return _coverLeft;
		}
		public function get coverCenter():Mesh
		{
			return _coverCenter;
		}
 
		public function setClosedState():void
		{
			_coverRight.rotationZ = -180;
			_coverRight.y = 23;
			_coverRight.x = -13;

			_coverCenter.rotationZ = -90;
			_coverCenter.y = 15;
 
			this.z = 70;
			this.x = -500;
 
		}
		public function setOpenState():void
		{
			_coverRight.rotationZ = 0;
			_coverRight.y = 0;
			_coverRight.x = 0;

			_coverCenter.rotationZ = 0;
			_coverCenter.y = 0;

			this.x = 0;
		}
 
		private function generate(material:TextureMaterial):void
		{
			var centercover_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0.11238899827003479,-4.457670211791992,-1.0999900102615356,1]);
			_coverCenter = buildMesh(new Geometry(), centercover_rd, "centercover", material);

			var centercover_data:Array =
			[Vector.<uint>([0,1,2,1,3,4,5,6,7,6,5,8,9,10,11,10,9,12,13,14,15,14,13,16,17,18,19,18,17,20,21,22,23,22,21,24]),
			Vector.<Number>([13.4442,-24.6314,-499.9,13.4442,-5.39269,500.1,13.4442,-24.6314,500.1,13.4442,-24.6314,-499.9,13.4442,-5.39269,-499.9,-13.7956,-24.6314,500.1,-13.7956,-5.39269,-499.9,-13.7956,-24.6314,-499.9,-13.7956,-5.39269,500.1,-13.7956,-24.6314,500.1,13.4442,-5.39269,500.1,-13.7956,-5.39269,500.1,13.4442,-24.6314,500.1,-13.7956,-5.39269,-499.9,13.4442,-24.6314,-499.9,-13.7956,-24.6314,-499.9,13.4442,-5.39269,-499.9,13.4442,-5.39269,500.1,-13.7956,-5.39269,-499.9,-13.7956,-5.39269,500.1,13.4442,-5.39269,-499.9,-13.7956,-24.6314,500.1,13.4442,-24.6314,-499.9,13.4442,-24.6314,500.1,-13.7956,-24.6314,-499.9]),
			Vector.<Number>([0.00656804,0.99184674,0.0229259,0.006770000000000054,0.00656821,0.006770000000000054,0.00656804,0.99184674,0.0229257,0.99184674,0.00656821,0.006770000000000054,0.0229257,0.99184674,0.00656804,0.99184674,0.0229259,0.006770000000000054,0.0290124,0.05634399999999995,0.00714645,0.006884000000000001,0.00714661,0.05634399999999995,0.0290123,0.006884000000000001,0.502183,0.9844835,0.538607,0.99801483,0.502183,0.99801483,0.538607,0.9844835,0.52431,0.0019529999999999825,0.503906,0.999662936,0.503906,0.0019529999999999825,0.52431,0.999662936,0.00491715,0.0019529999999999825,0.0250436,0.999662936,0.0250436,0.0019529999999999825,0.00491715,0.999662936])];
			fillData(_coverCenter, centercover_data);

			var leftcover_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,14.180399894714355,3.6471800804138184,0.8999900221824646,1]);
			_coverLeft = buildMesh(new Geometry(), leftcover_rd, "leftcover", material);

			var leftcover_data:Array =
			[Vector.<uint>([0,1,2,1,3,4,5,6,7,6,5,8,9,10,11,10,9,12,13,14,15,14,13,16,17,18,19,18,17,20,21,22,23,22,21,24]),
			Vector.<Number>([-0.175676,-24.6314,500.1,999.824,-24.6314,-499.9,999.824,-24.6314,500.1,-0.175676,-24.6314,500.1,-0.175764,-24.6314,-499.9,999.824,-5.39269,500.1,-0.175764,-5.39269,-499.9,-0.175676,-5.39269,500.1,999.824,-5.39269,-499.9,-0.175764,-5.39269,-499.9,999.824,-24.6314,-499.9,-0.175764,-24.6314,-499.9,999.824,-5.39269,-499.9,-0.175676,-24.6314,500.1,999.824,-5.39269,500.1,-0.175676,-5.39269,500.1,999.824,-24.6314,500.1,-0.175676,-24.6314,500.1,-0.175764,-5.39269,-499.9,-0.175764,-24.6314,-499.9,-0.175676,-5.39269,500.1,999.824,-24.6314,-499.9,999.824,-5.39269,500.1,999.824,-24.6314,500.1,999.824,-5.39269,-499.9]),
			Vector.<Number>([0.49799,0,0,1,0,0,0.49799,0,0.49799,1,1,1,0.512695,0,0.512695,1,1,0,0.0171009,0.99391899,0.0247738,0.007724999999999982,0.0247739,0.99391899,0.0171009,0.007724999999999982,0.0202114,0.9899373,0.0125385,0.003743000000000052,0.0125385,0.9899373,0.0202114,0.003743000000000052,0.50424,0.012028000000000039,0.513501,0.9830402,0.50424,0.9830402,0.513501,0.012028000000000039,0.0237054,0.005282000000000009,0.0179923,0.9387978,0.0237054,0.9387978,0.0179922,0.005282000000000009])];
			fillData(_coverLeft, leftcover_data);

			var rightcover_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-13.81980037689209,3.6471800804138184,0.8999919891357422,1]);
			_coverRight = buildMesh(new Geometry(), rightcover_rd, "rightcover", material);

			var rightcover_data:Array =
			[Vector.<uint>([0,1,2,1,3,4,5,6,7,6,5,8,9,10,11,10,9,12,13,14,15,14,13,16,17,18,19,18,17,20,21,22,23,22,21,24]),
			Vector.<Number>([-0.175764,-24.6314,-499.9,-0.175676,-5.39269,500.1,-0.175676,-24.6314,500.1,-0.175764,-24.6314,-499.9,-0.175764,-5.39269,-499.9,-1000.18,-24.6314,500.1,-1000.18,-5.39269,-499.9,-1000.18,-24.6314,-499.9,-1000.18,-5.39269,500.1,-1000.18,-24.6314,500.1,-0.175676,-5.39269,500.1,-1000.18,-5.39269,500.1,-0.175676,-24.6314,500.1,-1000.18,-5.39269,-499.9,-0.175764,-24.6314,-499.9,-1000.18,-24.6314,-499.9,-0.175764,-5.39269,-499.9,-0.175676,-5.39269,500.1,-1000.18,-5.39269,-499.9,-1000.18,-5.39269,500.1,-0.175764,-5.39269,-499.9,-1000.18,-24.6314,500.1,-0.175764,-24.6314,-499.9,-0.175676,-24.6314,500.1,-1000.18,-24.6314,-499.9]),
			Vector.<Number>([0.50424,0.9830402,0.513501,0.012028000000000039,0.50424,0.012028000000000039,0.50424,0.9830402,0.513501,0.9830402,0.0237054,0.9387978,0.0179922,0.005282000000000009,0.0237054,0.005282000000000009,0.0179923,0.9387978,0.0184373,0.99497116,0.0107643,0.008778999999999981,0.0107644,0.99497116,0.0184373,0.008778999999999981,0.0200552,1.00104803,0.0277281,0.0011839999999999629,0.0277281,1.00104803,0.0200552,0.0011839999999999629,0.510742,0,0.998047,1,0.998047,0,0.510742,1,0.49799,0,0,1,0,0,0.49799,1])];
			fillData(_coverRight, rightcover_data);

		}

		private function fillData(m:Mesh, mData:Array):void
		{
			for(var i:uint = 0;i<mData.length; i+=5)
				fillSubgeometry(m, mData[i], mData[i+1], mData[i+2]);
		}

		private function buildMesh(geometry:Geometry, rawData:Vector.<Number>, name:String, material:MaterialBase = null):Mesh
		{
			var mesh:Mesh = new Mesh( geometry, material);
			var t:Matrix3D = new Matrix3D(rawData);
			mesh.transform = t;
			mesh.name = name;
			 
			addChild(mesh);

			return mesh;
		}

		private function fillSubgeometry(mesh:Mesh, indices:Vector.<uint>, vertices:Vector.<Number>, uvs:Vector.<Number>):void
		{
			var subGeom:SubGeometry = new SubGeometry();
			subGeom.updateVertexData(vertices);
			subGeom.updateUVData(uvs);
			subGeom.updateIndexData(indices);
			subGeom.autoDeriveVertexNormals = true;
			subGeom.autoDeriveVertexTangents = true;
			mesh.geometry.addSubGeometry(subGeom);
		}

	}
}