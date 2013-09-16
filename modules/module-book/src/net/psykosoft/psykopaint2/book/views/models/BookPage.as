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
	import away3d.modifiers.gpu.PageBender;
	import away3d.animators.ModifierAnimator;

	public class BookPage extends ObjectContainer3D
	{
		private const PAGE_WIDTH:uint = 970
		private const PAGE_HEIGHT:uint = 970;
		private const STEP:uint = 10;

		private var _recto:Mesh;
		private var _verso:Mesh;
		private var _sharedGeom:Boolean;

		private var _rectoAnimator:ModifierAnimator;
		private var _versoAnimator:ModifierAnimator;
		private var _bend:PageBender;
		private var _lastRotation:Number;

		private var _lastDirection:int = -1;
		private var _factor:Number = 1;
		private var _increase:Number;
		private var _force:Number;
		private var _lastForce:Number;

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

			_increase = 1/STEP;

			initModifiers();
		}

		public function show():void
		{
			_recto.visible = _verso.visible = true;
		}
		public function hide():void
		{
			_recto.visible = _verso.visible = false;
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
			_bend = new PageBender(PAGE_WIDTH, 1, 1, 1);
			 
			_rectoAnimator = new ModifierAnimator(_bend);
			_versoAnimator = new ModifierAnimator(_bend);
			_recto.animator = _rectoAnimator;
			_verso.animator = _versoAnimator;

			bend(1, 1, 0);
		}

		//force -1/1  , origin 0/1, -45/45
		public function bend(force:Number, zeroOne:Number, foldRotation:Number):void
		{
			if(force>.99) force = .99;
			if(force<-.99) force = -.99;

			_force = force;

			if(_factor<1) force = interpolateForce(_force);
			
			_bend.force = force;
			var origin:Number = Math.abs(zeroOne)*PAGE_WIDTH;
			if(origin<1) origin = 1;
			_bend.origin = origin;
			_bend.foldRotation = foldRotation;
		}
 
		public function disposeContent():void
		{
			_recto.material = null;
			_verso.material = null;

			_bend.clear();
			_bend = null;
			_rectoAnimator.dispose();
			_versoAnimator.dispose();
			_recto.animator = null;
			_verso.animator = null;

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

		public function set direction(dir:int):void
		{
			if(_lastDirection != dir){
				_lastDirection = dir;
				_lastForce = _force;
				_factor = 0;
			}
		}
  
		private function interpolateForce(destForce:Number):Number
		{
			if(_factor == 1) return destForce;
			
			var currentForce:Number = _lastForce*(1-_factor) + destForce*_factor;
			_factor += _increase;
			
			if(_factor >= 1) _factor = 1;
	
			return currentForce;
		}
 
		private function generate(materialRecto:TextureMaterial, materialVerso:TextureMaterial):void
		{
			var rectoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 15, 15, true);
			_recto = new Mesh(rectoGeom, materialRecto);
			offsetGeometry(_recto);
			addChild(_recto);

			var versoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 15, 15, true);
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