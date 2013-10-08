package net.psykosoft.psykopaint2.book.views.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.core.base.Geometry;
	import away3d.materials.TextureMaterial;
	//import away3d.materials.ColorMaterial;
	import away3d.core.base.Geometry;
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PlaneGeometry;

	import away3d.core.base.ISubGeometry;
	import away3d.modifiers.gpu.PageBender;
	import away3d.animators.ModifierAnimator;
 
	public class BookPage extends ObjectContainer3D
	{
		private const PAGE_WIDTH:uint = 970
		private const PAGE_HEIGHT:uint = 970;

		//1/1 ratio from 512, 34.
		private const FACTOR_MARGIN:Number = 0.06640625;

		private const STEP:uint = 10;

		private var _recto:Mesh;
		private var _verso:Mesh;
		//private var _shade:Mesh;

		private var _marginRecto:Mesh;
		private var _marginVerso:Mesh;

		private var _sharedGeom:Boolean;

		private var _rectoAnimator:ModifierAnimator;
		private var _versoAnimator:ModifierAnimator;
		private var _marginRectoAnimator:ModifierAnimator;
		private var _marginVersoAnimator:ModifierAnimator;
		private var _bend:PageBender;
		private var _lastRotation:Number;

		private var _lastDirection:int = -1;
		private var _factor:Number = 1;
		private var _increase:Number;
		private var _force:Number;
		private var _lastForce:Number;
		private var _isBlankRecto:Boolean;
		private var _isLocked:Boolean;

		function BookPage(materialRecto:TextureMaterial, marginRectoMaterial:TextureMaterial, materialVerso:TextureMaterial, marginVersoMaterial:TextureMaterial, usedBookPage:BookPage = null, isBlankRecto:Boolean = false):void
		{
			super();
			_lastRotation = 0;
			_isBlankRecto = isBlankRecto;
			
			if(usedBookPage){
				_sharedGeom = true;
				_recto = new Mesh(usedBookPage.recto.geometry, materialRecto);
				_verso = new Mesh(usedBookPage.verso.geometry, materialVerso);

				//_shade = new Mesh(usedBookPage.shade.geometry, usedBookPage.shade.material);
				
				_marginRecto = new Mesh(usedBookPage.marginRecto.geometry, marginRectoMaterial);
				_marginVerso = new Mesh(usedBookPage.marginVerso.geometry, marginVersoMaterial);

				addChild(_recto);
				addChild(_verso);
				addChild(_marginRecto);
				addChild(_marginVerso);

			} else {
				generate(materialRecto, marginRectoMaterial, materialVerso, marginVersoMaterial);
			}

			_increase = 1/STEP;

			if(!_isBlankRecto) {
				//this.rotationZ = _lastRotation = 180;
			//} else {
				initModifiers();
			}
		}

		public function set lock(b:Boolean):void
		{
			_isLocked = b;
			
			if(_isLocked){
				hide();
			} else {
				show();
			}
		}

		public function get lock():Boolean
		{
			return _isLocked;
		}


		public function show():void
		{
			if(!_isLocked) _recto.visible = _verso.visible = _marginRecto.visible = _marginVerso.visible = true;
		}
		public function hide():void
		{
			_recto.visible = _verso.visible = _marginRecto.visible = _marginVerso.visible = false;
		}

		public function set rotation(degrees:Number):void
		{
			if(_isLocked) return;

			this.rotationZ = _lastRotation = degrees;
		}

		//public function set shadeScale(val:Number):void
		//{
		//	_shade.scaleX = Math.abs(val);
		//}

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

 		public function get isBlankRecto():Boolean
 		{
 			return _isBlankRecto;
 		}

		private function initModifiers():void
		{
			_bend = new PageBender(PAGE_WIDTH, 1, 1, 1);

			_rectoAnimator = new ModifierAnimator(_bend);
			_marginRectoAnimator = new ModifierAnimator(_bend);
			_recto.animator = _rectoAnimator;
			_marginRecto.animator = _marginRectoAnimator;
			 
			_versoAnimator = new ModifierAnimator(_bend);
			_marginVersoAnimator = new ModifierAnimator(_bend);
 
			_verso.animator = _versoAnimator;
			_marginVerso.animator = _marginVersoAnimator;
			 
			bend(1, 1, 0);
		}

		//force -1/1  , origin 0/1, -45/45
		public function bend(force:Number, zeroOne:Number, foldRotation:Number):void
		{
			if(_isBlankRecto || _isLocked) return;

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

			if(!_isBlankRecto){
				_bend.clear();
				_bend = null;
				_rectoAnimator.dispose();
				_versoAnimator.dispose();
				_marginRectoAnimator.dispose();
				_marginVersoAnimator.dispose();
				_recto.animator = null;
				_verso.animator = null;
				_marginVerso.animator = null;
				_marginRecto.animator = null;
			}

			if(!_sharedGeom){
				_recto.geometry.dispose();
				_verso.geometry.dispose();
				_marginRecto.geometry.dispose();
				_marginVerso.geometry.dispose();
			}
			 
			_recto = null;
			_verso = null;
			_marginRecto = null;
			_marginVerso = null;
		}

		public function get recto():Mesh
		{
			return _recto;
		}
		public function get verso():Mesh
		{
			return _verso;
		}

		//public function get shade():Mesh
		//{
		//	return _shade;
		//}
 
		public function get marginRecto():Mesh
		{
			return _marginRecto;
		}
		public function get marginVerso():Mesh
		{
			return _marginVerso;
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

		private function generate(materialRecto:TextureMaterial, marginRectoMaterial:TextureMaterial, materialVerso:TextureMaterial, marginVersoMaterial:TextureMaterial):void
		{
			var rectoGeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT, 15, 15, true);
			_recto = new Mesh(rectoGeom, materialRecto);
			offsetGeometry(CompactSubGeometry(_recto.geometry.subGeometries[0]) );

			var rTopMargin:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT * FACTOR_MARGIN, 15, 1, true);
			var subgeom:CompactSubGeometry = CompactSubGeometry(rTopMargin.subGeometries[0]);
			offsetGeometry( subgeom);

			var subgeomBottom:CompactSubGeometry = new CompactSubGeometry();
			subgeomBottom.updateData(subgeom.vertexData.concat());
			subgeomBottom.updateIndexData(subgeom.indexData.concat());
			offsetUVs(subgeom, true);
			offsetUVs(subgeomBottom, false);
			mergeSubGeometries(subgeom, subgeomBottom);

			var geometry:Geometry = new Geometry();
			geometry.addSubGeometry(subgeom);

			_marginRecto = new Mesh(geometry, marginRectoMaterial);
			_marginVerso= new Mesh(geometry.clone(), marginVersoMaterial);
			invertFacesSubgeometry(CompactSubGeometry(_marginVerso.geometry.subGeometries[0]) );
 
			_verso = new Mesh(_recto.geometry.clone(), materialVerso);
			invertFacesSubgeometry(CompactSubGeometry(_verso.geometry.subGeometries[0]) );

			
			//var _shadegeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT+ ( (PAGE_HEIGHT * FACTOR_MARGIN) *2), 1, 1, true);
			//var _shadegeom:PlaneGeometry = new PlaneGeometry(PAGE_WIDTH, PAGE_HEIGHT*2, 1, 1, true);
			//invertFacesSubgeometry(CompactSubGeometry(_shade.geometry.subGeometries[0]) );
			//_shade = new Mesh(_verso.geometry.clone(), new ColorMaterial(0xff0000, 1));
			//_shade.y -= 3;

			if(!_isBlankRecto){
				addChild(_recto);
				addChild(_marginRecto);	
			}
			
			addChild(_verso);
 			addChild(_marginVerso);

			//addChild(_shade);
 			
			_recto.x =  _verso.x = _marginRecto.x = _marginVerso.x = 0;
		}

		private function invertFacesSubgeometry(subGeom:CompactSubGeometry):void
		{
			var i:uint, j:uint, len:uint, tStride:uint, tOffs:uint, nStride:uint, nOffs:uint, uStride:uint, uOffs:uint;
			var indices:Vector.<uint> = subGeom.indexData;
			var data:Vector.<Number> = subGeom.vertexData;

			nOffs = subGeom.vertexNormalOffset;
			nStride = subGeom.vertexNormalStride;
			len = subGeom.numVertices;
			tOffs = subGeom.vertexTangentOffset;
			tStride = subGeom.vertexTangentStride;
			uOffs = subGeom.UVOffset;
			uStride = subGeom.UVStride;

			var ind0:uint;
			var ind2:uint;
			
			for (i = 0; i < indices.length; i += 3) {
				ind0 = indices[i];
				indices[i] = indices[ind2 = i + 2];
				indices[ind2] = ind0;
			}
			
			for (j = 0; j < len; j++) {
				
				data[nOffs + j*nStride] *= -1;
				data[nOffs + j*nStride + 1] *= -1;
				data[nOffs + j*nStride + 2] *= -1;
				
				data[tOffs + j*tStride] *= -1;
				data[tOffs + j*tStride + 1] *= -1;
				data[tOffs + j*tStride + 2] *= -1;
				ind0 = uOffs + j*uStride;
				data[ind0] = 1 - data[ind0];
			}
			
			subGeom.updateData(subGeom.vertexData);
		}

		private function offsetGeometry(subGeometry:CompactSubGeometry, offset:uint = 0):void
		{
			subGeometry.autoDeriveVertexNormals = false;
			subGeometry.autoDeriveVertexTangents = false;

			var vertexData:Vector.<Number> = subGeometry.vertexData;
			var halfWidth:Number = PAGE_WIDTH *.5;

			//var nOffs:uint = subGeometry.vertexNormalOffset;
			//var ind:uint;

			//updating only the x or y
			for (var i:int = offset; i < vertexData.length; i+=13) {
				vertexData[i]+= halfWidth;

				//ind = i+nOffs;
				//vertexData[ind++] = 0;
				//vertexData[ind++] = 1;
				//vertexData[ind++] = 0;

				//vertexData[ind++] = 0;
				//vertexData[ind++] = 0;
				//vertexData[ind++] = 1;
			}

			subGeometry.updateData(vertexData);
		}

		private function mergeSubGeometries(reciever:CompactSubGeometry, source:CompactSubGeometry):void
		{
			var recieverData:Vector.<Number> = reciever.vertexData;
			var mergedData:Vector.<Number> = recieverData.concat(source.vertexData);
			var recieverIndexData:Vector.<uint> = reciever.indexData;
			var sourceIndexData:Vector.<uint> = source.indexData;

			var offset:uint = 0;
			for (var i:int = 0; i < recieverIndexData.length; i++){
				 if(recieverIndexData[i] > offset) offset = recieverIndexData[i];
			}
			offset++;

			for (i = 0; i < sourceIndexData.length; i++)
				sourceIndexData[i] = sourceIndexData[i]+offset;

			recieverIndexData = recieverIndexData.concat(sourceIndexData);
			reciever.updateData(mergedData);
			reciever.updateIndexData(recieverIndexData);

			source = null;
		}

		private function offsetUVs(subGeometry:CompactSubGeometry, isTopMargin:Boolean):CompactSubGeometry
		{
			var vertices:Vector.<Number> = subGeometry.vertexData;
			var halfHeight:Number = PAGE_HEIGHT *.5;
			var offsetMargin:Number = (PAGE_HEIGHT * FACTOR_MARGIN) *.5;
			var offset:Number = halfHeight+offsetMargin;
			var ratioUV:Number = PAGE_HEIGHT / (PAGE_HEIGHT * FACTOR_MARGIN);
			var i:uint;
			var uvOffset:uint = subGeometry.UVOffset+1;
			
			if(isTopMargin){

				for (i = 2; i < vertices.length; i+=13){
					vertices[i] += offset;
					vertices[i+8] /= ratioUV;
				}

			} else {

				for (i = 2; i < vertices.length; i+=13){
					vertices[i] -= offset;
					vertices[i+8] /= ratioUV;
					vertices[i+8] += 1-(1/ratioUV);
				}
			}

			subGeometry.updateData(vertices);

			return subGeometry;
		}

	}
}