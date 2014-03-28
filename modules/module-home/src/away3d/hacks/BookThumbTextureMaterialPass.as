package away3d.hacks
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.textures.Texture2DBase;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;

	use namespace arcane;

	public class BookThumbTextureMaterialPass extends MaterialPassBase
	{
		private var _texture : Texture2DBase;
		private var _matrix : Matrix3D;

		public function BookThumbTextureMaterialPass(texture : Texture2DBase)
		{
			_matrix = new Matrix3D();
			_texture = texture;
			_numUsedTextures = 1;
			_numUsedStreams = 2;
		}

		public function get texture() : Texture2DBase
		{
			return _texture;
		}

		public function set texture(value : Texture2DBase) : void
		{
			_texture = value;
		}

		override arcane function getVertexCode() : String
		{
			return 	"m44 op, va0, vc0\n" + // transform to view space
					"mov v0, va1\n";                 // pass on uvs
		}

		override arcane function getFragmentCode(fragmentAnimatorCode:String):String
		{
			return "tex oc, v0, fs0 <2d, clamp, linear, nomip>\n";
		}


		override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D):void
		{
			super.activate(stage3DProxy, camera);

			var context : Context3D = stage3DProxy._context3D;
			context.setTextureAt(0, _texture.getTextureForStage3D(stage3DProxy));
		}

		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, viewProjection : Matrix3D) : void
		{
			var context : Context3D = stage3DProxy._context3D;

			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);

			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);

			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
		}
	}
}
