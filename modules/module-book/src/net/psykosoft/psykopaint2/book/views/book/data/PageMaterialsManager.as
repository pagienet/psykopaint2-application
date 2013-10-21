package net.psykosoft.psykopaint2.book.views.book.data
{
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.textures.BitmapCubeTexture;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.tools.utils.TextureUtils;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.EffectMethodBase;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.book.views.book.data.BlankBook;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;

 	public class PageMaterialsManager
 	{
 		private var _materials:Dictionary;
 		private var _textures:Dictionary;
 		private var _defaultPageMaterial:TextureMaterial;
 		private var _pageBitmapCubeTexture:BitmapCubeTexture;
 		private var _craftMaterial:TextureMaterial;
 		private var _ringsMaterial:TextureMaterial;
 		private var _blankBook:BlankBook;
 		private var _hasNuffPower:Boolean;
 		private var _maskBitmap:BitmapData;
 		private var _hasEnviro:Boolean;
 		private var _materialsCount:uint = 0;
 
     		public function PageMaterialsManager()
 		{
 			_materials = new Dictionary();
 			_textures = new Dictionary();
 			_hasNuffPower = PlatformUtil.hasRequiredPerformanceRating(2);
 		}

 		public function set blankBook(blankBook:BlankBook):void
 		{
 			_blankBook = blankBook;
 		}
 		

 		public function generateEnviroMapMethod(bitmapDatas:Vector.<BitmapData>):void
 		{
 			_pageBitmapCubeTexture = new BitmapCubeTexture(	bitmapDatas[0],
										bitmapDatas[1],
										bitmapDatas[2],
										bitmapDatas[3],
										bitmapDatas[4],
										bitmapDatas[5]);

			if(_hasNuffPower) _hasEnviro = true;
 
			var bt:BitmapTexture;
			if(_craftMaterial){
				bt = applyEnviroMethod(_craftMaterial);
 				if(bt) _textures["craft"] = bt;
			}

			if(_ringsMaterial){
				bt = applyEnviroMethod(_ringsMaterial);
 				if(bt) _textures["rings"] = bt;
			}

 		}
 
 		//craft
 		public function generateCraftMaterial(bitmapData:BitmapData):void
 		{
 			_craftMaterial = generateMaterialFromBitmapData(bitmapData);

 			if(_hasNuffPower && _hasEnviro){
 				var bt:BitmapTexture = applyEnviroMethod(_craftMaterial);
 				if(bt) _textures["craft"] = bt;
 			}
 		}

 		public function generateRingsMaterial(bitmapData:BitmapData):void
 		{
 			_ringsMaterial = generateMaterialFromBitmapData(bitmapData);

 			if(_hasNuffPower && _hasEnviro){
 				var bt:BitmapTexture = applyEnviroMethod(_ringsMaterial);
 				if(bt) _textures["rings"] = bt;
 			}
 		}
 
 		public function get craftMaterial():TextureMaterial
 		{
 			return _craftMaterial;
 		}

 		public function get ringsMaterial():TextureMaterial
 		{
 			return _ringsMaterial;
 		}

 		//pages
 		//returns the material for content per page side
 		public function getPageContentMaterial(index:uint):TextureMaterial
 		{
 			return getPageMaterial("mat"+index);
 		}
 		//returns the material of top and down marging (numbered) per page side
 		public function getPageMarginMaterial(index:uint):TextureMaterial
 		{
 			return getPageMaterial("margin"+index);
 		}

 		public function getEnviroMask(index:uint):BitmapTexture
 		{
 			return _textures["mask"+index];
 		}
 
 		private function getPageMaterial(id:String):TextureMaterial
 		{
 			var textureMaterial:TextureMaterial;

 			if(_materials[id]){
 				textureMaterial = _materials[id];
 			} else {
 				trace("The requested page ("+id+") has not been builded yet!!");
 				return null;
 			}
 			
 			return textureMaterial;
 		}
 		
 		public function resetPages(newStartIndex:uint):void
 		{
 			var material:TextureMaterial;
 			var marginMaterial:TextureMaterial;

 			var verso:Boolean = true;
 			for(var i:uint = 0;i<_materialsCount;i++){
 				material = getPageContentMaterial(i);
 				marginMaterial = getPageMarginMaterial(i);
 				verso = !verso;
 				resetPage(material, marginMaterial, newStartIndex, (verso)? 2 : 1);
 				newStartIndex++;
 			}
 		}

 		private function resetPage(material:TextureMaterial, marginMaterial:TextureMaterial, pageNumber:uint, isRecto:uint):void
 		{
 			if(!material) return;

 			var bmd:BitmapData;
 			var source:BitmapData;
 			var bt:BitmapTexture;
 			//update diffuse content as empty page
 			bt = BitmapTexture(material.texture);
 			bmd = bt.bitmapData;
 			bmd = _blankBook.getPageBitmapData("", pageNumber, bmd, isRecto);
 			bt.invalidateContent();
 			bt.bitmapData = bmd;

 			//update diffuse with propper number
 			bt = BitmapTexture(marginMaterial.texture);
 			bmd = _blankBook.getNumberedBasePageBitmapData(pageNumber, bt.bitmapData, isRecto);
 			bt.invalidateContent();
 			bt.bitmapData = bmd;

 			//reset normalmap:blankbook get map
 			if(material.normalMap){
 				bt = BitmapTexture(material.normalMap);
 				bmd = bt.bitmapData;
 				source = _blankBook.getBasePageNormalmap(false);
 				bmd.copyPixels(source, source.rect, source.rect.topLeft);
 				bt.invalidateContent();
 				bt.bitmapData = bmd;
 			}

			var spm:SinglePassMaterialBase = SinglePassMaterialBase(material);
			if(spm.numMethods>0){
				var method:EffectMethodBase = spm.getMethodAt(0);
				if(method is EnvMapMethod && _maskBitmap){
					bt = BitmapTexture(EnvMapMethod(method).mask);
					bmd = bt.bitmapData;
 					bmd.copyPixels(_maskBitmap, _maskBitmap.rect, _maskBitmap.rect.topLeft);
	 				bt.invalidateContent();
	 				bt.bitmapData = bmd;
				}
			}
 		}

 		public function registerMarginPageMaterial(index:uint, bitmapData:BitmapData):TextureMaterial
 		{
 			return registerMaterial("margin"+index, bitmapData);
 		}

 		public function registerContentPageMaterial(index:uint, bitmapData:BitmapData):TextureMaterial
 		{
 			_materialsCount++;
 			return registerMaterial("mat"+index, bitmapData, index);
 		}

 		public function dispose():void
 		{
 			var material:TextureMaterial;
 			var spm:SinglePassMaterialBase;
 			var methodsCount:uint;
 			var loop:uint;
 			var method:EffectMethodBase;
 			var mask:BitmapTexture;

 			for(var key:String in _materials){
 				material = _materials[key];
 				material.texture.dispose();
 				if(material.normalMap) material.normalMap.dispose();

				spm = SinglePassMaterialBase(material);
				methodsCount = spm.numMethods;
				if(methodsCount > 0){
					loop = methodsCount;
					while(loop!=0){
						try
						{
							method = spm.getMethodAt(loop);
							spm.removeMethod(method);
						} catch ( e:Error )
						{
							trace("Error in PageMaterialsManager.dispose() - better clean this up");
							
						}
						/*
						//clean up maps via dictionary clean up lower in code
						if(method is EnvMapMethod){
							mask = BitmapTexture(method);
							mask.bitmapData.dispose();
							mask.dispose();
							mask = null;
						} else {
							method.dispose();
						}
						*/
						method = null;
						loop--;
					}
				}
				material = null;
 				_materials[key] = null;
 			}
			 
 			if(_maskBitmap)_maskBitmap.dispose();
 			_pageBitmapCubeTexture.dispose();
 			_craftMaterial.dispose();
 			_craftMaterial = null;
 			_materials = null;

 			if(_textures){
 				var bmd:BitmapData;

 				for(key in _textures){//var key:String
 					bmd = BitmapTexture(_textures[key]).bitmapData;
 					bmd.dispose();
 					_textures[key].dispose();
 					_textures[key] = null;
	 			}
	 			_textures = null;
 			}

 			_materialsCount = 0;
 		}

 		public function adjustMaterialCount():void
 		{
 			var material:TextureMaterial;
 			_materialsCount = 0;
 			for(var key:String in _materials){
 				material = _materials[key];
 				if(material){
 					_materialsCount++;
				} else {
					_materials[key] = null;
				}
 			}
 		}

 		private function registerMaterial(id:String, bitmapData:BitmapData, ref:int = -1):TextureMaterial
 		{
 			var textureMaterial:TextureMaterial = generateMaterialFromBitmapData(bitmapData);

 			if(_hasNuffPower){
 				if(_hasEnviro && ref != -1 ){
 					var bt:BitmapTexture = applyEnviroMethod(textureMaterial);
 					_textures["mask"+ref] = bt;
 			 		textureMaterial.normalMap = generatePageNormalMap(id);
 			 	}
 			 }

 			_materials[id] = textureMaterial;
 
 			return textureMaterial;
 		}

 		private function generateMaterialFromBitmapData(bitmapData:BitmapData):TextureMaterial
 		{
 			bitmapData = validateMap(bitmapData);
 
			var bitmapTexture:BitmapTexture = new BitmapTexture(bitmapData);
			var textureMaterial:TextureMaterial = new TextureMaterial(bitmapTexture);
			//if(bitmapData.transparent) textureMaterial.alphaBlending = true;

			//to do once David has the equivallent for BitmapTexture
			//var bitmapTexture:TrackedTexture = new TrackedTexture(bitmapData);
			//var textureMaterial:TextureMaterial = new TextureMaterial(bitmapTexture);

			return textureMaterial;
		}

		private function generatePageNormalMap(id:String):BitmapTexture
		{
			var bitmapTexture:BitmapTexture = new BitmapTexture(_blankBook.getBasePageNormalmap(true));

			return bitmapTexture;
		}

		private function applyEnviroMethod(material:MaterialBase):BitmapTexture
 		{
 			if(_hasNuffPower) {
				if(!_maskBitmap) buildMaskEnviro();
				
				var enviroMethod:EnvMapMethod = new EnvMapMethod(_pageBitmapCubeTexture, .35);//0.16
				var bt:BitmapTexture = new BitmapTexture(_maskBitmap.clone());
				enviroMethod.mask = bt;
				SinglePassMaterialBase(material).addMethod(enviroMethod);

				return bt;
 			}

 			return null;
 		}

 		private function buildMaskEnviro():void
		{
			var maskColor:uint = 0x222222;
			_maskBitmap = new BitmapData(512,512, false, maskColor);
			var h:Number = 35;
			var rect:Rectangle = new Rectangle(0, 0, 512, h);
			_maskBitmap.fillRect(rect, 0);
			rect.y = 477;
			_maskBitmap.fillRect(rect, 0);
			var val:Number;
			var color:uint;
			rect.height = 1;
			var baseVal:uint = maskColor >> 16 & 0xFF;

			var j:uint;
			for(var i:uint = h; i<99; ++i){
				rect.y = i;
				val = baseVal * ( j/64);
				color = val << 16 | val << 8 | val;
				_maskBitmap.fillRect(rect, color );
				rect.y = 512 - i;
				_maskBitmap.fillRect(rect, color );
				j++;
			}
		}
 
		private function validateMap(origBmd:BitmapData):BitmapData
		{
			var nw:uint = origBmd.width;
			var nh:uint = origBmd.height;
			if(!TextureUtils.isPowerOfTwo(nw)) nw = TextureUtils.getBestPowerOf2(nw);
			
			if(!TextureUtils.isPowerOfTwo(nh)) nh = TextureUtils.getBestPowerOf2(nh);
			
			if(nw == origBmd.width && nh == origBmd.height)
				return origBmd;
			 
			var bmd:BitmapData = new BitmapData(nw, nh, origBmd.transparent, origBmd.transparent? 0x00FFFFFF : 0x000000);
			var w:Number = nw/origBmd.width;
			var h:Number = nh/origBmd.height;
			var t:Matrix = new Matrix();
			t.scale(w, h);
			bmd.draw(origBmd, t, null, "normal", null, true);
			
			origBmd.dispose();
			
			return bmd;
		}

 	}
 }