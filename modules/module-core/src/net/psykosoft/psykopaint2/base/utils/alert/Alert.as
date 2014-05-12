package net.psykosoft.psykopaint2.base.utils.alert
{

import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

import pl.mateuszmackowiak.nativeANE.dialogs.NativeAlertDialog;

public class Alert
{
	public function Alert() {
		super();
	}

	public static function show(message:String = "",title:String = "Error",buttons:Vector.<String> = null,closeHandler:Function = null,cancelable:Boolean = true,theme:int = -1):void {
		if(CoreSettings.RUNNING_ON_iPAD) {
			NativeAlertDialog.showAlert(message, title, buttons, closeHandler, cancelable, theme);
		}
		else {
			trace("ALERT: " + message);
		}
	}
}
}
