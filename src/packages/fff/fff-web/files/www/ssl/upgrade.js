
function init() {
	/* Nothing to do */
}

function restore_firmware() {
	if(!confirm("Sollen alle Einstellungen zur\xFCckgesetzt werden?")) return;
	send("/cgi-bin/upgrade", { func : 'restore_firmware' }, function(text) {
		setText('msg', text);
	});
}

