package net.psykosoft.psykopaint2.app.commands
{

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class RenderFrameCommand
	{
		[Inject]
		public var moduleManager:ModuleManager;

		public function execute():void {

//			trace( this, "execute ------------------------" );
//			trace( this, "-> canvasRenderer: " + canvasRenderer );

			// TODO: Figure out why clearing is necessary
			DisplayContextManager.stage3dProxy.clear();
			moduleManager.render();
			DisplayContextManager.stage3dProxy.context3D.setRenderToBackBuffer();
			DisplayContextManager.stage3dProxy.context3D.clear( 1, 1, 1, 1 );
			DisplayContextManager.away3d.render();
			DisplayContextManager.starling.nextFrame();
			DisplayContextManager.stage3dProxy.present();

		}
	}
}
