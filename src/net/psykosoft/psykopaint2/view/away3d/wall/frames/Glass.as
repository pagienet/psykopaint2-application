package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.CompositeDiffuseMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapCubeTexture;

	import flash.display.BlendMode;

	use namespace arcane;

	public class Glass extends ObjectContainer3D
	{
		private var _glassDiffuseMethod:CompositeDiffuseMethod;

		public function Glass( lightPicker:StaticLightPicker, reflectedTexture:BitmapCubeTexture, paintingWidth:Number, paintingHeight:Number ) {

			super();

			// Material.
			var glassMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF );
			glassMaterial.blendMode = BlendMode.ADD;
			glassMaterial.lightPicker = lightPicker; // TODO: see if everything else can be shared but this color material ( cause each glass instance will have its own light )

			// Env map.
			var envMapMethod:FresnelEnvMapMethod = new FresnelEnvMapMethod( reflectedTexture );
			envMapMethod.fresnelPower = 2;
			envMapMethod.normalReflectance = 0.01;
			glassMaterial.addMethod( envMapMethod );

			// Ambient.
			glassMaterial.ambient = 0;

			// Specular.
			glassMaterial.specular = 0;
			glassMaterial.gloss = 5;

			// Diffuse.
			_glassDiffuseMethod = new CompositeDiffuseMethod( modulateGlassDiffuseMethod );
			glassMaterial.diffuseMethod = _glassDiffuseMethod;

			// Mesh.
			var plane:Mesh = new Mesh( new PlaneGeometry( paintingWidth, paintingHeight ), glassMaterial );
			plane.rotationX = -90;
			addChild( plane );
		}

		private function modulateGlassDiffuseMethod( vo:MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache ):String {
				var viewDirFragmentReg:ShaderRegisterElement = _glassDiffuseMethod.viewDirFragmentReg;
				var normalFragmentReg:ShaderRegisterElement = _glassDiffuseMethod.normalFragmentReg;
				var temp:ShaderRegisterElement = regCache.getFreeFragmentSingleTemp();
				regCache.addFragmentTempUsages( temp, 1 );
				var code:String = "dp3 " + temp + ", " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" +
				"mul " + temp + ", " + temp + ", " + temp + "\n" +
				"sub " + temp + ", " + normalFragmentReg + ".z, " + temp + "\n" + // TODO: this is scene space dependent? need a 1.0 from somewhere
				// TODO: David says look for sharedMethodRegisters or something which has common registers
				// TODO: he also says look at CellDiffuseMethod for how to use custom uniforms
				"mul " + t + ".w, " + t + ".w, " + temp + "\n";
				regCache.removeFragmentTempUsage( temp );
				return code;
		}
	}
}
