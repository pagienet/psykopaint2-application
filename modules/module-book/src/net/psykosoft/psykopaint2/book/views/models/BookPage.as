package net.psykosoft.psykopaint2.book.views.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.core.base.Geometry;
	import away3d.materials.TextureMaterial;
	import away3d.core.base.Geometry;
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PlaneGeometry;

	import away3d.tools.helpers.MeshHelper;
	import away3d.modifiers.gpu.Bend;
	import away3d.animators.ModifierAnimator;

	public class BookPage extends ObjectContainer3D
	{
		private const PAGE_WIDTH:uint = 970
		private const PAGE_HEIGHT:uint = 970;

		private var _recto:Mesh;
		private var _verso:Mesh;
		private var _sharedGeom:Boolean;

		private var _rectoAnimator:ModifierAnimator;
		private var _versoAnimator:ModifierAnimator;
		private var _bend:Bend;
		private var _lastRotation:Number;

		function BookPage(materialRecto:TextureMaterial, materialVerso:TextureMaterial, usedBookPage:BookPage = null):void
		{
			super();
			_lastRotation = 0;
			
			if(usedBookPage){
				_sharedGeom = true;
				_verso = new Mesh(usedBookPage.verso.geometry, materialVerso);
				_recto = new Mesh(usedBookPage.recto.geometry, materialRecto);
				addChild(_recto);
				addChild(_verso);
			} else {
				generate(materialRecto, materialVerso);
			}

			initModifiers();
		}

		public function set rotation(degrees:Number):void
		{
			this.rotationZ = _lastRotation = degrees;
		}
		public function get lastRotation():Number
		{
			return _lastRotation;
		}
		public function get pageWidth():uint
 		{
 			return PAGE_WIDTH;
 		}
 		public function get pageHeight():uint
 		{
 			return PAGE_HEIGHT;
 		}

		private function initModifiers():void
		{
			_bend = new Bend(PAGE_WIDTH, 1, 1, 1);
			 
			_rectoAnimator = new ModifierAnimator(_bend);
			_versoAnimator = new ModifierAnimator(_bend);
			_recto.animator = _rectoAnimator;
			_verso.animator = _versoAnimator;

			bend(1, 1);
		}

		//force -1/1  , origin 0/1
		public function bend(force:Number, zeroOne:Number):void
		{
			if(force>.98) force = .98;
			if(force<-.98) force = -.98;
			_bend.force = force;
			var origin:Number = Math.abs(zeroOne)*PAGE_WIDTH;
			if(origin<1) origin = 2;
			_bend.origin = origin;
		}
 
		public function disposeContent():void
		{
			_recto.material = null;
			_verso.material = null;

			_rectoAnimator.dispose();
			_versoAnimator.dispose();
			_recto.animator = null;
			_verso.animator = null;
			_bend = null;
					
			if(!_sharedGeom){
				_recto.geometry.dispose();
				_verso.geometry.dispose();
			}
			 
			_recto = null;
			_verso = null;
		}

		public function get recto():Mesh
		{
			return _recto;
		}
		public function get verso():Mesh
		{
			return _verso;
		}

		private function generate(materialRecto:TextureMaterial, materialVerso:TextureMaterial):void
		{
			var rectoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 20, 1, true);
			_recto = new Mesh(rectoGeom, materialRecto);
			offsetGeometry(_recto);
			addChild(_recto);

			var versoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 20, 1, true);
			_verso = new Mesh(versoGeom, materialVerso);
			offsetGeometry(_verso);

			MeshHelper.invertFaces(_verso, true);
			addChild(_verso);
			
			_verso.x = _recto.x = 0;
		}

		private function offsetGeometry(mesh:Mesh):void
		{
			var subGeometry:CompactSubGeometry = CompactSubGeometry( mesh.geometry.subGeometries[0] );
			var vertices:Vector.<Number> = subGeometry.vertexData;
 
			var halfWidth:Number = PAGE_WIDTH *.5;
			//updating only the x in this case
			for (var i:int = 0; i < vertices.length; i+=13) {
				vertices[i]+= halfWidth; 
			}

			subGeometry.updateData(vertices);
		}

	}
}