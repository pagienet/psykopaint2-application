package net.psykosoft.psykopaint2.home.commands.load
{
	import away3d.hacks.StencilMethod;
	import away3d.materials.TextureMaterial;

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.display3D.Context3DCompareMode;

	import net.psykosoft.psykopaint2.home.views.book.HomeGeometryCache;
	import net.psykosoft.psykopaint2.home.views.book.HomeMaterialsCache;

	public class InitializeSharedHomeAssetsCommand extends AsyncCommand
	{
		override public function execute() : void
		{
			// make sure book is ready to go before it's shown
			// can be moved if memory is necessary later
			HomeGeometryCache.launch();
			HomeMaterialsCache.launch(onMaterialsLoaded);
		}

		private function onMaterialsLoaded() : void
		{
			// make sure frame material has the right stencil mode
			initFrameMaterial(HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.FRAME_WHITE));
			initFrameMaterial(HomeMaterialsCache.getTextureMaterialById(HomeMaterialsCache.FRAME_EMPTY));
			dispatchComplete(true);
		}

		private function initFrameMaterial(material:TextureMaterial):void
		{
			var stencilMethod:StencilMethod = new StencilMethod();
			stencilMethod.referenceValue = 40;
			stencilMethod.compareMode = Context3DCompareMode.NOT_EQUAL;
			material.addMethod(stencilMethod);
		}
	}
}
