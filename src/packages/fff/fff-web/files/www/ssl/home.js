
function formatSize(bytes) {
	if(typeof bytes === "undefined" || bytes == "") {
		return "-";
	} else if (bytes < 1000) {
		return bytes + "  B";
	} else if (bytes < 1000*1000) {
		return (bytes/ 1000.0).toFixed(0)  + " KB";
	} else if (bytes < 1000*1000*1000) {
		return (bytes/1000.0/1000.0).toFixed(1)  + " MB";
	} else {
		return (bytes/1000.0/1000.0/1000.0).toFixed(2) + " GB";
	}
}

function init() {
	send("/cgi-bin/home", { }, function(data) {
		var obj = fromUCI(data).misc.data;
		for(var key in obj) {
			var value = obj[key];

			if(key == 'stype') {
				continue;
			}

			//for traffic
			if(/_bytes$/.test(key)) {
				value = formatSize(value);
			}

			//for addresses
			if(typeof(value) == 'object') {
				value = "<ul><li>"+value.join("</li><li>")+"</li></ul>"
			}

			setText(key, value);
		}
	});

	addHelpText($("system"), "Eine \xdcbersicht \xfcber den Router.");
	addHelpText($("freifunk"), "Das \xf6ffentliche Freifunknetz..");
	addHelpText($("wan"), "Das Netz \xfcber dass das Internet erreicht wird.");
	addHelpText($("software"), "Einige installierte Softwareversionen.");
	addHelpText($("freifunk_user_count"), "Die Anzahl der Nutzer an diesem Router in den letzten zwei Stunden.");
	addHelpText($("has_vpn"), "Status der VPN-Verbindung zum Server im Internet.");
}
